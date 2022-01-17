function [data] = readRaw(obj, nChannels, nSamples)
%READRAW Summary of this function goes here
data = zeros(nChannels, nSamples);
channels = (1:nChannels) + obj.channelOffset;
if ~obj.isOpen
    obj.openDataset(channels);
end
p = gcp('nocreate');
try
    if obj.lastSampleRead == obj.nSamplesPerChannel
        data = [];
        return;
    end
    sampleStart = obj.lastSampleRead + 1;
    sampleEnd = obj.lastSampleRead + nSamples;
    sampleEnd = min(sampleEnd, obj.nSamplesPerChannel);
    memFiles = obj.memmapDataFiles;
    if isempty(p)
        temp = arrayfun(@(ch) memFiles{ch}.Data(sampleStart:sampleEnd),channels,'UniformOutput',false);
    else
        parfor ii = 1:nChannels
            ch = channels(ii);
            temp{ii} = memFiles{ch}.Data(sampleStart:sampleEnd); %#ok<PFBNS>
        end
    end
    data = cell2mat(temp)';
    obj.lastSampleRead = sampleEnd;
catch EX
    fprintf('Exception in readRaw...\n');
    fprintf('Trying to read from: [%d], to [%d]\n',...
        sampleStart,sampleEnd);
    keyboard
    obj.dataSize
    disp(EX)
    
end
% just return the data
%data = data.*obj.rawDataScaleFactor;
end

