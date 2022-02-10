function [spkTable] = phyinfo2mat(ops)
%% Import spike information from Phy
sp = loadKSdir(ops.rootZ);
[~, ~, ~, spikeSites] = ksDriftmap(ops.rootZ);

amp_info = tdfread([ops.rootZ '\cluster_amplitude.tsv']);
contam_info = tdfread([ops.rootZ '\cluster_contamPct.tsv']);
ksclass_info = tdfread([ops.rootZ '\cluster_KSLabel.tsv']);

%% Setup variable space for spike and waveform data
% Note: I've checked and it seems as though noise clusters are dropped from
% the import, and we don't need to include/exclude them manually.

unitList = double(unique(sp.clu));
nUnits = length(unitList);
% Find site for each ID'd cluster
for unitIdx = 1:nUnits
    unit = unitList(unitIdx);
    cluster(unitIdx,1) = unit;
    site(unitIdx,1) = double(mode(spikeSites(sp.clu == unit)));
    class{unitIdx,1} = ksclass_info.KSLabel(ksclass_info.cluster_id == unit,:);
    amplitude(unitIdx,1) = amp_info.Amplitude(amp_info.cluster_id == unit,:);
    contam(unitIdx,1) = contam_info.ContamPct(contam_info.cluster_id == unit,:);
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

sessionName = repmat({ops.sessionName},nUnits,1);
spkTable = table(sessionName,cluster,site,unitDSP,unitWAV,class,amplitude,contam);
spkTable = sortrows(spkTable,'site');

