storageDir = 'C:\Users\Steven\Desktop\TDT convert\cmandMat';
filesDMFC = getDirFilenames(storageDir,'DMFC');
timeWin = [-1000 2000];


parfor file = 1:length(filesDMFC)
    sessionData = parload([storageDir '\' filesDMFC{file}])
    ephysLog = importOnlineEphysLog;
    logIdx = find(not(cellfun('isempty',strfind(ephysLog.TDTfilename,sessionInfo.tdtFile))));


    [ttx, ttx_history, trialEventTimes] = processSessionTrials...
        (sessionData.Behavior.stateFlags_, sessionData.Behavior.Infos_);
    
    tdtLFP_aligned = alignLFP(sessionData.Behavior.Infos_,sessionData.LFP, timeWin);
    CSDanalysis = getCSD_multiple(tdtLFP_aligned.aligned, [900:1250])    
    
    
end

