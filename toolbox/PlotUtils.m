classdef PlotUtils
    %PLOTUTILS Non-stateful plotting utilities
    %   All methods are static. Computation state/results are not stored.
    %   All method calls will have to use classname prefix
    %   Plotting is done into the current axes. 
    
    methods (Static, Access=public)
        %%%%%%%%% Plotting %%%%%%%%%%
        function plotPsth(psthVec,psthBins,varargin)
            %  psthVec: A vector of [1 x nTimeBins ] of firing rates
            %  psthBins: A vector of [1 x nTimeBins ] of time in ms
            %  varargin:
            %      1: scalar for Y-axis firing rate scale            
            plot(psthBins, psthVec,'LineWidth',2);
            xlim([min(psthBins) max(psthBins)])
            if ~isempty(varargin)
                ylim([0 varargin{1}]);
            end
            line([0 0],get(gca,'Ylim'))
        end
        
        function plotRasters(rastersLogical, rasterBins)
            PlotUtils.doRastersAndBursts_(rastersLogical, rasterBins);
        end
        
        function plotBursts(bobTimes, eobTimes, rasterBins)
            PlotUtils.doRastersAndBursts_([], rasterBins, bobTimes, eobTimes);
        end
        
        function plotRastersAndBursts(rastersLogical, rasterBins, bobTimes, eobTimes)
            PlotUtils.doRastersAndBursts_(rastersLogical, rasterBins, bobTimes, eobTimes);
        end
                
    end
    
    methods (Static, Access=private)
        
        function doRastersAndBursts_(rastersLogical, rasterBins, varargin)
            % rastersLogical: Logical matrix [nTrials x mBins].
            %       For a given bin, no spike = 0, spike = 1,
            %     rasterBins: Vector of [1 x mBins]. Raster bin times in ms
            %
            fillRatio = 0.8; % How much of the plot to fill
            tickHeightFrac = 0.9;
            vertHeight_fx = @(nTrials) (fillRatio*max(get(gca,'YLim')))/nTrials;
            
            % Plot Rasters
            if ~isempty(rastersLogical)
                nTrials = size(rastersLogical, 1);
                % Verical offset for each trial
                vertHeight = vertHeight_fx(nTrials);
                % use 90 % for vertical height for tick
                tickHeight = tickHeightFrac*vertHeight;
                % Find the trial (yPoints) and timebin (xPoints) of each spike
                [trialNos,timebins] = find(rastersLogical);
                trialNos = trialNos';
                trialNos = trialNos.*vertHeight;
                timebins = timebins';
                x = [ rasterBins(timebins);rasterBins(timebins);NaN(size(timebins)) ];
                y = [ trialNos - tickHeight/2;trialNos + tickHeight/2;NaN(size(trialNos)) ];
                plot(x(:),y(:),'k','color',[0.2 0.2 0.2]);
                xlim([min(rasterBins) max(rasterBins)])
            end
            % Plot bursts
            % If varargs then plot bursts
            if length(varargin) >= 2
                bobT = varargin{1};
                eobT = varargin{2};
                nTrials = size(bobT,1);
                PlotUtils.doBursts_(bobT,eobT,rasterBins,vertHeight_fx(nTrials));
            end
            
        end
        
        function doBursts_(bobTimes, eobTimes, rasterBins, varargin)
            %  bobTimes: Cell array of {nTrials x 1}
            %  eobTimes: Cell array of {nTrials x 1}
            %  Note: Each cell has [1 x nBurst_times]
            %  varargin:
            %        vertHeight for each trial
            vertHeight = 1;
            if ~isempty(varargin)
                vertHeight = varargin{1};
            end
            
            x = [ cell2mat(vertcat(bobTimes)');
                cell2mat(vertcat(eobTimes)');
                NaN(size(cell2mat(vertcat(bobTimes)'))) ];
            
            trialNos = arrayfun(@(t) ones(1,numel(bobTimes{t})).*t,1:size(bobTimes,1),'UniformOutput',false);
            trialNos = cell2mat(vertcat(trialNos));
            trialNos = (trialNos.*vertHeight)-0.4*vertHeight;
            y = [ trialNos;trialNos;NaN(size(trialNos)) ];
            plot(x(:),y(:),'k','color',[0.9 0.0 0.0 0.4]);
            alpha(0.5)
            xlim([min(rasterBins) max(rasterBins)])
        end
        
    end
    
end

