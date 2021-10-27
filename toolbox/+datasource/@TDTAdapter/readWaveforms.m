function [ waveforms ] = readWaveforms(obj, wfSampleWin, wfTime)
% Read waveform data
%  wfSampleWin : number of data points for waveform relative to wfTime
%                example: [-20 40] = 61 datapoints per waveform
%  wfTime : spike time sample number (spike_times.npy)

channels = (1:numel(obj.dataFiles))';
if ~obj.isOpen
    obj.openDataset(channels);
end
wfWin = wfSampleWin(1):wfSampleWin(2);
wfTime = double(wfTime);

 memFiles = obj.memmapDataFiles;
 temp = cell(numel(wfTime),1);

 for jj=1:numel(wfTime)
     temp{jj,1} = arrayfun(@(ch) memFiles{ch}.Data(wfWin+wfTime(jj)),channels,'UniformOutput',false);
 end

 temp=cell2mat([temp{:}]);
 temp = reshape(temp(:),numel(wfWin),numel(channels),numel(wfTime));
 
 waveforms = permute(temp,[3 2 1]);

end
