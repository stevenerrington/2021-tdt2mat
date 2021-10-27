function [gazeInPixels] = tdtAnalog2Pixels(analogData, voltRange, signalRange, pixelRange)
%TDTFANALOG2PIXELS Convert TDT eye data in volts to screenPixels 
%
%   analogData : Vector of Eye (X or Y) data from TDT
%   voltRange : ADT volt range of TDT? or EDF?
%   signalRange : Signal range of EDF typically [-0.2 1.2]? 
%   pixelRange : Screen pixel range for EDF eye movement 
%                Screen dimensions: X:[0 1024] or Y: [0 768]%
%   OUTPUT:
%    gazeInPixels: Ref: Eyelink 1000 User Manual pp 124 or 125.
%                  R = (voltage-minvoltage)/(maxvoltage-minvoltage) 
%                  S = R*(maxrange-minrange)+minrange  
%                  Xgaze = S*(screenright-screenleft+1)+screenleft 
%
    if nargin~=4
        error(help(mfilename));
    end
    try
        dac2Volts  = (analogData - min(voltRange))./range(voltRange);
        volts2Pixels = dac2Volts.*range(signalRange) + min(signalRange);
        gazeInPixels = volts2Pixels.*range(pixelRange) + min(pixelRange);
    catch me
        disp(me);
        error(help(mfilename));
    end

end
