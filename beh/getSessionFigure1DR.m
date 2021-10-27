function getSessionFigure1DR(stopSignalBeh,stateFlags,RTdist,outFilename)

figure('Renderer', 'painters', 'Position', [100 100 800 800]);
targTrials = find(~isnan(stateFlags.IsTargetOn));

subplot(3,2,1);hold on
title(outFilename)
scatter(stopSignalBeh.inh_SSD,stopSignalBeh.inh_pnc,'filled','MarkerFaceColor',[116 164 188]/255)
plot(stopSignalBeh.inh_weibull.x,stopSignalBeh.inh_weibull.y,'k')
xlim([0 max(stopSignalBeh.inh_SSD)+3]); ylim([0 1]); box off; grid on
xlabel('Stop-signal delay (VR)'); ylabel('p(respond | stop-signal)')

subplot(3,2,2); hold on
bar(stopSignalBeh.inh_SSD',stopSignalBeh.inh_nTr,'FaceColor',[116 164 188]/255)
xlabel('Stop-signal delay (ms)'); ylabel('N trials')

   
subplot(3,2,3);hold on
histogram(stateFlags.FixHoldDuration(targTrials),...
    min(stateFlags.FixHoldDuration(targTrials)-50):25:...
    max(stateFlags.FixHoldDuration(targTrials)+50),...
    'FaceColor',[116 164 188]/255, 'LineStyle','none');
xlabel('Foreperiod (ms)'); ylabel('N trials')

subplot(3,2,4); hold on
plot(RTdist.nostop(:,1),RTdist.nostop(:,2),'k-')
plot(RTdist.noncanc(:,1),RTdist.noncanc(:,2),'k--')
xlim([100 600]); ylim([0 1])
xlabel('Saccade latency (ms)'); ylabel('CDF'); box off; grid on
text(mean(RTdist.nostop(:,1)),0.55,['NS mean = ' int2str(mean(RTdist.nostop(:,1))) ' ms'])
text(mean(RTdist.noncanc(:,1)),0.45,['NC mean = ' int2str(mean(RTdist.noncanc(:,1))) ' ms'])


binSize = 25;
for trl = 1:length(stateFlags.TrialNumber)-(binSize+1)
    time(trl) = mean(trl:trl+binSize);
    moving_RT(trl) = nanmean(RTdist.all(trl:trl+binSize));
    moving_pStop(trl) = nanmean(stateFlags.TrialType(trl:trl+binSize));
    moving_SSD(trl) = nanmean(round(stateFlags.UseSsdVrCount(trl:trl+binSize)*17,-1));

end

subplot(3,2,[5 6])
yyaxis right
plot(time,moving_pStop,'r')
ylim([0 1])
ylabel('P(Stop)')
yyaxis left
plot(time,moving_RT,'k')
hold on
plot(time,moving_SSD,'b-')
ylabel('Mean RT/SSD (ms)')
xlabel('Trial number')

end
