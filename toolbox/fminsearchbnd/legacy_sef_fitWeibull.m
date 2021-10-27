function [bestFitParams,minDiscrepancyFn,weibullY,fitOutput,exitFlag] = legacy_sef_fitWeibull(inh_SSD, inh_pNC, inh_nTr)
% . LEGACY function for testing and verification
%   [bestFitParams,minDiscrepancyFn] = Weibull(xData,yData,weights,pops)
%
%   Given data which describe points on the x and y axes, Weibull uses a
%   genetic algorithm approach to find parameters which minimize sum of
%   squares error based on the Weibull function:
%
%         yData = gamma - ((exp(-((xData./alpha).^beta))).*(gamma-delta))
%
%   The starting parameters and the upper and lower bounds are set to
%   provide good fits to inhibiton function data.
%   see Hanes, Patterson, and Schall. JNeurophysiol. 1998.
%
%   Written by david.c.godlove@vanderbilt.edu 10-23-10
%
%   INPUT:
%       xData              = points on the x axis. (SSDs in the case of an
%                            inhibion function)
%       yData              = points on the y axis. (p(noncanceled|SSD) for
%                            inhibition functions)
%       weights            = the number of observations at each point
%
%   OPTIONAL INPUT:
%       pops               = two value vector describing the starting
%                            number of individuals in each population and
%                            the starting number of populations. (see ga.m)
%                            default = [60 3];
%
%   OUTPUT:
%       bestFitParams    = four value vector containing optimum
%                            coeffecients such that:
%                            alpha = bestFitParams(1);
%                            beta  = bestFitParams(2);
%                            gamma = bestFitParams(3);
%                            delta = bestFitParams(4);
%       minDiscrepancyFn         = sum of squares error of xData and yData at the
%                            bestFitParams value.
%
%   see also get_SSRT, ga, and gaoptimset



if nargin < 4, pops = [60 3]; end
if nargin < 3, inh_nTr = [];  end

if length(inh_SSD) ~= length(inh_pNC)
  fprintf('Weibull: xData has length %d) and yData has length %d: they need to be the same', ...
    length(inh_SSD), length(inh_pNC));
  return
end

inh_SSD = reshape(inh_SSD, length(inh_SSD), 1);
inh_pNC = reshape(inh_pNC, length(inh_pNC), 1);
% Get rid of NaNs in the data
% ----------------------------
nanData         = isnan(inh_SSD) | isnan(inh_pNC);
inh_SSD(nanData)  = [];
inh_pNC(nanData)  = [];

% Sort the data
[inh_SSD, iX]     = sort(inh_SSD);
inh_pNC           = inh_pNC(iX);


% Might want to force the maximum to 1 and/or minimum to 0
MAX_TO_1_FLAG = 0;
MIN_TO_0_FLAG = 0;
if inh_pNC(end) > .9
    MAX_TO_1_FLAG = 1;
    minGamma = .9;
end
if inh_pNC(end) == 1
    minGamma = 1;
end
if inh_pNC(1) == 0
    MIN_TO_0_FLAG = 1;
    maxDelta = 0;
end


%1) specify initial param.
alpha = 200; %alpha: time at which inhition function reaches 67% probability
beta  = 1;   %beta : slope
gamma = 1;   %maximum probability value
delta = 0.5;   %minimum probability value

param=[alpha beta gamma delta]; %must be in this format for ge.m

lower_bounds = [1       1       0.5      0.0];  %bounds for parameters
upper_bounds = [1000     25      1.0      0.5];
if MAX_TO_1_FLAG
    lower_bounds = [1       1     minGamma    0.0];  %bounds for parameters
end
if MIN_TO_0_FLAG
    upper_bounds = [1000     25      1.0      maxDelta];
end

