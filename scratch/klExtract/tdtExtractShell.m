function success = tdtExtractShell(fileName)

success = 0;
reSort = 1;
dataDir= [mlRoot,'DATA/dataProcessed'];
% putDir = [tebaMount,'Users/Kaleb/proAntiProcessed/',fileName];
putDir = [tebaMount,'Users/Kaleb/proNoElongationColor_physio/',fileName];
% putDir = '~/git/tebaOut/';
nProbes = 1;
pauseForPhy = 1;
% try
    if reSort || ~exist([dataDir,filesep,fileName,'_probe1/params.py'])
        for i = 1:nProbes
            masterTdt_asFun(fileName,i);
        end
    end
    
    sortFolds=dir([dataDir,filesep,fileName,'*']);
    for iz = 1:nProbes
        clearvars -except iz z sortFolds reSort success dataDir fileName putDir pauseForPhy
        if pauseForPhy
%             evalStr = sprintf('!cd %s; source activate phy; phy template-gui params.py',fullfile(sortFolds(iz).folder,sortFolds(iz).name));
%             eval(sprintf('!cd %s',fullfile(sortFolds(iz).folder,sortFolds(iz).name)));
            keyboard
        end
        if (isempty(dir([sortFolds(iz).folder,filesep,sortFolds(iz).name,'/chan*.mat'])) && isempty(dir([putDir,filesep,'/Chan*']))) || reSort
            rez = load(sprintf('/home/loweka/DATA/dataProcessed/%s/rez.mat',sortFolds(iz).name));
            klRezToSpks(rez,'-r',[dataDir,'/']);%'Users/Kaleb/proAntiRaw']);
        end
    end
    
    if ~exist(putDir,'file')
        mkdir(putDir);
    end
    chan1s = dir(['/home/loweka/DATA/dataProcessed/',fileName,'_probe1/chan*.mat']);
    for i = 1:length(chan1s)
        unitFold = [putDir,filesep,'C',chan1s(i).name(2:(end-4))];
        if ~exist(unitFold), mkdir(unitFold); end
        movefile([chan1s(i).folder,filesep,chan1s(i).name],[unitFold,filesep,chan1s(i).name]);
    end
    chan1s = dir(['/home/loweka/DATA/dataProcessed/',fileName,'_probe2/chan*.mat']);
    for i = 1:length(chan1s)
        unitFold = [putDir,filesep,'C',chan1s(i).name(2:(end-4))];
        if ~exist(unitFold), mkdir(unitFold); end
        movefile([chan1s(i).folder,filesep,chan1s(i).name],[unitFold,filesep,chan1s(i).name]);
    end
    
    if ~exist([putDir,filesep,'Behav.mat']) || reSort
        dashes = strfind(fileName,'-');
        Task = klGetSession(fileName(1:(dashes(1)-1)),fileName((dashes(1)+1):(dashes(2)-1)),'-s',1,'-r',[tebaMount,'/data/Darwin/proNoElongationColor_physio'],'-p',[tebaMount,'/Users/Kaleb/proNoElongationColor_physio']);%klGetTask(fileName,'-p',1,'-f',1);
    else
        load([putDir,filesep,'Behav.mat']);
    end
%     if any(strcmpi(Task.TaskType,'Pro-Anti'))
%         klProAntiPhysio(fileName);
%     end
%     if any(strcmpi(Task.TaskType,'MG'))
%         klMGPhysio(fileName);
%     end    
    
    success = 1;
% end