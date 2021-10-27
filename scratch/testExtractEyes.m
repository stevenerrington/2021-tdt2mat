%function [trialEyes] = tdtExtractEyes(sessionDir, trialStartTimes, varargin)
baseDir = '/Volumes/schalllab/Users/Chenchal/Tempo_NewCode/Joule';
session = 'Joule-190319-123427';
sessionDir = fullfile(baseDir,session);
codesDir = fullfile(sessionDir,'ProcLib','CMD');
eventCodecFile = fullfile(codesDir,'EVENTDEF.PRO');
infosCodecFile = fullfile(codesDir, 'INFOS.PRO');



[evCode2Name, evName2Code, evTable] = getCodeDefs(eventCodecFile);


[infosCode2Name, infosName2Code, infosTable] = getCodeDefs(infosCodecFile);


[trialEvents, trialInfos, evCodec, infosCodec, tdtInfos ] = tdtExtractEvents(sessionDir, eventCodecFile, infosCodecFile);

trialStartTimes = trialEvents.TrialStart_;
trialEndTimes = trialEvents.Eot_;

[trialEyes] = tdtExtractEyes(sessionDir,[],[]);

[trialEyes2] = tdtExtractEyes(sessionDir, trialStartTimes, trialEndTimes);


