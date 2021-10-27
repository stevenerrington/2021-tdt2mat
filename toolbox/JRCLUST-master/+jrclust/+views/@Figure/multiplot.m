function [plotKey, YOffsets] = multiplot(obj, plotKey, scale, XData, YData, YOffsets, doScatter)
    % Create (nargin > 2) or rescale (nargin <= 2) a multi-line plot
    % TODO: separate these (presumably multiple plots are passed in somewhere)
    if nargin <= 2 % rescale
        obj.rescalePlot(plotKey, scale);
        % handle_fun_(@rescale_plot_, plotKey, scale);
        YOffsets = [];
        return;
    end

    if nargin < 7
        doScatter = 0;
    end

    if isa(YData, 'gpuArray')
        YData = gather(YData);
    end
    if isa(YData, 'int16')
        YData = single(YData);
    end

    if nargin < 6
        YOffsets = 1:size(YData, 2);
    end

    [plotKey, YOffsets] = doMultiplot(obj, plotKey, scale, XData, YData, YOffsets, doScatter);
end

%% LOCAL FUNCTIONS
function [plotKey, YOffsets] = doMultiplot(hFig, plotKey, scale, XData, YData, YOffsets, doScatter)
    %DOMULTIPLOT Create a multi-line plot
    shape = size(YData); % nSamples x nSites x (nSpikes)
    userData = struct('scale', scale, ...
                      'shape', shape, ...
                      'yOffsets', YOffsets, ...
                      'fScatter', doScatter);

    if doScatter % only for points that are not connected
        XData = XData(:);
        YData = YData(:)/scale + YOffsets(:);        
    elseif ismatrix(YData)
        if isempty(XData)
            XData = (1:shape(1))';
        end

        if isvector(XData)
            XData = repmat(XData(:), [1, shape(2)]);
        end

        if size(XData,1) > 2
            XData(end, :) = nan;
        end

        YData = bsxfun(@plus, YData/scale, YOffsets(:)');
    else % 3D array
        if isempty(XData)
            XData = bsxfun(@plus, (1:shape(1))', shape(1)*(0:shape(3)-1)); 
        elseif isvector(XData)
            XData = repmat(XData(:), [1, shape(3)]);
        end

        if size(XData, 1) > 2
            XData(end, :) = nan;
        end

        if isvector(YOffsets)
            YOffsets = repmat(YOffsets(:), [1, shape(3)]);
        end

        XData = permute(repmat(XData, [1, 1, shape(2)]), [1,3,2]);       
        YData = YData / scale;

        for iSpike = 1:shape(3)
            YData(:, :, iSpike) = bsxfun(@plus, YData(:, :, iSpike), YOffsets(:, iSpike)');
        end        
    end

    if ~hFig.hasPlot(plotKey)
        hFig.addPlot(plotKey, @line, XData(:), YData(:), 'UserData', userData);
    else
        hFig.updatePlot(plotKey, XData(:), YData(:), userData);
    end
end