% 
%% Parameters for Translation
sessionBaseDir = 'data/Joule/cmanding/ephys/TESTDATA/In-Situ';
baseSaveDir = 'dataProcessed/Joule/cmanding/ephys/TESTDATA/In-Situ';
sessName = 'Joule-190731-121704';
procLibDir = fullfile(sessionBaseDir,sessName,'ProcLib');
eventDefFile = fullfile(procLibDir,'CMD/EVENTDEF.PRO');
infosDefFile = fullfile(procLibDir,'CMD/INFOS.PRO');

% set it up in TranslateTDT
opts.sessionDir = fullfile(sessionBaseDir,sessName);
opts.baseSaveDir = baseSaveDir;
opts.eventDefFile = eventDefFile;
opts.infosDefFile = infosDefFile; 
opts.useTaskStartEndCodes = true;
opts.dropNaNTrialStartTrials = false;
opts.dropEventAllTrialsNaN = false;
% Offset for Info Code values_
opts.infosOffsetValue = 3000;
opts.infosHasNegativeValues = true;
opts.infosNegativeValueOffset = 32768;
% Eye data
opts.splitEyeIntoTrials = false;
opts.hasEdfDataFile = 0;
% opts.edf.useEye = 'X';
% opts.edf.voltRange = [-5 5];
% opts.edf.signalRange = [-0.2 1.2];
% opts.edf.pixelRange = [0 1024];


ZZ = TDTTranslator(opts);


[Task, TaskInfos, TrialEyes, EventCodec, InfosCodec, SessionInfo] = ZZ.translate(0);



