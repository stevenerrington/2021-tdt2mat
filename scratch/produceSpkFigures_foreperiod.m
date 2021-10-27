function produceSpkFigures_foreperiod(foreperiodTrials, SDF, trialEventTimes)


%% Preprocessing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
names = fieldnames( SDF );
DSPsubStr = 'DSP';
DSPstruct = rmfield( SDF, names( find( cellfun( @isempty, strfind( names , DSPsubStr ) ) ) ) );
DSPnames = fieldnames(DSPstruct);

foreperiod = trialEventTimes.target-trialEventTimes.fixation;

foreperiodPlotWin = [-250:2000];
targetPlotWin = [-999:250];

for neuronIdx = 1:length(DSPnames)

    %% SDF
    figure('Renderer', 'painters', 'Position', [100 100 1400 400]);
    subplot(1,2,1); hold on
    plot(foreperiodPlotWin,nanmean(SDF.(DSPnames{neuronIdx}).fixation(foreperiodTrials{1},foreperiodPlotWin+1000)),'color',[0 0 0])
    plot(foreperiodPlotWin,nanmean(SDF.(DSPnames{neuronIdx}).fixation(foreperiodTrials{2},foreperiodPlotWin+1000)),'color',[0.25 0.25 0.25])
    plot(foreperiodPlotWin,nanmean(SDF.(DSPnames{neuronIdx}).fixation(foreperiodTrials{3},foreperiodPlotWin+1000)),'color',[0.5 0.5 0.5])
    
    
    xlim([foreperiodPlotWin(1) foreperiodPlotWin(end)]);
    vline(0,'k'); vline(nanmedian(foreperiod(foreperiodTrials{1})),'k--'); vline(nanmedian(foreperiod(foreperiodTrials{3})),'k-.');
    xlabel('Time from Fixation (ms)'); ylabel('Firing rate (spks/sec)');
    legend({'Short','Mid','Long'},'location','northwest')
    
    subplot(1,2,2); hold on
    
    plot(targetPlotWin,nanmean(SDF.(DSPnames{neuronIdx}).target(foreperiodTrials{1},targetPlotWin+1000)),'color',[0 0 0])
    plot(targetPlotWin,nanmean(SDF.(DSPnames{neuronIdx}).target(foreperiodTrials{2},targetPlotWin+1000)),'color',[0.25 0.25 0.25])
    plot(targetPlotWin,nanmean(SDF.(DSPnames{neuronIdx}).target(foreperiodTrials{3},targetPlotWin+1000)),'color',[0.5 0.5 0.5])
    
    
    xlim([targetPlotWin(1) targetPlotWin(end)]);
    vline(0,'k'); vline(-nanmedian(foreperiod(foreperiodTrials{1})),'k--'); vline(-nanmedian(foreperiod(foreperiodTrials{3})),'k-.');
    xlabel('Time from Fixation (ms)'); ylabel('Firing rate (spks/sec)');
    legend({'Short','Mid','Long'},'location','northwest')
    
    
    title(DSPnames{neuronIdx})
end

end
