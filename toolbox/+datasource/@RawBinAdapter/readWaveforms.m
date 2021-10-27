function [ waveforms ] = readWaveforms(obj, wfSampleWin, wfTime)
% Read waveform data
%  wfSampleWin : number of data points for waveform relative to wfTime
%                example: [-20 40] = 61 datapoints per waveform
%  wfTime : spike time sample number (spike_times.npy)

channels = 1:obj.dataSize(1);
if ~obj.isOpen
    obj.memmapDataFiles{1} = memmapfile(obj.dataFiles{1},...
        'Offset',obj.headerOffset,'Format',obj.dataForm);
    obj.isOpen = 1;
end
wfWin = wfSampleWin(1):wfSampleWin(2);
wfTime = double(wfTime);

 memFile = obj.memmapDataFiles{1};
 temp = cell(numel(wfTime),1);

 for jj=1:numel(wfTime)
     temp{jj,1} = memFile.Data(channels,wfWin+wfTime(jj));
 end

 temp=cell2mat([temp{:}]);
 temp = reshape(temp(:),numel(wfWin),numel(channels),numel(wfTime));
 
 waveforms = permute(temp,[3 2 1]);

end
