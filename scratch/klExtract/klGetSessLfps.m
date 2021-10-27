function klGetSessLfps(subj,date)

% recFold = [tebaMount,'/data/',subj,'/proNoElongationColor_physio/'];
% procDir = [tebaMount,'/Users/Kaleb/proNoElongationColor_physio/'];
recFold = [tebaMount,'/data/',subj,'/proNoElongationColor_Sprobe/'];
procDir = [tebaMount,'/Users/Kaleb/proNoElongationColor_Sprobe/'];
minT = -200;
maxT = 500;
pnDiscrim = [4,2,4,2,0,0];
pnIdent = [0 0 1 1 0 1];

badChans = [1,2,31,32];

doMerge = 1;
subSess = 1;

% Get sessions for this date
rawFold=dir([recFold,subj,'*',date,'*']);
if length(rawFold) > 1
    if doMerge
        fprintf('Found multiple sessions for this date...');
        sessNames = {rawFold.name};
        isMerged = cellfun(@(x) contains(x,'Merged'),sessNames);
        if ~any(isMerged)
            warning('This session has not been merged... Sorting session %s only\n');
            rawFold = rawFold(subSess);
        else
            fprintf(' Found merged folder. Sorting on merged session\n');
            rawFold = rawFold(isMerged);
        end
    else
        rawFold = rawFold(subSess);
    end
elseif isempty(rawFold)
    fprintf('No sessions found for %d on date %d\n');
    return
end

% Get sevFiles
sevFiles = dir([rawFold.folder,'/',rawFold.name,'/*Lfp1*.sev']);

% Load behav file
load([procDir,rawFold.name,'/Behav.mat']);
allMeanLFP = cell(length(sevFiles),2);
allMeanTimes = cell(length(sevFiles),1);
allLFPMat = [];
printStr = [];
fprintf('Found %d Channels...',length(sevFiles));
for ic = 1:length(sevFiles)
    fprintf(repmat('\b',1,length(printStr)));
    printStr = sprintf(' Working on Channel %d',ic);
    fprintf(printStr);
    % Load this file
    thisChan = SEV2mat_kl(fullfile(sevFiles(ic).folder),'EVENTNAME','Lfp1','CHANNEL',ic);
    [thisChanMat, chanMatT] = klPlaceStream(Task,thisChan.Lfp1.data);
    allLFPMat = cat(3,allLFPMat,thisChanMat(:,chanMatT > minT & chanMatT < maxT));
    for ii = 1:6
        allMeanLFP{ic,1}(ii,:) = nanmean(thisChanMat(Task.Correct==1 & ismember(Task.TargetLoc,[135,180,225]) & ismember(Task.TaskType,'Pro-Anti') & Task.SingletonDiff==pnDiscrim(ii) & Task.HardColor==pnIdent(ii),chanMatT > minT & chanMatT < maxT),1);
        allMeanLFP{ic,2}(ii,:) = nanmean(thisChanMat(Task.Correct==1 & ismember(Task.TargetLoc,[45,0,315]) & ismember(Task.TaskType,'Pro-Anti') & Task.SingletonDiff==pnDiscrim(ii) & Task.HardColor==pnIdent(ii),chanMatT > minT & chanMatT < maxT),1);
    end
    allMeanTimes{ic,1} = chanMatT(chanMatT > minT & chanMatT < maxT);
end
fprintf(repmat('\b',1,length(printStr)));
fprintf('Done!\n');    

% Transform allLFPMat
allLFPMat(:,:,badChans) = nan;
csdMat = diff(allLFPMat,2,3);
allMeanCSD = cell(size(csdMat,3),3);
for ic = 1:size(csdMat,3)
    allMeanCSD{ic,1} = nanmean(csdMat(Task.Correct==1 & ismember(Task.TargetLoc,[135,180,225]) & ismember(Task.TaskType,'Pro-Anti') & Task.SingletonDiff > 0,:,ic),1);
    allMeanCSD{ic,2} = nanmean(csdMat(Task.Correct==1 & ismember(Task.TargetLoc,[45,0,315]) & ismember(Task.TaskType,'Pro-Anti') & Task.SingletonDiff > 0,:,ic),1);
    allMeanCSD{ic,3} = nanmean(csdMat(Task.Correct==1 & ismember(Task.TaskType,'Pro-Anti') & Task.SingletonDiff > 0,:,ic),1);
