clear all; clc

%% Set pathways for Kilosort and dependencies
ks2Paths = genpath('C:\Users\Steven\Desktop\TDT convert\tdt2mat\spkSorting\Kilosort-main');
addpath(ks2Paths);
npyPths = genpath('C:\Users\Steven\Desktop\TDT convert\tdt2mat\spkSorting\npy-matlab');
addpath(npyPths);

%% Directory and data structure
inData = 'C:\Users\Steven\Desktop\Data\In';
outData = 'C:\Users\Steven\Desktop\Data\Out';
session = 'Cmand1DR_Ephys-210120-100000';
sessionAnalysisDir = fullfile(outData,session);
nChan = 32;

ops.dataDir             = fullfile(inData,session);   
ops.datatype            = 'tdt2Bin';  % binary ('dat', 'bin') or 'openEphys'
ops.root                = sessionAnalysisDir;
ops.fbinary             = fullfile(ops.root, [session '.bin']); % will be created for 'openEphys'
rootZ                   = fullfile(ops.root,'ks2');
ops.fproc               = fullfile(rootZ, 'temp_wh.dat'); % residual from RAM of preprocessed data
ops.trange              = [0 Inf];	% time range to sort
ops.nt0                 = 61; % length of samples for waveform data?

% Create non-existent dirs
if ~exist(ops.root,'dir'); mkdir(ops.root); end
if ~exist(rootZ,'dir'); mkdir(rootZ); end

%% Get channel map
chanMapFile = 'C:\Users\Steven\Desktop\TDT convert\tdt2mat\spkSorting\Kilosort-main\configFiles\SE_chanMap.mat';
[~,fn]=fileparts(chanMapFile);
dest = fullfile(ops.root,[fn '.mat']);
copyfile(chanMapFile, dest,'f');
ops.chanMap = dest; % make this file using createChannelMapFile.m

%% Kilosort Directives
ops.verbose             = 1;
ops.showfigures         = 0;
ops.GPU                 = 1; % has to be 1, no CPU version yet, sorry
ops.parfor              = 1;
ops.useRAM              = 0; % not yet available

%% Kilosort parameters
ops.fs                  = 24414.14; % sampling rate
ops.NchanTOT            = nChan; % total number of channels
ops.Nchan               = nChan; % number of active channels 
ops.Nfilt               = 64; % number of filters to use (512, should be a multiple of 32)     
ops.nNeighPC            = [3]; % visualization only (Phy): number of channnels to mask the PCs, leave empty to skip (12)
ops.nNeigh              = [3]; % visualization only (Phy): number of neighboring templates to retain projections of (16)
ops.fshigh              = 300; % frequency for high pass filtering (150)
ops.minfr_goodchannels  = 0.1; % minimum firing rate on a "good" channel (0 to skip)
ops.Th                  = [6 12 12];  % threshold on projections (like in Kilosort1, can be different for last pass like [10 4])
ops.lam                 = [10 30 30];  % how important is the amplitude penalty (like in Kilosort1, 0 means not used, 10 is average, 50 is a lot) 
ops.AUCsplit            = 0.9; % splitting a cluster at the end requires at least this much isolation for each sub-cluster (max = 1)
ops.minFR               = 0; % minimum spike rate (Hz), if a cluster falls below this for too long it gets removed
ops.momentum            = [20 400]; % number of samples to average over (annealed from first to second value) 
ops.sigmaMask           = 30; % spatial constant in um for computing residual variance of spike
ops.ThPre               = 6; % threshold crossings for pre-clustering (in PCA projection space)

% **** danger, changing these settings can lead to fatal errors *********
% options for determining PCs
ops.spkTh               = -4.5;      % spike threshold in standard deviations (-6)
ops.reorder             = 1;       % whether to reorder batches for drift correction. 
ops.nskip               = 1;  % how many batches to skip for determining spike PCs
% ks1: ops.Nfilt               = 960;  % number of filters to use (512, should be a multiple of 32)
ops.Nfilt               = 1024; % max number of clusters
ops.nfilt_factor        = 10; % max number of clusters per good channel (even temporary ones)
ops.ntbuff              = 64;    % samples of symmetrical buffer for whitening and spike detection
ops.NT                  = 32*64*1024+ ops.ntbuff; % must be multiple of 32 + ntbuff. This is the batch size (try decreasing if out of memory). 
ops.whiteningRange      = 32; % number of channels to use for whitening each channel
ops.nSkipCov            = 1; % compute whitening matrix from every N-th batch
ops.scaleproc           = 2^16;   % int16 scaling of whitened data
ops.nPCs                = 3; % how many PCs to project the spikes into
ops.useRAM              = 0; % not yet available

%% Convert TDT .sev data into .bin format
if strcmp(ops.datatype , 'tdt2Bin')
    if ~exist(ops.fbinary,'file')        
        convertTdt2Bin(ops); 
    end
end

%% Run Kilosort functions
rez                = preprocessDataSub(ops);
tic
rez                = datashift2(rez, 1);
toc

[rez, st3, tF]     = extract_spikes(rez);
rez                = template_learning(rez, tF, st3);
[rez, st3, tF]     = trackAndSort(rez);
rez                = final_clustering(rez, tF, st3);
rez                = find_merges(rez, 1);

rootZ = fullfile(rootZ, 'kilosort3');
mkdir(rootZ)
rezToPhy2(rez, rootZ);



