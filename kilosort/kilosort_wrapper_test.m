%% Set directories and define data structure
% State directories with raw TDT data, and where the processed data will be
% stored
dirs.rawDataStore = 'C:\Users\Steven\Desktop\Data\In';
dirs.processDataStore = 'C:\Users\Steven\Desktop\Data\Out';
dirs.electrodeConfig = 'C:\Users\Steven\Desktop\2021-tdt2mat-main\kilosort\Kilosort-2.5\configFiles\';
% Define the session to analyise
session = 'jou-cmand1DR-DMFC-20201125';
sessionAnalysisDir = fullfile(dirs.processDataStore,session);


ops.dataDir             = fullfile(dirs.rawDataStore);   
ops.datatype            = 'bin';  % This code is taking .sev data and will convert it to .bin/.dat
ops.root                = sessionAnalysisDir;
ops.fbinary             = fullfile(dirs.rawDataStore, [session '.bin']); % will be created for 'openEphys'
ops.rootZ               = fullfile(ops.root,'ks2');
ops.fproc               = fullfile(ops.rootZ, 'temp_wh.dat'); % residual from RAM of preprocessed data
ops.trange              = [0 Inf];	% time range to sort
ops.nt0                 = 61; % length of samples for waveform data?
ops.fs                  = 24414.14;
ops.nChan               = 32;

% Create non-existent dirs
if ~exist(ops.root,'dir'); mkdir(ops.root); end
if ~exist(ops.rootZ,'dir'); mkdir(ops.rootZ); end

%% Convert TDT .sev data into .bin format
if strcmp(ops.datatype , 'tdt2Bin')
    if ~exist(ops.fbinary,'file')
        convertTdt2Bin(ops); % Main script for converting .sev to .bin. Scaling by 1e3 seems to work best and makes sense.
    end
end

%% Get channel map

electrodeSpacing = 150;
chanMapFile = [dirs.electrodeConfig 'Neuronexus_' int2str(electrodeSpacing) '.mat'];
[~,fn]=fileparts(chanMapFile);dest = fullfile(ops.root,[fn '.mat']);
copyfile(chanMapFile, dest,'f'); ops.chanMap = dest; % make this file using createChannelMapFile.m

%% Kilosort Directives
ops.verbose             = 0; % Output to console
ops.showfigures         = 0; % Display figures during sorting and drift correction
ops.GPU                 = 1; % Use GPU for analysis (CPU not yet available; 2022-01-02)
ops.parfor              = 1; % Use PARFOR where available
ops.useRAM              = 0; % Use RAM for analysis (not yet available; 2022-01-02)

tdt_ks_config                % Define kilosort parameters for analysis (separate script)

%% Run Kilosort functions
rez                = preprocessDataSub(ops);
rez                = datashift2(rez, 1); % last input is for shifting data    
rez                = learnAndSolve8b(rez, 1); % main tracking and template matching algorithm
rez                = find_merges(rez, 1);
rez                = splitAllClusters(rez, 1);
rez                = set_cutoff(rez);
rez.good           = get_good_units(rez);

%% Output Kilosort to Phy
rezToPhy(rez, ops.rootZ);

%% Import from Phy (GUI spike sorting/post-processing)
[spikes] = phy2mat(ops); 





