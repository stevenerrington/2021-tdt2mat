function P_LINEAR_LFP(tdtLFP,nChannels,f, ax)


spaceOffset = linspace(1,32,32);
scaleFactor = 100;

channelPlotIdx = 1:32;
channelNames = fieldnames(tdtLFP.data);

for ii = 1:length(channelPlotIdx)
    channelIdx = channelPlotIdx(ii);
    
    clear channelData
    channelData = nanmean(tdtLFP_aligned.aligned.(channelNames{channelIdx})...
        .target(ttx.nostop.all.all,:));
    
    test(ii,:) = ((channelData-channelData(1))*scaleFactor)+...
        spaceOffset(channelIdx);
    
    
end


plot([-1000:1999],test,'k','LineWidth',1)
set(gca,'ydir', 'rev', 'xlim', [-100 250], 'ylim', [0 33],...
    'ytick', spaceOffset, ...
    'xtick', -100:50:250)


end
%'yticklabel', labels, ...