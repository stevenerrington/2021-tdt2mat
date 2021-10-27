function klManualSortProcess(subj,date,varargin)

chanOff = 0;
% subj = sessName(1:(find(ismember(sessName,'-'),1)-1));
spkFS = 24414.0625;
wvWind = -30:30;

% Decode varargin
varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'-sub'}
            subSess = varargin{varStrInd(iv)+1};        
    end
end

% Get sessions for this subject, date
subjSess = dir([tebaMount,'/data/',subj,'/proNoElongationColor_physio/',subj,'-',date,'*']);
sessNames = {subjSess.name};
if length(sessNames)==1
    sessName = sessNames{1};
elseif exist('subSess','var')
    sessName = sessNames{subSess};
elseif any(cellfun(@(x) ~isempty(strfind(x,'Merged')),sessNames))
    sessName = sessNames{find(cellfun(@(x) ~isempty(strfind(x,'Merged')),sessNames),1)};
else
    fprintf('Found %d sessions for this date... Using session 1\n',length(sessNames));
    sessName = sessNames{1};
end

% Check for a manual sorting folder
% hasFold = exist([tebaMount,'/Users/Kaleb/testTdtBins/',sessName]);
hasFold = exist([tebaMount,'/data/',subj,'/proNoElongationColor_physio_bins/',sessName]);
% hasFold = exist(['~/Dropbox/tdtBins/',sessName]);
rawPath = [tebaMount,'/data/',subj,'/proNoElongationColor_physio'];
resultPath = [tebaMount,'/Users/Kaleb/proNoElongationColor_physio/',sessName];
% resultPath = ['~/git/tebaOut/',sessName];

if ~hasFold
    return
end

% Get .txt files
% sortTxt = dir([tebaMount,'/Users/Kaleb/testTdtBins/',sessName,'/*.txt']);
% sortTxt = dir(['~/Dropbox/tdtBins/',sessName,'/*.txt']);
sortTxt = dir([tebaMount,'/data/',subj,'/proNoElongationColor_physio_bins/',sessName,'/*.txt']);

% Move old files
if ~isempty(sortTxt)
    % Get old folders
    oldFolds = dir([resultPath,'/C*']);
    mkdir([resultPath,'/kilosortBackup']);
    for i = 1:length(oldFolds)
        movefile(fullfile(oldFolds(i).folder,oldFolds(i).name),[resultPath,'/kilosortBackup/',oldFolds(i).name]);
    end
end
        
clustNo = nan;
for it = 1:length(sortTxt)
    sortDat = load(fullfile(sortTxt(it).folder,sortTxt(it).name));
    if isempty(sortDat)
        continue
    end
    uUnits = nunique(sortDat(:,2));
    thisChan = str2double(sortTxt(it).name(5:(strfind(sortTxt(it).name,'.')-1)));
    allData = SEV2mat(fullfile(rawPath,sessName),'CHANNEL',thisChan);
    allTimes = (0:(length(allData.Wav1.data)-1)).*(1000/spkFS);
    for iu = 1:length(uUnits)
        theseTimes = sortDat(sortDat(:,2)==uUnits(iu),3).*1000;
        unitStr = sprintf('chan%d%s',thisChan+chanOff,num2abc(iu));
        spkInds = bsxfun(@plus,round(theseTimes.*spkFS./1000),wvWind);
        outOfBounds = any(spkInds < 1 | spkInds > length(allData.Wav1.data),2);
        spkInds(outOfBounds,:) = [];
        clusterWaves = allData.Wav1.data(spkInds);
        spkTimes = theseTimes;
        waves = clusterWaves;
        spikeQuality = 'manual';
        mkdir([resultPath,filesep,upper(unitStr(1)),unitStr(2:end)]);
        save([resultPath,filesep,upper(unitStr(1)),unitStr(2:end),'/',unitStr,'.mat'],'spkTimes','waves','clustNo','spikeQuality');
        
    end
end