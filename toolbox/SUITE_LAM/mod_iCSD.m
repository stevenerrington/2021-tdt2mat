function [CSD] = mod_iCSD(var)

%   INPUT SHOULD BE CHAN x SAMPLES (signal in microVolts)
%   OUTPUT IS nA/mm^3

    totchan              = size(var,1)/10;
    intercontact_spacing = 0.1; % in mm
    el_pos               = .1 : intercontact_spacing : totchan;   
    N                    = length(el_pos); % N: number of electrodes
    d                    = mean(diff(el_pos));
    
    out=[];
    for i=1:N-2
        for j=1:N
            if (i == j-1)
                out(i,j) = -2/d^2;
            elseif (abs(i-j+1) == 1)
                out(i,j) = 1/d^2;
            else
                out(i,j) = 0;
            end;
        end;
    end;

    
    cond  = 0.00040;       % conductivity of cortex (estimate from Logethetis, Kayser, Oeltermann 2007)
    CSD   = -cond*out*var; % [microA/mm^3]
    CSD   = CSD .*1000;    % now in [nanoA/mm^3]
    
end
   
