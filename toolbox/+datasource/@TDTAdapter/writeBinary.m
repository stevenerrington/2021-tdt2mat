function [nSampTOT] = writeBinary(obj,outputFile,int16ScaleFactor)
%WRITEBINARY Convert TDT Wav1 data in the multiple files to a single binary
%            file for Kilosort/ other python software to use
%   Detailed explanation goes here
  
  if strcmp('single',obj.dataForm)
     fprintf('Converting single to int16 before writing\n');
 end

 if ~obj.isOpen % open all data files
     obj.openDataset();
 end    
   dataSize = obj.dataSize; %[nChannels x nSamples]
   % split nSamples into reasonable batchsizes
   nSampTOT = 0;
   nBatches = 64;
   batchSize = [dataSize(1)  ceil(dataSize(2)/nBatches)];
   % Output
   if ~exist(fileparts(outputFile),'dir')
       mkdir(fileparts(outputFile));
   end
   fidw = fopen(outputFile,'w');
   tic
   for ii = 1:nBatches
       rawData = obj.readRaw(batchSize(1),batchSize(2));
       data = int16(rawData.*int16ScaleFactor);
       if ~isempty(data)
           data = data(:)';
           fwrite(fidw,data,'int16');
           nSampTOT = nSampTOT + numel(data);
           fprintf('Wrote batch %i of %i, %.4f\n',ii,nBatches,toc);
       end
   end
   fclose(fidw);
end
