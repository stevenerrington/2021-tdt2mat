function opts = getTDTopts(directoryStruct,tdtSession)

% Setup directory options to translate TDT datafile
opts.sessionDir = fullfile(directoryStruct.baseDir,tdtSession); 
opts.baseSaveDir = directoryStruct.saveDir;
opts.eventDefFile = directoryStruct.eventDefFile; 
opts.infosDefFile = directoryStruct.infosDefFile; 

% Setup translation flags to translate TDT datafile
opts.useTaskStartEndCodes = true; 
opts.dropNaNTrialStartTrials = false;
opts.dropEventAllTrialsNaN = false;

opts.infosOffsetValue = 3000; 
opts.infosHasNegativeValues = true;
opts.infosNegativeValueOffset = 32768;

% Set eye flags for translating TDT datafile
opts.splitEyeIntoTrials = false;
opts.hasEdfDataFile = 0;
opts.splitEyeIntoTrials = 0;