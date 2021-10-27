

parfor ii = 1:length(sessionList)
    
    % Load session data
    data = parload([dataDir '\' sessionList{ii}]);
    
    % Get session behavior
    fprintf(['Analysing session: ' sessionList{ii} '\n'])
    [ttx, ttx_history, trialEventTimes] = processSessionTrials...
        (data.Behavior.stateFlags_, data.Behavior.Infos_);
    [ttm] = processTrialMatching(data.Behavior.Stopping, ttx, trialEventTimes);
    
    % Align the LFPs from the session
    % Depth x time x trial
    tdtLFP = alignLFP(trialEventTimes, data.LFP, timeWin);
    
    channelNames = fieldnames(tdtLFP.data);
    
    for channelIdx = 1:32 % For each contact within the cortex
        channel = channelNames{channelIdx};
        fprintf(['Transforming LFP for CSD analysis on channel ' channel '... \n'])
        
        gammapower(channelIdx,ii) = bandpower(nanmean(tdtLFP.aligned.(channel).(alignName)(:,[900:1200])),1000,[40 80]);
        alphapower(channelIdx,ii) = bandpower(nanmean(tdtLFP.aligned.(channel).(alignName)(:,[900:1200])),1000,[9 29]);
    end
    
end


channelList = [1:32];

figure;
for ii = 1:length(sessionList)
    subplot(2,3,ii)
    plot(gammapower(:,ii)./max(gammapower(:,ii)), channelList,'b')
    hold on
    plot(alphapower(:,ii)./max(alphapower(:,ii)), channelList,'r')
    
    meanGamma(:,ii) = gammapower(:,ii)./max(gammapower(:,ii));
    meanAlpha(:,ii) = alphapower(:,ii)./max(alphapower(:,ii));
    set(gca,'ydir','reverse')
    ylim([1 20])
end

figure;
plot(mean(meanGamma,2), channelList,'b')
hold on
plot(mean(meanAlpha,2), channelList,'r')
set(gca,'ydir','reverse')

