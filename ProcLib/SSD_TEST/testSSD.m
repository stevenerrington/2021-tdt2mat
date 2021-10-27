%ssdTable = csvread('testSSDRun_021_fakeBreakFix.csv');
%ssdTable = csvread('testSSDRun_01_03_19_4.csv');
%ssdTable = csvread('testSSDRun_01_04_18_5long.csv');
%ssdTable = csvread('testSSDRun_01_07_19_1.csv');
%ssdTable = csvread('testSSDRun_01_07_19_2.csv');
%ssdTable = csvread('testSSDRun_01_07_19_3.csv');
%ssdTable = csvread('testSSDRun_01_07_19_4Final.csv');
fName='T:/Users/Chenchal/Tempo_NewCode/Isaac/testSSDR.csv';
ssdTable = csvread(fName);
if (size(ssdTable,2)  == 6)
  ssdTable = array2table(ssdTable,'VariableNames',{'TRL_NUM', 'VERT_RFRSH_SSD', 'VERT_RFRSH_COUNT', 'ssdTime', 'ssdTimeExpected','currWaitTicks'});
elseif (size(ssdTable,2)  == 8)
  ssdTable = array2table(ssdTable,'VariableNames',{'TRL_NUM', 'VERT_RFRSH_SSD', 'VERT_RFRSH_COUNT', 'ssdTime', 'ssdTimeExpected','currWaitTicks','watchEyeTicks','breakFixFlag'});
end

varNames = ssdTable.Properties.VariableNames;
if (sum(contains(varNames,'breakFixFlag')))
  ssdStats = grpstats(ssdTable,{'breakFixFlag','VERT_RFRSH_SSD'},{'min','mean','max','std'},'DataVars',{'ssdTime', 'currWaitTicks','watchEyeTicks'});
else
  ssdStats = grpstats(ssdTable,{'VERT_RFRSH_SSD'},{'min','median','mean','max','std'},'DataVars',{'ssdTime', 'currWaitTicks'});
end

%ssdTable.VERT_RFRSH_SSD & ssdTable.VERT_RFRSH_COUNT are same
% get distributions:
relTimeMs = -100:100;
relTimeMsEdges = -100-0.5:100+0.5;

if (sum(contains(varNames,'breakFixFlag')))
    uniqSsd = unique(ssdTable.VERT_RFRSH_SSD);
    ssdByRfrsh = arrayfun(@(x) ssdTable(ssdTable.VERT_RFRSH_SSD == x & ssdTable.breakFixFlag == 0 ,:),uniqSsd,'UniformOutput',false);
    ssdDistByRfrsh = arrayfun(@(x) histcounts(ssdTable{ssdTable.VERT_RFRSH_SSD == x  & ssdTable.breakFixFlag == 0 ,'ssdTime'}- x*16.67,relTimeMsEdges),...
        uniqSsd,'UniformOutput',false);
else
    uniqSsd = unique(ssdTable.VERT_RFRSH_SSD);
    ssdByRfrsh = arrayfun(@(x) ssdTable(ssdTable.VERT_RFRSH_SSD == x,:),uniqSsd,'UniformOutput',false);
    ssdDistByRfrsh = arrayfun(@(x) histcounts(ssdTable{ssdTable.VERT_RFRSH_SSD == x,'ssdTime'}- x*16.67,relTimeMsEdges),...
       uniqSsd,'UniformOutput',false);
end

figure
for ii=1:numel(uniqSsd)
    bar(relTimeMs,ssdDistByRfrsh{ii,1});
    expectedSsd = uniqSsd(ii)*16.67;
    title(['SSD_{expected} [#' num2str(uniqSsd(ii),'%d] = [') num2str(round(expectedSsd),'%d ms]')])
    figureFilenameTIF1 = ['PD_testSSD_SSD' int2str(uniqSsd(ii)) '_' datestr(now, 'yy-mm-dd')];
    saveas(gcf,['figures/2019_01_07/longSet/' figureFilenameTIF1], 'tiffn')
end

% for boxplot?
ssdsNoBreakFix = ssdTable{ssdTable.breakFixFlag == 0, {'VERT_RFRSH_SSD','ssdTime'}};
figure;
boxplot(ssdsNoBreakFix(:,2),round(ssdsNoBreakFix(:,1).*16.67))
figureFilenameTIF_boxplot = ['PD_testSSD_boxplot_' datestr(now, 'yy-mm-dd')];
saveas(gcf,['figures/2019_01_07/longSet/' figureFilenameTIF_boxplot], 'tiffn')
yticksVals = round([2:2:60].*16.67);
yticks(yticksVals)
grid on


