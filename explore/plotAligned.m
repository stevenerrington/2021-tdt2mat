
function [out] = plotAligned(conditions, Task, alignEvent,spkTimeRaw)
timeWin = [-1000 1000];
fx_times = @(x) spkTimeRaw(spkTimeRaw >= x+timeWin(1) & spkTimeRaw< x+timeWin(2))';
condFields = fieldnames(conditions);
figure
for ii = 1:numel(condFields)
    cond = condFields{ii};
    selectedTrls = conditions.(cond);
    spkTimes = arrayfun(fx_times,Task.(alignEvent)(selectedTrls),'UniformOutput',false);
    spkTimesAligned = SpikeUtils.alignSpikeTimes(spkTimes,Task.(alignEvent)(selectedTrls));
    spkRast = SpikeUtils.rasters(spkTimesAligned,timeWin);
    spkPsth = SpikeUtils.psth(spkTimesAligned,10,timeWin);
    
    % Output
    %out.spkTimes = spkTimes;
    out.(cond).spkTimesAligned = spkTimesAligned;
    out.(cond).selectedTrls = selectedTrls;
    fns = fieldnames(spkRast);
    for fn = 1:numel(fns)
       out.(cond).(fns{fn}) = spkRast.(fns{fn});
    end
    fns = fieldnames(spkPsth);
    for fn = 1:numel(fns)
       out.(cond).(fns{fn}) = spkPsth.(fns{fn});
    end
    
    % plot it
    PlotUtils.plotPsth(spkPsth.psth,spkPsth.psthBins)
    hold on
    PlotUtils.plotRasters(spkRast.rasters,spkRast.rasterBins)
    
end
title(sprintf('Aligned on Event - %s',alignEvent),'Interpreter','none')
drawnow
end
