
names = fieldnames( tdtSpk );
DSPsubStr = 'DSP';
DSPstruct = rmfield( tdtSpk, names( find( cellfun( @isempty, strfind( names , DSPsubStr ) ) ) ) );
DSPnames = fieldnames(DSPstruct);
WAVsubStr = 'WAV';
WAVstruct = rmfield( tdtSpk, names( find( cellfun( @isempty, strfind( names , WAVsubStr ) ) ) ) );
WAVnames = fieldnames(WAVstruct);
getColors

DSPidx = 4;%1:length(DSPnames)
DSPlabel = DSPnames{DSPidx};
WAVlabel = WAVnames{DSPidx};

figure('Renderer', 'painters', 'Position', [100 100 1300 800]);

% Plot Spike Width/Shape
subplot(5,6,[3 4 9 10]); hold on
plot(nanmean(tdtSpk.(WAVlabel)),'k','LineWidth',2)



%% SDF Alignments %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Target aligned
subplot(5,6,[5 6]); hold on
plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPlabel).target(ttx.nostop.all.all,:)),'color',colors.nostop)
plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPlabel).target(ttx.noncanceled.all.all,:)),'color',colors.noncanc)
plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPlabel).target(ttx.canceled.all.all,:)),'color',colors.canceled)
xlim([-250 500]); vline(0,'k'); xlabel('Time from Target (ms)')

% Saccade aligned
subplot(5,6,[11 12]); hold on
plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPlabel).saccade(ttx.nostop.all.all,:)),'color',colors.nostop)
plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPlabel).saccade(ttx.noncanceled.all.all,:)),'color',colors.noncanc)
xlim([-250 500]); vline(0,'k'); xlabel('Time from Saccade (ms)')

% Stop-Signal aligned
subplot(5,6,[17 18]); hold on
plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPlabel).stopSignal(ttx.noncanceled.all.all,:)),'color',colors.noncanc)
plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPlabel).stopSignal(ttx.canceled.all.all,:)),'color',colors.canceled)
xlim([-250 500]); vline(0,'k'); xlabel('Time from Stop Signal (ms)')

% Tone aligned
subplot(5,6,[23 24]); hold on
plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPlabel).tone(ttx.nostop.all.all,:)),'color',colors.nostop)
plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPlabel).tone(ttx.noncanceled.all.all,:)),'color',colors.noncanc)
plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPlabel).tone(ttx.canceled.all.all,:)),'color',colors.canceled)
xlim([-250 500]); vline(0,'k'); xlabel('Time from Tone (ms)')

% Reward aligned
subplot(5,6,[29 30]); hold on
plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPlabel).reward(ttx.nostop.all.all,:)),'color',colors.nostop)
plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPlabel).reward(ttx.noncanceled.all.all,:)),'color',colors.noncanc)
plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPlabel).reward(ttx.canceled.all.all,:)),'color',colors.canceled)
xlim([-250 500]); vline(0,'k'); xlabel('Time from Reward (ms)')

