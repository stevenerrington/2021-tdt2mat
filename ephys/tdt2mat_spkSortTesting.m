%% Setup extraction parameters
clear; clc;
ops.doSecondary = 1; ops.EEGrecorded = 0;
ops.saveOutput = 0; ops.makeSingleMAT = 1;

% Define session information
areaList = {'DMFC'};
sessionInfo.monkey = 'joule';
sessionInfo.date = '20210319';
sessionInfo.task = 'cmand1DR'; % memguide, cmand, visflash
sessionInfo.tdtFile = 'Cmand1DR_Ephys-210319-101802';

ops.getLFP = 0; ops.getSpk = 1; ops.getEEG = 0;

%% Input session information
sessionInfo.area = areaList{1}; % fef, sef, acc, beh
outFilename = [sessionInfo.monkey(1:3) '-' sessionInfo.task '-spkSort-3_qqFactor_r4-'...
    sessionInfo.area '-' sessionInfo.date];


%% Get online ephys data log
ephysLog = importOnlineEphysLog(sessionInfo.monkey);
logIdx = find(not(cellfun('isempty',strfind(ephysLog.TDTfilename,sessionInfo.tdtFile))));
if isempty(logIdx); logIdx = 1; else; logIdx = logIdx; end


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

% Get Ephys data
masterJrClust_wrapper(dirs)
jrc('manual','master_jrclust.prm');
tdtSpk = getJRclustSpks_test(dirs);

% CHECK OUT FILE NAME BEFORE PROCEEDING!

%% Secondary extractions
% Align Ephys
tic
if ops.doSecondary
    timeWin = [-1000 2000];
    [tdtSDF_aligned] = alignSDF(trialEventTimes, Infos, tdtSpk, timeWin);
end
toc
%% Print output
produceBehFigures % Produce behavioral figures

if ops.doSecondary
    produceSpkFigures(dirs, outFilename, tdtInfo, sessionInfo, ephysLog, logIdx,...
        tdtSpk, tdtSDF_aligned, Infos, ttx, stopSignalBeh)
end

