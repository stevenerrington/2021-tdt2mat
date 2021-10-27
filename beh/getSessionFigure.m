function getSessionFigure(stopSignalBeh,stateFlags,RTdist,ttx,outFilename)

figure('Renderer', 'painters', 'Position', [100 100 800 800]);

subplot(2,2,1);hold on
title(outFilename)
scatter(stopSignalBeh.inh_SSD,stopSignalBeh.inh_pnc,'filled','MarkerFaceColor',[116 164 188]/255)
plot(stopSignalBeh.inh_weibull.x,stopSignalBeh.inh_weibull.y,'k')
xlim([0 round(max(stopSignalBeh.inh_SSD),-2)]); ylim([0 1]); box off; grid on
xlabel('Stop-signal delay (ms)'); ylabel('p(respond | stop-signal)')

subplot(2,2,2); hold on
bar(stopSignalBeh.inh_SSD,stopSignalBeh.inh_nTr,'FaceColor',[116 164 188]/255)
xlabel('Stop-signal delay (ms)'); ylabel('N trials')
xlim([0 max(stopSignalBeh.inh_SSD)+50]);...
    if round(max(stopSignalBeh.inh_nTr),-2) ~= 0
    ylim([round(min(stopSignalBeh.inh_nTr),-2) round(max(stopSignalBeh.inh_nTr),-2)]); box off; grid on
    end
   
subplot(2,2,3);hold on
histogram(stateFlags.FixHoldDuration(ttx.nostop.all.all),...
    min(stateFlags.FixHoldDuration(ttx.nostop.all.all)-50):25:...
    max(stateFlags.FixHoldDuration(ttx.nostop.all.all)+50),...
    'FaceColor',[116 164 188]/255, 'LineStyle','none');
xlabel('Foreperiod (ms)'); ylabel('N trials')

subplot(2,2,4); hold on
plot(RTdist.nostop(:,1),RTdist.nostop(:,2),'k-')
plot(RTdist.noncanc(:,1),RTdist.noncanc(:,2),'k--')
xlim([100 600]); ylim([0 1])
xlabel('Saccade latency (ms)'); ylabel('CDF'); box off; grid on
text(mean(RTdist.nostop(:,1)),0.55,['NS mean = ' int2str(mean(RTdist.nostop(:,1))) ' ms'])
text(mean(RTdist.noncanc(:,1)),0.45,['NC mean = ' int2str(mean(RTdist.noncanc(:,1))) ' ms'])


end
