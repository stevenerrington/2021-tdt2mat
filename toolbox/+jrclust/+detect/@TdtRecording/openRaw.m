function openRaw(obj)
    %OPENRAW Open the raw recording file for reading
        
    if obj.rawIsOpen
        return;
    end
    
    channels = (1:numel(obj.dataFiles))';
    try
        obj.memmapDataFiles = arrayfun(@(ch) memmapfile(obj.dataFiles{ch},...
            'Offset',obj.headerOffset,'Format',obj.dataForm),channels,'UniformOutput',false);
        obj.rawIsOpen = 1;
    catch EX
        fprintf('Exception in openDataset...\n');
        disp(EX)
        keyboard
    end
end