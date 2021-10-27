clear all
clc
getColors


%% Get online ephys data log
ephysLog = importOnlineEphysLog;
dataDir = 'C:\Users\Steven\Desktop\TDT convert\cmandMat';
timeWin = [-1000 2000];
plotWin = [-100:600];
sessionList = ephysLog.Session(strcmp(ephysLog.DMFC,'1') & strcmp(ephysLog.UseFlag,'1'));

parfor ii = 1:length(sessionList)
    try
        data = parload([dataDir '\' sessionList{ii}]);
        fprintf([sessionList{ii} '\n'])
        [ttx, ttx_history, trialEventTimes] = processSessionTrials...
            (data.Behavior.stateFlags_, data.Behavior.Infos_);
        [ttm] = processTrialMatching(data.Behavior.Stopping, ttx, trialEventTimes);
        
        tdtSpk_aligned = alignSDF...
            (trialEventTimes, data.Behavior.Infos_, data.Spikes, timeWin);
        
        names = fieldnames( tdtSpk_aligned ); DSPsubStr = 'DSP';
        DSPstruct = rmfield( tdtSpk_aligned, names( find( cellfun( @isempty, strfind( names , DSPsubStr ) ) ) ) );
        DSPnames = fieldnames(DSPstruct);
        
        for neuronIdx = 1:length(DSPnames)
            
            figure('Renderer', 'painters', 'Position', [100 100 600 300]);
            
            ssrt1 = data.Behavior.Stopping.inh_SSD(2) + data.Behavior.Stopping.ssrt.integrationWeighted;
            ssrt2 = data.Behavior.Stopping.inh_SSD(3) + data.Behavior.Stopping.ssrt.integrationWeighted;
            ssrt3 = data.Behavior.Stopping.inh_SSD(4) + data.Behavior.Stopping.ssrt.integrationWeighted;
            
            win1 = round(1000+ssrt1 + plotWin);
            win2 = round(1000+ssrt2 + plotWin);
            win3 = round(1000+ssrt3 + plotWin);
            
            
            ssd1_c_plot = plot(plotWin,nanmean(tdtSpk_aligned.(DSPnames{neuronIdx}).target(ttm.C.C{2},win1)),...
                'color',colors.canceled);
            hold on
            ssd1_go_plot = plot(plotWin,nanmean(tdtSpk_aligned.(DSPnames{neuronIdx}).target(ttm.C.GO{2},win1)),...
                'color',colors.nostop);
            
            ssd2_c_plot = plot(plotWin,nanmean(tdtSpk_aligned.(DSPnames{neuronIdx}).target(ttm.C.C{3},win2)),...
                'color',colors.canceled);
            hold on
            ssd2_go_plot = plot(plotWin,nanmean(tdtSpk_aligned.(DSPnames{neuronIdx}).target(ttm.C.GO{3},win2)),...
                'color',colors.nostop);
            
            ssd3_c_plot = plot(plotWin,nanmean(tdtSpk_aligned.(DSPnames{neuronIdx}).target(ttm.C.C{4},win3)),...
                'color',colors.canceled);
            hold on
            ssd3_go_plot = plot(plotWin,nanmean(tdtSpk_aligned.(DSPnames{neuronIdx}).target(ttm.C.GO{4},win3)),...
                'color',colors.nostop);
            
            ssd1_c_plot.Color(4) = 0.25; ssd1_go_plot.Color(4) = 0.25;
            ssd2_c_plot.Color(4) = 0.6; ssd2_go_plot.Color(4) = 0.6;
            ssd3_c_plot.Color(4) = 1; ssd3_go_plot.Color(4) = 1;
            
            
            xlim([-100 600]); vline(0,'k'); 

            
            xlabel('Time from SSRT (ms)'); ylabel('Firing rate (spks/sec)');
            legend({'C','NS'},'location','northwest')
            title([sessionList{ii} '--' DSPnames{neuronIdx}])
            
            
            set(gcf,'Units','inches');
            screenposition = get(gcf,'Position');
            set(gcf,...
                'PaperPosition',[0 0 screenposition(3:4)],...
                'PaperSize',[screenposition(3:4)]);
            saveas(gcf,['C:\Users\Steven\Desktop\ACC_conflictNeurons\' sessionList{ii} '-' DSPnames{neuronIdx} '.jpg'])
            close gcf
        end
        
        
        
    catch
       fprintf([sessionList{ii} ' ***ERROR**** \n'])

    end
    
    
    
end


