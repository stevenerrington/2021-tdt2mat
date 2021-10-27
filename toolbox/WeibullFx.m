function [weibullErr,predictedY] = WeibullFx(coeffs,xData,varargin)

  weibullErr = NaN;
  predictedY = weibull(coeffs,xData);
  if numel(varargin) == 1
      yData = varargin{1};
    % If we need a decreasing Weibull, do that here
    % if mean(diff(yData)) < 0
    %     ypred = 1-ypred;
    % end
    % Sum of squared errors method (SSE):
    weibullErr = sum((predictedY-yData).^2);
      
  end
end

function [sse, yPred] = weibullErr(coeffs, x, y)
    % This is the objective function to minimize
    % Sum of squared errors method (SSE):
    %generate predictions
    %yPred = coeffs(3) - ((exp(-((x./coeffs(1)).^coeffs(2)))).*(coeffs(3)-coeffs(4)));
    yPred = weibull(coeffs,x);
    % % If we need a decreasing Weibull, do that here
    % if mean(diff(yData)) < 0
    %     ypred = 1-ypred;
    % end

    % Sum of squared errors method (SSE):
    %compute SSE
    sse=sum((yPred-y).^2);
end

function [yVals] = weibull(coeffs,x)
    yVals = coeffs(3) - ((exp(-((x./coeffs(1)).^coeffs(2)))).*(coeffs(3)-coeffs(4)));
    yVals = yVals(:);
end