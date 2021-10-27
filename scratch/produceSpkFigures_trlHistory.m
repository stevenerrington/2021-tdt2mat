function produceSpkFigures_trlHistory(ttx, SDF, Behavior)


%% Preprocessing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
names = fieldnames( SDF );
DSPsubStr = 'DSP';
DSPstruct = rmfield( SDF, names( find( cellfun( @isempty, strfind( names , DSPsubStr ) ) ) ) );
DSPnames = fieldnames(DSPstruct);

getColors


ITI_fixation = Behavior.Infos_.FixSpotOn_(ttx.nostop.all.all(1:end-1)+1)-...
    Behavior.Infos_.RewardDelayEnd_(ttx.nostop.all.all(1:end-1));

ITI_target = Behavior.Infos_.Target_(ttx.nostop.all.all(1:end-1)+1)-...
    Behavior.Infos_.RewardDelayEnd_(ttx.nostop.all.all(1:end-1));

for neuronIdx = 1:length(DSPnames)

    %% SDF
    figure('Renderer', 'painters', 'Position', [100 100 1000 400]);
    hold on
    plot(-200:10000,nanmean(SDF.(DSPnames{neuronIdx}).reward(ttx.nostop.all.all,:)),'color',colors.nostop)
    plot(-200:10000,nanmean(SDF.(DSPnames{neuronIdx}).reward(ttx.noncanceled.all.all,:)),'color',colors.noncanc)
    plot(-200:10000,nanmean(SDF.(DSPnames{neuronIdx}).reward(ttx.canceled.all.all,:)),'color',colors.canceled)
    xlim([-200 7500]); vline(0,'k'); vline(nanmedian(ITI_fixation),'r'); vline(nanmedian(ITI_target),'g');
    xlabel('Time from Reward (ms)'); ylabel('Firing rate (spks/sec)');
    legend({'NS','NC','C'},'location','northwest')
    title(DSPnames{neuronIdx})
end

end
