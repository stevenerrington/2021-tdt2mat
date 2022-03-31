count = 0;

summaryTable = table();

for sessionIdx = 1:size(dajo_datamap,1)
    for electrodeIdx = 1:dajo_datamap.nElectrodes(sessionIdx)
        count = count + 1;
        
        sessionN = sessionIdx;
        electrode = electrodeIdx;
        monkey = {dajo_datamap.animalInfo(sessionIdx).monkey}  ;
        session = dajo_datamap.neurophysInfo{sessionIdx}.dataFilename(electrodeIdx);
        area = dajo_datamap.neurophysInfo{sessionIdx}.area(electrodeIdx);
        spk_flag = dajo_datamap.neurophysInfo{sessionIdx}.spk_flag(electrodeIdx);
        acc_flag = strcmp(dajo_datamap.neurophysInfo{sessionIdx}.area(electrodeIdx),'ACC');
        dmfc_flag = strcmp(dajo_datamap.neurophysInfo{sessionIdx}.area(electrodeIdx),'DMFC');
        try
            nUnits = sum(dajo_datamap.neurophysInfo{sessionIdx}.spkInfo(electrodeIdx).unitInfo.flag_noise == 0);
        catch
            nUnits = 0;
        end
        
        summaryTable(count,:) = table(session, sessionN, monkey, electrode, area, acc_flag, dmfc_flag, spk_flag, nUnits);
    end
end


for sessionIdx = 1:size(dajo_datamap,1)
    
    sessionRowIdx = [];
    sessionRowIdx = find(summaryTable.sessionN == sessionIdx);
    
    dualProbe_flag =  sum(summaryTable.spk_flag(sessionRowIdx)) == 2;
    
    if dualProbe_flag == 0 & summaryTable.spk_flag(sessionRowIdx) == 1 & summaryTable.acc_flag(sessionRowIdx) == 1
        label{sessionIdx,1} = 'acc';
        
    elseif dualProbe_flag == 0 & summaryTable.spk_flag(sessionRowIdx) == 1 & summaryTable.dmfc_flag(sessionRowIdx) == 1
        label{sessionIdx,1} = 'dmfc';
        
    elseif dualProbe_flag == 1 & sum(summaryTable.dmfc_flag(sessionRowIdx) == 1) == 2
        label{sessionIdx,1} = 'dmfc_dmfc';
        
    elseif dualProbe_flag == 1 & sum(summaryTable.acc_flag(sessionRowIdx) == 1) == 2
        label{sessionIdx,1} = 'acc_acc';
        
    elseif dualProbe_flag == 1 & sum(summaryTable.acc_flag(sessionRowIdx) == 1) == 1
        label{sessionIdx,1} = 'dmfc_acc';
        
    else
        label{sessionIdx,1} = 'beh';
    end
    
    monkey{sessionIdx,1} = dajo_datamap.animalInfo(sessionIdx).monkey;
    
end


sessions_all = 1:size(dajo_datamap,1);
sessions_da = find(strcmp(monkey,'darwin'));
sessions_jo = find(strcmp(monkey,'joule'));

inputSession_all = {sessions_all, sessions_da, sessions_jo};
inputLabel_all = {'all','da','jo'};

for cat = 1:3
    clear inputSession_cat n_acc_only n_dmfc_only n_dmfc_dmfc n_acc_acc n_dmfc_acc n_beh_only
    
    inputSession_cat = inputSession_all{cat};
    
    n_acc_only = sum(strcmp(label(inputSession_cat),'acc'));
    n_dmfc_only = sum(strcmp(label(inputSession_cat),'dmfc'));
    n_dmfc_dmfc = sum(strcmp(label(inputSession_cat),'dmfc_dmfc'));
    n_acc_acc = sum(strcmp(label(inputSession_cat),'acc_acc'));
    n_dmfc_acc = sum(strcmp(label(inputSession_cat),'dmfc_acc'));
    n_beh_only = sum(strcmp(label(inputSession_cat),'beh'));
    
    figure('Renderer', 'painters', 'Position', [100 100 300 300]);
    donut([n_beh_only,n_dmfc_only,n_acc_only,n_dmfc_acc,n_dmfc_dmfc,n_acc_acc],...
        {'Behavior','DMFC','ACC','DMFC-ACC','DMFC-DMFC','ACC-ACC'});
    title(inputLabel_all{cat})
    
end


