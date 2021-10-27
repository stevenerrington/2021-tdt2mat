sessionBaseDir = 'data/Joule/cmanding/ephys/TESTDATA/In-Situ';
baseSaveDir = 'dataProcessed/Joule/cmanding/ephys/TESTDATA/In-Situ';
sessName = 'Joule-190820-124819';
spikesMatFile = fullfile(baseSaveDir,sessName,'Spikes.mat');
lowerAlpha = 96;% 97='a' 98 ='b' etc
waveformWin = (1:61)-20; % in time samples
% Session _Wav1_Ch*.sev files sorted by channelNo:
d = dir(fullfile(sessionBaseDir,sessName,'*_Wav1_*.sev'));
[~,chNos]=sort(cellfun(@(x) str2double(x{1}),regexp( {d.name}, '_Ch(\d+)', 'tokens' )));
dataFiles = strcat({d(chNos).folder},filesep,{d(chNos).name})';
% jrclust output
jrcResFile = fullfile(baseSaveDir,sessName,'jrclustTh5','master_tdt_jrclust_res.mat');
res = load(jrcResFile);
allSpikes = struct();
channels = unique(res.spikeSites);
fs = 24414.0625; % sampling frequency Hz
for ch = 1:numel(channels)   
    chan = channels(ch);
    memFile = memmapfile(dataFiles{chan},'Offset',40,'Format','single','writable',false);
    fx_rawWf = @(x) memFile.Data(waveformWin+x);
    unitString = num2str(chan,'DSP%02i');
    wavString = num2str(chan,'WAV%02i');
    spkIdsByCh = res.spikesBySite{ch};
    spkClustNos = res.spikeClusters(spkIdsByCh);
    spkTimeSamples = res.spikeTimes(spkIdsByCh);
    uniqClustNos = unique(spkClustNos);
    uniqClustNos(uniqClustNos<0)=[];
    for cl = 1:numel(uniqClustNos)
        clustNo = uniqClustNos(cl);
        clustLetter = char(cl+lowerAlpha);
        clustTimeSamples = double(spkTimeSamples(spkClustNos==clustNo));
        allSpikes.([unitString clustLetter]) = clustTimeSamples*(1000.0/fs);
        % all waves not yet
        allSpikes.([wavString clustLetter]) = cell2mat(arrayfun(fx_rawWf,clustTimeSamples','UniformOutput',false))';
    end
end
% save Spike times and waveforms
save(spikesMatFile,'-struct', 'allSpikes')


