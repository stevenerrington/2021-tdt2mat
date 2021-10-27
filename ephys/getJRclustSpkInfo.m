function [jrSpkInfo] = getJRclustSpkInfo(jrcResFile)

% Load in JRclust output
res = load(jrcResFile);
clusterSites = res.clusterSites;
nClusters = length(clusterSites);

for clusterIdx = 1:nClusters
    chan = clusterSites(clusterIdx);
    unitString = num2str(chan,'DSP%02i');
    wavString = num2str(chan,'WAV%02i');
    
    nClusters_depth = find(clusterSites == clusterSites(clusterIdx));
    clustNo = find(clusterIdx == nClusters_depth);
    clustLetter = char(clustNo+96); % 97 is the char code for 'a"
    
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

jrSpkInfo = table(DSP_id,WAV_id,channel,nSpikes,isoDistance,ISIratio,Lratio,SNR,Vpp_raw,Vpp);


end
