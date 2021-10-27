function CSDanalysis = getCSD_multiple(tdtLFP, window)

alignNames = {'target','tone'};

for alignIdx = 1:length(alignNames)
    
    alignName = alignNames{alignIdx};

    % Contact mapping
    CSDanalysis.contactMap.nContacts = 32;
    channelNames = fieldnames(tdtLFP.data);
    
    for channelIdx = 1:CSDanalysis.contactMap.nContacts
        channel = channelNames{channelIdx};
        fprintf(['Aligning LFP for CSD on channel ' channel '... \n'])
        
        CSDanalysis.(alignName).CSDarray(:,:,channelIdx) =...
            tdtLFP.aligned.(channel).(alignName)(:,:);
        CSDanalysis.(alignName).linearLFP(channelIdx,:) =...
            nanmean(CSDanalysis.(alignName).CSDarray(:,:,channelIdx));
    end
    
    CSDanalysis.(alignName).CSDarray =...
        permute(CSDanalysis.(alignName).CSDarray, [3 2 1]);
    CSDanalysis.(alignName).CSDarray =...
        CSDanalysis.(alignName).CSDarray(:,window,:);
    
    fprintf(['Performing CSD analysis aligned on %s.\n'], alignName)
    
    CSDanalysis.(alignName).CSD = D_CSD_BASIC(CSDanalysis.(alignName).CSDarray,...
        'cndt', 0.0004, 'spc', 0.15);
    
    CSDanalysis.(alignName).window = window;
    
end

end



