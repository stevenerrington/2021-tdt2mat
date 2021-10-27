function [ttm] = processTrialMatching(stopSignalBeh, ttx, trialEventTimes)
SSRT = stopSignalBeh.ssrt.integrationWeighted;
goIdx = ttx.nostop.all.all;

for ssdIdx = 1:length(stopSignalBeh.inh_SSD)
    SSD = stopSignalBeh.inh_SSD(ssdIdx);
    
    [ttm.NC.GO{ssdIdx}, ~] = latencyMatchIndexer(goIdx, SSD, SSRT, 'NC', trialEventTimes);
    ttm.NC.NC{ssdIdx} = stopSignalBeh.ssd_ttx.NC{ssdIdx};
    
    [ttm.C.GO{ssdIdx}, ~] = latencyMatchIndexer(goIdx, SSD, SSRT, 'C', trialEventTimes);
    ttm.C.C{ssdIdx} = stopSignalBeh.ssd_ttx.C{ssdIdx};

end
