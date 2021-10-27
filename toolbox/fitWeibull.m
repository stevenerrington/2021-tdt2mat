function [raceModel] = fitWeibull(inh_SSD, inh_pNC, inh_nTr, varargin)
%function [bestFitParams,minDiscrepancyFn,weibullY,fitOutput,exitFlag,raceModel] = fitWeibull(inh_SSD, inh_pNC, inh_nTr, varargin)
%FITWEIBULL Fit a Weibull function to the given data
% Usage:
% Fastest:(default) using fmincon
% [bestFitParams,minDiscrepancyFn,weibullY,fitOutput,exitFlag] =
%     fitWeibull(inh_SSD,inh_pNC,inh_nTr);
% Slowest:
% [bestFitParams,minDiscrepancyFn,weibullY,fitOutput,exitFlag] = ...
%     fitWeibull(inh_SSD,inh_pNC,inh_nTr,'plotProgress','printProgress');
% Plot error after iteration:
% [bestFitParams,minDiscrepancyFn,weibullY,fitOutput,exitFlag] = ...
%     fitWeibull(inh_SSD,inh_pNC,inh_nTr,'plotProgress')
% Print best fit params for each iteration:
% [bestFitParams,minDiscrepancyFn,weibullY,fitOutput,exitFlag] = ...
%     fitWeibull(inh_SSD,inh_pNC,inh_nTr,'printProgress')
% 
% Given data which describe points on the x and y axes, firWeibull finds
% parameters which minimize sum of squares error based on the Weibull function: 
%
%    yData = gamma - ((exp(-((xData./alpha).^beta))).*(gamma-delta))
%
% The starting parameters and the upper and lower bounds are set to provide
% good fits to inhibiton function data. 
%   see Hanes, Patterson, and Schall. JNeurophysiol. 1998.
%
% INPUT:
%   inh_SSD: x-data (SSDs for inhibion function) 
%   inh_pNC: y-data (p(noncanceled|SSD) for inhibition function) 
%   inh_nTr: weights (count(nTrials|SSD) fro inhibition function)
%
% OUTPUT:
%   bestFitParams: a vector of optimum coeffecients of fit 
%                  [alpha beta gamma delta]           
%   minDiscrepancyFn: sum of squared errors at bestFitParams  
%   weibullY: a vector of predicted Y-values that can be used to plot over
%             the inhibition fx
%   fitOutput: The output of the fitting routine (fminsearch)
%   exitFlag: Status of the fit
%
%   see also FMINCON FMINSEARCHBND GA LEGACY_SEF_FITWEIBULL FMINSEARCH
%
% Author: david.c.godlove@vanderbilt.edu 
% Date: 2010/10/23
% Last modification: 2019/05/03
% /////////////////// Modifications ////////////////////////
% Revision History:
% 2019/05/03 chenchal subraveti
%       Adapted from: SEF_beh_fitWeibull.m
%       Retained setting of bounds and initial params
%       Removed option for 'pops' as it is not used.
% 2019/05/07 chenchal subraveti
%      If optimization toobox is not present: use fminsearchbnd (slower)
%      If optimization toobox is present: Use fmincon (faster)
%      Added 'printProgress' and 'plotProgress' options
%      legacy_sef_fitweibull did *not* use genetic algoritm. Tried ga, but was extremely slow 
%      Added flag for forceGA (to force Genetic Algorithm - checks for Global Optimization Toolbox) 
%      Default is set to useFmincon (checks for Optimization Toolbox)
%      If Optimization Toolbox is absent, then uses FMINSEARCHBND call
%      Only one of the algorithms is used
%      ForceGA flag is statically turned OFF. you have to edit the
%      fitWeibull.m file to turn back on
%      UseParallel is turned OFF since, all alogrithms are tested to run
%      faster without the parallelization (more overhead for small dataset,
%      I guess) 
%