end
csdMat=cell2mat(allMeanCSD(:,3));
for iz = 1:size(csdMat,2)
csdInterp(:,iz) = spline(1:30,csdMat(:,iz),1:.1:30);
end
ks=klGetKern('width',10,'type','gauss');
kt=klGetKern('width',10,'type','gauss');
csdSmoothSpace = conv2(csdInterp',ks,'same')';
csdSmoothTime = conv2(csdSmoothSpace,kt,'same');
smoothCSD = csdSmoothTime;
% Loop and plot all conditions
% figure();
% for ic = 1:length(sevFiles)
%     sp(1) = subplot(1,2,1); hold on;
%     plot(allMeanTimes{ic,1},allMeanLFP{ic,1}(1,:),'color','k','linewidth',3);
%     plot(allMeanTimes{ic,1},allMeanLFP{ic,1}(2,:),'color','k','linewidth',1);
%     plot(allMeanTimes{ic,1},allMeanLFP{ic,1}(3,:),'color',[.8 .2 .2],'linewidth',3);
%     plot(allMeanTimes{ic,1},allMeanLFP{ic,1}(4,:),'color',[.8 .2 .2],'linewidth',1);
%     
%     sp(2) = subplot(1,2,2); hold on;
%     plot(allMeanTimes{ic,1},allMeanLFP{ic,2}(1,:),'color','k','linewidth',3);
%     plot(allMeanTimes{ic,1},allMeanLFP{ic,2}(2,:),'color','k','linewidth',1);
%     plot(allMeanTimes{ic,1},allMeanLFP{ic,2}(3,:),'color',[.8 .2 .2],'linewidth',3);
%     plot(allMeanTimes{ic,1},allMeanLFP{ic,2}(4,:),'color',[.8 .2 .2],'linewidth',1);
%     
%     set(gca,'XLim',[minT,maxT]);
%     
%     pause;
%     clf;
% end

clear sp;
meanValsLeft = cell2mat(cellfun(@(x) nanmean(x,1),allMeanLFP(:,1),'Uni',0));
meanValsRight = cell2mat(cellfun(@(x) nanmean(x,1),allMeanLFP(:,2),'Uni',0));
meanTimes = nanmean(cell2mat(allMeanTimes));

% Rearrange channels
% preMap = [10,11,12,13,23,22,21,20,2,3,4,5,31,30,29,28,17,18,19,32,16,15,14,1,27,26,25,24,6,7,8,9];
% postMap = [25,23,32,18,30,20,28,22,26,24,15,1,13,3,11,5,9,7,16,2,14,4,12,6,10,8,27,21,29,19,31,17];
% preMap = [27,5
% meanLeftTmp = meanValsLeft(preMap,:);
% % meanLeftTmp(preMap,:) = meanLeftTmp;
% meanRightTmp = meanValsRight(preMap,:);
% % meanRightTmp(preMap,:) = meanRightTmp;
% meanValsLeft = meanLeftTmp;
% meanValsRight = meanRightTmp;

figure();
sp(1) = subplot(1,2,1); hold on;
for ic = 1:length(sevFiles)
    h(ic,1) = plot(meanTimes,meanValsLeft(ic,:)-(.02*(ic-1)),'color',[.2 .8 .8]);
    h(ic,2) = plot(meanTimes,meanValsRight(ic,:)-(.02*(ic-1)),'color',[.8 .2 .8]);
end
legend(h(ic,:),{'Ipsi','Contra'});
set(gca,'YTick',(-30:5:0).*.02,'YTickLabel',31:-5:0,'tickdir','out','ticklength',get(gca,'ticklength').*2,'YMinorTick','on','XMinorTick','on');
ylabel('Channel Number');
xlabel('Time From Array');
sp(2) = subplot(1,2,2);
csdLeft = diff(meanValsLeft,2,1);
csdRight = diff(meanValsRight,2,1);
s=surf(meanTimes,(0:-.1:-29).*.02,smoothCSD);
set(gca,'YTick',(-30:5:0).*.02,'YTickLabel',31:-5:0,'tickdir','out','ticklength',get(gca,'ticklength').*2,'YMinorTick','on','XMinorTick','on');
set(s,'edgecolor','none'); view(2);
xlabel('Time From Array (ms)');
ylabel('CSD');
colormap('jet'); %caxis([-.05, .05]);% colorbar;
linkaxes(sp,'y');

figure();
sp2(1) = subplot(1,2,1); hold on;
for ic = 1:length(sevFiles)
    h2(ic,1) = plot(meanTimes,(meanValsLeft(ic,:)-(meanValsRight(ic,:)))-(.02*(ic-1)),'color','k');
end
legend(h2(ic,1),{'Ipsi - Contra'});
set(gca,'YTick',(-30:5:0).*.02,'YTickLabel',31:-5:0,'tickdir','out','ticklength',get(gca,'ticklength').*2,'YMinorTick','on','XMinorTick','on');
ylabel('Channel Number');
xlabel('Time From Array');
sp2(2) = subplot(1,2,2); hold on;
s=surf(meanTimes,(0:-.1:-29).*.02,smoothCSD);
set(gca,'YTick',(-30:5:0).*.02,'YTickLabel',31:-5:0,'tickdir','out','ticklength',get(gca,'ticklength').*2,'YMinorTick','on','XMinorTick','on');
set(s,'edgecolor','none'); view(2);
xlabel('Time From Array (ms)');
ylabel('CSD');
colormap('jet'); %caxis([-.05, .05]);% colorbar;
linkaxes(sp2,'y');



keyboard

