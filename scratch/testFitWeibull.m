inh_SSD = beh.raceModel.inh_SSD;
inh_pNC = beh.raceModel.inh_pNC;
inh_nTr = beh.raceModel.inh_nTr;

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
    lb = [1       1       0.5      0.0];  
    ub = [1000    25      1.0      0.5];
    % force bounds max to 1 and/or min to 0
    if inh_pNC(end) > .9 
        lb(3) = 0.9;
    elseif inh_pNC(end) == 1
        lb(3) = 1;
    end
    if inh_pNC(1) == 0
        ub(4) = 0;
    end

%% Weight data by number of observations for each (x,y) pair
    [ssd, pNC] = arrayfun(@(x,y,t) deal(repmat(x,t,1),repmat(y,t,1)),...
                         inh_SSD,inh_pNC,inh_nTr,'UniformOutput',false);
    ssd = cell2mat(ssd);
    pNC = cell2mat(pNC);
       
        % Set up optimization options - you can leave any of these blank and fminsearch will use
    % defaults.
    searchOptions = struct(...
        'Display','none',...
        'MaxIter',100000,...
        'MaxFunEvals',100000,...
        'TolX',1e-6,...
        'TolFun',1e-6, ...
        'FunValCheck','off',...
        'UseParallel','always',...
        'OutputFcn', @firstOutputFunction,...  
         'PlotFcns',@firstPlotFunction);
   
   %[bestFitParams minDiscrepancyFn exitflag output] = SEF_Toolbox_fminsearchbnd(@(param) Weibull_error(inh_SSD, inh_pNC, param),param,lower_bounds,upper_bounds,options);
    %fminsearchbnd(@(param) weibull(param,ssd,pNC),param,lb,ub,searchOptions);
    
    [r_fminc.x,r_fminc.fval,r_fminc.exitflag,r_fminc.output] = fmincon(@(param) weibullErr(param,ssd,pNC),param,[],[],[],[],lb,ub,[],searchOptions);
    
    [f_fminc.x,f_fminc.fval,f_fminc.exitflag,f_fminc.output] = fminsearchbnd(@(param) weibullErr(param,ssd,pNC),param,lb,ub,searchOptions);
    
    gaOptions = searchOptions;
    gaOptions.PlotFcns=@gaplotbestf;
    [ga_fminc.x,ga_fminc.fval,ga_fminc.exitflag,ga_fminc.output] = ga(@(param) weibullErr(param,ssd,pNC),4,[],[],[],[],lb,ub,[],gaOptions);
    
    
    r_fminc
    f_fminc
    ga_fminc
    
    
    
    function [sse, yPred] = weibullErr(coeffs, x, y)
        % This is the objective function to minimize
        % Sum of squared errors method (SSE):
        %generate predictions
        %yPred = coeffs(3) - ((exp(-((x./coeffs(1)).^coeffs(2)))).*(coeffs(3)-coeffs(4)));
        yPred = weibullFx(coeffs,x);
        % % If we need a decreasing Weibull, do that here
        % if mean(diff(yData)) < 0
        %     ypred = 1-ypred;
        % end

        % Sum of squared errors method (SSE):
        %compute SSE
        sse=sum((yPred-y).^2);
    end

    function [yVals] = weibullFx(coeffs,x)
        yVals = coeffs(3) - ((exp(-((x./coeffs(1)).^coeffs(2)))).*(coeffs(3)-coeffs(4)));
        yVals = yVals(:);
    end


    
    % Define output and print functions.  These functions are nexted WITHIN the overall routine so they 
    % have access to variables in the above code if needed.
    %

    function stop = firstOutputFunction(xOutputfcn, optimValues, state, varargin)
        % create an output function for the fMinSearch
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

        stop = false;

        % NOTE: this makes a bit of a messy display, but shows what you can do with an output
        % function.  You can get much of the same information using the fminsearch input option
        % 'Display', 'iter'
        disp(sprintf('Iteration: %d,  Evals: %d,  Current Min Value: %d', ...
            optimValues.iteration, optimValues.funccount, optimValues.fval));
        disp(['Best x so far: [' sprintf('%g ', xOutputfcn) ']']);
        
        % you could place plotting code here if you didn't want the automatic figure handling of the
        % plot functions.
        
        % you can also modify the value of 'stop' here to true if you want fminseach to terminate
        % based on any criteria you'd put here.
    end
        
    function stop = firstPlotFunction(xOutputfcn, optimValues, state, varargin)
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
        
        stop = false;
        
        hold on; 
        % this is fun - it simply plots the optimization variable (inverse figure of merit) as it 
        % goes along, so you can see it improving, or stop the iterations if it stagnates.
        rectangle('Position', ...
            [(optimValues.iteration - 0.45) optimValues.fval, 0.9, 0.5*optimValues.fval]);
        set(gca, 'YScale', 'log');
        
        % when you run this, try pressing the 'stop' or 'pause' buttons on the plot.
        
        % you can add any code here that you desire.
        
    end
    