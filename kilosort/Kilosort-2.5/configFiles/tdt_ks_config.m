ops.fs = 24414.14;       % sample rate
ops.fshigh = 300;        % frequency for high pass filtering (150)
ops.Th = [8 4];          % threshold on projections (like in Kilosort1, can be different for last pass like [10 4])
ops.lam = 10;            % how important is the amplitude penalty (like in Kilosort1, 0 means not used, 10 is average, 50 is a lot) 
ops.AUCsplit = 0.9;      % splitting a cluster at the end requires at least this much isolation for each sub-cluster (max = 1)
ops.minFR = 1/5;         % minimum spike rate (Hz), if a cluster falls below this for too long it gets removed
ops.momentum = [20 400]; % number of samples to average over (annealed from first to second value) 
ops.sigmaMask = 30;      % spatial constant in um for computing residual variance of spike
ops.ThPre = 4;           % threshold crossings for pre-clustering (in PCA projection space)
ops.sig = 20;            % spatial scale for datashift kernel
ops.nblocks = 5;         % type of data shifting (0 = none, 1 = rigid, 2 = nonrigid)

% options for determining PCs (danger, changing these settings can lead to
% fatal errors)
ops.spkTh = -4;         % spike threshold in standard deviations (-6)
ops.reorder = 1;         % whether to reorder batches for drift correction. 
ops.nskip = 25;          % how many batches to skip for determining spike PCs
ops.nfilt_factor = 4;    % max number of clusters per good channel (even temporary ones)
ops.ntbuff = 64;    	 % samples of symmetrical buffer for whitening and spike detection
ops.NT = 64*1024+ ops.ntbuff; % must be multiple of 32 + ntbuff. This is the batch size (try decreasing if out of memory). 
ops.whiteningRange = 32; % number of channels to use for whitening each channel
ops.nSkipCov = 25;       % compute whitening matrix from every N-th batch
ops.scaleproc = 1e3; %1  % int16 scaling of whitened data
ops.nPCs = 3;            % how many PCs to project the spikes into
ops.NchanTOT = 32;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% PREVIOUS KILOSORT SETTINGS
% ops.fs                  = 24414.14; % sampling rate
% ops.NchanTOT            = nChan; % total number of channels
% ops.Nchan               = nChan; % number of active channels 
% ops.Nfilt               = 64; % number of filters to use (512, should be a multiple of 32)     
% ops.nNeighPC            = [3]; % visualization only (Phy): number of channnels to mask the PCs, leave empty to skip (12)
% ops.nNeigh              = [3]; % visualization only (Phy): number of neighboring templates to retain projections of (16)
% ops.fshigh              = 300; % frequency for high pass filtering (150)
% ops.minfr_goodchannels  = 0.1; % minimum firing rate on a "good" channel (0 to skip)
% ops.Th                  = [4 8];  % threshold on projections (like in Kilosort1, can be different for last pass like [10 4])
% ops.lam                 = [10 30 30];  % how important is the amplitude penalty (like in Kilosort1, 0 means not used, 10 is average, 50 is a lot) 
% ops.AUCsplit            = 0.9; % splitting a cluster at the end requires at least this much isolation for each sub-cluster (max = 1)
% ops.minFR               = 0; % minimum spike rate (Hz), if a cluster falls below this for too long it gets removed
% ops.momentum            = [20 400]; % number of samples to average over (annealed from first to second value) 
% ops.sigmaMask           = 30; % spatial constant in um for computing residual variance of spike
% ops.ThPre               = 6; % threshold crossings for pre-clustering (in PCA projection space)
% 
% % **** danger, changing these settings can lead to fatal errors *********
% % options for determining PCs
% ops.spkTh               = -4;      % spike threshold in standard deviations (-6)
% ops.reorder             = 1;       % whether to reorder batches for drift correction. 
% ops.nskip               = 1;  % how many batches to skip for determining spike PCs
% % ks1: ops.Nfilt               = 960;  % number of filters to use (512, should be a multiple of 32)
% ops.Nfilt               = 1024; % max number of clusters
% ops.nfilt_factor        = 10; % max number of clusters per good channel (even temporary ones)
% ops.ntbuff              = 64;    % samples of symmetrical buffer for whitening and spike detection
% ops.NT                  = 32*64*1024+ ops.ntbuff; % must be multiple of 32 + ntbuff. This is the batch size (try decreasing if out of memory). 
% ops.whiteningRange      = 32; % number of channels to use for whitening each channel
% ops.nSkipCov            = 1; % compute whitening matrix from every N-th batch
% ops.scaleproc           = 1;   % int16 scaling of whitened data
% ops.nPCs                = 3; % how many PCs to project the spikes into
% ops.useRAM              = 0; % not yet available
% ops.nblocks             = 5;