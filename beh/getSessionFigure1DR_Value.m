function getSessionFigure1DR_Value(valueStopSignalBeh,valueRTdist,ttx,outFilename)

figure('Renderer', 'painters', 'Position', [100 100 800 800]);

%% Inhibition function
subplot(2,2,1)
plot(valueStopSignalBeh.inh_weibull.hi.x,valueStopSignalBeh.inh_weibull.hi.y,'r')
hold on
scatter(valueStopSignalBeh.inh_SSD.hi,valueStopSignalBeh.inh_pnc.hi,...
    'filled','MarkerFaceColor',[255 1 1]/255,'MarkerFaceAlpha',0.2)
plot(valueStopSignalBeh.inh_weibull.lo.x,valueStopSignalBeh.inh_weibull.lo.y,'b')
hold on
scatter(valueStopSignalBeh.inh_SSD.lo,valueStopSignalBeh.inh_pnc.lo,...
    'filled','MarkerFaceColor',[1 1 255]/255,'MarkerFaceAlpha',0.2)
xlim([0 400]); ylim([0 1]); box off; grid on
xlabel('Stop-signal delay (ms)'); ylabel('p(respond | stop-signal)')
title(outFilename)

%% RT distribution
subplot(2,2,2)
plot(valueRTdist.hi.noncanc(:,1),valueRTdist.hi.noncanc(:,2),'r--')
hold on
plot(valueRTdist.hi.nostop(:,1),valueRTdist.hi.nostop(:,2),'r-')

plot(valueRTdist.lo.noncanc(:,1),valueRTdist.lo.noncanc(:,2),'b--')
hold on
plot(valueRTdist.lo.nostop(:,1),valueRTdist.lo.nostop(:,2),'b-')
xlim([100 600]); ylim([0 1]); box off; grid on
xlabel('Saccade Latency (ms)'); ylabel('P(Saccades)')
legend({'High: Non-canceled','High: No-stop',...
    'Low: Non-canceled','Low: No-stop'},'Location','southeast')

%% SSRT values
subplot(2,2,3)
bar([1, 2],[valueStopSignalBeh.ssrt.lo.integrationWeighted,...
    valueStopSignalBeh.ssrt.hi.integrationWeighted],'FaceColor',[0.8 0.8 0.8])
set(gca,'xticklabel',{'Low','High'})
xlabel('Reward Amount'); ylabel('SSRTint (ms)')
box off

%% 
subplot(2,2,4)
y = [[length(ttx.canceled.all.lo)  length(ttx.noncanceled.all.lo) length(ttx.nostop.all.lo)]./...
    sum([length(ttx.canceled.all.lo)  length(ttx.noncanceled.all.lo) length(ttx.nostop.all.lo)]);...
    [length(ttx.canceled.all.hi)  length(ttx.noncanceled.all.hi) length(ttx.nostop.all.hi)]./...
    sum([length(ttx.canceled.all.hi)  length(ttx.noncanceled.all.hi) length(ttx.nostop.all.hi)])];
bar(y,'stacked'); ylabel('P(Trials)');
set(gca,'xticklabel',{'Low','High'})
legend('Canceled','Non-canceled','No-stop','Location','north')
box off

end
