function onlineBehPlots(beh)
useOutcomesForInhibitionPlot = 1;
figure('units','normalized','outerposition',[0 0 1 1])
h_rwrdByTrial = subplot(321);
h_inhbFx = subplot(322);
h_cumlRwrdBlk = subplot(323);
h_rt = subplot(324);
h_rwrdLastBlks = subplot(325);
h_trialOutcoms = subplot(326);
h_infos = axes(gcf,'Position',[0.01 0.95 0.98 0.04]);
[myColors, histColors] = getColors();
%% Infos
axes(h_infos);
box off
set(h_infos,'Visible','off')
text(0.1,0.5,beh.session,'FontWeight','bold','FontSize',12)

%% Trial outcomes grouped-stack plot
% stack: pre-, post- SSD only valid for STOP trials
%Plot
axes(h_trialOutcoms);
addPlotZoom();
data = table2array(beh.trial.outcomes);
labels = beh.trial.outcomes.Properties.RowNames';
groups = size(data,1)/2;
stacks = size(data,2);
barsInGroup = 2;

hold on;
for i=1:groups*barsInGroup
    h(i,1:stacks)=bar([data(i,:);nan(1,stacks)],'stacked'); %#ok<AGROW>
end
%Group and set xdata
x1=1:groups;
barWidth = 0.4;
x0=x1-barWidth;
pos=[x0;x1];
xpos=pos(:)';
ticks = [];
for ii = 0:groups-1
     ticks = [ticks [0.6 1.0]+ii]; %#ok<AGROW>
end
for i=1:groups*barsInGroup
    set(h(i,:),'xdata',xpos(i))
end
set(h,'barwidth',0.4)
grid on
xticks(ticks)
xlim([0.2 3.4])
xticklabels(labels)
xtickangle(45)
ylabel('Number of Trials');
title('Trial outcomes - Stacked [pre-SSD, post-SSD]')

%% Inhibition fx plot - Using taskInfos.Is.... vars
yscale = 1.18;
[~,weibullY] = WeibullFx(beh.raceModel.Params,beh.raceModel.inh_SSD);
if ~useOutcomesForInhibitionPlot
    axes(h_inhbFx)
    addPlotZoom();
    yyaxis('left');
    plot(beh.inhFx.ssdStatsAll.mean_UseSsdVrCount, beh.inhFx.values.pNC,'o-k','LineWidth',1.5,'MarkerSize',8);
    hold on
    plot(beh.inhFx.ssdStatsAll.mean_UseSsdVrCount,weibullY,'*:r','LineWidth',2,'MarkerSize',10);
    
    xticks(beh.inhFx.ssdStatsAll.mean_UseSsdVrCount)
    ylim([0 yscale])
    ylabel('pNC')
    xlabel('SSD (# vertical refresh)')
    grid on
    title('Inhibition function')
    yyaxis('right');
    
    hh = bar(beh.trial.stopOutcomesBySsd.ssdVrCount,table2array(beh.trial.stopOutcomesBySsd(:,2:end)),'stacked');
    set(hh,{'FaceColor'},histColors(1:numel(hh)),'EdgeColor','none','FaceAlpha',0.7);
    
    legend([{'pNC' 'WeibullFit'},beh.trial.stopOutcomesBySsd.Properties.VariableNames(2:end)],'Box','off','Location','northwest');
    
    ylim([0 max(beh.inhFx.values.nTrials)*yscale])
    set(gca, 'SortMethod', 'depth')
    ylabel('# STOP trials')
