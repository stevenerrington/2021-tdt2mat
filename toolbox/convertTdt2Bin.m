function [ops] = convertTdt2Bin(ops,varargin)
% convert tdt _Wav1_ .sev files into binary file:
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
% assume that the [min, max] volts on any channel for signal will not
% exceed [-1 1] mV --> [-32768 32767] = [2^15 0 2^15] bits
% TDT: milli = [-1 1]mV into 2^17 bits
    if numel(varargin)>0
        signalMilliVolts = [-varargin{1} varargin{1}];
    else
        signalMilliVolts = [-1 1];
    end
    fprintf('int16Scaling: [%0.1f %0.1f] mV --> = [2^16 0 2^16] int16 bits\n',...
        signalMilliVolts(1),signalMilliVolts(2));
    int16ScaleFactor = 2^17/range(signalMilliVolts);
    fprintf('Factor for scaling TDT data from single to int16 : %i\n',int16ScaleFactor); 
    fileSuffix = ops.tdtFilePattern; %'*Wav1_*.sev';
    ds = fullfile(ops.dataDir,fileSuffix);    
    fprintf('Using files with pattern : %s\n',fileSuffix);
    T = interface.IDataAdapter.newDataAdapter('sev',ds,'rawDataScaleFactor',1);
    T.writeBinary(outputFile,int16ScaleFactor);
    ops.int16ScaleFactor = int16ScaleFactor;

end