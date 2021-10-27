
projectsDir = 'C:/Users/subravcr/Documents/Projects/lab-schall/';
dataPath = 'C:/scratch/subravcr/ksData/Darwin';
analysisDir = 'C:/scratch/subravcr/ksDataProcessed/Darwin';
session = 'Darwin-190724-094624';
chanMapFile = [projectsDir 'schalllab-cmand/toolbox/probes/linear-probe-1-32chan-150um.mat'];
sessionAnalysisDir = fullfile(analysisDir,session);
nChan = 32;
%% Add to path for conversion to bin file
toolboxPaths = genpath([projectsDir 'schalllab-cmand/toolbox']);
addpath(toolboxPaths);
ePhysPaths = genpath([projectsDir 'schalllab-cmand/ePhys']);
addpath(ePhysPaths);
%% Params and configuration for Kilosort2
ks2Paths = genpath([projectsDir 'Kilosort2']);
addpath(ks2Paths);
npyPths = genpath([projectsDir 'npy-matlab']);
addpath(npyPths);

%% Data stuff
ops.dataDir             = fullfile(dataPath,session);   
ops.datatype            = 'tdt2Bin';  % binary ('dat', 'bin') or 'openEphys'
ops.tdtFilePattern      = '*_RSn1_ch*.sev';
ops.root                = sessionAnalysisDir;
% ops.fbinary             = fullfile(ops.root, [session '.bin']); % will be created for 'openEphys'
ops.fbinary             = fullfile(ops.root, [session '.bin']); % will be created for 'openEphys'
rootZ                   = fullfile(ops.root,'ks2');
ops.fproc               = fullfile(rootZ, 'temp_wh.dat'); % residual from RAM of preprocessed data
% ops.trange              = [0 Inf];	% time range to sort
ops.trange              = [0 Inf];	% time range to sort
% need ops.nt0 for fitTemplates
ops.nt0                 = 61; % length of samples for waveform data?

% Create non-existent dirs
if ~exist(ops.root,'dir')
    mkdir(ops.root);
end
if ~exist(rootZ,'dir')
    mkdir(rootZ);
end
%% Other params
ops.fs                  = 24414;        % sampling rate
ops.NchanTOT            = nChan;           % total number of channels
ops.Nchan               = nChan;           % number of active channels 
ops.Nfilt               = 64;           % number of filters to use (512, should be a multiple of 32)     
ops.nNeighPC            = [3]; % visualization only (Phy): number of channnels to mask the PCs, leave empty to skip (12)
ops.nNeigh              = [3]; % visualization only (Phy): number of neighboring templates to retain projections of (16)
%% Channel map file
% define the channel map as a filename (string) or simply an array
[~,fn]=fileparts(chanMapFile);
dest = fullfile(rootZ,[fn '.mat']);
copyfile(chanMapFile, dest,'f');
ops.chanMap             = dest; % make this file using createChannelMapFile.m

% frequency for high pass filtering (150)
ops.fshigh = 300;   

% minimum firing rate on a "good" channel (0 to skip)
ops.minfr_goodchannels  = 0.1; 

% threshold on projections (like in Kilosort1, can be different for last pass like [10 4])
ops.Th                  = [10 4];  

% how important is the amplitude penalty (like in Kilosort1, 0 means not used, 10 is average, 50 is a lot) 
ops.lam                 = [10];  

% splitting a cluster at the end requires at least this much isolation for each sub-cluster (max = 1)
ops.AUCsplit            = 0.9; 

% minimum spike rate (Hz), if a cluster falls below this for too long it gets removed
ops.minFR               = 0; %1/50; 

% number of samples to average over (annealed from first to second value) 
ops.momentum            = [20 400]; 

% spatial constant in um for computing residual variance of spike
ops.sigmaMask           = 30; 

% threshold crossings for pre-clustering (in PCA projection space)
ops.ThPre               = 8; 
%% danger, changing these settings can lead to fatal errors
% options for determining PCs
ops.spkTh               = -4.5;      % spike threshold in standard deviations (-6)
ops.reorder             = 1;       % whether to reorder batches for drift correction. 
ops.nskip               = 1;  % how many batches to skip for determining spike PCs
% ks1: ops.Nfilt               = 960;  % number of filters to use (512, should be a multiple of 32)
ops.Nfilt               = 1024; % max number of clusters
ops.nfilt_factor        = 10; % max number of clusters per good channel (even temporary ones)
ops.ntbuff              = 64;    % samples of symmetrical buffer for whitening and spike detection
ops.NT                  = 512*1024+ ops.ntbuff; % must be multiple of 32 + ntbuff. This is the batch size (try decreasing if out of memory). 
ops.whiteningRange      = nChan; % number of channels to use for whitening each channel
ops.nSkipCov            = 1; % compute whitening matrix from every N-th batch
ops.scaleproc           = 1;   % int16 scaling of whitened data
ops.nPCs                = 3; % how many PCs to project the spikes into
ops.useRAM              = 1; % not yet available

%% directives
ops.verbose             = 1;
ops.showfigures         = 1;
ops.GPU                 = 1; % has to be 1, no CPU version yet, sorry
ops.parfor              = 1;
ops.useRAM              = 0; % not yet available
%% Process
tic

if strcmp(ops.datatype , 'tdt2Bin')
    if ~exist(ops.fbinary,'file')        
        convertTdt2Bin(ops); 
    end
end

% preprocess data to create temp_wh.dat
rez = preprocessDataSub(ops);

% time-reordering as a function of drift
rez = clusterSingleBatches(rez);
save(fullfile(rootZ, 'rez.mat'), 'rez', '-v7.3');

% main tracking and template matching algorithm
rez = learnAndSolve8b(rez);

% final merges
rez = find_merges(rez, 1);

% final splits by SVD
rez = splitAllClusters(rez, 1);

% final splits by amplitudes
rez = splitAllClusters(rez, 0);

% decide on cutoff
rez = set_cutoff(rez);

fprintf('found %d good units \n', sum(rez.good>0))

%% Save results to sub-folder
% write to Phy
rezToPhy(rez, rootZ);

%% if you want to save the results to a Matlab file... 

% discard features in final rez file (too slow to save)
rez.cProj = [];
rez.cProjPC = [];

% save final results as rez2
fprintf('Saving final results in rez2  \n')
fname = fullfile(rootZ, 'rez2.mat');
save(fname, 'rez', '-v7.3');

%%
fclose('all');
delete(ops.fproc);

%% copy this master_ks2.m file to the analysys directory session root 
src = [mfilename('fullpath') '.m'];
[~,fn] = fileparts(src);
dest = fullfile(ops.root,[fn '.m.']);
copyfile(src,dest,'f');

%% Remove from paths...
rmpath(npyPths)
rmpath(ks2Paths)
rmpath(toolboxPaths)
rmpath(ePhysPaths)
