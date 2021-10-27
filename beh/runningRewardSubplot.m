function runningRewardSubplot(stateFlags,Infos)


beh.reward.varNames = {'TrialType','TrialNumber','BlockNum', 'IsLoRwrd','JuiceStart_','JuiceEnd_','rewardDuration'};
beh.reward.values = array2table(...
    [stateFlags.TrialType stateFlags.TrialNumber stateFlags.BlockNum stateFlags.IsLoRwrd ...
    Infos.JuiceStart_ Infos.JuiceEnd_ Infos.JuiceEnd_-Infos.JuiceStart_],...
    'VariableNames', beh.reward.varNames);
temp =[Infos.InfosStart_;Infos.InfosEnd_(end)]-Infos.InfosStart_(1);
beh.reward.values.sessionTime=temp(2:end)./1000;
% Tag with outcomes
beh.reward.values.Go = stateFlags.IsGoCorrect==1;
beh.reward.values.Cancelled = stateFlags.IsCancelledNoBrk==1;
beh.reward.values.NonCancelled = stateFlags.IsNonCancelledNoBrk==1;
beh.reward.values.ErrorOrTimeout = (stateFlags.IsGoErr==1 | stateFlags.IsNogoErr==1 | ...
    stateFlags.IsCancelledBrk==1 | stateFlags.IsNonCancelledBrk==1 | ...
    ~isnan(Infos.AcquireFixError_) | ~isnan(Infos.FixBreak_));
% Add block start and block end trial numbers
beh.reward.values.BlockStart = diff([0;beh.reward.values.BlockNum]);
beh.reward.values.BlockEnd = diff([beh.reward.values.BlockNum;0]);
% Cumulative reward duration by block
blkStartEndVals = [find(beh.reward.values.BlockStart) find(beh.reward.values.BlockEnd)];
% add trial nos for block start and end
beh.reward.block=array2table([(1:size(blkStartEndVals,1))' blkStartEndVals],'VariableNames',{'blkNum','startTrialNum','endTrialNum'});
% cumul reward duration by block
temp = beh.reward.values.rewardDuration;
temp(isnan(temp))=0;
beh.reward.values.cumulRwrdDuration = cumsum(temp);
beh.reward.values.cumulBlockRwrdDuration = cell2mat(arrayfun(@(x,y) cumsum(temp(x:y)),blkStartEndVals(:,1),blkStartEndVals(:,2),'UniformOutput',false));

yyaxis left
blockColors = [0.7 0.7 0.7
    0.8 0.8 0.8];
blockAlpha = 0.5;
vy = beh.reward.values.rewardDuration;
yLims = [0 max(vy)];
vy(isnan(vy))=0;
vy = movmean(vy,10);
% add block number patches to the plot
blockStartEnds = [0;beh.reward.block.endTrialNum];
vertices = arrayfun(@(x) [...
    blockStartEnds(x),yLims(1)   %(x1y1)
    blockStartEnds(x+1),yLims(1) %(x2y1)
    blockStartEnds(x+1),yLims(2) %(x2y2)
    blockStartEnds(x),yLims(2)],... %(x1y2)
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
ylim(yLims)
hold off



end
