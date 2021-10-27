

%ks1Phy = '/scratch/subravcr/ksDataProcessed/Joule/cmanding/ephys/TESTDATA/In-Situ/Joule-190725-111052/ks1_0';
%npyFiles = dir([ks1Phy '/*.npy']);
baseDataLoc = 'data/Joule/cmanding/ephys/TESTDATA/In-Situ';
tank = 'Joule-190731-121704';
wavBase = fullfile(baseDataLoc, tank);
%% Wav1_Ch*.sev files and their properties
wavFiles=dir(fullfile(wavBase,'*Wav1_Ch*.sev'));
wavFileSize=wavFiles(1).bytes;
wavFileOffset = 40;
dataWidth = 4;
dataType = 'single';
nTimeSamples = (wavFileSize-40)/dataWidth;
Fs = 24414.0625;

%% Explore signal quality
ch = 1;
memWavFile = memmapfile(fullfile(wavFiles(ch).folder,wavFiles(1).name),'Offset', 40,'Format', 'single','Writable', false);

% https://www.mathworks.com/help/signal/ref/snr.html
x = memWavFile.Data;
[snr_x,noisePow_x] = snr(x(1:100000),Fs);
[snr_xk,noisePow_xk] = snr(xk(1:100000),Fs);

snr(double(x),Fs);

snr(double(xk),Fs);




% Check the recording quality
wavFns = dir([wavBase '/*Wav1_Ch*.sev']);
sampleType = 'single';
sampleWidth = 4;
dataShape = [size(wavFns,1), (wavFns(1).bytes-40)/sampleWidth];
wavFns = strcat({wavFns.folder},filesep,{wavFns.name})';


wavCh1=memmapfile([wavFn '1.sev'],'Offset', 40, 'Format','single');
wavCh2=memmapfile([wavFn '2.sev'],'Offset', 40, 'Format','single');
wavCh3=memmapfile([wavFn '3.sev'],'Offset', 40, 'Format','single');
wavCh4=memmapfile([wavFn '4.sev'],'Offset', 40, 'Format','single');

wavCh1=wavCh1.Data;
wavCh2=wavCh2.Data;
wavCh3=wavCh3.Data;
wavCh4=wavCh4.Data;


figure
plot(1:10)
hold on
plot(wavCh1); drawnow
plot(wavCh2); drawnow
plot(wavCh3); drawnow
plot(wavCh4); drawnow



