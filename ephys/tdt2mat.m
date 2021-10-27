%% Setup Extraction
clear; clc; 
ops.getLFP = 1; ops.getSpk = 1; ops.getEEG = 0;
ops.doSecondary = 1; ops.saveOutput = 1; ops.makeSingleMAT = 1;

%% Input session information
sessionInfo.monkey = 'darwin';
sessionInfo.date = '20210405';
sessionInfo.area = 'DMFC'; % fef, sef, acc, beh
sessionInfo.task = 'cmand1DR'; % memguide, cmand, visflash
sessionInfo.tdtFile = 'Cmand1DR_ECoG-210504-091030';

outFilename = [sessionInfo.monkey(1:3) '-' ...
                sessionInfo.task '-' ...
                sessionInfo.area '-' ...
                sessionInfo.date];

%% Get online ephys data log
ephysLog = importOnlineEphysLog;
logIdx = find(not(cellfun('isempty',strfind(ephysLog.TDTfilename,sessionInfo.tdtFile))));

%% Set directories
dirs.rawDir = 'C:\Users\Steven\Desktop\Data\Raw';
dirs.processedDir = ['C:\Users\Steven\Desktop\TDT convert\cmandOutput\' outFilename];
dirs.experimentName = sessionInfo.tdtFile;
dirs.figureFolder = [dirs.processedDir,'\figures'];

if ~exist(dirs.figureFolder);  mkdir(dirs.figureFolder); end
if ~exist(dirs.processedDir); mkdir(dirs.processedDir); end

%% Run TDT translation
% Extract data from TDT format into Matlab
warning off
tdtOptions = getTDTopts(getTDTdir(dirs.rawDir,dirs.processedDir),dirs.experimentName);
[Infos, stateFlags, TrialEyes, ~, ~, tdtInfo] = TDTTranslator(tdtOptions).translate(0);

% Clean out error transfer trials
[stateFlags,Infos] = cleanTranslateError(stateFlags,Infos);

% Extract behavior
[ttx, ttx_history, trialEventTimes] = processSessionTrials (stateFlags, Infos);
[stopSignalBeh, RTdist] = extractStopBeh(stateFlags,Infos,ttx);
[valueBeh] = extractValueBeh(Infos,ttx);
[valueStopSignalBeh, valueRTdist] = extractValueStopBeh(stateFlags,Infos,ttx);
[ttm] = processTrialMatching(stopSignalBeh, ttx, trialEventTimes);

% Get Eyes Data
%%%%%%%%%% to be complete: saccade dynamics, alignedEyeTrace
tdtEyes = alignEyes(trialEventTimes,TrialEyes, [-1000 2000]); % <- This needs checking!

% Get Ephys data
[tdtLFP, tdtSpk, ~] = getTDTephys(dirs, ops);


%% Secondary extractions
% Align Ephys
if ops.doSecondary
    timeWin = [-1000 2000];
    tdtLFP_aligned = alignLFP(trialEventTimes,tdtLFP, timeWin);
    tdtSpk_aligned = alignSDF(trialEventTimes, Infos, tdtSpk, timeWin);
    
    % Get CSD
    CSDanalysis = getSessionCSD(tdtLFP_aligned, [900:1250]);
end

%% Print output
produceBehFigures % Produce behavioral figures

if ops.doSecondary
    produceCSDFigures(dirs, outFilename, tdtInfo, sessionInfo, ephysLog, logIdx, ttx, CSDanalysis)
    produceSpkFigures(dirs, outFilename, tdtInfo, sessionInfo, ephysLog, logIdx,...
        tdtSpk, tdtSpk_aligned, Infos, ttx, stopSignalBeh)
end

%% Save output
% save Spike times and waveforms
if ops.saveOutput
    extractOutFolder = [dirs.processedDir,'\mat'];
    
    if ~exist(extractOutFolder)
        mkdir(extractOutFolder);
    end
    
    spkfileName = fullfile(extractOutFolder,'Spikes.mat');
    lfpfileName = fullfile(extractOutFolder,'LFP.mat');
    behfileName = fullfile(extractOutFolder,'Behavior.mat');
    eyesfileName = fullfile(extractOutFolder,'Eyes.mat');
    
    fprintf('Saving spike data... \n');save('-v7.3', spkfileName, 'tdtSpk');
    fprintf('Saving LFP data... \n');save('-v7.3', lfpfileName, 'tdtLFP'); 
    fprintf('Saving behavioral data... \n'); save(behfileName, 'RTdist', 'sessionInfo',...
        'stateFlags', 'stopSignalBeh','tdtInfo', 'trialEventTimes',...
        'ttm', 'ttx', 'ttx_history', 'valueBeh', 'valueRTdist',...
        'valueStopSignalBeh');   
    fprintf('Saving eye data... \n'); save(eyesfileName, 'tdtEyes', 'TrialEyes'); 
     
end

if ops.makeSingleMAT
    fprintf('Saving single session datafile... \n');

    extractOutFolder = 'C:\Users\Steven\Desktop\TDT convert\cmandMat';
    sessionFileName = fullfile(extractOutFolder,[outFilename '.mat']);
    
    Spikes = tdtSpk; LFP = tdtLFP; Eyes = TrialEyes.tdt;
    SessionInfo = struct('general',sessionInfo,'tdt_',tdtInfo');
    Behavior = struct('stateFlags_',stateFlags,'Infos_',Infos);
    Trials = struct('ttx',ttx,'ttm',ttm,'ttx_history',ttx_history);
    Behavior.Value = struct('valueBeh',valueBeh,'valueStopBeh',valueStopSignalBeh,'valueRTdist',valueRTdist);
    Behavior.Stopping = stopSignalBeh;
    
    save('-v7.3', sessionFileName, 'Spikes','LFP','Eyes','SessionInfo','Behavior','Trials');
    
    clear Spikes LFP Eyes SessionInfo Behavior Trials
end

%%

