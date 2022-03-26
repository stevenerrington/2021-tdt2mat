
%% Clear environment
clear; clc;
dirs.masterData = 'S:\Users\Current Lab Members\Steven Errington\2021_DaJo\mat\';
dirs.outDir = 'S:\Users\Current Lab Members\Steven Errington\temp\dajo_ksSpkTable\';
load('2021-dajo-datamap.mat')
getColors

%% Get Session Information
% Get Ephys log and tidy
ephysLog = importOnlineEphysLogMaster;

% For each logged session
for logIdx = 1:size(ephysLog,1)
    try
    % Get the session number
    sessionIdx = str2num(ephysLog.SessionN{logIdx});
    penIdx = str2num(ephysLog.ProbeIdx{logIdx});
    
    fprintf('Analysing electrode %i of %i | %s.          \n',...
        logIdx,size(ephysLog,1),ephysLog.Session{logIdx});
    
    clearvars -except ephysLog dirs dajo_datamap logIdx sessionIdx penIdx colors
    % Define data directories and files
    beh_file = dajo_datamap.behInfo(sessionIdx).dataFile;
    spk_file = dajo_datamap.neurophysInfo{sessionIdx}.spkFile...
        {find(strcmp(dajo_datamap.neurophysInfo{sessionIdx}.spkFile,...
        [ephysLog.Session{logIdx} '-spk.mat']) == 1)};  % Sessions may have multiple pens.
    
    % Load in spike and behavioral data
    clear beh_data spk_data ttx trialEventTimes tdtSpk_aligned
    beh_data = load([dirs.masterData beh_file]);
    spk_data = load([dirs.masterData spk_file]);
    
    % Align spikes
    [ttx, ~, trialEventTimes] = processSessionTrials...
        (beh_data.events.stateFlags_, beh_data.events.Infos_);
    tdtSpk_aligned = alignSDF...
        (trialEventTimes(:,[3,4,6,7]), beh_data.events.Infos_, spk_data.spikes.time, [-1000 2000]);
    
    %%
    clear clusters
    clusters.dsp = fieldnames(spk_data.spikes.time);
    clusters.wav = fieldnames(spk_data.spikes.waveform);
    
    %%
    events = fieldnames(tdtSpk_aligned.(clusters.dsp{1}));
    trialTypes = {'canceled','noncanceled','nostop'};
    valueTypes = {'all','hi','lo'};
    
    for clusterIdx = 1:length(clusters.dsp)
        try
            %% Organise data
            % Event aligned SDF
            for eventIdx = 1:length(events)
                for trialTypeIdx = 1:length(trialTypes)
                    for valueTypeIdx = 1:length(valueTypes)
                        eventSDF.(events{eventIdx}).(trialTypes{trialTypeIdx}).(valueTypes{valueTypeIdx}) =...
                            nanmean(tdtSpk_aligned.(clusters.dsp{clusterIdx}).(events{eventIdx})...
                            (ttx.(trialTypes{trialTypeIdx}).all.(valueTypes{valueTypeIdx}),:));
                    end
                end
            end
            
            % Waveform
            wf_mean = nanmean(spk_data.spikes.waveform.(clusters.wav{clusterIdx}));
            wf_ci = [wf_mean + (2*nanstd(spk_data.spikes.waveform.(clusters.wav{clusterIdx}))) ;...
                wf_mean - (2*nanstd(spk_data.spikes.waveform.(clusters.wav{clusterIdx})))];
            
            wf_min = find(wf_mean == min(wf_mean));
            wf_max = find(wf_mean == max(wf_mean));
            wf_width = round(abs(wf_max-wf_min)*(24414.14/1000));
            
            % Amplitude x time
            amp_time = [spk_data.spikes.amplitudes.(clusters.dsp{clusterIdx}),...
                spk_data.spikes.time.(clusters.dsp{clusterIdx})];
            
            % unaligned SDF
            raw_sdf = SpkConvolver (spk_data.spikes.time.(clusters.dsp{clusterIdx}),...
                round(max(beh_data.events.Infos_.InfosEnd_)+10000), 'PSP');
            
            %% Generate figure
            f_h = figure('Renderer', 'painters', 'Position', [100 100 1500 800]);
            ax = subplot(10, 10,[1 2 11 12]);
            
            % Session information and text %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            text(-0.5,1.1,[ephysLog.Session{logIdx} ' / ' clusters.dsp{clusterIdx}], 'FontSize',15, 'Interpreter', 'none');
            text(-0.5,0.85,['Monkey: ' ephysLog.Monkey{logIdx} ' / Date: '...
                ephysLog.Date{logIdx} ' / Site: ' char(ephysLog.AP_Grid(logIdx))...
                ' , ' char(ephysLog.ML_Grid(logIdx))],'FontWeight','bold','FontSize',15, 'Interpreter', 'none');
            text(-0.5,0.6,'Spike Sorting Information','FontWeight','bold');
            text(-0.5,0.45,['Spike Width (Peak to Trough): ' int2str(wf_width) '\mus']);
            text(-0.5,0.3,['N Spikes: ' int2str(length(spk_data.spikes.time.(clusters.dsp{clusterIdx})))]);
            text(-0.5,0.15,['Sort Method: Kilosort | Phy']);
            set ( ax, 'visible', 'off')
            
            % Session Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ax = subplot(10, 10,[21 22 31 32]);
            
            text(-0.5,1,'Session Information','FontWeight','bold');
            text(-0.5,0.85,['Session: ' ephysLog.Session{logIdx}],'Interpreter', 'none');
            text(-0.5,0.7,['TDT Blockname: ' ephysLog.TDTfilename{logIdx}],'Interpreter', 'none');
            text(-0.5,0.55,['Date: ' dajo_datamap.sessionInfo(sessionIdx).date]);
            text(-0.5,0.4,['Duration: ' int2str(dajo_datamap.sessionInfo(sessionIdx).duration) ' seconds']);
            text(-0.5,0.25,['Electrode: ' ephysLog.Electrode_brand{logIdx} ' ' ephysLog.Electrode_Serial{logIdx}]);
            text(-0.5,0.1,['Location: ' [dajo_datamap.neurophysInfo{sessionIdx}.area{penIdx} ': AP, '] char(ephysLog.AP_Grid(logIdx))...
                '; ML, ' char(ephysLog.ML_Grid(logIdx)) '']);
            text(-0.5,-0.05,['Electrode Settle Time: ' ephysLog.ElectrodeSettleTime{logIdx}]);
            text(-0.5,-0.20,['Electrode Settle Depth: ' ephysLog.ElectrodeSettleDepth{logIdx}]);
            set ( ax, 'visible', 'off')
            
            % Waveform %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ax = subplot(10, 10, [4 5 14 15]);
            plot(wf_mean,'k','LineWidth',2); hold on
            box off; title('Waveform')
            set ( ax, 'visible', 'off')
            
            % Inter-spike interval %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ax = subplot(10, 10, [24 25 34 35]);
            ISI = [];
            ISI = diff(spk_data.spikes.time.(clusters.dsp{clusterIdx}));
            histogram([ISI(ISI < 50)],0:2:50,'LineStyle','None','FaceColor','k')
            box off; xlabel('ISI (ms)'); ylabel('Frequency');
            
            % Session SDF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ax = subplot(10, 10, [7 8 9 10 17 18 19 20]);
            %   histogram(spk_data.spikes.time.(clusters.dsp{clusterIdx}),0:5000:dajo_datamap.sessionInfo(sessionIdx).duration*1000)
            %   yyaxis right
            plot((1:length(raw_sdf)),movmean(raw_sdf,10000),'k-') % 2 Second
            
            hline(mean(raw_sdf),'r-'); ylabel('Firing rate (spks/s)')
            xlim([1 dajo_datamap.sessionInfo(sessionIdx).duration*1000]); box off
            
            % Spike amplitude %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ax = subplot(10, 10, [27 28 29 30 37 38 39 40]);
            clear spkIdx;
            scatter(amp_time(:,2),amp_time(:,1),...
                0.5,'k','filled','MarkerFaceAlpha',0.1); hold on;
            plot(amp_time(:,2),movmean(amp_time(:,1),100),'k')
            xlim([1 dajo_datamap.sessionInfo(sessionIdx).duration*1000]); box off
            xlabel('Time (ms)'); ylabel('Spike Amplitude (a.u.)')
            ylim([quantile(amp_time(:,1),0.005) quantile(amp_time(:,1),0.995)])
            hline(mean(amp_time(:,1)),'r-')
            
            % Event aligned SDF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % - Standard trial comparisons
            h= subplot(10,10,[51 52 61 62]); hold on
            plot(-1000:2000,eventSDF.target.nostop.all,'color',colors.nostop)
            plot(-1000:2000,eventSDF.target.noncanceled.all,'color',colors.noncanceled)
            plot(-1000:2000,eventSDF.target.canceled.all,'color',colors.canceled)
            xlim([-200 600]); vline(0,'k'); xlabel('Time from Target (ms)'); ylabel('Firing rate (spks/sec)');
            legend({'NS','NC','C'},'location','northwest')
            h.XTick = [-200:100:600]; h.XMinorTick = 'on';
            
            h = subplot(10,10,[53 54 63 64]); hold on
            plot(-1000:2000,eventSDF.saccade.nostop.all,'color',colors.nostop)
            plot(-1000:2000,eventSDF.saccade.noncanceled.all,'color',colors.noncanceled)
            xlim([-200 600]); vline(0,'k'); xlabel('Time from Saccade (ms)');
            h.XTick = [-200:100:600]; h.XMinorTick = 'on'; legend off
            
            h = subplot(10,10,[55 56 65 66]); hold on
            plot(-1000:2000,eventSDF.stopSignal.canceled.all,'color',colors.canceled)
            plot(-1000:2000,eventSDF.stopSignal.noncanceled.all,'color',colors.noncanceled)
            xlim([-200 600]); vline(0,'k'); xlabel('Time from Stop-Signal (ms)');
            h.XTick = [-200:100:600]; h.XMinorTick = 'on'; legend off
            
            h = subplot(10,10,[57 58 59 60 67 68 69 70]); hold on
            plot(-1000:2000,eventSDF.tone.canceled.all,'color',colors.canceled)
            plot(-1000:2000,eventSDF.tone.noncanceled.all,'color',colors.noncanceled)
            plot(-1000:2000,eventSDF.tone.nostop.all,'color',colors.nostop)
            xlim([-200 1200]); vline([0 500],'k'); xlabel('Time from Tone (ms)');
            h.XTick = [-200:100:1200]; h.XMinorTick = 'on'; legend off
            
            % - value no-stop comparisons
            h = subplot(10,10,[71 72 81 82]); hold on
            pos = get(h, 'Position'); posnew = pos; posnew(2) = posnew(2) - 0.06; set(h, 'Position', posnew)
            plot(-1000:2000,eventSDF.target.nostop.hi,'color',colors.hiRew)
            plot(-1000:2000,eventSDF.target.nostop.lo,'color',colors.loRew)
            xlim([-200 600]); vline(0,'k'); xlabel('Time from Target (ms)'); ylabel('Firing rate (spks/sec)');
            legend({'High','Low'},'location','northwest')
            h.XTick = [-200:100:600]; h.XMinorTick = 'on';
            
            h = subplot(10,10,[73 74 83 84]); hold on
            pos = get(h, 'Position'); posnew = pos; posnew(2) = posnew(2) - 0.06; set(h, 'Position', posnew)
            plot(-1000:2000,eventSDF.saccade.nostop.hi,'color',colors.hiRew)
            plot(-1000:2000,eventSDF.saccade.nostop.lo,'color',colors.loRew)
            xlim([-200 600]); vline(0,'k'); xlabel('Time from Saccade (ms)');
            h.XTick = [-200:100:600]; h.XMinorTick = 'on'; legend off
            
            h = subplot(10,10,[75 76 77 78 79 80 85 86 87 88 89 90]); hold on
            pos = get(h, 'Position'); posnew = pos; posnew(2) = posnew(2) - 0.06; set(h, 'Position', posnew)
            plot(-1000:2000,eventSDF.tone.nostop.hi,'color',colors.hiRew)
            plot(-1000:2000,eventSDF.tone.nostop.lo,'color',colors.loRew)
            xlim([-200 2000]); vline([0 500],'k'); xlabel('Time from Tone (ms)');
            h.XTick = [-200:100:2000]; h.XMinorTick = 'on'; legend off
            
            
            %% Figure out
            figureOutFolder = 'S:\Users\Current Lab Members\Steven Errington\temp\dajo_datacuration\SPK-figures';
            set(gcf,'Units','inches');
            screenposition = get(gcf,'Position');
            set(gcf,...
                'PaperPosition',[0 0 screenposition(3:4)],...
                'PaperSize',[screenposition(3:4)]);
            saveas(gcf,[figureOutFolder '\' ephysLog.Session{logIdx} '-' clusters.dsp{clusterIdx} '.jpg'])
            close gcf
        catch
            figureOutFolder = 'S:\Users\Current Lab Members\Steven Errington\temp\dajo_datacuration\SPK-figures';
            f_h = figure('Renderer', 'painters', 'Position', [100 100 1500 800]);
            set(gcf,'Units','inches');
            screenposition = get(gcf,'Position');
            set(gcf,...
                'PaperPosition',[0 0 screenposition(3:4)],...
                'PaperSize',[screenposition(3:4)]);
            saveas(gcf,[figureOutFolder '\' ephysLog.Session{logIdx} '-' clusters.dsp{clusterIdx} '.jpg'])
            close gcf
        end
        
    end
    catch m 
        loop_errors{logIdx} = m;
    end
    
end