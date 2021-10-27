%% Generate figures and save them
% -> For GO/NO-GO
if strcmp(sessionInfo.task, 'gonogo')
    outputGONOGO(sessionInfo,tdtInfo,stateFlags,Infos,outFilename) % Output go-nogo data to excel to track development
end
% -> For Standard Cmanding
if strcmp(sessionInfo.task, 'cmand')
    outputCmand(sessionInfo,tdtInfo,stateFlags,Infos,stopSignalBeh,outFilename) % Output go-nogo data to excel to track development
    getSessionFigure1DR(stopSignalBeh,stateFlags,RTdist,ttx,outFilename)
    saveas(gcf,[dirs.figureFolder '\' outFilename '-cmandBeh_main.pdf'])
end

% -> For 1DR Cmanding
if strcmp(sessionInfo.task, 'cmand1DR')
    outputCmand1DR(sessionInfo,tdtInfo,stateFlags,Infos,stopSignalBeh,ttx,outFilename) % Output go-nogo data to excel to track development
    getSessionFigure1DR(stopSignalBeh,stateFlags,RTdist,outFilename)
    saveas(gcf,[dirs.figureFolder '\' outFilename '-cmandBeh_main.pdf'])
    close gcf
    getSessionFigure1DR_Value(valueStopSignalBeh,valueRTdist,ttx,outFilename)
    saveas(gcf,[dirs.figureFolder '\' outFilename '-cmandBeh_value.pdf'])
    close gcf
end


%% Optional timing figure for testing SSD validity
% timingFig = getExpTimingFigure(stateFlags,Infos,outFilename);
% saveas(gcf,['C:\Users\Steven\Desktop\' outFilename '_timingFigure.pdf'])
