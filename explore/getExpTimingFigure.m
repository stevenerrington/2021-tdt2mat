function figureName = getExpTimingFigure(stateFlags,Infos,outFilename)
figureName = figure('Renderer', 'painters', 'Position', [100 100 800 800]);
subplot(2,2,1)
histogram(stateFlags.UseSsdVrCount-stateFlags.SsdVrCount)
xlabel('Vertical refresh difference'); ylabel('Frequency')
title(outFilename)
subplot(2,2,2)
histogram((Infos.PdTriggerRight_-Infos.Target_)-(stateFlags.UseSsdVrCount*(1000/60)))
xlim([-32 32])
xlabel('Stop Signal Photodiode x VR Count Difference (ms)');

subplot(2,2,3)
histogram(Infos.PdTriggerRight_-Infos.StopSignal_)
xlim([-32 32])
xlabel('Stop Signal Photodiode x Event Code Difference (ms)'); ylabel('Frequency')

subplot(2,2,4)
histogram(Infos.PdTriggerLeft_-Infos.FixSpotOn_)
xlim([-32 32])
xlabel('Fix Spot On Photodiode x Event Code Difference (ms)');
end

