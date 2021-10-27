function P_LINEAR_LFP(linearLFP, nChannels, channelPlotIdx, f, ax)


hold off;
set(0, 'currentfigure', f);
set(f, 'currentaxes', ax);
hold on;

spaceOffset = linspace(1,nChannels,nChannels);
spaceOffset = spaceOffset(channelPlotIdx);
scaleFactor = 100;

linearLFP = linearLFP(channelPlotIdx,:);

for ii = 1:size(linearLFP,1)
    linearLFP(ii,:) = ((linearLFP(ii,:) - linearLFP(ii,1))*...
        scaleFactor)+spaceOffset(ii);
end

for ii = 1 : length(channelPlotIdx)
    i = channelPlotIdx(ii);
    if isEven(i)
        labels{ii} = num2str(i);
    else
        labels{ii} = [];
    end
end



plot([-1000:1999],linearLFP,'k','LineWidth',1.5)
set(gca,'ydir', 'rev', 'xlim', [-100 250], 'ylim', [min(channelPlotIdx)-1 max(channelPlotIdx)+1],...
    'ytick', spaceOffset, 'yticklabel', labels, ...
    'xtick', -100:50:250)
xlabel('Time from event (ms)');
ylabel('Lower <- (Depth) -> Upper');

end
