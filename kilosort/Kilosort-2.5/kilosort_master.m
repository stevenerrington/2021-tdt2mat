function [rez] = kilosort_master(ops)



fprintf('Found %d "good" units \n', sum(rez.good>0))

fprintf('Saving results to Phy for post-processing  \n');
% 
% % discard features in final rez file (too slow to save)
% rez.cProj = [];
% rez.cProjPC = [];

% final time sorting of spikes, for apps that use st3 directly
[~, isort]   = sortrows(rez.st3);
rez.st3      = rez.st3(isort, :);

% Ensure all GPU arrays are transferred to CPU side before saving to .mat
rez_fields = fieldnames(rez);
for i = 1:numel(rez_fields)
    field_name = rez_fields{i};
    if(isa(rez.(field_name), 'gpuArray'))
        rez.(field_name) = gather(rez.(field_name));
    end
end

% fprintf('Saving final results in rez2  \n')
% fname = fullfile(rootZ, 'rez2.mat');
% save(fname, 'rez', '-v7.3');

end
