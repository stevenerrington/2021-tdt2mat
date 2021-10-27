% 
% sessionBaseDir = '/mnt/teba/data/Leonardo/SingleTgt-Go-NoGo';
% baseSaveDir = 'dataProcessed/Leonardo';
% sessName = 'Leonardo-181009-151736';%'Leonardo-181008-142316';
% procLibDir =fullfile(sessionBaseDir,sessName,'ProcLib');
% eventDefFile = fullfile(procLibDir,'EVENTDEF.pro');
% infosDefFile = fullfile(procLibDir,'search/INFOS.pro');


% sessionBaseDir = 'data/Joule';
% baseSaveDir = 'dataProcessed/Joule';
% sessName = 'Joule-181008-111153';
% procLibDir ='/Users/subravcr/teba/local/Tempo/rigProcLibs/FixRoom029/ProcLib_011';
% eventDefFile = fullfile(procLibDir,'EVENTDEF.PRO');
% infosDefFile = fullfile(procLibDir,'CMD/INFOS.PRO');


% set it up in TranslateTDT
%     opts.useTaskEndCode = true;
%     opts.dropNaNTrialStartTrials = false;
%     opts.useNegativeValsInInfos = true;
%     opts.infosNegativeOffset = 32768;


opts.sessionDir = fullfile(sessionBaseDir,sessName);
opts.baseSaveDir = baseSaveDir;
opts.eventDefFile = eventDefFile;
opts.infosDefFile = infosDefFile; 
opts.hasEdfDataFile = 1;
opts.edf.useEye = 'X';
opts.edf.voltRange = [-5 5];
opts.edf.signalRange = [-0.2 1.2];
opts.edf.pixelRange = [0 1024];


ZZ = TDTTranslator(opts);


[Task, TaskInfos, TrialEyes, EventCodec, InfosCodec, SessionInfo] = ZZ.translate(0);



