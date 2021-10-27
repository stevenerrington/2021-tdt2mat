function klConvertJR(sessName)

sessDir = [tebaMount,'/Users/Kaleb/proNoElongationColor_physio/'];

% Load Spikes
if ~exist([sessDir,sessName,'/Spikes.mat'])
    fprintf('Couldn''t find Spikes.mat... Exiting\n');
    return
end

x=load([sessDir,sessName,'/Spikes.mat']);

spkNames = fieldnames(x);
spkNames(cellfun(@(x) strcmpi(x(1),'W'),spkNames)) = [];

for i = 1:length(spkNames)
    if length(x.(spkNames{i})) < 5000
        continue
    end
    chanStr = ['Chan',spkNames{i}(4:end)];
    chanDir = [sessDir,sessName,'/',chanStr];
    mkdir(chanDir);
    spkTimes = x.(spkNames{i});
    waves = x.(['WAV',spkNames{i}(4:end)]);
    save([chanDir,'/',lower(chanStr),'.mat'],'spkTimes','waves');
end