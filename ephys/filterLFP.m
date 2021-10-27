function fLFP = filterLFP(inputLFP ,lowerBand ,upperBand ,samplingFreq)
% fLFP = filt_LFP (sig1 , lower_limit , upper_limit )
%
% filt_LFP uses a butterworth filter to bandpass filter the signal between
% lower and upper limit
%
% INPUTS :
% sig1 = signal to be filtered
% lower_limit = lower bound of bandpass
% upper_limit = upper bound of bandpass
% sF = sampling Frequency ( default : 2000 Hz)
% Set Default sF = 1000 Hz

if nargin < 4
    samplingFreq = 1000;
end
if isempty(samplingFreq)
    samplingFreq = 1000;
end

Nyquist_freq = samplingFreq/2;

lowcut = lowerBand/Nyquist_freq;
highcut = upperBand/Nyquist_freq;

filter_order = 2; % may need to be changed based on bandpass limits

passband = [lowcut highcut];

[Bc Ac] = butter(filter_order , passband);

fLFP = filtfilt(Bc ,Ac ,inputLFP);

end
