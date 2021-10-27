function csd_trial = D_CSD_BASIC(lfp_in, varargin)

cndt           = 0.0004;
spc            = .1; % in mm

varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'cndt'}
            cndt = varargin{varStrInd(iv)+1};
        case {'spc'}
            spc = varargin{varStrInd(iv)+1};
    end
end

csd_trial = nan(size(lfp_in,1), size(lfp_in,2), size(lfp_in,3));

for i_trial = 1 : size(lfp_in,3)
    
    t_csd       = lfp_in(:,:,i_trial);
    csd_in      = t_csd .* 1000; % mV to uV
    
    nChan       = size( csd_in, 1 ) * spc;
    
    dChan       = spc : spc : nChan;
    
    nE = length( dChan );
    d = mean( diff( dChan ) );
    
    t_csd = [];
    for i = 1 : nE - 2
        for j = 1 : nE
            if i == (j - 1)
                t_csd( i, j ) = -2 / d^2;
            elseif abs( i - j + 1) == 1
                t_csd( i, j ) = 1 / d^2;
            else
                t_csd( i, j ) = 0; 
            end
        end
    end
    
    csd_trial(2:end-1,:,i_trial) = -cndt * t_csd * csd_in;
    csd_trial(2:end-1,:,i_trial) = csd_trial(2:end-1,:,i_trial) .* 1000; % uA/mm3 to nA/mm3
    
end
end