function CumulDist = cumulDist(Input)

% This function inputs an array, and outputs the cumulitive distribution.
Input = reshape(Input,[],1);
Input = sort(Input, 'ascend');
N = length(Input);

for i = 1:N   % for each data point:
    X(i,1) = Input(i);    % x value is simply the value of the data point
    Y(i,1) = i/N ;  % This way, the Y for the Nth item is 1, and the Y for the 1st item is 1/N. and the 0th item is 0. 
end

CumulDist = [X Y];
end

    
    
    
