classdef SpikeUtils
    %SPIKEUTILS Non-stateful spike utilities
    %   All methods are static. Computation state/results are not stored.
    %   All method calls will have to use classname prefix
    %
    
    methods (Static, Access=public)
        function outArg = jpsth(alignedSpikesX, alignedSpikesY, timeWin, binWidth, coincidenceBins)            
            nTrials = size(alignedSpikesX,1);           
            xPsth = SpikeUtils.psth(alignedSpikesX,binWidth,timeWin);
            yPsth = SpikeUtils.psth(alignedSpikesY,binWidth,timeWin);
            timeBins = timeWin(1):binWidth:timeWin(2);            
            % Cross correlation histogram for -lag:lag bins of JPSTH
            fx_xcorrh = @(jpsth,lagBins)...
                [-abs(lagBins):abs(lagBins);arrayfun(@(x) mean(diag(jpsth,x)),...
                -abs(lagBins):abs(lagBins))]';
            % Coincidence Histogram
            fx_coinh = @getCoincidence;
           
            % JPSTH Equations from Aertsen et al. 1989
            % Note bins [1,1] is top-left and [n,n] is bottom-right
            % Eq. 3
            rawJpsth = (xPsth.spikeCounts'*yPsth.spikeCounts)/nTrials;
            % Eq. 4
            predicted = xPsth.psth' * yPsth.psth;	
            % Eq. 5
            unnormalizedJpsth = rawJpsth - predicted; 
            % Eq. 7a
            normalizer = xPsth.psthStd' * yPsth.psthStd; 
            % Eq. 9
            normJpsth = unnormalizedJpsth ./ normalizer;          
            normJpsth(isnan(normJpsth)) = 0;
            % lagBins for xCorr
            xCorrHist = fx_xcorrh(normJpsth,floor(numel(timeBins)/2));
            % Coincidence Hist
            coinHist = fx_coinh(normJpsth,coincidenceBins);
            
            % Create output structure
            
            temp = SpikeUtils.rasters(alignedSpikesX,timeWin);
            outArg.rasterBins = {temp.rasterBins};
            outArg.xRasters = {temp.rasters};
            temp = SpikeUtils.rasters(alignedSpikesY,timeWin);
            outArg.yRasters = {temp.rasters};            
            outArg.xPsthBins = {xPsth.psthBins};
            outArg.xPsth = {xPsth.psth};
            outArg.xPsthStd = {xPsth.psthStd};
            outArg.yPsthBins = {yPsth.psthBins};
            outArg.yPsth = {yPsth.psth};
            outArg.yPsthStd = {yPsth.psthStd};
            outArg.normalizedJpsth = normJpsth;
            outArg.xCorrHist = xCorrHist;
            outArg.coincidenceHist = coinHist;
            outArg.xSpikeCounts = {xPsth.spikeCounts};
            outArg.ySpikeCounts = {yPsth.spikeCounts};
            outArg.rawJpsth = rawJpsth;
            % If single trial then these values are scalar
            outArg.predictedJpsth = predicted; % same as outerProduct
            if numel(predicted)==1
                outArg.predictedJpsth = {predicted};
            end            
            outArg.normalizer = normalizer;
            if numel(normalizer)==1
                outArg.normalizer = {normalizer};
            end
        end
        
        function outArg = jeromiahJpsth(alignedSpikesX, alignedSpikesY, timeWin, binWidth, coincidenceBinWidth)
            %JEROMIAHJPSTH Compute JPSTH using previous methods
            xCounts = spikeCounts(SpikeUtils.cellArray2mat(alignedSpikesX),timeWin,binWidth);
            yCounts = spikeCounts(SpikeUtils.cellArray2mat(alignedSpikesY),timeWin,binWidth);
            outArg = jpsth_jer(xCounts,yCounts,coincidenceBinWidth);
            outArg.xCounts = xCounts;
            outArg.yCounts = yCounts;
        end
        
        function outArg = alignSpikeTimes(spikes, alignTime, varargin)
            %ALIGNSPIKETIMES Returns aligned spiketime cell array.  If a
            %timeWindow [-t t] is given, trims the output to the time
            %window given
            trim = false;
            nTrials = size(spikes,1);
            if numel(varargin)>0
                trim = true;
                timeWin = varargin{1};
            end
            if numel(alignTime) == 1
                alignTime = repmat(alignTime,nTrials,1);
            elseif numel(alignTime) ~= nTrials
            end
            if ~iscell(spikes)
                spikes = SpikeUtils.mat2CellArray(spikes);
            end
            outArg = arrayfun(@(x) spikes{x}-alignTime(x), (1:nTrials)','UniformOutput',false); 
            if trim
               outArg = cellfun(@(x) x(x>=timeWin(1) & x<=timeWin(2)), outArg,'UniformOutput',false);
            end
        end
        
        function outArg = cellArray2mat(spikes)
            %CELLARRAY2MAT Convert cellarray of timestamps to nan filled
            %matrix
            if ~iscell(spikes)
                error('Input must be a cell array of spike times\n');
            end
            maxSpks = max(cellfun(@numel,spikes));
            outArg = cell2mat(cellfun(@(x) [x nan(1,maxSpks-numel(x))],spikes,'UniformOutput',false));
        end
 
        function outArg = mat2CellArray(spikes)
            %MAT2CELLARRAY Convert matrix of timestamps (0 or NaN filled)
            %filled to cell array of timestamps
            if iscell(spikes)
                error('Input must be a matrix of spike times\n');
            end
            nTrials = size(spikes,1);
            if any(isnan(spikes))
                % assume NaN filled spiketime matrix
                outArg = arrayfun(@(x) spikes(x,~isnan(spikes(x,:))), (1:nTrials)','UniformOutput',false);
            else
                if min(min(spikes)) < 0
                    error('Unable to convert to cellArray for negative spiketimes. The spike times seem to be aligned on some event.\')
                end
                % assume 0 filled spiketime matrix
                outArg = arrayfun(@(x) spikes(x,spikes(x,:)>0), (1:nTrials)','UniformOutput',false);
            end
        end
                
        function outArg = rasters(cellSpikeTimes,timeWin)
            %RASTERS Construct an instance of this class
            %   outArg is a logical array.  Bins are *delays* 1 ms apart,
            %   and rasters will contain *at most* 1 spike per bin
            minTrialIsi = cell2mat(arrayfun(@(x) min([diff(x{1}) Inf]),cellSpikeTimes,'UniformOutput',false));
            if sum(minTrialIsi<1) > 0 % No of trials where spikes occur closer than 1 millisecond
                warning('Some spikes occur within 1 millisec in [%d] trials. ...Multiple spikes occuring within 1 millisec are treated as 1.', ...
                    sum(minTrialIsi<1));
            end
            binCenters = min(timeWin) : max(timeWin);
            outArg.rasters = cell2mat(cellfun(@(x) logical(hist(x,binCenters)),...
                cellSpikeTimes,'UniformOutput',false));
            outArg.rasterBins = min(timeWin):max(timeWin);
        end
        
        function outArg = isiCvFromRasters(rasterMat)
            %ISICVFROMRASTERS compute ISI distribution and Cv (by trials)
            %   rasterMat: rows are trials, columns are binCounts [0 or 1]
            %             bins are assumed to 1ms apart
            cellSpiketimesRel = cellfun(@(x) find(x>0),num2cell(rasterMat,2),'UniformOutput',false);
            outArg = SpikeUtils.isiCv(cellSpiketimesRel);
        end
                
        function outArg = isiCv(cellSpiketimes)
            %SPIKETIMESCELLARRAY compute ISI distribution and Cv (by trials)
            %   cellSpikeTimes : Cell array of doubles. The cell array must
            %   be {nTrials x 1}. Each element in the cell array is a
            %   column vector (nTimeStamps x 1) of timestamps
            trialIsi = cellfun(@diff,cellSpiketimes,'UniformOutput',false);
            outArg.trialCv = cellfun(@(x) std(x)/mean(x),trialIsi);
            temp = cell2mat(trialIsi');
            [outArg.isiDistrib,outArg.isi] = hist(temp,0:max(temp));
        end
        
        function outArg = psth(cellSpikeTimes,binWidth,timeWin)
            %PSTH Compute PSTH, PSTH-SD, PSTH-VAR for given spike times.
            %   cellSpikeTimes : Cell array of doubles (aligned spikeTimes).  The
            %      cell array must be {nTrials x 1}. Each clement in the cell
            %      array is a column vector (nTimeStamps x 1) of timestamps
            %   binWidth: Bin width in ms for PSTH
            %   timeWin: [minTime maxTime] for PSTH
            %   fx:  Built-in function-handle to be used for PSTH. Valid
            %        args are: @nanmean, @nanstd, @nanvar
            
            binCenters = min(timeWin):binWidth:max(timeWin);
            outArg.psthBins = min(timeWin):binWidth:max(timeWin);
            outArg.spikeCounts = cell2mat(cellfun(@(x) hist(x,binCenters),...
                cellSpikeTimes,'UniformOutput',false));
            outArg.psth = mean(outArg.spikeCounts);
            outArg.psthStd = std(outArg.spikeCounts);
            outArg.psthVar = var(outArg.spikeCounts);
        end
        
        function outArg = jpsthXcorrHist(jpsth,lagBins)
            %JPSTHXCORRHIST Summary of this method goes here
            %   Detailed explanation goes here
            % Function handle for Cross correlation histogram
            %    for -lag:lag bins of JPSTH
            % fx_xcorrh = @(jpsth,lagBins)...
            %     [-abs(lagBins):abs(lagBins);arrayfun(@(x) mean(diag(jpsth,x)),...
            %     -abs(lagBins):abs(lagBins))]';
            outArg = [-abs(lagBins):abs(lagBins);arrayfun(@(x) mean(diag(jpsth,x)),...
                -abs(lagBins):abs(lagBins))]';
        end
        
        function [outArg, jpsth] = jpsthCoincidenceHist(jpsth, lagBins)
            %JPSTHCOINCIDENCEHIST Extract diagnols and find mean
            % 
            % Create mask for upper and lower triangular matrix
            % above and below lagBins
            mask = tril(jpsth, lagBins) & triu(jpsth, -lagBins);
            jpsth(~mask) = NaN;
            outArg = nansum(jpsth,1);
        end
        
        function outputArg = getPsthFuns()
            outputArg = { @SpikeUtils.rasters % rasters fx
                @SpikeUtils.psth % psth fx
                };
        end
        
        function outArg = getJpsthFuns()
            outArg = { @SpikeUtils.jpsthXcorrHist % cross-corr hist fx
                @SpikeUtils.jpsthCoincidenceHist % coincidence hist fx
                };
        end
        
        function outArg = pspKernel()
            outArg = SpikeUtils.getPspKernel_();
        end
        
        
        function oSpikeTimes = groupSpikeTimes(spikeTimesAllCells, cellGroups)
            %   spikeTimesAllCells: cell array of { nTrials x mUnits}
            %           Each cell is a double [1 x nSpikeTimes] of spike times for a tiral
            %           for a given unit
            %   cellGroups: A cell array of indexs into spikeTimesAllcells
            %          example: cellGrps = {[1 2 3] [4 5 6 7 8] [9 10 11
            %          12 13 14] [15:29]
            if numel(cellGroups)==size(spikeTimesAllCells,2)
                oSpikeTimes = spikeTimesAllCells;
                return;
            end
            % if no. if cell groups is < no. of cols in spikeTimesAllCells,
            % we have more than 1 unit on some channels
            nTrials = size(spikeTimesAllCells,1);
            oSpikeTimes = cell(nTrials,numel(cellGroups));
            for i = 1:numel(cellGroups)
                c = cellGroups{i};
                z = spikeTimesAllCells(:,c);
                oSpikeTimes(:,i) = arrayfun(@(t) sort(vertcat(z{t,:})),(1:nTrials)','UniformOutput',false);
            end
        end
        
        
    end
    
    methods (Static, Access=private)
        function [ coinh, coinMat ] = getCoincidence_(jpsth,lagBins)
            %GETCOINCIDENCE Summary of this function goes here
            %   Detailed explanation goes here
            % Note 1: Bins [1,1] is top-left and [nBins,nBins] is bottom-right
            % such that the main diagonal top-left to bottom-right is synchronous
            % firing of both cells at 0-lag. The length of task time is
            % (nBins*binWidth).
            % Note 2: Along the diagnonal is the evolution of firing (spike) synchrony
            % during the task between pair of cells. Y-Cell is cell chosen for Y-Axis
            % and X-Cell is cell chosen for X-Axis.
            % Note 3: We can thus get evolution of firing synchrony for any lag(s), as:
            % diag(0): Y-Cell fires synchronous to X-Cell with lag of (0*binWidth)
            % diag(i): Y-Cell fires synchronous to X-Cell with lag of +(i*binWidth)
            % diag(-i): Y-Cell fires synchronous to X-Cell with lag of -(i*binWidth)
            nBins = size(jpsth,1);
            
            % Aertsen
            lags = -(abs(lagBins)):abs(lagBins);
            coinMat = zeros(nBins,numel(lags));
            for i = lags
                d = diag(jpsth,i)';
                if isempty(d)
                    coinMat = [];
                    return
                end
                coinMat(abs(i)+1:end,lags==i) = d;
            end
            coinh = [(1:nBins)' sum(coinMat,2)];
            
        end
        
        function [ kernel ] = getPspKernel_()
            %function [ kernel ] = pspKernel(growth, decay)
            %PSPKERNEL Summary of this function goes here
            %   Detailed explanation goes here
            growth_ms = 1;
            decay_ms = 20;
            factor = 8;
            bins = 0:round(decay_ms*factor);
            fx_exp = @(x) exp(-bins./x);
            kernel = [zeros(1,length(bins)-1) ...
                (1-fx_exp(growth_ms)).*fx_exp(decay_ms)]';
            kernel = kernel./sum(kernel);
            
            %Note: convn works column wise for matrix:
            % resultTrialsInColumns  =  convn(TrialsInRowsMatrix' ,
            %    kernelColumnVector, 'same'); % not transpose in the end
            %
            % resultTrialsInRows  =  convn(TrialsInRowsMatrix' , kernelColumnVector,
            % 'same')'; % added transpose int he end
        end
        
        
        
        
    end
    
end

