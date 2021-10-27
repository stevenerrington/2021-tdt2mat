clear all; clc; getColors

%% Set parameters
dataDir = 'C:\Users\Steven\Desktop\TDT convert\cmandMat';
timeWin = [-1000 2000]; plotWin = [-100:600]; csdWin = [900:1250];
alignName = 'tone'; 

ephysLog = importOnlineEphysLog;
sessionList = ephysLog.Session(strcmp(ephysLog.PerpFlag,'1') & strcmp(ephysLog.DMFC,'1'));
ctxTop = ephysLog.CtxTopChannel(strcmp(ephysLog.PerpFlag,'1') & strcmp(ephysLog.DMFC,'1'));

session = 1;
data = parload([dataDir '\' sessionList{session}]);
fprintf(['Analysing session: ' sessionList{session} '\n'])
[ttx, ttx_history, trialEventTimes] = processSessionTrials...
    (data.Behavior.stateFlags_, data.Behavior.Infos_);
[ttm] = processTrialMatching(data.Behavior.Stopping, ttx, trialEventTimes);

% Align the LFPs from the session
% Depth x time x trial
tdtLFP = alignLFP(trialEventTimes, data.LFP, timeWin);
channelNames = fieldnames(tdtLFP.data);

figure;
for ii = 1:str2double(ctxTop{session})+3
subplot(str2double(ctxTop{session})+3,1,ii)
    
nc_trial = nanmean(tdtLFP.aligned.(channelNames{ii}).saccade(ttx.noncanceled.all.all,[900:1600]));
ns_trial = nanmean(tdtLFP.aligned.(channelNames{ii}).saccade(ttx.nostop.all.all,[900:1600]));

plot(-100:600,nc_trial,'color',colors.noncanc); hold on
plot(-100:600,ns_trial,'color',colors.nostop);

end
