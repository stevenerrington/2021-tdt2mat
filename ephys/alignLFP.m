function tdtLFP = alignLFP(trialEventTimes,tdtLFP, alignmentWindow)

fnames = fieldnames(trialEventTimes);
alignmentEvents = fnames(1:length(fnames)-3);
nEvents = length(alignmentEvents);

channelNames = fieldnames(tdtLFP.data);
nChannels = length(channelNames);

alignTemp = cell(nChannels,length(alignmentEvents));

parfor channelIdx = 1:nChannels
    channel = channelNames{channelIdx};
    fprintf(['Aligning LFP for ' channel '... \n'])
    
    for alignmentIdx = 1:nEvents
        alignmentName = alignmentEvents{alignmentIdx};
        
        alignmentTimes = trialEventTimes.(alignmentName);
        nTrials = length(alignmentTimes);
        
        for trl = 1:nTrials
            
            if isnan(alignmentTimes(trl))
                
                alignTemp{channelIdx,alignmentIdx}(trl,:) = nan(1,range(alignmentWindow));
                
            else
                idx_1 = H_T2S(alignmentTimes(trl), G_FS('slow')) + alignmentWindow(1);
                idx_2 = H_T2S(alignmentTimes(trl), G_FS('slow')) + alignmentWindow(2)-1;
                
                alignTemp{channelIdx,alignmentIdx}(trl,:) = tdtLFP.data.(channel)...
                    (idx_1:idx_2);
                
            end
            
        end
        
    end
end


for channelIdx = 1:nChannels
    channel = channelNames{channelIdx};
    
    for alignmentIdx = 1:nEvents
        alignmentName = alignmentEvents{alignmentIdx};

        tdtLFP.aligned.(channel).(alignmentName) = ...
            alignTemp{channelIdx,alignmentIdx};
    end
end