%2) weight Data Points if called for
if ~isempty(inh_nTr)
    x_weighted = [];
    y_weighted = [];
    for iSSD=1:length(inh_SSD)
        CurrWeighted_x = repmat(inh_SSD(iSSD),inh_nTr(iSSD),1);
        CurrWeighted_y = repmat(inh_pNC(iSSD),inh_nTr(iSSD),1);
        x_weighted = [x_weighted; CurrWeighted_x];
        y_weighted = [y_weighted; CurrWeighted_y];
    end
    inh_SSD = x_weighted;
    inh_pNC = y_weighted;
end

%3) set ga options
% pop_number = pops(1);%length(pop_options)=number of populations, values = size of populations
% pop_size = pops(2);  %more/larger populations means more thorough search of param space, but
% %also longer run time.  [30 30 30] is probably bare minimum.
% pop_options(1:pop_number) = pop_size;
% 
% hybrid_options=@fmincon;%run simplex after ga to refine parameters
% % ga_options=gaoptimset('PopulationSize',pop_options,'HybridFcn',hybrid_options,'display','off','UseParallel','always');
% ga_options=gaoptimset('PopulationSize',pop_options,'HybridFcn',hybrid_options,'display','off');

%4) run GA
%fit model
% [bestFitParams,minDiscrepancyFn]=ga(...
%     @(param) Weibull_error(xData,yData,param),...
%     length(param),...
%     [],[],[],[],...
%     lower_bounds,...
%     upper_bounds,...
%     [],...
%     ga_options);

    searchOptions = struct(...
        'Display','none',...
        'MaxIter',100000,...
        'MaxFunEvals',100000,...
        'TolX',1e-6,...
        'TolFun',1e-6, ...
        'FunValCheck','off',...
        'UseParallel','always',...
        'OutputFcn', [],...  
        'PlotFcns',[]);
        % 'OutputFcn', @firstOutputFunction,... 
        % 'PlotFcns',@firstPlotFunction
    [bestFitParams, minDiscrepancyFn, exitFlag, fitOutput] = SEF_Toolbox_fminsearchbnd(@(param) Weibull_error(inh_SSD, inh_pNC, param),param,lower_bounds,upper_bounds,searchOptions);

%5)Debugging: test-plot
alpha=bestFitParams(1);
beta=bestFitParams(2);
gamma=bestFitParams(3);
delta=bestFitParams(4);
for i = 1:1:max(inh_SSD)+10
    ypred(i,1) = gamma - ((exp(-((i./alpha).^beta))).*(gamma-delta));
end
weibullY = ypred;
% hold on
% plot(1:max(inh_SSD)+10,weibullY,'marker','o','linestyle','none')

end



function discrepancyFn = Weibull_error(xData,yData,param)
%This subfuction looks at the current data and parameters and figures out
%the sum of squares error.  The genetic fitting algorithm above tries to
%find param values to minimize SSE.

%get param
alpha = param(1);
beta  = param(2);
gamma = param(3);
delta = param(4);


% Sum of squared errors method (SSE):
%generate predictions
ypred = gamma - ((exp(-((xData./alpha).^beta))).*(gamma-delta));
% % If we need a decreasing Weibull, do that here
% if mean(diff(yData)) < 0
%     ypred = 1-ypred;
% end

%compute SSE
SSE=sum((ypred-yData).^2);
discrepancyFn = SSE;


end


