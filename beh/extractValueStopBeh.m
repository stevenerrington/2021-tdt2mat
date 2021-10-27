function [valueStopSignalBeh, valueRTdist] = extractValueStopBeh(stateFlags,Infos,ttx)

% Parameters
monitorRefresh = 1000/60;
rewardLabels = {'lo','hi'};

for rewardIdx = 1:length(rewardLabels)
    rewardLabel = rewardLabels{rewardIdx};
    
    % RT distribution
    valueRTdist.(rewardLabel).all = Infos.Decide_ - Infos.Target_;
    valueRTdist.(rewardLabel).nostop = cumulDist(valueRTdist.(rewardLabel).all(ttx.nostop.all.(rewardLabel)));
    valueRTdist.(rewardLabel).noncanc = cumulDist(valueRTdist.(rewardLabel).all(ttx.noncanceled.all.(rewardLabel)));
    
    % Stop-signal delay
    inh_SSD = unique(stateFlags.UseSsdVrCount);
    ssdVRvalues = inh_SSD(~isnan(inh_SSD));
    inh_SSD = round(ssdVRvalues*monitorRefresh);
    
    clear inh_nTr inh_pnc
    for ssdIdx = 1:length(inh_SSD)
        clear stopTrialIdx
        stopTrialIdx = find(stateFlags.UseSsdVrCount == ssdVRvalues(ssdIdx));
        
        valueStopSignalBeh.ssd_ttx.NC.(rewardLabel){ssdIdx} =...
            stopTrialIdx(ismember(stopTrialIdx, ttx.noncanceled.all.(rewardLabel)));
        valueStopSignalBeh.ssd_ttx.C.(rewardLabel){ssdIdx} =...
            stopTrialIdx(ismember(stopTrialIdx, ttx.canceled.all.(rewardLabel)));
        
        clear n_NC n_C
        n_NC = length(valueStopSignalBeh.ssd_ttx.NC.(rewardLabel){ssdIdx});
        n_C  = length(valueStopSignalBeh.ssd_ttx.C.(rewardLabel){ssdIdx});
        
        inh_nTr(ssdIdx) = n_NC+n_C;
        inh_pnc(ssdIdx) = n_NC/(inh_nTr(ssdIdx));
    end
    
    valueStopSignalBeh.inh_SSD.(rewardLabel) = inh_SSD;
    valueStopSignalBeh.inh_pnc.(rewardLabel) = inh_pnc;
    valueStopSignalBeh.inh_nTr.(rewardLabel) = inh_nTr;
    
    [valueStopSignalBeh.inh_weibull.(rewardLabel).parameters,~,...
        valueStopSignalBeh.inh_weibull.(rewardLabel).x,...
        valueStopSignalBeh.inh_weibull.(rewardLabel).y] =...
        fitWeibull(valueStopSignalBeh.inh_SSD.(rewardLabel),...
        valueStopSignalBeh.inh_pnc.(rewardLabel),...
        valueStopSignalBeh.inh_nTr.(rewardLabel));
    
    valueStopSignalBeh.ssrt.(rewardLabel) = cmand_SSRT(valueStopSignalBeh.inh_SSD.(rewardLabel),...
        valueStopSignalBeh.inh_pnc.(rewardLabel),valueStopSignalBeh.inh_nTr.(rewardLabel),...
        valueRTdist.(rewardLabel).nostop(:,1),...
        valueStopSignalBeh.inh_weibull.(rewardLabel).parameters);
end
end

