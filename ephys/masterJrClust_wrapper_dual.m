function masterJrClust_wrapper_dual(dirs, electrodeIdx)

% Set options
processedDir = [dirs.processedDir '\JRclust'];
rawDir = dirs.rawDir ;
fileName = dirs.experimentName;

sessString = 'rawRecordings = {''Joule-190726-102233.bin''};';
mapString = 'siteLoc = [0, 150; 0, 300; 0, 450; 0, 600; 0, 750; 0, 900; 0, 1050; 0, 1200; 0, 1350; 0, 1500; 0, 1650; 0, 1800; 0, 1950; 0, 2100; 0, 2250; 0, 2400; 0, 2550; 0, 2700; 0, 2850; 0, 3000; 0, 3150; 0, 3300; 0, 3450; 0, 3600; 0, 3750; 0, 3900; 0, 4050; 0, 4200; 0, 4350; 0, 4500; 0, 4650; 0, 4800];';
ops.dataDir = fullfile(rawDir,fileName);
ops.fbinary = [processedDir,'\',fileName,'\',fileName,'.bin'];

% Read in the master jrclust params file
% fDat = fileread('C:\Users\Steven\Desktop\Data\master_jrclust_changeme.prm');
fDat = fileread('C:\Users\Steven\Desktop\Data\master_jrclust_SpkSortTesting.prm');

% Replace filename
sessStart = strfind(fDat,sessString);
% Get name of first channel
WAVrawname = ['Wav' int2str(electrodeIdx)];
firstChan = dir(sprintf(['%s/%s/*' WAVrawname '*Ch1.sev'],rawDir,fileName));
sessReplace = sprintf('rawRecordings = {''%s\\%s\\%s''};',rawDir,fileName,firstChan.name);
% sessReplace = sprintf('rawRecordings = {''%s\\%s\\%s''};',rawPath,fileName,firstChan.name);
% sessReplace = sprintf('rawRecordings = {''%s.bin''};',fileName);
fDatReplace = [fDat(1:(sessStart-1)),sessReplace,fDat((sessStart+length(sessString)):end)];

% Deal with path differences
rmpath(genpath('C:\toolbox\JRCLUST-master'))
rmpath(genpath('C:\Users\Steven\Desktop\TDT convert\tdt2mat'))
addpath(genpath('C:\toolbox\JRCLUST-master'));
addpath(genpath('C:\Users\Steven\Desktop\TDT convert\tdt2mat'));


% Write as new .prm
if ~exist([processedDir])
    mkdir([processedDir]);
end

f=fopen([processedDir,'\master_jrclust.prm'],'w+');
fwrite(f,fDatReplace);
fclose all;

thisDir = cd;
cd(processedDir);
jrc('detect-sort','master_jrclust.prm');


end

