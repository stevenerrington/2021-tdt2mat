function [spikes] = phy2mat(ops)
%% Import spike information from Phy
sp = loadKSdir(ops.rootZ);
[spikeTimes, spikeAmps, ~, spikeSites] = ksDriftmap(ops.rootZ);

%% Waveform extraction
%  Get Parameters
gwfparams.dataDir = ops.rootZ;           % KiloSort/Phy output folder
gwfparams.fileName = '\temp_wh.dat';     % .dat file containing the raw 
gwfparams.dataType = 'int16';            % Data type of .dat file (this should be BP filtered)
gwfparams.nCh = 32;                      % Number of channels that were streamed to disk in .dat file
gwfparams.wfWin = [-40 41];              % Number of samples before and after spiketime to include in waveform
gwfparams.nWf = 2000;                    % Number of waveforms per unit to pull out
gwfparams.spikeTimes =    spikeTimes;    % Vector of cluster spike times (in samples) same length as .spikeClusters
gwfparams.spikeClusters = sp.clu;        % Vector of cluster IDs (Phy nomenclature)   same length as .spikeTimes

%  Run main extraction
wf = getWaveForms(gwfparams);


%% Setup variable space for spike and waveform data
unitList = unique(sp.clu);
nUnits = length(unitList);
% Find site for each ID'd cluster
for unitIdx = 1:nUnits
    unit = unitList(unitIdx);
    cluster(unitIdx,1) = unit;
    site(unitIdx,1) = spikeSites(find(sp.clu == unit,1));
end

% Get labels for the output (e.g. DSP01a, WAV01a = first unit on ch 1)
for unitIdx = 1:nUnits
      unit_site = find(unitIdx == find(site == site(unitIdx,1)));
      dspString = num2str(site(unitIdx,1),'DSP%02i');
      wavString = num2str(site(unitIdx,1),'WAV%02i');
      clustLetter = char(unit_site+96); % 97 is the char code for 'a"
      unitDSP{unitIdx,1} = [dspString clustLetter];
      unitWAV{unitIdx,1} = [wavString clustLetter];
end

spkTable = table(cluster,site,unitDSP,unitWAV);
spkTable = sortrows(spkTable,'site');
%% Get spike information for each unit
% NOTE: Sampling rate adjustment for spike time is made here. After this,
% spikes are in ms, and not in samples.

for unitIdx = 1:nUnits
    unit = spkTable.cluster(unitIdx);
    spikes.time.(spkTable.unitDSP{unitIdx}) = round(spikeTimes(sp.clu == unit)*(24414.14/1000));
    spikes.amplitudes.(spkTable.unitDSP{unitIdx}) = spikeAmps(sp.clu == unit);
end

% Note - DSPs aren't in order: I'm conscious of not making a mismatch, so
% haven't tried to sort yet.

%% Get spike waveform for each unit
% NOTE: Due to array size issues, we have subsampled 2000 spikes.
% NOTE: Sampling rate adjustment for spike time is made here. After this,
% spikes are in ms, and not in samples.

for unitIdx = 1:nUnits
    unit = spkTable.cluster(unitIdx);
    spikes.waveform.(spkTable.unitWAV{unitIdx}) = squeeze(wf.waveForms(unitIdx,:,spikeSites(find(sp.clu == unit,1)),:));
    spikes.waveform_spkTime.(spkTable.unitWAV{unitIdx}) = wf.spikeTimeKeeps(unitIdx,:)*(24414.14/1000);
end





