dataDir = 'C:\Users\Steven\Desktop\TDT convert\cmandMat';
timeWin = [-1000 8000];
getColors;

sessionList =...
    {'dar-cmand1DR-ACC-20210115'};

dspList = {'DSP32a'};

sessionIdx = 1;
data = parload([dataDir '\' sessionList{sessionIdx}]);

fprintf([sessionList{sessionIdx} '\n'])
[ttx, ttx_history, trialEventTimes] = processSessionTrials...
    (data.Behavior.stateFlags_, data.Behavior.Infos_);
[ttm] = processTrialMatching(data.Behavior.Stopping, ttx, trialEventTimes);


tdtSpk_aligned = alignSDF...
    (trialEventTimes, data.Behavior.Infos_, data.Spikes, timeWin);

sdf{sessionIdx}.fixation.nostop =...
    nanmean(tdtSpk_aligned.(dspList{sessionIdx}).fixation(ttx.nostop.all.all,:));
sdf{sessionIdx}.fixation.noncanceled =...
    nanmean(tdtSpk_aligned.(dspList{sessionIdx}).fixation(ttx.noncanceled.all.all,:));
sdf{sessionIdx}.fixation.canceled =...
    nanmean(tdtSpk_aligned.(dspList{sessionIdx}).fixation(ttx.canceled.all.all,:));


highTrials = [ttx.nostop.all.hi;ttx.noncanceled.all.hi;ttx.canceled.all.hi];
lowTrials = [ttx.nostop.all.lo;ttx.noncanceled.all.lo;ttx.canceled.all.lo];

sdf{sessionIdx}.target.highValue =...
    nanmean(tdtSpk_aligned.(dspList{sessionIdx}).target(highTrials,:));
sdf{sessionIdx}.target.lowValue =...
    nanmean(tdtSpk_aligned.(dspList{sessionIdx}).target(lowTrials,:));


sdf{sessionIdx}.saccade.nostop =...
    nanmean(tdtSpk_aligned.(dspList{sessionIdx}).saccade(ttx.nostop.all.all,:));
sdf{sessionIdx}.saccade.noncanceled =...
    nanmean(tdtSpk_aligned.(dspList{sessionIdx}).saccade(ttx.noncanceled.all.all,:));

sdf{sessionIdx}.saccade.nostop_after =...
    nanmean(tdtSpk_aligned.(dspList{sessionIdx}).target(ttx.nostop.all.all(1:end-1)+1,:));
sdf{sessionIdx}.saccade.noncanceled_after =...
    nanmean(tdtSpk_aligned.(dspList{sessionIdx}).target(ttx.noncanceled.all.all(1:end-1)+1,:));


ssdIdx = 3; ssdValue = data.Behavior.Stopping.inh_SSD(ssdIdx);
ssrtValue = round(data.Behavior.Stopping.ssrt.integrationWeighted);
alignWin = -timeWin(1)+[ssdValue-200:ssdValue+750];

sdf{sessionIdx}.stopping.nostop =...
    nanmean(tdtSpk_aligned.(dspList{sessionIdx}).target(ttm.C.GO{ssdIdx},alignWin));
sdf{sessionIdx}.stopping.canceled =...
    nanmean(tdtSpk_aligned.(dspList{sessionIdx}).target(ttm.C.C{ssdIdx},alignWin));



sdf{sessionIdx}.reward.nostop =...
    nanmean(tdtSpk_aligned.(dspList{sessionIdx}).reward(ttx.nostop.all.all,:));
sdf{sessionIdx}.reward.noncanceled =...
    nanmean(tdtSpk_aligned.(dspList{sessionIdx}).reward(ttx.noncanceled.all.all,:));
sdf{sessionIdx}.reward.canceled =...
    nanmean(tdtSpk_aligned.(dspList{sessionIdx}).reward(ttx.canceled.all.all,:));

sdf{sessionIdx}.timeout.all =...
    nanmean(tdtSpk_aligned.(dspList{sessionIdx}).timeout(:,:));





%% DSP23c 20210115


etaTimeToNextTrial_noStop = trialEventTimes.fixation(ttx.nostop.all.all(1:end-1)+1) - trialEventTimes.saccade(ttx.nostop.all.all(1:end-1));
etaTimeToNextTrial_noncanc = trialEventTimes.fixation(ttx.noncanceled.all.all(1:end-1)+1) - trialEventTimes.saccade(ttx.noncanceled.all.all(1:end-1));

etaTimeToReward_nostop = trialEventTimes.reward(ttx.nostop.all.all(1:end-1)) - trialEventTimes.saccade(ttx.nostop.all.all(1:end-1));
etaTimeToReward_noncanc = trialEventTimes.reward(ttx.noncanceled.all.all(1:end-1)) - trialEventTimes.saccade(ttx.noncanceled.all.all(1:end-1));

figure; histogram(etaTimeToNextTrial_noStop); 
figure; histogram(etaTimeToNextTrial_noncanc); 
etaNextTrial_saccade = nanmedian([etaTimeToNextTrial_noStop;etaTimeToNextTrial_noncanc]);
etaReward_saccade = nanmedian([etaTimeToReward_nostop;etaTimeToReward_noncanc]);


figure('Renderer', 'painters', 'Position', [100 100 800 250]);
a = subplot(1,2,1); hold on
plot(timeWin(1):timeWin(2),sdf{neuronIdx}.saccade.nostop,'color',colors.nostop);
plot(timeWin(1):timeWin(2),sdf{neuronIdx}.saccade.noncanceled,'color',colors.noncanc);
xlim([-200 5000]); xlabel('Time from Saccade (ms)'); ylabel('Firing Rate (spks/sec)');
vline(0,'k'); vline(etaReward_saccade,'g-'); vline(etaNextTrial_saccade,'r-'); title(sessionList{neuronIdx})

b = subplot(1,2,2); hold on
plot(timeWin(1):timeWin(2),sdf{neuronIdx}.saccade.nostop_after,'color',colors.nostop);
plot(timeWin(1):timeWin(2),sdf{neuronIdx}.saccade.noncanceled_after,'color',colors.noncanc);
xlim([-250 750]); xlabel('Time from Saccade (ms)'); ylabel('Firing Rate (spks/sec)');
vline(0,'k'); title(sessionList{neuronIdx})







%% DSP26b 20210321

figure('Renderer', 'painters', 'Position', [100 100 400 250]);
a = subplot(1,1,1); hold on
plot(timeWin(1):timeWin(2),sdf{neuronIdx}.reward.nostop,'color',colors.nostop);
plot(timeWin(1):timeWin(2),sdf{neuronIdx}.reward.noncanceled,'color',colors.noncanc);
plot(timeWin(1):timeWin(2),sdf{neuronIdx}.reward.canceled,'color',colors.canceled);
xlim([-600 600]); xlabel('Time from Saccade (ms)'); ylabel('Firing Rate (spks/sec)');
vline(0,'k'); title(sessionList{neuronIdx})


%% DSP11a 20210420

figure('Renderer', 'painters', 'Position', [100 100 800 250]);
a = subplot(1,2,1); hold on
plot(-200:750,sdf{neuronIdx}.stopping.nostop,'color',colors.nostop);
plot(-200:750,sdf{neuronIdx}.stopping.canceled,'color',colors.canceled);
xlim([-200 750]); xlabel('Time from Saccade (ms)'); ylabel('Firing Rate (spks/sec)');
vline(0,'k'); vline(ssrtValue,'k--'); title(sessionList{neuronIdx})

b = subplot(1,2,2); hold on
plot(timeWin(1):timeWin(2),sdf{neuronIdx}.reward.nostop,'color',colors.nostop);
plot(timeWin(1):timeWin(2),sdf{neuronIdx}.reward.canceled,'color',colors.canceled);
xlim([-1000 250]); xlabel('Time from Reward (ms)'); ylabel('Firing Rate (spks/sec)');
vline(-600,'k'); vline(0,'k'); title(sessionList{neuronIdx})

%%
figure('Renderer', 'painters', 'Position', [100 100 800 250]);
a = subplot(1,1,1); hold on
plot(timeWin(1):timeWin(2),sdf{neuronIdx}.target.lowValue,'color',colors.nostop);
plot(timeWin(1):timeWin(2),sdf{neuronIdx}.target.highValue,'color',colors.canceled);
xlim([-200 750]); xlabel('Time from Saccade (ms)'); ylabel('Firing Rate (spks/sec)');
vline(0,'k'); title(sessionList{neuronIdx})




%% Next trial proportion


nTrlHistory.nostop_noncanceled = sum(ismember(ttx.nostop.all.all+1,ttx.noncanceled.all.all));
nTrlHistory.nostop_canceled = sum(ismember(ttx.nostop.all.all+1,ttx.canceled.all.all));
nTrlHistory.nostop_nostop = sum(ismember(ttx.nostop.all.all+1,ttx.nostop.all.all));
nTrlHistory.nostop_total = length(ttx.nostop.all.all+1);
nTrlHistory.nostop_other = nTrlHistory.nostop_total-nTrlHistory.nostop_noncanceled-...
    nTrlHistory.nostop_canceled-nTrlHistory.nostop_nostop;

nTrlHistory.noncanceled_noncanceled = sum(ismember(ttx.noncanceled.all.all+1,ttx.noncanceled.all.all));
nTrlHistory.noncanceled_canceled = sum(ismember(ttx.noncanceled.all.all+1,ttx.canceled.all.all));
nTrlHistory.noncanceled_nostop = sum(ismember(ttx.noncanceled.all.all+1,ttx.nostop.all.all));
nTrlHistory.noncanceled_total = length(ttx.noncanceled.all.all+1);
nTrlHistory.noncanceled_other = nTrlHistory.noncanceled_total-nTrlHistory.noncanceled_noncanceled-...
    nTrlHistory.noncanceled_canceled-nTrlHistory.noncanceled_nostop;

nTrlHistory.canceled_noncanceled = sum(ismember(ttx.canceled.all.all+1,ttx.noncanceled.all.all));
nTrlHistory.canceled_canceled = sum(ismember(ttx.canceled.all.all+1,ttx.canceled.all.all));
nTrlHistory.canceled_nostop = sum(ismember(ttx.canceled.all.all+1,ttx.nostop.all.all));
nTrlHistory.canceled_total = length(ttx.canceled.all.all+1);
nTrlHistory.canceled_other = nTrlHistory.canceled_total-nTrlHistory.canceled_noncanceled-...
    nTrlHistory.canceled_canceled-nTrlHistory.canceled_nostop;



figure('Renderer', 'painters', 'Position', [100 100 800 250]);
subplot(1,3,1)
pie([nTrlHistory.nostop_nostop, nTrlHistory.nostop_canceled,...
    nTrlHistory.nostop_noncanceled,nTrlHistory.nostop_other])
title('No stop')

subplot(1,3,2)
pie([nTrlHistory.noncanceled_nostop, nTrlHistory.noncanceled_canceled,...
    nTrlHistory.noncanceled_noncanceled,nTrlHistory.noncanceled_other])
title('Non-canceled')

subplot(1,3,3)
pie([nTrlHistory.canceled_nostop, nTrlHistory.canceled_canceled,...
    nTrlHistory.canceled_noncanceled,nTrlHistory.canceled_other])
title('Canceled')

labels = {'No-stop','Canceled','Non-canceled','Invalid'};
lgd = legend(labels);
lgd.Location = 'east';
