function [data] = readRaw(obj, nChannels, nSamples)
%READRAW Summary of this function goes here
    data = zeros(nChannels, nSamples);
    if ~obj.isOpen
        obj.memmapDataFiles{1} = memmapfile(obj.dataFiles{1},...
            'Offset',obj.headerOffset,'Format',obj.dataForm);
        obj.isOpen = 1;
    end
    %p = gcp('nocreate'); can we use a parallel lookup in a matrix?
    try
        if obj.lastSampleRead == obj.nSamplesPerChannel
            data = [];
            return;
        end
        % Read data from *all* channels
        sampleStart = obj.lastSampleRead + 1;
        sampleEnd = obj.lastSampleRead + (obj.nChannelsTotal*nSamples);
        sampleEnd = min(sampleEnd, obj.nSamplesPerChannel*obj.nChannelsTotal);
        memFiles = obj.memmapDataFiles;
        % for last samples, data may be less than nSamples for per channel
        data = reshape(memFiles{1}.Data(sampleStart:sampleEnd),obj.nChannelsTotal,[]);
    catch EX
        fprintf('Exception in readRaw...\n');
        fprintf('Trying to read from: [%d], to [%d]\n',...
            sampleStart,sampleEnd);
        obj.dataSize
        disp(EX)
    end
    data = data.*obj.rawDataScaleFactor;
    obj.lastSampleRead = sampleEnd;
    % For a binary file with a vector of data,
    % if we read less than max channels, offset pointer to channel#1 for next read
    if (nChannels < obj.nChannelsTotal)
        data = data(1:nChannels,:);
    end
end

