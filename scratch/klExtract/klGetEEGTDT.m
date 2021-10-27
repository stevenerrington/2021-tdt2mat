function EEG = klGetEEGTDT(sessName,varargin)

% Set defaults
fresh = 1;
rawDir = '/mnt/teba/data/Kaleb/antiSessions/';
% rawDir = '/mnt/teba/Users/Kaleb/proAntiRaw';
procDir = '/mnt/teba/Users/Kaleb/proAntiProcessed/';
doSave = 0;
print = 1;

% Decode varargin
varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'-p','print'}
            print = varargin{varStrInd(iv)+1};
        case {'-f','fresh'}
            fresh = varargin{varStrInd(iv)+1};
        case {'-r','rawDir','rawdir'}
            rawDir = varargin{varStrInd(iv)+1};
        case {'-proc'}
            procDir = varargin{varStrInd(iv)+1};
        case {'-s','save'}
            doSave = varargin{varStrInd(iv)+1};
    end
end

% Set up directory stuff
if ~ismember(sessName(end),['/','\']), sessName(end+1) = filesep;  end
if ismember(rawDir(end),['/','\']), fileName = [rawDir,sessName]; else fileName = [rawDir,filesep,sessName]; end
if ismember(procDir(end),['/','\']), saveDir = [procDir,sessName]; else saveDir = [procDir,filesep,sessName]; end

% Determine which TDT function to use
if ispc
    getFun = @TDTbin2mat;%2mat;
elseif isunix
    getFun = @TDTbin2mat;
end

% Get eye positions
skipEEG = 0;
if exist(sprintf('%sEEG.mat',saveDir),'file') && ~fresh
    load(sprintf('%sEEG.mat',saveDir));
    if isfield(EEG,'Good') && EEG.Good==1
        skipEEG = 1;
    end
end
EEG.Good = 0;
if ~skipEEG
    if print
        if exist('printStr','var')
            for ib = 1:length(printStr)
                fprintf('\b');
            end
        end
        printStr = 'Getting EEG Traces...';
        fprintf(printStr);
    end
    goodChan = 0;
    for ic = 1:16 % Max EEG channels?
        try
            eegRaw = getFun(fileName,'TYPE',{'streams'},'STORE','EEGG','VERBOSE',0,'CHANNEL',ic);
            goodChan = ic;
        end
        if goodChan ~= ic
            break;
        end
        EEG.rawTraces(ic,:) = eegRaw.streams.EEGG.data;
        EEG.sampRate = eegRaw.streams.EEGG.fs;
    end
    EEG.Times = (0:size(EEG.rawTraces,2)).*1000/EEG.sampRate;
    EEG.Good = 1;
    if print
        for ib = 1:length(printStr)
            fprintf('\b');
        end
        printStr = 'Saving EEG...';
        fprintf(printStr);
    end
    if doSave
        save(sprintf('%sEEG.mat',saveDir),'EEG');
    end
end