%% Create output struct
   fields = {'inh_SSD','inh_pNC','inh_nTr',... % input values
             'fx','Params','Err',... % function best fit-params, sse
             'PredY','Fit','ExitFlag'... % fit results
       };
   raceModel = cell2struct(cell(numel(fields),1),fields);
   raceModel.fx = @WeibullFx;
   raceModel.inh_SSD = inh_SSD;
   raceModel.inh_pNC = inh_pNC;
   raceModel.inh_nTr = inh_nTr;
   
%% Choose algorithm to use or Force Genetic Algorithm
% Set default to use FMINCON
   useFmincon = 1;
   forceGA = 0;
   toolboxes = ver;
   toolboxes = cellstr(char(toolboxes.Name));
   if forceGA
       if sum(strcmpi(toolboxes,'Global Optimization Toolbox'))
           forceGA = 1;
       else
           forceGA = 0;
           warning('Global Optimization Toolbox not present. NOT using GENETIC ALGORITHM');
       end
   end
   
   if useFmincon && sum(strcmpi(toolboxes,'Optimization Toolbox'))
       useFmincon = 1;
   else
       useFmincon = 0;
   end

%% options for display
   displayProgress = [0 0];
   if numel(varargin)>0
      displayProgress = contains({'printProgress','plotProgress'},varargin,'IgnoreCase',true);
   end
%% Search options
     % UseParallel is truned off takes time to start and is slower
    searchOptions = struct(...
        'Display','none',...
        'MaxIter',100000,...
        'MaxFunEvals',100000,...
        'TolX',1e-12,...
        'TolFun',1e-12, ...
        'OutputFcn',[],...
        'PlotFcns',[],...
        'UseParallel',0,...
        'FunValCheck','off');  
     if displayProgress(1)
         searchOptions.Display = 'iter';
     end
     if displayProgress(2)
         searchOptions.PlotFcns = @plotProgress;
     end
        
%% Check inputs
    logicalStr = {'FALSE','TRUE'};
    % check and convert to column vector
    assert(isvector(inh_SSD) && isvector(inh_pNC),'fitWeibull:InputNonVector',...
        sprintf('Inputs must be vectors. Is a vector: inh_SSD [%s], inh_pNC [%s]',...
        logicalStr{isvector(inh_SSD)+1},logicalStr{isvector(inh_pNC)+1}));
    % check number of elements
    assert(numel(inh_SSD)==numel(inh_pNC),'fitWeibull:InputSizeMismatch',...
        sprintf('Number of elements in inh_SSD [%d] must match number of elements in inh_pNC [%d]',numel(inh_SSD),numel(inh_pNC)))
    % Check weights
    if nargin == 3
        assert(numel(inh_SSD)==numel(inh_pNC),'fitWeibull:InputWeightsMismatch',...
            sprintf('Number of elements in inh_nTr [%d] must match number of elements in inh_SSD [%d]',numel(inh_nTr),numel(inh_SSD)))
        inh_nTr = inh_nTr(:);
    else
        inh_nTr = ones(numel(inh_SSD),1);
    end
    
%% Clean inputs and sort
    ssd = inh_SSD(:);
    pNC = inh_pNC(:);
    weights = inh_nTr(:);
    nanIdx = isnan(ssd) | isnan(pNC);
    ssd(nanIdx) = [];
    pNC(nanIdx) = [];
    weights(nanIdx) = [];
    % sort data
    [ssd, idx] = sort(ssd);
    pNC = pNC(idx);
    weights = weights(idx);
%% Specify model parameters and bounds
    % alpha: time at which inhition function reaches 67% probability
    alpha = 200;
    % beta: slope
    beta  = 1;
    % gamma: maximum probability value
    gamma = 1; 
    % delta: minimum probability value
    delta = 0.5;   
    % must be in this format for ge.m
    param = [alpha beta gamma delta];
    % bounds for parameter optimization by position
    loBound = [1       1       0.5      0.0];  
    upBound = [1000    25      1.0      0.5];
    % force bounds max to 1 and/or min to 0
    if pNC(end) > .9 
        loBound(3) = 0.9;
    end
    if pNC(end) == 1
        loBound(3) = 1;
    end
    if pNC(1) == 0
        upBound(4) = 0;
    end

