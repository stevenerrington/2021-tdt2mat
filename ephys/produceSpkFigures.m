function produceSpkFigures(dirs, outFilename, tdtInfo, sessionInfo, ephysLog, logIdx, tdtSpk, tdtSpk_aligned, Infos, ttx, stopSignalBeh)


%% Preprocessing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
names = fieldnames( tdtSpk );
DSPsubStr = 'DSP';
DSPstruct = rmfield( tdtSpk, names( find( cellfun( @isempty, strfind( names , DSPsubStr ) ) ) ) );
DSPnames = fieldnames(DSPstruct);
WAVsubStr = 'WAV';
WAVstruct = rmfield( tdtSpk, names( find( cellfun( @isempty, strfind( names , WAVsubStr ) ) ) ) );
WAVnames = fieldnames(WAVstruct);

getColors


% Load JRclust data
processedDir = dirs.processedDir;
jrcResFile = fullfile(processedDir,'JRclust','master_jrclust_res.mat');
res = load(jrcResFile);

for neuronIdx = 1:length(DSPnames)
    %% Figure  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Subplot mapping
    % 01 02 03 04 05 06 07 08 09 10
    % 11 12 13 14 15 16 17 18 19 20
    % 21 22 23 24 25 26 27 28 29 30
    % 31 32 33 34 35 36 37 38 39 40
    % 41 42 43 44 45 46 47 48 49 50
    % 51 52 53 54 55 56 57 58 59 60
    % 61 62 63 64 65 66 67 68 69 70
   
    % Open figure window
    f_h = figure('Renderer', 'painters', 'Position', [100 100 1500 800]);
    fprintf(['Plotting DSP %i of %i for session ' outFilename '. \n'], neuronIdx, length(DSPnames))
    
    % Calculate required variables
    maxTime = find(res.meanWfGlobalRaw(:,res.clusterSites (neuronIdx),neuronIdx) == min(res.meanWfGlobalRaw(:,res.clusterSites (neuronIdx),neuronIdx)));
    minTime = find(res.meanWfGlobalRaw(:,res.clusterSites (neuronIdx),neuronIdx) == max(res.meanWfGlobalRaw(:,res.clusterSites (neuronIdx),neuronIdx)));
    spkWidth = (round(abs(maxTime-minTime)*(G_FS('fast'))/1000));
    
    %% Neuron Information
    ax = subplot(7, 10,[1 2 11 12]);
    
    text(-0.5,1.2,[outFilename ' / ' DSPnames{neuronIdx}], 'FontSize',15, 'Interpreter', 'none');
    text(-0.5,1.05,['Monkey: ' sessionInfo.monkey ' / Date: ' sessionInfo.date ' / Site: ' char(ephysLog.AP_Grid(logIdx)) ' , ' char(ephysLog.ML_Grid(logIdx))],'FontWeight','bold','FontSize',15, 'Interpreter', 'none');
    text(-0.5,0.8,'Spike Sorting Information','FontWeight','bold');
    text(-0.5,0.7,['Spike Width (Peak to Trough): ' int2str(spkWidth) '\mus']);
    text(-0.5,0.6,['N Spikes: ' int2str(res.unitCount(neuronIdx))]);
    text(-0.5,0.5,['ISI Ratio: ' num2str(res.unitISIRatio(neuronIdx),3)]);
    text(-0.5,0.4,['Signal-to-Noise Ratio: ' num2str(res.unitSNR(neuronIdx),3)]);
    text(-0.5,0.3,['L-Ratio: ' num2str(res.unitLRatio(neuronIdx),3)]);
    
    set ( ax, 'visible', 'off')
    
    %% Session Information
    ax = subplot(7, 10,[21 22 31 32]);
    
    text(-0.5,1,'Session Information','FontWeight','bold');
    text(-0.5,0.9,['Session: ' outFilename],'Interpreter', 'none');
    text(-0.5,0.8,['TDT Blockname: ' tdtInfo.blockname],'Interpreter', 'none');
    text(-0.5,0.7,['Date: ' tdtInfo.date]);
    text(-0.5,0.6,['Duration: ' tdtInfo.duration]);
    text(-0.5,0.4,['Electrode: ' ephysLog.Electrode_brand{logIdx} ' ' ephysLog.Electrode_Serial{logIdx}]);
    text(-0.5,0.3,['Location: ' [sessionInfo.area ': AP, '] char(ephysLog.AP_Grid(logIdx))...
        '; ML, ' char(ephysLog.ML_Grid(logIdx)) '']);
    text(-0.5,0.2,['Electrode Settle Time: ' ephysLog.ElectrodeSettleTime{logIdx}]);
    text(-0.5,0.1,['Electrode Settle Depth: ' ephysLog.ElectrodeSettleDepth{logIdx}]);
    set ( ax, 'visible', 'off')
    
    
    %% Waveform
    ax = subplot(7, 10, [3 4 13 14]);
