%% Set directories and define data structure
% State directories with raw TDT data, and where the processed data will be
% stored
%% Clear environment
clear; clc;
dirs.rawDataStore = 'S:\Users\Current Lab Members\Steven Errington\temp\dajo_bin';
dirs.processDataStore = 'S:\Users\Current Lab Members\Steven Errington\2021_DaJo\spk';
dirs.electrodeConfig = 'C:\Users\Steven\Desktop\2021-tdt2mat-main\kilosort\Kilosort-2.5\configFiles\';
dataDir = 'S:\Users\Current Lab Members\Steven Errington\2021_DaJo\mat\';

%% Get Session Information
% Get Ephys log and tidy
ephysLog = importOnlineEphysLogMaster;
ephysLog = ephysLog(strcmp(ephysLog.UseFlag,'?') | strcmp(ephysLog.UseFlag,'1'),:);

% Get usable session IDs for looping
sessionList = cellfun(@str2num,ephysLog.SessionN);
uniqueSessionList = unique(sessionList);
spkTable_all = table();

parfor logIdx = 1:size(ephysLog,1)
    try
        fprintf('Analysing electrode %i of %i | %s.          \n',...
            logIdx,size(ephysLog,1),ephysLog.Session{logIdx});
        
        % Define the session to analyise
        session = ephysLog.Session{logIdx};
        sessionAnalysisDir = fullfile(dirs.processDataStore,session);
        
        ops = struct();        
        ops.root                = sessionAnalysisDir;
        ops.rootZ               = fullfile(ops.root);
        ops.fs                  = 24414.14;
        ops.nChan               = 32;
        
        [spkTable] = phy2mat_infoOut(ops);      
        session = repmat({session}, size(spkTable,1),1);
        spkTable.cluster = session;
        spkTable_all = [spkTable_all; spkTable];
        
    catch m
        fprintf('            ERROR: %i of %i | %s.          \n',...
            logIdx,size(ephysLog,1),ephysLog.Session{logIdx});
        
        errorSession{logIdx} = m;
    end
end


writetable(spkTable_all,['S:\Users\Current Lab Members\Steven Errington\temp\dajo_spikeData.csv']);