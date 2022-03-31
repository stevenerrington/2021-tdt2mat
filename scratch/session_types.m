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

end

clear n_acc_only n_dmfc_only n_dmfc_dmfc n_acc_acc n_dmfc_acc n_beh_only

n_acc_only = sum(strcmp(label,'acc'));
n_dmfc_only = sum(strcmp(label,'dmfc'));
n_dmfc_dmfc = sum(strcmp(label,'dmfc_dmfc'));
n_acc_acc = sum(strcmp(label,'acc_acc'));
n_dmfc_acc = sum(strcmp(label,'dmfc_acc'));
n_beh_only = sum(strcmp(label,'beh'));



donut([n_beh_only,n_dmfc_only,n_acc_only,n_dmfc_acc,n_dmfc_dmfc,n_acc_acc],...
    {'Behavior','DMFC','ACC','DMFC-ACC','DMFC-DMFC','ACC-ACC'})%,...
    %{[1 0 0],[1 0 0],[1 0 0],[1 0 0],[1 0 0],[1 0 0]})
