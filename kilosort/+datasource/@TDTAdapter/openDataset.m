function [chanMinMaxV] = openDataset(obj,varargin)
%OPENDATASET create memmapfile object array for accessing data
    channels = (1:numel(obj.dataFiles))';
    if ~isempty(varargin)
        channels = varargin{1};
    end
    obj.memmapDataFiles = arrayfun(@(ch) memmapfile(obj.dataFiles{ch},...
        'Offset',obj.headerOffset,'Format',obj.dataForm),channels,'UniformOutput',false);
    memFiles = obj.memmapDataFiles;
    p = gcp('nocreate');
    tic
    try
        if isempty(p)
            for ii = 1:numel(channels)
                ch = channels(ii);
                %minV{ii,1} = min(memFiles{ch}.Data); 
                %maxV{ii,1} = max(memFiles{ch}.Data); 
               
            end
        else
            parfor ii = 1:numel(channels)
                ch = channels(ii);
                %minV{ii,1} = min(memFiles{ch}.Data); 
                %maxV{ii,1} = max(memFiles{ch}.Data); 
            end
        end        
        
        %obj.chanMinMaxV = [cell2mat(minV) cell2mat(maxV)];
        obj.chanMinMaxV = [NaN NaN];
        
        
%         
%         for ii = channels
%             obj.memmapDataFiles{ii,1} = memmapfile(obj.dataFiles{ii},...
%                 'Offset',obj.headerOffset,'Format',obj.dataForm);
%             obj.chanMinMaxV(ii,2) = max(obj.memmapDataFiles{ii,1}.Data);
%             obj.chanMinMaxV(ii,1) = min(obj.memmapDataFiles{ii,1}.Data);
%         end
        chanMinMaxV = obj.chanMinMaxV;
        obj.isOpen = 1;
    catch EX
        fprintf('Exception in openDataset...\n');
        disp(EX)
        keyboard
    end
    toc
end