function [x,fval,exitflag,output]=SEF_Toolbox_fminsearchbnd(fun,x0,LB,UB,options,varargin)
% FMINSEARCHBND: FMINSEARCH, but with bound constraints by transformation
% usage: x=FMINSEARCHBND(fun,x0)
% usage: x=FMINSEARCHBND(fun,x0,LB)
% usage: x=FMINSEARCHBND(fun,x0,LB,UB)
% usage: x=FMINSEARCHBND(fun,x0,LB,UB,options)
% usage: x=FMINSEARCHBND(fun,x0,LB,UB,options,p1,p2,...)
% usage: [x,fval,exitflag,output]=FMINSEARCHBND(fun,x0,...)
% 
% arguments:
%  fun, x0, options - see the help for FMINSEARCH
%
%  LB - lower bound vector or array, must be the same size as x0
%
%       If no lower bounds exist for one of the variables, then
%       supply -inf for that variable.
%
%       If no lower bounds at all, then LB may be left empty.
%
%       Variables may be fixed in value by setting the corresponding
%       lower and upper bounds to exactly the same value.
%
%  UB - upper bound vector or array, must be the same size as x0
%
%       If no upper bounds exist for one of the variables, then
%       supply +inf for that variable.
%
%       If no upper bounds at all, then UB may be left empty.
%
%       Variables may be fixed in value by setting the corresponding
%       lower and upper bounds to exactly the same value.
%
% Notes:
%
%  If options is supplied, then TolX will apply to the transformed
%  variables. All other FMINSEARCH parameters should be unaffected.
%
%  Variables which are constrained by both a lower and an upper
%  bound will use a sin transformation. Those constrained by
%  only a lower or an upper bound will use a quadratic
%  transformation, and unconstrained variables will be left alone.
%
%  Variables may be fixed by setting their respective bounds equal.
%  In this case, the problem will be reduced in size for FMINSEARCH.
%
%  The bounds are inclusive inequalities, which admit the
%  boundary values themselves, but will not permit ANY function
%  evaluations outside the bounds. These constraints are strictly
%  followed.
%
%  If your problem has an EXCLUSIVE (strict) constraint which will
%  not admit evaluation at the bound itself, then you must provide
%  a slightly offset bound. An example of this is a function which
%  contains the log of one of its parameters. If you constrain the
%  variable to have a lower bound of zero, then FMINSEARCHBND may
%  try to evaluate the function exactly at zero.
%
%
% Example usage:
% rosen = @(x) (1-x(1)).^2 + 105*(x(2)-x(1).^2).^2;
%
% fminsearch(rosen,[3 3])     % unconstrained
% ans =
%    1.0000    1.0000
%
% fminsearchbnd(rosen,[3 3],[2 2],[])     % constrained
% ans =
%    2.0000    4.0000
%
% See test_main.m for other examples of use.
%
%
% See also: fminsearch, fminspleas
%
%
% Author: John D'Errico
% E-mail: woodchips@rochester.rr.com
% Release: 4
% Release date: 7/23/06

% size checks
xsize = size(x0);
x0 = x0(:);
n=length(x0);

if (nargin<3) || isempty(LB)
  LB = repmat(-inf,n,1);
else
  LB = LB(:);
end
if (nargin<4) || isempty(UB)
  UB = repmat(inf,n,1);
else
  UB = UB(:);
end

if (n~=length(LB)) || (n~=length(UB))
  error 'x0 is incompatible in size with either LB or UB.'
end

% set default options if necessary
if (nargin<5) || isempty(options)
  options = optimset('fminsearch');
end

% stuff into a struct to pass around
params.args = varargin;
params.LB = LB;
params.UB = UB;
params.fun = fun;
params.n = n;
params.OutputFcn = [];

% 0 --> unconstrained variable
% 1 --> lower bound only
% 2 --> upper bound only
% 3 --> dual finite bounds
% 4 --> fixed variable
params.BoundClass = zeros(n,1);
for i=1:n
  k = isfinite(LB(i)) + 2*isfinite(UB(i));
  params.BoundClass(i) = k;
  if (k==3) && (LB(i)==UB(i))
    params.BoundClass(i) = 4;
  end
end

