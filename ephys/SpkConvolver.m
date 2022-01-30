function SessionSDF = SpkConvolver (SpkData, SessionEndTime, ConvType)

if strcmp(ConvType, 'PSP') == 1
    
    xrange = 0:100;
    R_nonNormalized = ([1 - exp(-xrange./1)] .* exp (-xrange./100) );   % defining R, which is the Rate function. This will be convolved with Raster data (see below)
    R = R_nonNormalized/sum(R_nonNormalized);
    R2use = [zeros(1,length(xrange))  R];

elseif strcmp(ConvType, 'Gauss') == 1
    tg          = 1;     % From Pouget et al 2005 (in turn from Sayer et al 1990)
    td          = 20;    % From Pouget et al 2005 (in turn from Sayer et al 1990)
    normalize   = 1;
       
    mu = 0;
    sd = td; N = sd*5; t=-N:N;
    R2use = (1/sqrt(2*pi*sd.^2))*exp(-t.^2/(2*sd.^2));
end

S2 = zeros(1, SessionEndTime);
S2(SpkData) = 1;

SessionSDF = conv(S2, R2use, 'same')*1000;




