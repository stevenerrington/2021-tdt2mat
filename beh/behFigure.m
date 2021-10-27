f_h = figure('Renderer', 'painters', 'Position', [100 100 1500 800]);
%% Session Information
ax = subplot(7, 10,[1 2]);
text(-0.5,1.2,[outFilename], 'FontSize',15, 'Interpreter', 'none');
% text(-0.5,1.05,['Monkey: ' sessionInfo.monkey ' / Date: ' sessionInfo.date ' / Site: ' char(ephysLog.AP_Grid(logIdx)) ' , ' char(ephysLog.ML_Grid(logIdx))],'FontWeight','bold','FontSize',15, 'Interpreter', 'none');

text(-0.5,0.9,'Session Information','FontWeight','bold');
text(-0.5,0.7,['Date: ' tdtInfo.date]);
text(-0.5,0.5,['Duration: ' tdtInfo.duration]);
text(-0.5,0.3,['Location: ' [sessionInfo.area ': AP, '] char(ephysLog.AP_Grid(logIdx))...
    '; ML, ' char(ephysLog.ML_Grid(logIdx)) '']);
set ( ax, 'visible', 'off')

%% Ntrls by SSD values
ax = subplot(7, 10, [11 12 21 22]);
bar(stopSignalBeh.inh_SSD',stopSignalBeh.inh_nTr,'FaceColor',[116 164 188]/255)
ylabel('N trials'); box off
pos = get(ax, 'Position');
posnew = pos; posnew(1) = posnew(1) - 0.05; set(ax, 'Position', posnew)
xlim([0 max(stopSignalBeh.inh_SSD)+100]); xticks({})
%% Standard Inhibition Function
ax = subplot(7, 10, [31 32 41 42]); hold on
scatter(stopSignalBeh.inh_SSD,stopSignalBeh.inh_pnc,'filled','MarkerFaceColor',[116 164 188]/255)
plot(stopSignalBeh.inh_weibull.x,stopSignalBeh.inh_weibull.y,'k')
xlim([0 max(stopSignalBeh.inh_SSD)+100]); ylim([0 1]); box off; grid on
ylabel('p(respond | stop-signal)')
pos = get(ax, 'Position');
posnew = pos; posnew(1) = posnew(1) - 0.05; set(ax, 'Position', posnew)

%% Standard RT dist
ax = subplot(7, 10, [33 34 43 44]); hold on
plot(RTdist.nostop(:,1),RTdist.nostop(:,2),'k-')
plot(RTdist.noncanc(:,1),RTdist.noncanc(:,2),'k--')
xlim([100 600]); ylim([0 1])
ylabel('CDF'); box off; grid on
text(mean(RTdist.nostop(:,1)),0.55,['NS mean = ' int2str(mean(RTdist.nostop(:,1))) ' ms'])
text(mean(RTdist.noncanc(:,1)),0.45,['NC mean = ' int2str(mean(RTdist.noncanc(:,1))) ' ms'])

%% Value Inhibition Function
ax = subplot(7, 10, [51 52 61 62]);
plot(valueStopSignalBeh.inh_weibull.hi.x,valueStopSignalBeh.inh_weibull.hi.y,'r')
hold on
scatter(valueStopSignalBeh.inh_SSD.hi,valueStopSignalBeh.inh_pnc.hi,...
    'filled','MarkerFaceColor',[255 1 1]/255,'MarkerFaceAlpha',0.2)
plot(valueStopSignalBeh.inh_weibull.lo.x,valueStopSignalBeh.inh_weibull.lo.y,'b')
hold on
scatter(valueStopSignalBeh.inh_SSD.lo,valueStopSignalBeh.inh_pnc.lo,...
    'filled','MarkerFaceColor',[1 1 255]/255,'MarkerFaceAlpha',0.2)
xlim([0 max(stopSignalBeh.inh_SSD)+100]); ylim([0 1]); box off; grid on
xlabel('Stop-signal delay (ms)'); ylabel('p(respond | stop-signal)')
pos = get(ax, 'Position');
posnew = pos; posnew(1) = posnew(1) - 0.05; set(ax, 'Position', posnew)

%% Value RT dist
ax = subplot(7, 10, [53 54 63 64]);
plot(valueRTdist.hi.noncanc(:,1),valueRTdist.hi.noncanc(:,2),'r--')
hold on
plot(valueRTdist.hi.nostop(:,1),valueRTdist.hi.nostop(:,2),'r-')

plot(valueRTdist.lo.noncanc(:,1),valueRTdist.lo.noncanc(:,2),'b--')
hold on
plot(valueRTdist.lo.nostop(:,1),valueRTdist.lo.nostop(:,2),'b-')
xlim([100 600]); ylim([0 1]); box off; grid on
xlabel('Saccade Latency (ms)'); ylabel('P(Saccades)')


%% SSRT values
ax = subplot(7, 10, [13 14 23 24]);
b = bar([1, 2, 3],[stopSignalBeh.ssrt.integrationWeighted,...
    valueStopSignalBeh.ssrt.lo.integrationWeighted,...
    valueStopSignalBeh.ssrt.hi.integrationWeighted]);
set(gca,'xticklabel',{'Standard','Low','High'})
b.FaceColor = 'flat';
b.CData(1,:) = [0.8 0.8 0.8]; b.CData(2,:) = [0 0 1.0]; b.CData(3,:) = [1 0 0];

ylabel('SSRTint (ms)')
box off


%% Running Reward Average
ax = subplot(7, 10, [6 7 8 9 10 16 17 18 19 20]);
pos = get(ax, 'Position');
runningRewardSubplot(stateFlags,Infos)

%% SSD & PStop x Session Time
binSize = 25;
for trl = 1:length(stateFlags.TrialNumber)-(binSize+1)
    time(trl) = mean(trl:trl+binSize);
    moving_RT(trl) = nanmean(RTdist.all(trl:trl+binSize));
    moving_pStop(trl) = nanmean(stateFlags.TrialType(trl:trl+binSize));
    moving_SSD(trl) = nanmean(round(stateFlags.UseSsdVrCount(trl:trl+binSize)*17,-1));
    
end

ax = subplot(7, 10, [46 47 48 49 50 56 57 58 59 60]);
plot(time,moving_pStop,'r'); ylim([0 1]); ylabel('P(Stop)')
xlabel('Trial number'); xlim([1 length(time)])
pos = get(ax, 'Position');
posnew = pos; posnew(2) = posnew(2) - 0.1; set(ax, 'Position', posnew)
box off

%% RT x Session Time
ax = subplot(7, 10, [26 27 28 29 30 36 37 38 39 40]);
pos = get(ax, 'Position'); posnew = pos; posnew(2) = posnew(2) - 0.05; set(ax, 'Position', posnew)
yyaxis left; plot(time,moving_RT,'b'); ylabel('RT (ms)'); ylim([0 600])
hold on; yyaxis right; plot(time,moving_SSD,'Color',[0.8500, 0.3250, 0.0980]); ylabel('SSD (ms)')
ylim([0 600])
xlim([1 length(time)]); box off


%% Output figure
figureOutFolder = [dirs.processedDir,'\figures'];
set(gcf,'Units','inches');
screenposition = get(gcf,'Position');
set(gcf,...
    'PaperPosition',[0 0 screenposition(3:4)],...
    'PaperSize',[screenposition(3:4)]);
saveas(gcf,[dirs.figureFolder '\' outFilename '-behavior.pdf'])
close gcf