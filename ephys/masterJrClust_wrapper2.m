function masterJrClust_wrapper(fileName,varargin)

isPoly2 = 0;
chanSpacing = 150;
doExtract = 1;
waitForManual = 1;

% Decode varargin
varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'-p'}
            isPoly2 = varargin{varStrInd(iv)+1};
        case {'-s'}
            chanSpacing = varargin{varStrInd(iv)+1};
        case {'-e'}
            doExtract = varargin{varStrInd(iv)+1};
        case {'-w'}
            waitForManual = varargin{varStrInd(iv)+1};
    end
end


monkName = fileName(1:(regexp(fileName,'-','once')-1));

% Set options
doConvert = 0;
outPath = [tebaMount,'/Users/Kaleb/proNoElongationColor_physio/'];
rawPath = [tebaMount,'/data/',monkName,'/proNoElongationColor_physio/'];
sessString = 'rawRecordings = {''Joule-190726-102233.bin''};';
mapString = 'siteLoc = [0, 150; 0, 300; 0, 450; 0, 600; 0, 750; 0, 900; 0, 1050; 0, 1200; 0, 1350; 0, 1500; 0, 1650; 0, 1800; 0, 1950; 0, 2100; 0, 2250; 0, 2400; 0, 2550; 0, 2700; 0, 2850; 0, 3000; 0, 3150; 0, 3300; 0, 3450; 0, 3600; 0, 3750; 0, 3900; 0, 4050; 0, 4200; 0, 4350; 0, 4500; 0, 4650; 0, 4800];';
ops.dataDir = fullfile(rawPath,fileName);
ops.fbinary = [outPath,'/',fileName,'/',fileName,'.bin'];
% fullfile(fileName,'sessionBinary.bin');

if doConvert
    convertWav2Bin(ops);
end

% Read in the master jrclust params file
fDat = fileread('~/git/jrClust/schalllab-cmand/ephys/master_jrclust_changeme.prm');

% Replace filename
sessStart = strfind(fDat,sessString);
% Get name of first channel
firstChan = dir(sprintf('%s/%s/*Wav1*Ch1.sev',rawPath,fileName));
% sessReplace = sprintf('rawRecordings = {''%s/%s''};',rawPath,fileName);
sessReplace = sprintf('rawRecordings = {''%s/%s/%s''};',rawPath,fileName,firstChan.name);
% sessReplace = sprintf('rawRecordings = {''%s.bin''};',fileName);
fDatReplace = [fDat(1:(sessStart-1)),sessReplace,fDat((sessStart+length(sessString)):end)];

if isPoly2
    mapStart = strfind(fDatReplace,mapString);
    mapReplace = 'siteLoc = [';
    for i = 1:32
        mapReplace = [mapReplace,sprintf('%d %d',50*mod(i,2),25*i)];
        if i == 32
            mapReplace = [mapReplace,'];'];
        else
            mapReplace = [mapReplace,';'];
        end
    end
    fDatReplace = [fDatReplace(1:(mapStart-1)),mapReplace,fDatReplace((mapStart+length(mapString)):end)];
else
    mapStart = strfind(fDatReplace,mapString);
    mapReplace = 'siteLoc = [';
    for i = 1:32
        mapReplace = [mapReplace,sprintf('%d %d',0,chanSpacing*i)];
        if i == 32
            mapReplace = [mapReplace,'];'];
        else
            mapReplace = [mapReplace,';'];
        end
    end
    fDatReplace = [fDatReplace(1:(mapStart-1)),mapReplace,fDatReplace((mapStart+length(mapString)):end)];
end

% Write as new .prm
if ~exist([outPath,'/',fileName])
    mkdir([outPath,'/',fileName]);
end
f=fopen([outPath,'/',fileName,'/master_jrclust.prm'],'w+');
fwrite(f,fDatReplace);
fclose all;

% Deal with path differences
if contains(which('jrclust.detect.newRecording'),'JRCLUST')
    rmpath(genpath('~/git/jrClust/JRCLUST/'))
    rmpath(genpath('~/git/jrClust/schalllab-cmand/'))
    addpath(genpath('~/git/jrClust/JRCLUST/'));
    addpath(genpath('~/git/jrClust/schalllab-cmand'));
end

thisDir = cd;
cd([outPath,'/',fileName]);
jrc('detect-sort','master_jrclust.prm');
if waitForManual
    jrc('manual','master_jrclust.prm');
    keyboard
    close all;
end
cd(thisDir);
if doExtract
    klGetJrclustSpikes_asFun(fileName,outPath);
end