%% Weight data by number of observations for each (x,y) pair
    [ssd, pNC] = arrayfun(@(x,y,t) deal(repmat(x,t,1),repmat(y,t,1)),ssd,pNC,weights,'UniformOutput',false);
    ssd = cell2mat(ssd);
    pNC = cell2mat(pNC);

%% Use fmincon or fminsearchbnd depending on presence of optimization toolbox - GA is too slow
   if forceGA
       fprintf('Using GA (Genetic Algorithm)...\n') %#ok<UNRCH>
       % Genetic algorithm --> very, very slow... do not use
       gaOptions = searchOptions;
       if displayProgress(2)
           gaOptions.PlotFcns=@gaplotbestf;
       else
           gaOptions.PlotFcns=[];
       end
       [bestFitParams,minDiscrepancyFn,exitFlag,fitOutput] = ...
           ga(@(param) WeibullFx(param,ssd,pNC),numel(param),[],[],[],[],loBound,upBound,[],gaOptions);
   elseif useFmincon
       fprintf('Using FMINCON...\n')
       [bestFitParams,minDiscrepancyFn,exitFlag,fitOutput] = ...
           fmincon(@(param) WeibullFx(param,ssd,pNC),param,[],[],[],[],loBound,upBound,[],searchOptions);
   else
       fprintf('Using FMINSEARCHBND...\n')
       [bestFitParams,minDiscrepancyFn,exitFlag,fitOutput] = ...
           fminsearchbnd(@(param) WeibullFx(param,ssd,pNC),param,loBound,upBound,searchOptions);
   end
    
   [~, weibullY] = WeibullFx(bestFitParams,(0:max(inh_SSD)+10));
%% Populate output struct
   raceModel.Params = bestFitParams;
   raceModel.Err = minDiscrepancyFn;
   raceModel.PredY = weibullY;
   raceModel.Fit = fitOutput;
   raceModel.ExitFlag = exitFlag;

end

function stop = plotProgress(xOutputfcn, optimValues, state, varargin)
    % create an print function for the fMinSearch
    %
    % NOTE: The plot functions do their own management of the plot and axes - if you want to
    % plot on your own figure or axes, just do the plotting in the output function, and leave
    % the plot function blank.  
    %
    % One thing the plot function DOES have it that it installs STOP and PAUSE buttons on the
    % plot that allow you to interrupt the optimization to go in and see what's going on, and 
    % then resume, or stop the iteration and still have it exit normally (and report output 
    % values, etc).  
    %
    % inputs:
    % 1) xOutputfcn = the current x values
    % 2) optimValues - structure having:
    %         optimValues.iteration = iter;  % iteration number
    %         optimValues.funccount = numf;  % number of function eval's so far
    %         optimValues.fval = f;          % value of the function at current iter.
    %         optimValues.procedure = how;   % how is fminsearch current method (expand, contract, etc)
    % 3) State = 'iter','init' or 'done'     % where we are in the fminsearch algorithm.
    % 4) varargin is passed thru fminsearch to the user function and can be anything.
    %

    symb={'\alpha','\beta ','\gamma','\delta'}';
    xOutputfcn = xOutputfcn(:);
    titleTxt = '';
    if numel(varargin)==0
        titleTxt = join(strcat(symb(1:numel(xOutputfcn)),{' : '},num2str(xOutputfcn,'%4.4f')),'; ');
    end
    titleTxt = [titleTxt;strcat(['State: ' state],{'    SSE : '}, num2str(optimValues.fval,'%4.4f'))];

    stop = false;

    hold on; 
    % this is fun - it simply plots the optimization variable (inverse figure of merit) as it 
    % goes along, so you can see it improving, or stop the iterations if it stagnates.
    rectangle('Position', ...
        [(optimValues.iteration - 0.45) optimValues.fval, 0.9, 0.5*optimValues.fval]);
    set(gca, 'YScale', 'log');

    title(titleTxt,'Interpreter','tex');
    xlabel('Iteration #')
    ylabel('log(SSE)')

    % when you run this, try pressing the 'stop' or 'pause' buttons on the plot.

    % you can add any code here that you desire.

end