% 
%     meanWav = nanmean(tdtSpk.(WAVnames{neuronIdx}));
%     ciplot(meanWav-sem(tdtSpk.(WAVnames{neuronIdx})),...
%         meanWav+sem(tdtSpk.(WAVnames{neuronIdx})),1:length(meanWav),'k'); hold on

    meanWav = res.meanWfGlobalRaw(:,res.clusterSites (neuronIdx),neuronIdx);
    plot(meanWav,'k'); hold on
    
    box off; xlim([1 61]); title('Waveform')
    set ( ax, 'visible', 'off')
    
    %% Inter-spike interval
    ax = subplot(7, 10, [6 7 16 17]);
    ISI = [];
    ISI = diff(res.spikesByCluster{neuronIdx});
    histogram([ISI],-1:1:50,'LineStyle','None')
    box off; xlabel('ISI (ms)'); ylabel('Frequency')
        
    %% Session SDF    
    ax = subplot(7, 10, [9 10 19 20]);      
    SessionSDF = SpkConvolver (tdtSpk.(DSPnames{neuronIdx}), round(max(Infos.InfosEnd_)+1000), 'PSP');
    plot((1:length(SessionSDF))/1000,SessionSDF,'k'); hold on
    plot((1:length(SessionSDF))/1000,movmean(SessionSDF,10000),'g-') % 10 Second

    hline(mean(SessionSDF),'r-'); xlabel('Session Time (secs)'); ylabel('Firing rate (spks/s)')
    xlim([1 max((1:length(SessionSDF))/1000)])
        
    %% Spike amplitude
    ax = subplot(13, 10, [57 58 59 60  67 68 69 70  77 78 79 80]);
    clear spkIdx; spkIdx = find(res.spikeClusters == neuronIdx);
    scatter(tdtSpk.(DSPnames{neuronIdx}),abs(double(res.spikeAmps(spkIdx))),...
        2,'k','filled','MarkerFaceAlpha',0.5); hold on; 
    
    plot(tdtSpk.(DSPnames{neuronIdx}),movmean(abs(double(res.spikeAmps(spkIdx))),100),'g')
    xlim([1 max(Infos.TaskEnd_)])
    box off; xlabel('Time (ms)'); ylabel('Spike Amplitude (mv)')
    hline(mean(abs(res.spikeAmps(spkIdx))),'r-')    
    if max(abs(double(res.spikeAmps(spkIdx)))) > 300
        ylim([0 300])
    end
    
    
    %% Similarity matrix
    ax = subplot(13, 10, [53 54 55 63 64 73 74]);
    simMatrix = imagesc(1:length(DSPnames),1:length(DSPnames),res.waveformSim);
    xticks([1:length(DSPnames)]);yticks([1:length(DSPnames)]);
    
    clear DSPlabel
    for ii = 1:length(DSPnames)
        if mod(ii,2) == 1; DSPlabel{ii} = []; else DSPlabel{ii} = DSPnames{ii}; end
    end
    
    xticklabels(DSPlabel); yticklabels(DSPlabel); xtickangle(45)
    colorbar; 
    
    %% SDF
    subplot(7,10,[51 52 61 62]); hold on
    plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPnames{neuronIdx}).target(ttx.nostop.all.all,:)),'color',colors.nostop)
    plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPnames{neuronIdx}).target(ttx.noncanceled.all.all,:)),'color',colors.noncanc)
    plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPnames{neuronIdx}).target(ttx.canceled.all.all,:)),'color',colors.canceled,'lineWidth',1.5)
    xlim([-250 500]); vline(0,'k'); xlabel('Time from Target (ms)'); ylabel('Firing rate (spks/sec)');
    legend({'NS','NC','C'},'location','northwest')
 
    % Saccade aligned
    subplot(7,10,[53 54 63 64]); hold on
    plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPnames{neuronIdx}).stopSignal(ttx.noncanceled.all.all,:)),'color',colors.noncanc)
    plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPnames{neuronIdx}).stopSignal(ttx.canceled.all.all,:)),'color',colors.canceled,'lineWidth',1.5)
    xlim([-250 500]); vline(0,'k'); vline(stopSignalBeh.ssrt.integrationWeighted,'k--'); xlabel('Time from Stop Signal (ms)')
  
    % Stop-Signal aligned
    subplot(7,10,[55 56 65 66]); hold on
   plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPnames{neuronIdx}).saccade(ttx.nostop.all.all,:)),'color',colors.nostop)
    plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPnames{neuronIdx}).saccade(ttx.noncanceled.all.all,:)),'color',colors.noncanc)
    xlim([-250 500]); vline(0,'k'); xlabel('Time from Saccade (ms)')
       
    % Tone aligned
    subplot(7,10,[57 58 67 68]); hold on
    plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPnames{neuronIdx}).tone(ttx.nostop.all.all,:)),'color',colors.nostop)
    plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPnames{neuronIdx}).tone(ttx.noncanceled.all.all,:)),'color',colors.noncanc)
    plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPnames{neuronIdx}).tone(ttx.canceled.all.all,:)),'color',colors.canceled,'lineWidth',1.5)
    xlim([-250 500]); vline(0,'k'); xlabel('Time from Tone (ms)')
    
    % Reward aligned
    subplot(7,10,[59 60 69 70]); hold on
    plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPnames{neuronIdx}).reward(ttx.nostop.all.all,:)),'color',colors.nostop)
    plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPnames{neuronIdx}).reward(ttx.noncanceled.all.all,:)),'color',colors.noncanc)
    plot(-1000:2000,nanmean(tdtSpk_aligned.(DSPnames{neuronIdx}).reward(ttx.canceled.all.all,:)),'color',colors.canceled,'lineWidth',1.5)
    xlim([-250 500]); vline(0,'k'); xlabel('Time from Reward (ms)')
    
    %% Figure output
    
    figureOutFolder = [dirs.processedDir,'\figures'];
    set(gcf,'Units','inches');
    screenposition = get(gcf,'Position');
    set(gcf,...
        'PaperPosition',[0 0 screenposition(3:4)],...
        'PaperSize',[screenposition(3:4)]);
    saveas(gcf,[dirs.figureFolder '\' outFilename '-' DSPnames{neuronIdx} '.jpg'])
    close gcf
    
end