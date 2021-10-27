function [chanMinMaxV] = openDataset(obj,varargin)
%OPENDATASET create memmapfile object array for accessing data
    channels = (1:numel(obj.dataFiles))';
    if ~isempty(varargin)
        channels = varargin{1};
    end
    try
    obj.memmapDataFiles = arrayfun(@(ch) memmapfile(obj.dataFiles{ch},...
        'Offset',obj.headerOffset,'Format',obj.dataForm),channels,'UniformOutput',false);
        obj.chanMinMaxV = [NaN NaN];
        chanMinMaxV = obj.chanMinMaxV;
        obj.isOpen = 1;
    catch EX
        fprintf('Exception in openDataset...\n');
        disp(EX)
        keyboard
    end

end
