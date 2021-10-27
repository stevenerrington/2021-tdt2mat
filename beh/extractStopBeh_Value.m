function [stopSignalBeh, RTdist] = extractStopBeh(stateFlags,Infos,ttx)
% Parameters
monitorRefresh = 1000/60;


%% Standard analysis
% RT distribution
RTdist.all = Infos.Decide_ - Infos.Target_;
RTdist.nostop = cumulDist(RTdist.all(ttx.nostop.all.all));
RTdist.noncanc = cumulDist(RTdist.all(ttx.noncanceled.all.all));

% Stop-signal delay 
inh_SSD = unique(stateFlags.UseSsdVrCount);
inh_SSD = round(inh_SSD(~isnan(inh_SSD))*monitorRefresh);

for ssdIdx = 1:length(inh_SSD)
    clear stopTrialIdx
    stopTrialIdx = find(ssdIdx == stateFlags.UseSsdIdx+1);
    
    stopSignalBeh.all.ssd_ttx.NC{ssdIdx} =...
        stopTrialIdx(ismember(stopTrialIdx, ttx.noncanceled.all.all));
    stopSignalBeh.all.ssd_ttx.C{ssdIdx} =...
        stopTrialIdx(ismember(stopTrialIdx, ttx.canceled.all.all));    
    
    n_NC = length(stopSignalBeh.all.ssd_ttx.NC{ssdIdx});
    n_C  = length(stopSignalBeh.all.ssd_ttx.C{ssdIdx});
    
    inh_nTr(ssdIdx) = n_NC+n_C;
    inh_pnc(ssdIdx) = n_NC/(inh_nTr(ssdIdx));

end

stopSignalBeh.all.inh_SSD = inh_SSD;
stopSignalBeh.all.inh_pnc = inh_pnc;
stopSignalBeh.all.inh_nTr = inh_nTr;

[stopSignalBeh.all.inh_weibull.parameters,~,...
    stopSignalBeh.all.inh_weibull.x,...
    stopSignalBeh.all.inh_weibull.y] =...
    fitWeibull(stopSignalBeh.all.inh_SSD, stopSignalBeh.all.inh_pnc, stopSignalBeh.all.inh_nTr);

stopSignalBeh.all.ssrt = cmand_SSRT(stopSignalBeh.all.inh_SSD,...
    stopSignalBeh.all.inh_pnc,stopSignalBeh.all.inh_nTr,...
    RTdist.nostop(:,1),...
    stopSignalBeh.all.inh_weibull.parameters);

% [stopDataBEESTS] = cmand_BEESTpreprocess(stateFlags,Infos)

%% Value based analysis
% RT distribution
valuestopSignalBeh.all.RTdist.all = Infos.Decide_ - Infos.Target_;
valuestopSignalBeh.all.RTdist.nostop.hi = cumulDist(RTdist.all(ttx.nostop.all.hi));
valuestopSignalBeh.all.RTdist.nostop.lo = cumulDist(RTdist.all(ttx.nostop.all.lo));
valuestopSignalBeh.all.RTdist.noncanc.hi = cumulDist(RTdist.all(ttx.noncanceled.all.hi));
valuestopSignalBeh.all.RTdist.noncanc.lo = cumulDist(RTdist.all(ttx.noncanceled.all.lo));


inh_nTr = []; inh_pnc = []; n_NC = []; n_C = [];
for ssdIdx = 1:length(inh_SSD)
    clear stopTrialIdx
    stopTrialIdx = find(ssdIdx == stateFlags.UseSsdIdx+1 & stateFlags.IsHiRwrd == 1);
    
    valuestopSignalBeh.all.ssd_ttx.NC.hi{ssdIdx} =...
        stopTrialIdx(ismember(stopTrialIdx, ttx.noncanceled.all.hi));
    valuestopSignalBeh.all.ssd_ttx.NC.lo{ssdIdx} =...
        stopTrialIdx(ismember(stopTrialIdx, ttx.noncanceled.all.lo));

    valuestopSignalBeh.all.ssd_ttx.C.hi{ssdIdx} =...
        stopTrialIdx(ismember(stopTrialIdx, ttx.canceled.all.hi));        
    valuestopSignalBeh.all.ssd_ttx.C.lo{ssdIdx} =...
        stopTrialIdx(ismember(stopTrialIdx, ttx.canceled.all.lo));    
    
    n_NC.hi = length(valuestopSignalBeh.all.ssd_ttx.NC.hi{ssdIdx});
    n_C.hi  = length(valuestopSignalBeh.all.ssd_ttx.C.hi{ssdIdx});
    n_NC.lo = length(valuestopSignalBeh.all.ssd_ttx.NC.lo{ssdIdx});
    n_C.lo  = length(valuestopSignalBeh.all.ssd_ttx.C.lo{ssdIdx});
    
    inh_nTr.hi(ssdIdx) = n_NC.hi+n_C.hi;
    inh_pnc.hi(ssdIdx) = n_NC.hi/(inh_nTr.hi(ssdIdx));
    inh_nTr.lo(ssdIdx) = n_NC.lo+n_C.lo;
    inh_pnc.lo(ssdIdx) = n_NC.lo/(inh_nTr.lo(ssdIdx));
end


valuestopSignalBeh.all.inh_SSD = inh_SSD;
valuestopSignalBeh.all.inh_pnc = inh_pnc;
valuestopSignalBeh.all.inh_nTr = inh_nTr;

[valuestopSignalBeh.all.inh_weibull.parameters,~,...
    valuestopSignalBeh.all.inh_weibull.x,...
    valuestopSignalBeh.all.inh_weibull.y] =...
    fitWeibull(valuestopSignalBeh.all.inh_SSD, valuestopSignalBeh.all.inh_pnc, valuestopSignalBeh.all.inh_nTr);

valuestopSignalBeh.all.ssrt.hi = cmand_SSRT(valuestopSignalBeh.all.inh_SSD,...
    valuestopSignalBeh.all.inh_pnc,valuestopSignalBeh.all.inh_nTr,...
    valuestopSignalBeh.all.RTdist.nostop(:,1),...
    valuestopSignalBeh.all.inh_weibull.parameters);








end
