function [ops] = convertTdt2Bin(ops, varargin)
% convert tdt _Wav1_ or _RSn1_ .sev files into binary file:
%   no header and
%   scaled to int16
%   interleaved linear data format:
%     [ch1,t0],[ch2,t0],...[chN,t0],...
%     [ch1,t1],[ch2,t1],...[chN,t1],...
%     [ch1,tM],[ch2,tM],...[chN,tM]
%  File size in bytes should be: nChannels * mTimesamples * 2

% TDT data collection: Usually selected dropdown menu is:
%     milli volts, float32
%     Data is saved in millivolts for atleast the *Wav1_.sev files
%if ~exist(ops.root,'dir')
%    mkdir(ops.root);
%end

outputFile = ops.fbinary;
% conversion factor for micro volts
% when converted to uV, the fractional part lost when typecasted to int16
% a better way if to scale the range into 2^16 values, and save the AD bits
% but then we would need to use a ADC conversion factor for spike sorting
% whereas if we save as int16(uVolts), we use a conversion factor of 1.0 in
% doing spike sorting


%% Double pass the data to find the grand(min, max) of all channels 
%  so that an appropriate scale factor can be chosen for maximum resolution
%  for int16 scaling with minimal loss due to conversion form single data
%  type. It is possible that this max/min may(?) correspond to a spurious
%  noise spike? So, lets get the 99th percentile of abs. max and scale it
%  to nearest bits

    scaleFactor = 1;
    % assume that the [min, max] volts on any channel for signal will not
    % exceed [-1 1] mV --> [-32768 32767] = [2^15 0 2^15] bits
    fprintf('int16Scaling: [-1 1] mV --> [-32768 32767] = [2^15 0 2^15] bits\n');
    signalMilliVolts = ops.signalMilliVolts;
    int16ScaleFactor = 2^16./range(signalMilliVolts);
    if numel(varargin) == 1
        int16ScaleFactor = varargin{1};
    end
    fprintf('Factor for scaling TDT data from single to int16 : %i\n',int16ScaleFactor); 
    ds = fullfile(ops.dataDir,'*_Wav1_*.sev');
    T = interface.IDataAdapter.newDataAdapter('sev',ds,'rawDataScaleFactor',scaleFactor);
    T.writeBinary(outputFile,int16ScaleFactor);
    ops.int16ScaleFactor = int16ScaleFactor;

end