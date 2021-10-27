function [Spikes] = getJRclustSpks_dual(dirs, electrodeIdx)

% Set directories
rawDir =  dirs.rawDir;
processedDir = dirs.processedDir;
fileName = dirs.experimentName;

% Load in JRclust output
jrcResFile = fullfile(processedDir,'JRclust','master_jrclust_res.mat');
res = load(jrcResFile);

% Set parameters
channels = 1:numel(res.spikesBySite);
fs = 24414.0625; % sampling frequency Hz
waveformWin = (1:61)-20; % in time samples
Spikes = struct();

% Session _Wav1_Ch*.sev files sorted by channelNo:
d = dir(fullfile(rawDir,fileName,['*_Wav' int2str(electrodeIdx) '_*.sev']));
[~,chNos]=sort(cellfun(@(x) str2double(x{1}),regexp( {d.name}, '_Ch(\d+)', 'tokens' )));
dataFiles = strcat({d(chNos).folder},filesep,{d(chNos).name})';

clusterSites = res.clusterSites;
nClusters = length(clusterSites);

% Extract spike times and waveforms for each detected cluster
parfor clusterIdx = 1:nClusters
    chan = clusterSites(clusterIdx);
    fprintf(['Extracting spikes and waveforms for cluster ' int2str(clusterIdx) '... \n'])
    memFile = memmapfile(dataFiles{chan},'Offset',40,'Format','single','writable',false);
    fx_rawWf = @(x) memFile.Data(waveformWin+x);

    
    spkIdx = res.spikesByCluster{clusterIdx}; spkIdx = spkIdx(spkIdx > 0);
    clustTimeSamples = double(res.spikeTimes(spkIdx))';
    
    DSP{clusterIdx} = round(clustTimeSamples*(1000.0/fs));
    % all waves not yet
    
    clustTimeSamplesWav = clustTimeSamples(clustTimeSamples > 60);
    clustTimeSamplesWav = clustTimeSamplesWav(clustTimeSamplesWav < (length(memFile.Data)-60));

    WAV{clusterIdx} = cell2mat(arrayfun(fx_rawWf,clustTimeSamplesWav,'UniformOutput',false))';
end

for clusterIdx = 1:nClusters
    chan = clusterSites(clusterIdx);
    unitString = num2str(chan,'DSP%02i');
    wavString = num2str(chan,'WAV%02i');
    
    nClusters_depth = find(clusterSites == clusterSites(clusterIdx));
    clustNo = find(clusterIdx == nClusters_depth);
    clustLetter = char(clustNo+96); % 97 is the char code for 'a"
    
    Spikes.([unitString clustLetter]) = DSP{clusterIdx};
    Spikes.([wavString clustLetter]) = WAV{clusterIdx};
    
    cluster_DSPnames{clusterIdx,1} = [unitString clustLetter];
    cluster_WAVnames{clusterIdx,1} = [wavString clustLetter];
    
end

DSP_id = cluster_DSPnames;
WAV_id = cluster_WAVnames;
channel = clusterSites';
nSpikes = res.unitCount;
isoDistance = res.unitIsoDist';
ISIratio = res.unitISIRatio';
Lratio = res.unitLRatio';
SNR = res.unitSNR;
Vpp_raw = res.unitVppRaw;
Vpp = res.unitVpp;

Spikes.jrSpkInfo = table(DSP_id,WAV_id,channel,nSpikes,isoDistance,ISIratio,Lratio,SNR,Vpp_raw,Vpp);




    
end
