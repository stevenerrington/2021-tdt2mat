function klPullMUA(sessName)

%
baseDir = [tebaMount,'/data/Darwin/proNoElongationColor_physio/'];
procDir = [tebaMount,'/Users/Kaleb/proNoElongationColor_physio/'];
nRMS = 5;

% Get number of channels
d=dir([baseDir,sessName,'/*Wav1*.sev']);
nChans = length(d);

printStr = [];
for ic = 1:nChans
    fprintf(repmat('\b',1,length(printStr)));
    printStr = sprintf('Working on channel %d (of %d)...',ic,nChans);
    fprintf(printStr);
    chanDat=TDTbin2mat('/mnt/teba/data/Darwin/proNoElongationColor_physio/Darwin-190926-085937','TYPE',{'streams'},'STORE',{'Wav1'},'CHANNEL',ic);
    tVect = ((1:length(chanDat.streams.Wav1.data))-1).*(1000/chanDat.streams.Wav1.fs);
    vrms = rms(chanDat.streams.Wav1.data);
    thresh = -vrms*nRMS;
    vShft = [chanDat.streams.Wav1.data(2:end),nan];
    spkInds = find(chanDat.streams.Wav1.data > thresh & vShft <= thresh);
    if isempty(spkInds)
        continue
    end
    spkTimes = tVect(spkInds)';
    waveInds = bsxfun(@plus,spkInds',-30:30);
    oobWaves = any(waveInds < 1,2) | any(waveInds > length(chanDat.streams.Wav1.data),2);
    waves = chanDat.streams.Wav1.data(waveInds(~oobWaves,:));
    
    chanStr = num2str(ic);
    if length(chanStr) < 2
        chanStr = ['0',chanStr];
    end
    mkdir([procDir,sessName,'/MUA',chanStr]);
    save([procDir,sessName,'/MUA',chanStr,'/mua',chanStr,'.mat'],'spkTimes','waves');
end
fprintf('Done!\n');