function [Spikes] = extractSpks(ops,dirs)

%% Convert TDT SEV files to BIN format for processing
% Skip if binary files already exist

%% Run main JRClust setup script
%  Execute main cluster extraction & analysis
masterJrClust_wrapper(dirs)
%  Allow for manual curation of the detected clusters
jrc('manual','master_jrclust.prm');
%  Import clusters into .mat format to allow for further analysis
Spikes = getJRclustSpks(dirs);



end
