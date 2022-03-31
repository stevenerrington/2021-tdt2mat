load('2021-dajo-datamap.mat')
dataDir = 'S:\Users\Current Lab Members\Steven Errington\2021_DaJo\mat\';

for sessionIdx = 1:size(dajo_datamap,1)
    
    clear beh_data DMC_table sessionName monkeyName sessionN outTable
    beh_data = load([dataDir dajo_datamap(sessionIdx,:).behInfo.dataFile]);
    
    fprintf('Analysing session %i of %i  |  %s    \n',...
        sessionIdx,size(dajo_datamap,1),dajo_datamap(sessionIdx,:).behInfo.dataFile)
    
    [DMC_table] = cmand_DMCprocess(beh_data.events.stateFlags_,...
        beh_data.events.Infos_);
    
    sessionName = repmat(dajo_datamap.session(sessionIdx),size(DMC_table,1),1);
    monkeyName = repmat(dajo_datamap(sessionIdx,:).animalInfo.monkey(1:2),size(DMC_table,1),1);
    sessionN = repmat(dajo_datamap.sessionN(sessionIdx),size(DMC_table,1),1);
    
    outTable = [table(sessionName,monkeyName,sessionN),DMC_table];
    
    writetable(outTable,...
        ['S:\Users\Current Lab Members\Steven Errington\temp\dajo_stopCSV\dmc\'...
        sessionName{1} '-stopBeh.csv'],'WriteRowNames',true)
    
end