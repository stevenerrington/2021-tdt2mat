function [roi] = readRawROI(obj, rows, cols)
%READRAW Summary of this function goes here

    if ~obj.rawIsOpen
        obj.openRaw();
    end
    p = gcp('nocreate');
    try
        memFiles = obj.memmapDataFiles;
        if isempty(p)
            temp = arrayfun(@(ch) memFiles{ch}.Data(cols),rows,'UniformOutput',false);
        else
            parfor ii = 1:numel(rows)
                ch = rows(ii);
                temp{ii} = memFiles{ch}.Data(cols); %#ok<PFBNS>
            end
        end
        roi = cell2mat(temp)';
        % Convert to microvolts (assume scaling 'milli' is used)
        roi = roi.*10^3; 
    catch EX
        fprintf('Exception in readRaw...\n');
        obj.dataSize
        disp(EX);
    end
end

