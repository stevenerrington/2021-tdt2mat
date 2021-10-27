function tdtLFP = alignLFP(trialEventTimes,tdtLFP)

fnames = fieldnames(trialEventTimes);
alignmentEvents = fnames(1:6);

channelNames = fieldnames(tdtLFP.data);
nChannels = length(tdtLFP.info.channels);

alignmentWindow = [-1000 2000];

tdtLFP.aligned = [];

for channelIdx = 1:nChannels
    channel = channelNames{channelIdx};
    
    for alignmentIdx = 1:length(alignmentEvents)
        alignmentName = alignmentEvents{alignmentIdx};
        
        alignmentTimes = trialEventTimes.(alignmentName);
        
        for trl = 1:length(alignmentTimes)
            
            if isnan(alignmentTimes(trl))
                
                tdtLFP.aligned.(channel).(alignmentName)(trl,:) = nan(1,range(alignmentWindow));
                
            else
                idx_1 = H_T2S(alignmentTimes(trl), G_FS('slow')) + alignmentWindow(1);
                idx_2 = H_T2S(alignmentTimes(trl), G_FS('slow')) + alignmentWindow(2)-1;

                tdtLFP.aligned.(channel).(alignmentName)(trl,:) = ...
                    tdtLFP.data.(channel)...
                    (idx_1:idx_2);
            end
            
        end
        
    end
end











% TEST FIGURES
% 
% figure;
% subplot(2,1,1)
% plot(alignmentWindow(1):alignmentWindow(2)-1,...
%     nanmean(tdtLFP.aligned.LFP_9.target(ttx.nostop.all.all,:)))
% vline(0,'k')
% vline(find( nanmean(tdtLFP.aligned.LFP_9.target(ttx.nostop.all.all,:)) == max( nanmean(tdtLFP.aligned.LFP_9.target(ttx.nostop.all.all,:))))+alignmentWindow(1),'r')
% 
% subplot(2,1,2)
% plot(alignmentWindow(1):alignmentWindow(2)-1,...
%     nanmean(tdtLFP.aligned.LFP_9.target(ttx.canceled.all.all,:)))
% vline(0,'k')
% vline(find( nanmean(tdtLFP.aligned.LFP_9.target(ttx.canceled.all.all,:)) == max( nanmean(tdtLFP.aligned.LFP_9.target(ttx.canceled.all.all,:))))+alignmentWindow(1),'r')
% 