else
    %% Inhibition fx plot - Using outcomeEvents
    axes(h_inhbFx)
    addPlotZoom();
    yyaxis('left');
    plot(beh.inhFx.ssdStatsAll.mean_UseSsdVrCount, beh.inhFx.values.pNC_,'o-k','LineWidth',1.5,'MarkerSize',8);
    hold on
    plot(beh.inhFx.ssdStatsAll.mean_UseSsdVrCount,weibullY,'*:r','LineWidth',2,'MarkerSize',10);

    xticks(beh.inhFx.ssdStatsAll.mean_UseSsdVrCount)
    ylim([0 1.1])
    ylabel('pNC')
    xlabel('SSD (# vertical refresh)')
    grid on
    title('Inhibition function')
    yyaxis('right');
    
    hh = bar(beh.trial.stopOutcomesBySsd.ssdVrCount,table2array(beh.trial.stopOutcomesBySsd(:,2:end)),'stacked');
    set(hh,{'FaceColor'},histColors(1:numel(hh),:),'EdgeColor','none','FaceAlpha',0.7);
    
    legend([{'pNC' 'WeibullFit'},beh.trial.stopOutcomesBySsd.Properties.VariableNames(2:end)],'Box','off','Location','northwest');
    
    
    ylim([0 max(beh.inhFx.values.nTrials)*yscale])
    set(gca, 'SortMethod', 'depth')
    ylabel('# STOP trials')
end

%% Reaction times
axes(h_rt)
addPlotZoom();
plot(beh.reactionTimes.binEdges(2:end)-1,cumsum(beh.reactionTimes.GoCorrect)./sum(beh.reactionTimes.GoCorrect),'-b','LineWidth',1.5)
hold on
plot(beh.reactionTimes.binEdges(2:end)-1,cumsum(beh.reactionTimes.NonCancelled)./sum(beh.reactionTimes.NonCancelled),'--r','LineWidth',1.5)
hold off
xlim(beh.reactionTimes.xlims)
ylim([0 1.02])
xlabel('Reaction Time (ms)')
ylabel('Normalized cumulative count')
legend({'Go','NonCancelled'},'Box','off','Location','northwest')
title('Normalized Reaction Time CDF')


%% Reward duration by trial no/block num
axes(h_rwrdByTrial)
addPlotZoom();
box on
yyaxis left
blockColors = [0.7 0.7 0.7
               0.8 0.8 0.8];
