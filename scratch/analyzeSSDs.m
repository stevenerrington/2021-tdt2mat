fName = 'stopSig.csv';
%ssdTable = csvread(fName,1);

ssdTable = readtable(fName,'ReadVariableNames',true);
refreshRate = 1000/60;
% varNames: TRL_NUMBER, TRL_STOP_SIGNAL_DELAY, TRL_TARG_SSD_VRT_RFRSH_COUNT, TRL_TARG_ON_TIME, TRL_STOP_SIGNAL_TIME, TRL_STOP_SIGNAL_DURATION
ssdTable.ssdTimeExpected = (ssdTable.TRL_STOP_SIGNAL_DELAY)* refreshRate;
ssdTable.ssdTimeFromVRCount = (ssdTable.TRL_TARG_SSD_VRT_RFRSH_COUNT)* refreshRate;
ssdTable.ssdTimeFromTickCount = ssdTable.TRL_STOP_SIGNAL_DURATION;
ssdTable.ssdTimeFromTargOnSSOn = ssdTable.TRL_STOP_SIGNAL_TIME - ssdTable.TRL_TARG_ON_TIME;


varNames = ssdTable.Properties.VariableNames;

ssdStats = grpstats(ssdTable,{'TRL_STOP_SIGNAL_DELAY'},{'min','median','mean','max','std'},...
                              'DataVars',{'ssdTimeExpected', 'ssdTimeFromVRCount',...
                                          'ssdTimeFromTickCount','ssdTimeFromTargOnSSOn'});
% get distributions:
relTimeMs = -30:30;
relTimeMsEdges = -30-0.5:30+0.5;


    uniqSsd = unique(ssdTable.TRL_STOP_SIGNAL_DELAY);
    ssdByRfrsh = arrayfun(@(x) ssdTable(ssdTable.TRL_STOP_SIGNAL_DELAY == x,:),uniqSsd,'UniformOutput',false);
    ssdDistFromVRCount = arrayfun(@(x) histcounts(ssdTable{ssdTable.TRL_STOP_SIGNAL_DELAY == x,'ssdTimeFromVRCount'}- x*refreshRate,relTimeMsEdges),...
       uniqSsd,'UniformOutput',false);
    ssdDistFromTickCount = arrayfun(@(x) histcounts(ssdTable{ssdTable.TRL_STOP_SIGNAL_DELAY == x,'ssdTimeFromTickCount'}- x*refreshRate,relTimeMsEdges),...
       uniqSsd,'UniformOutput',false);
    ssdDistFromTargOnSSOn = arrayfun(@(x) histcounts(ssdTable{ssdTable.TRL_STOP_SIGNAL_DELAY == x,'ssdTimeFromTargOnSSOn'}- x*refreshRate,relTimeMsEdges),...
       uniqSsd,'UniformOutput',false);

figure
for ii=1:numel(uniqSsd)
    expectedSsd = uniqSsd(ii)*16.67;
    subplot(3,1,1)
    bar(relTimeMs,ssdDistFromVRCount{ii,1});
    hold on
    line([16.67 16.67],get(gca,'ylim'),'LineStyle', '--')  
    line([-16.67 -16.67],get(gca,'ylim'),'LineStyle', '--')  
    hold off
    ylabel('ssdDistFromVRCount (ms)');
    xlabel('Rel. time (SSD - Expected SSD) (ms)')
    title(['SSD_{expected} [#' num2str(uniqSsd(ii),'%d] = [') num2str(round(expectedSsd),'%d ms]')])
    subplot(3,1,2)
    bar(relTimeMs,ssdDistFromTickCount{ii,1});
    hold on
    line([16.67 16.67],get(gca,'ylim'),'LineStyle', '--')  
    line([-16.67 -16.67],get(gca,'ylim'),'LineStyle', '--')  
    hold off
    ylabel('ssdDistFromTickCount (tics=ms)');
    xlabel('Rel. time (SSD - Expected SSD) (ms)')
    title(['SSD_{expected} [#' num2str(uniqSsd(ii),'%d] = [') num2str(round(expectedSsd),'%d ms]')])
    subplot(3,1,3)
    bar(relTimeMs,ssdDistFromTargOnSSOn{ii,1});
    hold on
    line([16.67 16.67],get(gca,'ylim'),'LineStyle', '--')  
    line([-16.67 -16.67],get(gca,'ylim'),'LineStyle', '--')  
    hold off
    ylabel('ssdDistFromTargOnSSOn (ms)');
    xlabel('Rel. time (SSD - Expected SSD) (ms)')
    title(['SSD_{expected} [#' num2str(uniqSsd(ii),'%d] = [') num2str(round(expectedSsd),'%d ms]')])
    drawnow
    pause
end

% for boxplot?
figure;
subplot(1,3,1)
ssdTimeFromVRCountCount = ssdTable{:, {'TRL_STOP_SIGNAL_DELAY','ssdTimeFromVRCount'}};
boxplot(ssdTimeFromVRCountCount(:,2),round(ssdTimeFromVRCountCount(:,1).*refreshRate))
set(gca,'XTickLabelRotation',45);
xlabel('SSD time Expected (ms)');
ylabel('SSD Time: PD VR Count (ms)');
yticksVals = round([2:2:60].*16.67);
yticks(yticksVals)
grid on

subplot(1,3,2)
ssdTimeFromTickCount = ssdTable{:, {'TRL_STOP_SIGNAL_DELAY','ssdTimeFromTickCount'}};
boxplot(ssdTimeFromTickCount(:,2)-refreshRate/2,round(ssdTimeFromTickCount(:,1).*refreshRate))
set(gca,'XTickLabelRotation',45);
xlabel('SSD time Expected (ms)');
ylabel('SSD Time: Tick Count (ms)');
yticksVals = round([2:2:60].*16.67);
yticks(yticksVals)
grid on
title('SSD time comaprision');

subplot(1,3,3)
ssdTimeFromTargOnSSOn = ssdTable{:, {'TRL_STOP_SIGNAL_DELAY','ssdTimeFromTargOnSSOn'}};
boxplot(ssdTimeFromTargOnSSOn(:,2),round(ssdTimeFromTargOnSSOn(:,1).*refreshRate))
set(gca,'XTickLabelRotation',45);
xlabel('SSD time Expected (ms)');
ylabel('SSD Time: StopSignalOnTime - TargOnTime (ms)');
yticksVals = round([2:2:60].*16.67);
yticks(yticksVals)
grid on
