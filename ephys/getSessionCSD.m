function CSDanalysis = getSessionCSD(tdtLFP, window)

alignNames = {'target','tone'};

for alignIdx = 1:length(alignNames)
    
    alignName = alignNames{alignIdx};

    % Contact mapping
    channelNames = fieldnames(tdtLFP.data);
    CSDanalysis.contactMap.nContacts = length(channelNames);
    
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
    
    CSDanalysis.(alignName).all =...
        SUITE_LAM(CSDanalysis.(alignName).CSDarray);
    
    CSDanalysis.(alignName).window = window;
    
end

end



