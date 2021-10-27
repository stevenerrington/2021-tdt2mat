function [allWaves, vSDF, mSDF] = viewUnits(file)

if ~exist('myDir','var'),
    myDir = 'Y:/Users/Kaleb/dataProcessed';
end

% Get number of channels for loop
chanDir = dir(sprintf('%s/%s/Channel*',myDir,file));
chanNames = {chanDir.name};
nChans = length(chanNames);
chans = nan(1,nChans);
for i = 1:nChans,
    chans(i) = str2num(chanNames{i}(8:end));
end
chans = sort(chans);

% Load task if necessary
if nChans > 0,
    load(sprintf('%s/%s/Behav.mat',myDir,file));
end

allWaves = [];
for ic = 1:nChans,
    
    % Get units on channel
    chanUnits = dir(sprintf('%s/%s/Channel%d/Unit*',myDir,file,ic));
    
    if ~isempty(chanUnits),
        for iu = 1:length(chanUnits),
            close all;
            fprintf('Plotting Channel %d, Unit %d\n',ic,iu);
            
            load(sprintf('%s/%s/Channel%d/%s/Spikes.mat',myDir,file,ic,chanUnits(iu).name));
            
            allWaves = cat(1,allWaves,nanmean(spikes.waves,1));
%             [vSDF,vTimes] = klSpkRatev2(spikes.spiketimes);
%             [mSDF,mTimes] = klSpkRatev2(spikes.spiketimes-repmat(Task.GoCue+Task.SRT,1,size(spikes.spiketimes,2)));
%             
%             figure();
%             subplot(1,2,1);
%             pltMeanStd(vTimes,nanmean(vSDF(Task.Correct==1,:),1),nanstd(vSDF(Task.Correct==1,:),[],1)./sqrt(size(vSDF(Task.Correct==1,:),1)));
%             set(gca,'XLim',[-200 500]);
%             
%             subplot(1,2,2);
%             pltMeanStd(mTimes,nanmean(mSDF(Task.Correct==1,:),1),nanstd(mSDF(Task.Correct==1,:),[],1)./sqrt(size(mSDF(Task.Correct==1,:),1)));
%             set(gca,'XLim',[-500,200]);
%             
%             keyboard
            
        end
    end
end
