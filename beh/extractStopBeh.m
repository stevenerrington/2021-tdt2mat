function [stopSignalBeh, RTdist] = extractStopBeh(stateFlags,Infos,ttx)

% Parameters
monitorRefresh = 1000/60;

% RT distribution
RTdist.all = Infos.Decide_ - Infos.Target_;
RTdist.nostop = cumulDist(RTdist.all(ttx.nostop.all.all));
RTdist.noncanc = cumulDist(RTdist.all(ttx.noncanceled.all.all));

% Stop-signal delay 
inh_SSD = unique(stateFlags.UseSsdVrCount);
ssdVRvalues = inh_SSD(~isnan(inh_SSD));
inh_SSD = round(ssdVRvalues*monitorRefresh);

for ssdIdx = 1:length(inh_SSD)
    clear stopTrialIdx
    stopTrialIdx = find(stateFlags.UseSsdVrCount == ssdVRvalues(ssdIdx));
    
    stopSignalBeh.ssd_ttx.NC{ssdIdx} =...
        stopTrialIdx(ismember(stopTrialIdx, ttx.noncanceled.all.all));
    stopSignalBeh.ssd_ttx.C{ssdIdx} =...
        stopTrialIdx(ismember(stopTrialIdx, ttx.canceled.all.all));    
    
    n_NC = length(stopSignalBeh.ssd_ttx.NC{ssdIdx});
    n_C  = length(stopSignalBeh.ssd_ttx.C{ssdIdx});
    
    inh_nTr(ssdIdx) = n_NC+n_C;
    inh_pnc(ssdIdx) = n_NC/(inh_nTr(ssdIdx));

end

stopSignalBeh.inh_SSD = inh_SSD;
stopSignalBeh.inh_pnc = inh_pnc;
stopSignalBeh.inh_nTr = inh_nTr;

[stopSignalBeh.inh_weibull.parameters,~,...
    stopSignalBeh.inh_weibull.x,...
    stopSignalBeh.inh_weibull.y] =...
    fitWeibull(stopSignalBeh.inh_SSD, stopSignalBeh.inh_pnc, stopSignalBeh.inh_nTr);

stopSignalBeh.ssrt = cmand_SSRT(stopSignalBeh.inh_SSD,...
    stopSignalBeh.inh_pnc,stopSignalBeh.inh_nTr,...
    RTdist.nostop(:,1),...
    stopSignalBeh.inh_weibull.parameters);

% [stopDataBEESTS] = cmand_BEESTpreprocess(stateFlags,Infos)

end
