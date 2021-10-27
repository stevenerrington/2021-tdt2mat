function klProcessSingleChannels(subj,date,varargin)

pauseForSort = 1;

% Set directories
rootDir = [tebaMount,'/data/Leonardo/VisualSearch-NeuralRecording/'];
outDir = [tebaMount,'/Users/Kaleb/SingleChannelRecordings/'];
vMax = 3e-1;%4;


% Get recordings from this date
recs = dir([rootDir,'/',subj,'*',date,'*']);

% Start loop for recordings
for ir = 1:length(recs)
    [Task, Eyes, PD, EEG, tdt] = klGetTask(recs(ir).name,'-r',rootDir,'-proc',outDir);
    if ~exist([outDir,recs(ir).name],'file')
        mkdir([outDir,recs(ir).name]);
    end
    fprintf('Reading Channel 1 for recording %d...',ir);
    y=TDTbin2mat(fullfile(rootDir,recs(ir).name),'TYPE',{'streams'},'STORE','Wav1','CHANNEL',1);
    f=fopen([outDir,recs(ir).name,'/Chan1.bin'],'w+');
    fprintf('Writing Channel 1 for recording %d...',ir);
    dat = y.streams.Wav1.data;
    dat(dat > vMax) = vMax;
    dat(dat < -vMax) = -vMax;
    fwrite(f,dat.*(2^16),'int16');%.*1000,'int16');
    fprintf('Done!\n');
    fclose(f);

end


if pauseForSort
    keyboard
end

for ir = 1:length(recs)
    T=DataAdapter.newDataAdapter('tdt',fullfile(rootDir,recs(ir).name));
    sortTxt = dir(fullfile(outDir,recs(ir).name,'*Chan*.txt'));
    if isempty(sortTxt)
        continue
    end
    sortDat = load(fullfile(sortTxt.folder,sortTxt.name));
    uUnits = nunique(sortDat(:,2));
    thisChan = 1;
    for iu = 1:length(uUnits)
        theseTimes = sortDat(sortDat(:,2)==uUnits(iu),3).*1000;
        clusterWaves = T.getWaveforms(-50:50,theseTimes,thisChan,0);
        unitStr = sprintf('chan%d%s',thisChan+0,num2abc(iu));

        spkTimes = theseTimes;
        waves = clusterWaves;
        spikeQuality = 'manual';
        save([outDir,filesep,recs(ir).name,filesep,unitStr,'.mat'],'spkTimes','waves','spikeQuality');

    end
end