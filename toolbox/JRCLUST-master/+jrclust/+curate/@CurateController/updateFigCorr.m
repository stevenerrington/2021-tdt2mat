function updateFigCorr(obj)
    %UPDATEFIGCORR Plot cross correlation
    if isempty(obj.selected) || ~obj.hasFig('FigCorr')
        return;
    end

    plotFigCorr(obj.hFigs('FigCorr'), obj.hClust, obj.hCfg, obj.selected);
end

%% LOCAL FUNCTIONS
function hFigCorr = plotFigCorr(hFigCorr, hClust, hCfg, selected)
    %DOPLOTFIGCORR Plot timestep cross correlation
    if numel(selected) == 1
        iCluster = selected(1);
        jCluster = iCluster;
    else
        iCluster = selected(1);
        jCluster = selected(2);
    end

    jitterMs = 0.5; % bin size for correlation plot
    nLagsMs = 25; % show 25 msec

    jitterSamp = round(jitterMs*hCfg.sampleRate/1000); % 0.5 ms
    nLags = round(nLagsMs/jitterMs);

    iTimes = int32(double(hClust.spikeTimes(hClust.spikesByCluster{iCluster}))/jitterSamp);

    if iCluster ~= jCluster
        iTimes = [iTimes, iTimes - 1, iTimes + 1]; % check for off-by-one
    end
    jTimes = int32(double(hClust.spikeTimes(hClust.spikesByCluster{jCluster}))/jitterSamp);

    % count agreements of jTimes + lag with iTimes
    lagSamp = -nLags:nLags;
    intCount = zeros(size(lagSamp));
    for iLag = 1:numel(lagSamp)
        if iCluster == jCluster && lagSamp(iLag)==0
            continue;
        end
        intCount(iLag) = numel(intersect(iTimes, jTimes + lagSamp(iLag)));
    end

    lagTime = lagSamp*jitterMs;

    % draw the plot
    if ~hFigCorr.hasAxes('default')
        hFigCorr.addAxes('default');
        hFigCorr.addPlot('hBar', @bar, lagTime, intCount, 1);
        hFigCorr.axApply('default', @xlabel, 'Time (ms)');
        hFigCorr.axApply('default', @ylabel, 'Counts');
        hFigCorr.axApply('default', @grid, 'on');
        hFigCorr.axApply('default', @set, 'YScale', 'log');
    else
        hFigCorr.updatePlot('hBar', lagTime, intCount);
    end

    if iCluster ~= jCluster
        hFigCorr.axApply('default', @title, sprintf('Unit %d vs. Unit %d', iCluster, jCluster));
    else
        hFigCorr.axApply('default', @title, sprintf('Unit %d', iCluster));
    end
    hFigCorr.axApply('default', @set, 'XLim', jitterMs*[-nLags, nLags]);
end
