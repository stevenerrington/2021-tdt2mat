function directoryStruct = getTDTdir(dataStore, saveDir)

directoryStruct.baseDir = dataStore;

% Directory where data will be saved to
directoryStruct.saveDir = saveDir;

% TEMPO ProcLib & Specific TEMPO files (for event & infos codes)
directoryStruct.procLibDir =   'C:\Users\Steven\Desktop\TDT convert\tdt2mat\ProcLib';
directoryStruct.eventDefFile = fullfile(directoryStruct.procLibDir,'CMD/EVENTDEF.PRO');
directoryStruct.infosDefFile = fullfile(directoryStruct.procLibDir,'CMD/INFOS.PRO');



end
