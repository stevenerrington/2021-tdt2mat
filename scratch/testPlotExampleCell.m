figure; plot(mean(Spikes.WAV32a))

SessionSDF = SpkConvolver (Spikes.DSP32a, round(max(Infos.InfosEnd_)), 'PSP');
timeWin = [-1000:2000];

ChannelList = {'DSP32a'};

SessionSDF = SpkConvolver (Spikes.(ChannelList{1}), round(max(Infos.InfosEnd_)), 'PSP');

[SDF.(ChannelList{1})] = alignSDF(SessionSDF, trialEventTimes, [-1000:2000])




clear alignTimes
alignTimes = trialEventTimes.tone(:);


clear test
for ii = 1:length(alignTimes)
    if isnan(alignTimes(ii))
        test(ii,:) = nan(1,range(timeWin)+1);
    else
        test(ii,:) = SessionSDF(alignTimes(ii)+timeWin(1):alignTimes(ii)+timeWin(end));
    end
end


figure('Renderer', 'painters', 'Position', [100 100 1200 400]);
subplot(1,2,1); hold on
plot(timeWin,nanmean(test(ttx.nostop.all.hi,:)),'k-','LineWidth',2)
plot(timeWin,nanmean(test(ttx.nostop.all.lo,:)),'k-','LineWidth',0.5)
% plot(timeWin,nanmean(test(ttx.canceled.all.all,:)),'color',colors.canceled)
vline(0,'k-')
% vline(nanmean(trialEventTimes.saccade(ttx.noncanceled.all.all.all)-trialEventTimes.target(ttx.noncanceled.all.all.all)),'r-.')
% vline(nanmean(trialEventTimes.tone(ttx.noncanceled.all.all.all)-trialEventTimes.target(ttx.noncanceled.all.all.all)),'r--')
% vline(nanmean(trialEventTimes.reward(ttx.noncanceled.all.all.all)-trialEventTimes.target(ttx.noncanceled.all.all.all)),'r-')
vline(500,'k-')
% vline(nanmean(trialEventTimes.saccade(ttx.nostop.all.all)-trialEventTimes.target(ttx.nostop.all.all)),'g-.')
% vline(nanmean(trialEventTimes.tone(ttx.nostop.all.all)-trialEventTimes.target(ttx.nostop.all.all)),'g--')
% vline(nanmean(trialEventTimes.reward(ttx.nostop.all.all)-trialEventTimes.target(ttx.nostop.all.all)),'g-')
xlabel('Time from Target (ms)'); ylabel('Firing rate (spks/s)')
legend({'High','Low'},'Location','southeast')
title([outFilename ': DSP32a'])

subplot(1,2,2)
plot(mean(Spikes.WAV32a),'k')
peak = find(mean(Spikes.WAV32a) == max(mean(Spikes.WAV32a)));
trough = find(mean(Spikes.WAV32a) == min(mean(Spikes.WAV32a)));
width = round(((peak - trough)*(G_FS('fast')/1000)));
xlim([0 size(Spikes.WAV32a,2)+1])
vline(peak); vline(trough);
legend(['Width = ' int2str(width) ' \mus'],'Location','southeast')
box off
