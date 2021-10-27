dataDir = 'C:\Users\Steven\Desktop\TDT convert\cmandMat';
timeWin = [-1000 2000];
getColors;

sessionList =...
    {'dar-cmand1DR-ACC-20210321',...
    'dar-cmand1DR-ACC-20210313',...
    'dar-cmand1DR-ACC-20210316',...
    'dar-cmand1DR-ACC-20210304',...
    'dar-cmand1DR-ACC-20210306',...
    'dar-cmand1DR-ACC-20210213',...
    'dar-cmand1DR-ACC-20210115'};

dspList = {'DSP26b','DSP32a','DSP29a','DSP01a','DSP11a','DSP19a','DSP23c'};

parfor sessionIdx = 1:length(sessionList)
    
    try
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
    
    sdf{sessionIdx}.saccade.nostop =...
        nanmean(tdtSpk_aligned.(dspList{sessionIdx}).saccade(ttx.nostop.all.all,:));
     sdf{sessionIdx}.saccade.noncanceled =...
        nanmean(tdtSpk_aligned.(dspList{sessionIdx}).saccade(ttx.noncanceled.all.all,:));
        
    sdf{sessionIdx}.reward.nostop =...
        nanmean(tdtSpk_aligned.(dspList{sessionIdx}).reward(ttx.nostop.all.all,:));
     sdf{sessionIdx}.reward.noncanceled =...
        nanmean(tdtSpk_aligned.(dspList{sessionIdx}).reward(ttx.noncanceled.all.all,:));
     sdf{sessionIdx}.reward.canceled =...
        nanmean(tdtSpk_aligned.(dspList{sessionIdx}).reward(ttx.canceled.all.all,:));       
       
    sdf{sessionIdx}.timeout.all =...
        nanmean(tdtSpk_aligned.(dspList{sessionIdx}).timeout(:,:));
    catch
    fprintf([sessionList{sessionIdx} ' : ERROR       \n'])
    end
    
    
end


%%
for neuronIdx = 1:length(sessionList)
    try
    figure('Renderer', 'painters', 'Position', [100 100 1500 300]);
    a = subplot(1,4,1); hold on
    plot(timeWin(1):timeWin(2),sdf{neuronIdx}.fixation.nostop,'color',colors.nostop);
    plot(timeWin(1):timeWin(2),sdf{neuronIdx}.fixation.noncanceled,'color',colors.noncanc);
    plot(timeWin(1):timeWin(2),sdf{neuronIdx}.fixation.canceled,'color',colors.canceled);
    xlim([-1000 1500]); xlabel('Time from Fixation (ms)'); ylabel('Firing Rate (spks/sec)');
    vline(0,'k'); title(sessionList{neuronIdx})
    
    b = subplot(1,4,2); hold on
    plot(timeWin(1):timeWin(2),sdf{neuronIdx}.saccade.nostop,'color',colors.nostop);
    plot(timeWin(1):timeWin(2),sdf{neuronIdx}.saccade.noncanceled,'color',colors.noncanc);
    xlim([-250 600]); xlabel('Time from Saccade (ms)'); ylabel('Firing Rate (spks/sec)');
    vline(0,'k')
    
    c = subplot(1,4,3); hold on
    plot(timeWin(1):timeWin(2),sdf{neuronIdx}.reward.nostop,'color',colors.nostop);
    plot(timeWin(1):timeWin(2),sdf{neuronIdx}.reward.noncanceled,'color',colors.noncanc);
    plot(timeWin(1):timeWin(2),sdf{neuronIdx}.reward.canceled,'color',colors.canceled);
    xlim([-600 1200]); xlabel('Time from Reward (ms)'); ylabel('Firing Rate (spks/sec)');
    vline(0,'k')
    
    d = subplot(1,4,4); hold on
    plot(timeWin(1):timeWin(2),sdf{neuronIdx}.timeout.all,'color',[0.25 0.25 0.25]);
    xlim([-500 1000]); xlabel('Time from Timeout Tone (ms)'); ylabel('Firing Rate (spks/sec)');
    vline(0,'k')
    
    
    linkaxes([a b c d],'y')
    
    catch
    end
    
   
end



    
    