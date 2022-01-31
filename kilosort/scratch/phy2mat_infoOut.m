function [spkTable] = phy2mat_infoOut(ops)
%% Import spike information from Phy
sp = loadKSdir(ops.rootZ);
[~, ~, ~, spikeSites] = ksDriftmap(ops.rootZ);

clusterInfo_phy = tdfread([ops.rootZ '\cluster_info.tsv']);

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
end

% Get labels for the output (e.g. DSP01a, WAV01a = first unit on ch 1)
for unitIdx = 1:nUnits
    unit_site = find(unitIdx == find(site == site(unitIdx,1)));
    dspString = num2str(site(unitIdx,1),'DSP%02i');
    wavString = num2str(site(unitIdx,1),'WAV%02i');
    clustLetter = char(unit_site+96); % 97 is the char code for 'a"
    unitDSP{unitIdx,1} = [dspString clustLetter];
    unitWAV{unitIdx,1} = [wavString clustLetter];
    
    contamPct(unitIdx,1) = clusterInfo_phy.ContamPct(clusterInfo_phy.cluster_id ==  cluster(unitIdx,1),:);
    amplitude(unitIdx,1) = clusterInfo_phy.Amplitude(clusterInfo_phy.cluster_id ==  cluster(unitIdx,1),:);
    ksClass{unitIdx,1} = {clusterInfo_phy.KSLabel(clusterInfo_phy.cluster_id ==  cluster(unitIdx,1),:)};
end

spkTable = table(cluster,site,unitDSP,unitWAV,contamPct,amplitude,ksClass);
spkTable = sortrows(spkTable,'site');