% transform starting values into their unconstrained
% surrogates. Check for infeasible starting guesses.
x0u = x0;
k=1;
for i = 1:n
  switch params.BoundClass(i)
    case 1
      % lower bound only
      if x0(i)<=LB(i)
        % infeasible starting value. Use bound.
        x0u(k) = 0;
      else
        x0u(k) = sqrt(x0(i) - LB(i));
      end
      
      % increment k
      k=k+1;
    case 2
      % upper bound only
      if x0(i)>=UB(i)
        % infeasible starting value. use bound.
        x0u(k) = 0;
      else
        x0u(k) = sqrt(UB(i) - x0(i));
      end
      
      % increment k
      k=k+1;
    case 3
      % lower and upper bounds
      if x0(i)<=LB(i)
        % infeasible starting value
        x0u(k) = -pi/2;
      elseif x0(i)>=UB(i)
        % infeasible starting value
        x0u(k) = pi/2;
      else
        x0u(k) = 2*(x0(i) - LB(i))/(UB(i)-LB(i)) - 1;
        % shift by 2*pi to avoid problems at zero in fminsearch
        % otherwise, the initial simplex is vanishingly small
        x0u(k) = 2*pi+asin(max(-1,min(1,x0u(k))));
      end
      
      % increment k
      k=k+1;
    case 0
      % unconstrained variable. x0u(i) is set.
      x0u(k) = x0(i);
      
      % increment k
      k=k+1;
    case 4
      % fixed variable. drop it before fminsearch sees it.
      % k is not incremented for this variable.
  end
  
end
% if any of the unknowns were fixed, then we need to shorten
% x0u now.
if k<=n
  x0u(k:n) = [];
end

% were all the variables fixed?
if isempty(x0u)
  % All variables were fixed. quit immediately, setting the
  % appropriate parameters, then return.
  
  % undo the variable transformations into the original space
  x = xtransform(x0u,params);
  
  % final reshape
  x = reshape(x,xsize);
  
  % stuff fval with the final value
  fval = feval(params.fun,x,params.args{:});
  
  % fminsearchbnd was not called
  exitflag = 0;
  
  output.iterations = 0;
  output.funcount = 1;
  output.algorithm = 'fminsearch';
  output.message = 'All variables were held fixed by the applied bounds';
  
  % return with no call at all to fminsearch
  return
end

% Check for an outputfcn. If there is any, then substitute my
% own wrapper function.
if ~isempty(options.OutputFcn)
  params.OutputFcn = options.OutputFcn;
  options.OutputFcn = @outfun_wrapper;
end

% now we can call fminsearch, but with our own
% intra-objective function.
[xu,fval,exitflag,output] = fminsearch(@intrafun,x0u,options,params);

% undo the variable transformations into the original space
x = xtransform(xu,params);

% final reshape
x = reshape(x,xsize);

% Use a nested function as the OutputFcn wrapper
  function stop = outfun_wrapper(x,varargin);
    % we need to transform x first
    xtrans = xtransform(x,params);
    
    % then call the user supplied OutputFcn
    stop = params.OutputFcn(xtrans,varargin{1:(end-1)});
    
  end

end % mainline end

% ======================================
% ========= begin subfunctions =========
% ======================================
function fval = intrafun(x,params)
% transform variables, then call original function

% transform
xtrans = xtransform(x,params);

% and call fun
fval = feval(params.fun,xtrans,params.args{:});

end % sub function intrafun end

% ======================================
function xtrans = xtransform(x,params)
% converts unconstrained variables into their original domains

xtrans = zeros(1,params.n);
% k allows some variables to be fixed, thus dropped from the
% optimization.
k=1;
for i = 1:params.n
  switch params.BoundClass(i)
    case 1
      % lower bound only
      xtrans(i) = params.LB(i) + x(k).^2;
      
      k=k+1;
    case 2
      % upper bound only
      xtrans(i) = params.UB(i) - x(k).^2;
      
      k=k+1;
    case 3
      % lower and upper bounds
      xtrans(i) = (sin(x(k))+1)/2;
      xtrans(i) = xtrans(i)*(params.UB(i) - params.LB(i)) + params.LB(i);
      % just in case of any floating point problems
      xtrans(i) = max(params.LB(i),min(params.UB(i),xtrans(i)));
      
      k=k+1;
    case 4
      % fixed variable, bounds are equal, set it at either bound
      xtrans(i) = params.LB(i);
    case 0
      % unconstrained variable.
      xtrans(i) = x(k);
      
      k=k+1;
  end
end

end % sub function xtransform end

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