blockAlpha = 0.5;
vy = beh.reward.values.rewardDuration;
yLims = [0 ceil(max(vy)/20)*20];
vy(isnan(vy))=0;
vy = movmean(vy,10);
% add block number patches to the plot 
blockStartEnds = [0;beh.reward.block.endTrialNum];
vertices = arrayfun(@(x) [...
                          blockStartEnds(x),yLims(1)   %(x1y1)
                          blockStartEnds(x+1),yLims(1) %(x2y1)
                          blockStartEnds(x+1),yLims(2)*0.9 %(x2y2)
                          blockStartEnds(x),yLims(2)*0.9],... %(x1y2)
          (1:size(blockStartEnds,1)-1)','UniformOutput',false);
nBlocks = size(vertices,1);
%odd blocks
idx = 1:2:nBlocks;
patch('Faces',reshape(1:numel(idx)*4,4,[])','Vertices',cell2mat(vertices(idx)),...
      'FaceColor',blockColors(1,:),'FaceAlpha',blockAlpha, 'EdgeColor', 'none');
%even blocks
idx = 2:2:nBlocks;
patch('Faces',reshape(1:numel(idx)*4,4,[])','Vertices',cell2mat(vertices(idx)),...
      'FaceColor',blockColors(2,:),'FaceAlpha',blockAlpha, 'EdgeColor', 'none');
hold on
% plot the line as stairs plot
stairs(beh.reward.values.TrialNumber,vy,'LineWidth',1.25)
ylabel('Moving Avg. (ms)')
ylim(yLims)
xlabel('Trial number')
xlim([0 numel(vy)])
title('Reward duration during session')
% plot mean amout per block
yyaxis right
blockStartEnds = [0;beh.reward.block.endTrialNum];
blockStartEnds = [blockStartEnds(1:end-1) blockStartEnds(2:end) nan(numel(blockStartEnds)-1,1)]';
blockCenters = nanmean(blockStartEnds)';
tempReward = beh.reward.values.rewardDuration;
tempReward(isnan(tempReward))=0;
nTrlsPerBlk = [beh.reward.block.endTrialNum(1); diff(beh.reward.block.endTrialNum)-1];
meanDurPerBlk= arrayfun(@(x) mean(tempReward(beh.reward.block.startTrialNum(x):beh.reward.block.endTrialNum(x))), beh.reward.block.blkNum);
blockMeans = [repmat(meanDurPerBlk,1,2) nan(numel(meanDurPerBlk),1)]';
plot(blockStartEnds(:),blockMeans(:),'-r','LineWidth',2);
ylabel('Block Avg. (ms)')
yLims2 = [0 ceil(max(blockMeans(:))/20)*20];
ylim(yLims)
hold off
%% Reward duration by trial no/block num (Only last n blocks)
lastNBlocks = 3;
blkStart = nBlocks-lastNBlocks+1;
axes(h_rwrdLastBlks)
addPlotZoom();
box on
yyaxis left

if mod(blkStart,2) == 1
%odd blocks
idx = blkStart:2:nBlocks;
patch('Faces',reshape(1:numel(idx)*4,4,[])','Vertices',cell2mat(vertices(idx)),...
      'FaceColor',blockColors(1,:),'FaceAlpha',blockAlpha, 'EdgeColor', 'none');
idx = blkStart+1:2:nBlocks;
patch('Faces',reshape(1:numel(idx)*4,4,[])','Vertices',cell2mat(vertices(idx)),...
      'FaceColor',blockColors(2,:),'FaceAlpha',blockAlpha, 'EdgeColor', 'none');
else
%even blocks
idx = blkStart:2:nBlocks;
patch('Faces',reshape(1:numel(idx)*4,4,[])','Vertices',cell2mat(vertices(idx)),...
      'FaceColor',blockColors(2,:),'FaceAlpha',blockAlpha, 'EdgeColor', 'none');
%even blocks
idx = blkStart:2:nBlocks;
patch('Faces',reshape(1:numel(idx)*4,4,[])','Vertices',cell2mat(vertices(idx)),...
      'FaceColor',blockColors(1,:),'FaceAlpha',blockAlpha, 'EdgeColor', 'none');
end
hold on
% plot the line as stairs plot
lastNBlockTrlIdx = beh.reward.values.BlockNum >= (nBlocks - lastNBlocks);
stairs(beh.reward.values.TrialNumber(lastNBlockTrlIdx),vy(lastNBlockTrlIdx),'LineWidth',1.25)
ylabel('Moving Avg. (ms)')
ylim(yLims)
xlabel('Trial number')
xlim([0 numel(vy)])
title(sprintf('Reward duration - last [%d] blocks',lastNBlocks))
% plot mean amounts per block
yyaxis right
xVec = blockStartEnds(:,blkStart:end);
yVec = blockMeans(:,blkStart:end);
plot(xVec(:),yVec(:),'-r','LineWidth',2);
xlim([min(xVec(:)) max(xVec(:))])
ylabel('Block Avg. (ms)')
ylim(yLims)
grid on
text(blockCenters(blkStart:end),repmat(max(ylim)*0.9,lastNBlocks,1),...
    arrayfun(@(x) num2str(x,'#%d'),blkStart:nBlocks,'UniformOutput',false),...
    'HorizontalAlignment','center','FontWeight','bold');


%% Cumulative Reward duration (CRD) by session time by block 
% The cumulative reward duration is reset when new block starts
axes(h_cumlRwrdBlk)
addPlotZoom();
box on
% add block number patches to the plot 
yLims = [0 ceil(max(beh.reward.values.cumulBlockRwrdDuration)/50)*50];
blockStartEnds = [0;beh.reward.values.sessionTime(beh.reward.block.endTrialNum)];
xLims = [0 max(blockStartEnds)];
vertices = arrayfun(@(x) [...
                          blockStartEnds(x),yLims(1)   %(x1y1)
                          blockStartEnds(x+1),yLims(1) %(x2y1)
                          blockStartEnds(x+1),yLims(2)*0.9 %(x2y2)
                          blockStartEnds(x),yLims(2)*0.9],... %(x1y2)
          (1:size(blockStartEnds,1)-1)','UniformOutput',false);
nBlocks = size(vertices,1);
%odd blocks
idx = 1:2:nBlocks;
patch('Faces',reshape(1:numel(idx)*4,4,[])','Vertices',cell2mat(vertices(idx)),...
      'FaceColor',blockColors(1,:),'FaceAlpha',blockAlpha,...
      'EdgeColor', blockColors(1,:),'LineWidth', 0.5);
%even blocks
idx = 2:2:nBlocks;
patch('Faces',reshape(1:numel(idx)*4,4,[])','Vertices',cell2mat(vertices(idx)),...
      'FaceColor',blockColors(2,:),'FaceAlpha',blockAlpha,...
      'EdgeColor', blockColors(1,:),'LineWidth', 0.5);
ylabel('Cumul. (ms)')
ylim(yLims)
xlabel('Session time (s)')
xlim(xLims)
hold on
% Compute vertices for all outcomes
blockStartEnds = [0;beh.reward.values.sessionTime];
vy = [0;beh.reward.values.cumulBlockRwrdDuration];
vy1 = vy(1:end-1);
vy2 = vy(2:end);
% when new block starts reset to zero
vy1(beh.reward.block.startTrialNum) = 0;

vertices = arrayfun(@(x) [...
                          blockStartEnds(x),vy1(x)   %(x1y1)
                          blockStartEnds(x+1),vy1(x) %(x2y1)
                          blockStartEnds(x+1),vy2(x) %(x2y2)
                          blockStartEnds(x),vy2(x)],... %(x1y2)
          (1:size(blockStartEnds,1)-1)','UniformOutput',false);
% draw patches for each outcome
patchLabels = {'Go';'Cancelled';'NonCancelled';'Timeout/Error'};
%patchColors = {[1.0 1.0 0.0];[0.0 0.0 1.0];[1.0 0.0 0.0];[0.5 0.5 0.5]};
patchColors = {myColors.yellow;myColors.cyan;myColors.red;myColors.gray_5};

% go patches
h=[];
idx = find(beh.reward.values.Go==1);
h(1) = patch('Faces',reshape(1:numel(idx)*4,4,[])','Vertices',cell2mat(vertices(idx)),...
      'FaceColor',patchColors{1},'EdgeColor',patchColors{1});
% cancelled patches
idx = find(beh.reward.values.Cancelled==1);
h(2) = patch('Faces',reshape(1:numel(idx)*4,4,[])','Vertices',cell2mat(vertices(idx)),...
      'FaceColor',patchColors{2},'EdgeColor',patchColors{2});
% non-cancelled patches
idx = find(beh.reward.values.NonCancelled==1);
h(3) = patch('Faces',reshape(1:numel(idx)*4,4,[])','Vertices',cell2mat(vertices(idx)),...
      'FaceColor',patchColors{3},'EdgeColor',patchColors{3},'LineWidth',2);
% timeout-error patches
idx = find(beh.reward.values.ErrorOrTimeout==1);
h(4) = patch('Faces',reshape(1:numel(idx)*4,4,[])','Vertices',cell2mat(vertices(idx)),...
      'FaceColor',patchColors{4},'EdgeColor', patchColors{4},'LineWidth',2);
  
title('Cumulative reward duration for trials in block')
l=legend(h,patchLabels','Location','North','Orientation','Horizontal','box','off');
%set(l,'Position',[0.91 0.30 0.054 0.054])

end

%% Add plot zoom
function addPlotZoom()
    thisPlot.pos = get(gca,'Position');
    thisPlot.zoom = 0;
    set(gca,'UserData',thisPlot);
    set(gca,'ButtonDownFcn',@plotZoom);
end

function [myColors, histColors] =getColors()
    myColors = struct();

    myColors.blue =[0,0,1];
    myColors.black = [0,0,0];
    myColors.red = [1,0,0];
    myColors.green = [0,1,0];
    myColors.yellow = [1,1,0];
    myColors.cyan = [0,1,1];
    myColors.magenta = [1,0,1];
    myColors.white = [1,1,1];
    myColors.gray_5 = [0.5,0.5,0.5];
    
    % default colors for stacked histogram
    histColors = {...
        [0     0.447 0.741]
        [0.929 0.694 0.125]
        [0.466 0.674 0.188]
        [0.635 0.078 0.184]
        [0.85  0.325 0.098]
        [0.494 0.184 0.556]
        [0.85  0.325 0.098]
        [0.494 0.184 0.556]
        [0.301 0.745 0.933]
        [0     0.447 0.741]
        [0.929 0.694 0.125]
        [0.466 0.674 0.188]...
        };
    

    
    
end