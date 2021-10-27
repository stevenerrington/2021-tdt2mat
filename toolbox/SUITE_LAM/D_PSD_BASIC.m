function [psd, psd_norm, f] = D_PSD_BASIC(lfp_in, varargin)

if size(lfp_in, 3) > 1
   
    lfp_t = [];
    for i = 1 : size(lfp_in, 3)
        lfp_t = cat(2, lfp_t, lfp_in(:,:,i));
    end
    lfp_t(:,isnan(lfp_t(1,:))) = [];
    
else
    lfp_t = lfp_in;
end

if ~exist('varargin', 'var')
    varargin = [512, 1000, 512, 0];
end

[msg,nfft,Fs,window,noverlap,p,dflag]=D_CHK_PSD(varargin,lfp_in(1,:));
error(msg)

for i_ch = 1 : size(lfp_t, 1)
    
    x = lfp_t(i_ch,:);
    % compute PSD
    window = window(:);
    n = length(x);		    % Number of data points
    nwind = length(window); % length of window
    if n < nwind            % zero-pad x if it has length less than the window length
        x(nwind)=0;  n=nwind;
    end
    % Make sure x is a column vector; do this AFTER the zero-padding
    % in case x is a scalar.
    x = x(:);
    
    k = fix((n-noverlap)/(nwind-noverlap));	% Number of windows
    % (k = fix(n/nwind) for noverlap=0)
    
    index = 1:nwind;
    %KMU = k*norm(window)^2;	% Normalizing scale factor ==> asymptotically unbiased
    KMU = k*sum(window)^2;     % alt. Nrmlzng scale factor ==> peaks are about right
    
    Spec = zeros(nfft,1); % Spec2 = zeros(nfft,1);
    for i=1:k
        if strcmp(dflag,'none')
            xw = window.*(x(index));
        elseif strcmp(dflag,'linear')
            xw = window.*detrend(x(index));
        else
            xw = window.*detrend(x(index),'constant');
        end
        index = index + (nwind - noverlap);
        Xx = abs(fft(xw,nfft)).^2;
        
        Spec = Spec + Xx;
        %     Spec2 = Spec2 + abs(Xx).^2;
    end
    
    % Select first half
    if ~any(any(imag(x)~=0))   % if x is not complex
        if rem(nfft,2)    % nfft odd
            select = (1:(nfft+1)/2)';
        else
            select = (1:nfft/2+1)';
        end
        Spec = Spec(select);
        
    else
        select = (1:nfft)';
    end
    freq_vector = (select - 1)*Fs/nfft;
    
    % find confidence interval if needed
    %if (nargout == 3) || ((nargout == 0) && ~isempty(p))
    %    if isempty(p)
    %        p = .95;    % default
    %    end
    
    %    confid = Spec * jnm_chi2conf(p,k)/KMU;
    
    %    if noverlap > 0
    %        disp('Warning: confidence intervals inaccurate for NOVERLAP > 0.')
    %    end
    %end
    
    Spec = Spec*(1/KMU);
    
    psd(i_ch,:) = Spec;
    f = freq_vector;
end

for i_f = 1 : size(psd, 2)
    
    for i_ch = 1 : size(lfp_t, 1)
        
        psd_norm( i_ch, i_f ) = ( psd( i_ch, i_f ) ...
            - mean( psd( :, i_f ) ) ) ...
            / mean( psd( :, i_f ) ) * 100;
        
    end
end
end
