sessionBaseDir = 'E:/data/Joule/cmanding/ephys/TESTDATA/In-Situ';
baseSaveDir = 'E:/Dropbox/SCHALL_preProcessingData/dataProcessed/Joule/cmanding/ephys/TESTDATA/In-Situ';
sessName = 'Joule-190827-134608';
lfpMatFile = fullfile(baseSaveDir,sessName,'Lfps.mat');
% LFP files
d = dir(fullfile(sessionBaseDir,sessName,'*_Lfp1_*.sev'));
lfpHeader = TDTbin2mat(d(1).folder,'Headers',1,'Store','Lfp1');
lfpHeader = lfpHeader.stores.Lfp1;
save(lfpMatFile,'lfpHeader');
for ch = 1:numel(d)   
    lfpFn = fullfile(d(ch).folder,d(ch).name);
    fprintf('reading file: %s...',d(ch).name);
    chNo =  regexp(lfpFn,'Ch(\d+)','tokens');
    chNo = chNo{1}{1};
    lfpVar=num2str(str2double(chNo),'AD_LFP%02i');
    memFile = memmapfile(lfpFn,'Offset',40,'Format','single','writable',false);
    z.(lfpVar)=memFile.Data;
    fprintf('saving LFP variable %s to file %s\n',lfpVar,lfpMatFile);
    save(lfpMatFile,'-append','-struct','z');
    clearvars z
end
