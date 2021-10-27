function [alignStartIndex, alignedEdfVec] = tdtAlignEyeWithEdf(edfEyeVec, tdtEyeVec, edfSamplingFreqHz, tdtSamplingFreqHz, alignWindowSecs, edfOptions)
%TDTALIGNEYEWITHEDF Align EDF eye data with TDT eye data
%Note:
% Replace values in EDF eye data that is missed/defaulted
% Seems to be 1E8 is the value.  Also MISSING_DATA = -32768
%
%   edfEyeVec : Vector of Eye (X or Y) data from EDF file collected on Eyelink
%   tdtEyeVec : Vector of Eye (X or Y) data from TDT file collected on TDT
%   edfSamplingFreqHz : Sampling frequency of EDF
%   tdtSamplingFreqHz : Sampling frequency of TDT for Eye channels
%   alignWindowSecs : In Seconds. Converted to number of edf bins to slide the data for computing alignment.
%   edfOptions : A struct with the following fields
%                    useEye : Which eye data to use X or Y [not used in this function]
%                    voltRange : voltage range of ADC [-5 5]
%                    signalRange : signal range of Eyelink [-0.2 1.2]
%                    pixelRange : screen pixels in X or Y [0 1024]
%
%   OUTPUT:
%     alignStartIndex : The index of edfEyeVec that when aligned with the
%                       first index of tdtEyeVec will show minimal mean
%                       squared distance between tdtEyeVec and edfEyeVec. 
%     alignedEdfVec : Truncated edfEyeVec. Data from the first data point
%                     of edfVec which whenaligned with first datapoint of
%                     tdtEyeVec will show minimal mean squared distance
%                     between tdtEyeVec and edfEyeVec. 
%
% Example:
%   [alignStartIndex, alignedEdfVec] = eyeAlignEdfWithTdt(edfX, tdtX, 1000, 1017, 100, edfOptions);
%
% See also RESAMPLE, MEAN, TDTANALOG2PIXELS, EDF2MAT
% Third-party utility EDF2MAT from edf-converter https://github.com/uzh/edf-converter for
%   MISSING_DATA_VALUE = -32768;
%   EMPTY_VALUE  = 1e08;
%   


    MISSING_DATA_VALUE  = -32768;
    EMPTY_VALUE         = 1e08;

    edfEyeVec(edfEyeVec==MISSING_DATA_VALUE)=nan;
    edfEyeVec(edfEyeVec==EMPTY_VALUE)=nan;

    edfFs = round(edfSamplingFreqHz);
    tdtFs = round(tdtSamplingFreqHz);
    tdtEyeVecResampled = single(resample(double(tdtEyeVec),edfFs,tdtFs));
    alignStartIndex = alignVectors(edfEyeVec,tdtEyeVecResampled,alignWindowSecs * edfFs, edfOptions);
    alignedEdfVec = edfEyeVec(alignStartIndex:end);
end

function [lag] = alignVectors(edfVec, tdtVec, slidingWinBins, edfOptions)
    % for conversion to gaze in pixels
    voltRange = edfOptions.voltRange; %[-5 5];
    signalRange = edfOptions.signalRange; %[-0.2 1.2];
    pixelRange = edfOptions.pixelRange; %[0 1024]; % X-only
    % In edf bin time 1ms if colledted at 1000Hz
    tdtNBins = numel(tdtVec);
    nGazeEdf = (edfVec - min(edfVec))./range(edfVec);
    nGazeTdt = tdtAnalog2Pixels(tdtVec,voltRange,signalRange,pixelRange);
    nGazeTdt = (nGazeTdt - min(nGazeTdt))./range(nGazeTdt);
    meanSquaredDiff = nan(slidingWinBins,1);
    parfor ii = 1:slidingWinBins
        if ii+tdtNBins-1 <= numel(nGazeEdf)
            edfForAlign = nGazeEdf(ii:ii+tdtNBins-1);
            meanSquaredDiff(ii,1) =  nanmean(((nGazeTdt - edfForAlign).^2));
        end
    end
    lag = find(meanSquaredDiff==nanmin(meanSquaredDiff),1,'first');

end



