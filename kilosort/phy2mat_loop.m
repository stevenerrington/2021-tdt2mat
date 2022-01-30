%% Set directories and define data structure
% State directories with raw TDT data, and where the processed data will be
% stored
%% Clear environment
clear; clc;
dirs.rawDataStore = 'S:\Users\Current Lab Members\Steven Errington\temp\dajo_bin';
dirs.processDataStore = 'S:\Users\Current Lab Members\Steven Errington\temp\dajo_kilosort';
dirs.electrodeConfig = 'C:\Users\Steven\Desktop\2021-tdt2mat-main\kilosort\Kilosort-2.5\configFiles\';
dataDir = 'S:\Users\Current Lab Members\Steven Errington\2021_DaJo\mat\';

%% Get Session Information
% Get Ephys log and tidy
ephysLog = importOnlineEphysLogMaster;
ephysLog = ephysLog(strcmp(ephysLog.UseFlag,'?') | strcmp(ephysLog.UseFlag,'1'),:);

% Get usable session IDs for looping
sessionList = cellfun(@str2num,ephysLog.SessionN);
uniqueSessionList = unique(sessionList);

parfor logIdx = 1:size(ephysLog,1)
    try
        fprintf('Analysing electrode %i of %i | %s.          \n',...
            logIdx,size(ephysLog,1),ephysLog.Session{logIdx});
        
        % Define the session to analyise
        session = ephysLog.Session{logIdx};
        sessionAnalysisDir = fullfile(dirs.processDataStore,session);
        
        ops = struct();        
        ops.dataDir             = fullfile(dirs.rawDataStore);
        ops.datatype            = 'bin';  % This code is taking .sev data and will convert it to .bin/.dat
        ops.root                = sessionAnalysisDir;
        ops.fbinary             = fullfile(dirs.rawDataStore, [session '.bin']); % will be created for 'openEphys'
        ops.rootZ               = fullfile(ops.root);
        ops.fproc               = fullfile(ops.rootZ, 'temp_wh.dat'); % residual from RAM of preprocessed data
        ops.trange              = [0 Inf];	% time range to sort
        ops.nt0                 = 61; % length of samples for waveform data?
        ops.fs                  = 24414.14;
        ops.nChan               = 32;
        
        [spikes] = phy2mat(ops);
        
        spk_file = ephysLog.Session{logIdx};
        parsave_spks([dataDir spk_file '-spk.mat'], spikes);
        
    catch
        fprintf('            ERROR: %i of %i | %s.          \n',...
            logIdx,size(ephysLog,1),ephysLog.Session{logIdx});
    end
end