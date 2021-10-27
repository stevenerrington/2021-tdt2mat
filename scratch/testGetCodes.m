% Test for translateTdt/getCodeDefs
% See also GETCODEDEFS, GETRELCODES, VERIFYEVENTCODES, TDTEXTRACTBEHAVIOR

% function [code2Name, name2Code] = getCodeDefs(codesFile)
%codesDir = '/Volumes/schalllab/Users/Chenchal/Tempo_NewCode/Joule-190312-162436/ProcLib/CMD';

codesDir = '/Users/subravcr/Projects/lab-schall/Tempo/schalllab-rig029/ProcLib/CMD';

[evCode2Name, evName2Code, evTable] = getCodeDefs(fullfile(codesDir,'EVENTDEF.PRO'));


[infosCode2Name, infosName2Code, infosTable] = getCodeDefs(fullfile(codesDir,'INFOS.PRO'));

