dataDir = 'C:\Users\Steven\Desktop\TDT convert\cmandMat';
timeWin = [-1000 2000]; plotWin = [-100:600]; csdWin = [900:1250];
alignName = 'saccade'; 


[ttx, ttx_history, trialEventTimes] = processSessionTrials...
    (Behavior.stateFlags_, Behavior.Infos_);
[ttm] = processTrialMatching(Behavior.Stopping, ttx, trialEventTimes);

% Align the LFPs from the session
% Depth x time x trial
tdtLFP = alignLFP(trialEventTimes, LFP, timeWin);
channelNames = fieldnames(tdtLFP.data);

dACC_channel = 10; vACC_channel = 28;

dACC_NCmean = nanmean(tdtLFP.aligned.(channelNames{dACC_channel}).saccade(ttx.noncanceled.left.all,[900:1600]));
dACC_NSmean = nanmean(tdtLFP.aligned.(channelNames{dACC_channel}).saccade(ttx.nostop.left.all,[900:1600]));

vACC_NCmean = nanmean(tdtLFP.aligned.(channelNames{vACC_channel}).saccade(ttx.noncanceled.left.all,[900:1600]));
vACC_NSmean = nanmean(tdtLFP.aligned.(channelNames{vACC_channel}).saccade(ttx.nostop.left.all,[900:1600]));


figure('Renderer', 'painters', 'Position', [100 100 600 600]);
subplot(2,2,1)
plot(plotWin,dACC_NCmean,'k--','LineWidth',2); hold on; plot(plotWin,dACC_NSmean,'k')
xlim([-100 500]); ylabel('Voltage')
title('dACC')

subplot(2,2,2)
plot(plotWin,dACC_NCmean-dACC_NSmean,'k')
xlim([-100 500]); ylabel('Difference')

subplot(2,2,3)
plot(plotWin,vACC_NCmean,'k--','LineWidth',2); hold on; plot(plotWin,vACC_NSmean,'k')
xlim([-100 500]); xlabel('Time from Saccade (ms)'); ylabel('Voltage')
title('vACC')

subplot(2,2,4)
plot(plotWin,vACC_NCmean-vACC_NSmean,'k');
xlim([-100 500]); xlabel('Time from Saccade (ms)'); ylabel('Difference')

