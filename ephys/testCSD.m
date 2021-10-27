function CSDanalysis = getSessionCSD(tdtLFP, window, trials)

clear CSDanalysis trials


% Contact mapping
contactMap.nContacts = 32; contactMap.midContact = contactMap.nContacts/2; contactMap.buffer = 0;
contactMap.upperContacts = 1:midContact+contactMap.buffer;  
contactMap.lowerContacts = contactMap.midContact-contactMap.buffer:contactMap.nContacts;


for channelIdx = 1:nChannels
    channel = channelNames{channelIdx};
    fprintf(['Aligning LFP for CSD on channel ' channel '... \n'])

    CSDanalysis.CSDarray(:,:,channelIdx) = tdtLFP.aligned.(channel).target(trials,:);    
    CSDanalysis.linearLFP(channelIdx,:) = nanmean(CSDanalysis.CSDarray(:,:,channelIdx));
end

CSDanalysis.CSDarray = permute(CSDanalysis.CSDarray, [3 2 1]);
CSDanalysis.CSDarray = CSDanalysis.CSDarray(:,window,:);

CSDanalysis.all = SUITE_LAM(CSDanalysis.CSDarray);
CSDanalysis.upper = SUITE_LAM(CSDanalysis.CSDarray(contactMap.upperContacts,:,:));
CSDanalysis.lower = SUITE_LAM(CSDanalysis.CSDarray(contactMap.lowerContacts,:,:));

end



