
%% Setup Extraction
clear; clc;
ops.getLFP = 1; ops.getSpk = 1; ops.getEEG = 1;
ops.doSecondary = 1; ops.saveOutput = 1; ops.makeSingleMAT = 1;

%% Input session information
sessionInfo.monkey = 'TEST';
sessionInfo.date = 'TEST';
sessionInfo.area = 'TEST'; % fef, sef, acc, beh
sessionInfo.task = 'cmand1DR'; % memguide, cmand, visflash
sessionInfo.tdtFile = 'Cmand1DR_64EEG-210618-100000';

outFilename = [sessionInfo.monkey(1:3) '-' ...
    sessionInfo.task '-' ...
    sessionInfo.area '-' ...
    sessionInfo.date];

%% Set directories
dirs.rawDir = 'C:\Users\Steven\Desktop\Data\Raw';
dirs.processedDir = ['C:\Users\Steven\Desktop\TDT convert\cmandOutput\' outFilename];
dirs.experimentName = sessionInfo.tdtFile;
dirs.figureFolder = [dirs.processedDir,'\figures'];
% 
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
tdtFun = @TDTbin2mat; eegLabel = 'rEEG';
eegData = tdtFun([dirs.rawDir '\' dirs.experimentName],...
    'TYPE',{'streams'},'STORE',eegLabel,'VERBOSE',0);

for channel = 1:size(eegData.streams.(eegLabel).data,1)
    channellabel = ['EEG_' int2str(channel)];
    tdtEEG.data.(channellabel) = filterLFP(double(eegData.streams.(eegLabel).data(channel,:)),...
        1, 40,eegData.streams.(eegLabel).fs);
end

tdtEEG.info.samplingFreq = eegData.streams.(eegLabel).fs;
tdtEEG.info.startTime = eegData.streams.(eegLabel).startTime;
%%
timeWin = [-1000 2000];
tdtEEG_aligned = alignLFP(trialEventTimes,tdtEEG, timeWin);
getColors

for ii = 1:size(eegData.streams.(eegLabel).data,1)
    EEGchan = ['EEG_' int2str(ii)];
    clear errorEEG correctEEG
    errorEEG = nanmean(tdtEEG_aligned.aligned.(EEGchan).saccade(ttx.noncanceled.right.all,:));
    correctEEG = nanmean(tdtEEG_aligned.aligned.(EEGchan).saccade(ttx.nostop.right.all,:));
    
    %     errorEEG = errorEEG - mean(mean(tdtEEG_aligned.aligned.(EEGchan).saccade...
    %         ([ttx.noncanceled.all.all; ttx.nostop.right.all],800:1000)));
    %     correctEEG = correctEEG - mean(mean(tdtEEG_aligned.aligned.(EEGchan).saccade...
    %         ([ttx.noncanceled.all.all; ttx.nostop.right.all],800:1000)));
    
    figure('Renderer', 'painters', 'Position', [100 100 800 500]);
    subplot(2,1,1)
    plot(timeWin(1)+1:timeWin(2),errorEEG,'k--','LineWidth',2); hold on
    plot(timeWin(1)+1:timeWin(2),correctEEG,'k-','LineWidth',1); hold on
    xlim([-200 600]); vline(0,'k'); hline(0,'k')
    set(gca,'YDir','reverse')
    
    subplot(2,1,2)
    plot(timeWin(1)+1:timeWin(2),correctEEG-errorEEG,'color',colors.noncanc); hold on
    xlim([-200 600]); vline(0,'k'); hline(0,'k')
    set(gca,'YDir','reverse')
end
