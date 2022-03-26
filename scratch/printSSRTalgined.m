clear all; clc
load('2021-dajo-datamap')
getColors
dirs.masterData = 'S:\Users\Current Lab Members\Steven Errington\2021_DaJo\mat\';

sessionIdxList = sort(unique([127]));

for logIdx = 1:size(sessionIdxList,2)
    sessionIdx = sessionIdxList(logIdx);
    
    % Define data directories and files
    beh_file = dajo_datamap.behInfo(sessionIdx).dataFile;
    spk_file = dajo_datamap.neurophysInfo{sessionIdx}.spkFile...
        {find(strcmp(dajo_datamap.neurophysInfo{sessionIdx}.area,...
        'DMFC'),1)};  % Sessions may have multiple pens.
    
    % Load in spike and behavioral data
    beh_data = load([dirs.masterData beh_file]);
    spk_data = load([dirs.masterData spk_file]);
    
    % Align spikes
    [ttx, ~, trialEventTimes] = processSessionTrials...
        (beh_data.events.stateFlags_, beh_data.events.Infos_);
    [stopSignalBeh, RTdist] = extractStopBeh(beh_data.events.stateFlags_,beh_data.events.Infos_,ttx);
    [valueBeh] = extractValueBeh(beh_data.events.Infos_,ttx);
    [valueStopSignalBeh, valueRTdist] = extractValueStopBeh(beh_data.events.stateFlags_,beh_data.events.Infos_,ttx);
    [ttm] = processTrialMatching(stopSignalBeh, ttx, trialEventTimes);
    
    tdtSpk_aligned = alignSDF...
        (trialEventTimes(:,[4,5,8]), beh_data.events.Infos_, spk_data.spikes.time, [-1000 2000]);
    
    
    clusters.dsp = fieldnames(spk_data.spikes.time);
    events = fieldnames(tdtSpk_aligned.(clusters.dsp{1}));
    trialTypes = {'C','GO'};
    valueTypes = {'all','hi','lo'};
    
    for clusterIdx = 1:length(clusters.dsp)
        %% Organise data
        % Event aligned SDF
        for eventIdx = 1:length(events)
            for trialTypeIdx = 1:length(trialTypes)
                for ssdIdx = 1:length(ttm.C.(trialTypes{trialTypeIdx}))
                    eventSDF.(events{eventIdx}).(trialTypes{trialTypeIdx}).allSSD(ssdIdx,:) =...
                        nanmean(tdtSpk_aligned.(clusters.dsp{clusterIdx}).(events{eventIdx})...
                        (ttm.C.(trialTypes{trialTypeIdx}){ssdIdx},:));
                end
            end
        end
        
        for eventIdx = 1:length(events)
            for trialTypeIdx = 1:length(trialTypes)
                eventSDF.(events{eventIdx}).(trialTypes{trialTypeIdx}).matchedSSD =...
                    nanmean(eventSDF.(events{eventIdx}).(trialTypes{trialTypeIdx}).allSSD);
            end
        end
        
        
        % Find middle SSD
        [~,midSSDidx] = min(abs(stopSignalBeh.inh_pnc-0.5));
        
        %% Generate figure
        f_h = figure('Renderer', 'painters', 'Position', [100 100 1200 300]);

        % SSRT Aligned (conflict) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ax = subplot(1,3,1); hold on
        
        plot(-1000:2000,eventSDF.ssrt.C.allSSD(midSSDidx-1,:), 'color', [colors.canceled 0.3])
        plot(-1000:2000,eventSDF.ssrt.C.allSSD(midSSDidx,:), 'color', [colors.canceled 0.6])
        plot(-1000:2000,eventSDF.ssrt.C.allSSD(midSSDidx+1,:), 'color', [colors.canceled 0.9])
        
        plot(-1000:2000,eventSDF.ssrt.GO.allSSD(midSSDidx+1,:), 'color', [colors.nostop 0.9])
        plot(-1000:2000,eventSDF.ssrt.GO.allSSD(midSSDidx+1,:), 'color', [colors.nostop 0.9])
        plot(-1000:2000,eventSDF.ssrt.GO.allSSD(midSSDidx+1,:), 'color', [colors.nostop 0.9])
        xlim([-200 600]); vline(0,'k')
        xlabel('Time from SSRT (ms)'); ylabel('FR (spks/sec)')
        title('Conflict Period')
        
        ymin = nanmin([eventSDF.ssrt.C.matchedSSD, eventSDF.ssrt.GO.matchedSSD,...
            eventSDF.reward.C.matchedSSD, eventSDF.reward.GO.matchedSSD])*0.9;
        
        ymax = nanmax([eventSDF.ssrt.C.matchedSSD, eventSDF.ssrt.GO.matchedSSD,...
            eventSDF.reward.C.matchedSSD, eventSDF.reward.GO.matchedSSD])*1.1;
        % SSRT Aligned (longer) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ax = subplot(1,3,2); hold on
        plot(-1000:2000,eventSDF.ssrt.C.matchedSSD, 'color', colors.canceled)
        plot(-1000:2000,eventSDF.ssrt.GO.matchedSSD, 'color', colors.nostop)
        xlim([-200 600]); ylim([ymin ymax]); vline(0,'k')
        xlabel('Time from SSRT (ms)'); ylabel('FR (spks/sec)')
        title('Goal Maintenance & Timing Period')
        
        % Tone Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ax = subplot(1,3,3); hold on
        plot(-1000:2000,eventSDF.reward.C.matchedSSD, 'color', colors.canceled)
        plot(-1000:2000,eventSDF.reward.GO.matchedSSD, 'color', colors.nostop)
        xlim([-600 200]); ylim([ymin ymax]); vline(0,'k'); vline(-500,'k')
        xlabel('Time from Reward (ms)');
        title([dajo_datamap.neurophysInfo{sessionIdx}.spkFile{1}(1:end-8) ' - ' clusters.dsp{clusterIdx} ])
        
        
        
        
        %% Figure out
        figureOutFolder = 'S:\Users\Current Lab Members\Steven Errington\temp\dajo_datacuration\SSRT_SPK-figures\_vector';
        set(gcf,'Units','inches');
        screenposition = get(gcf,'Position');
        set(gcf,...
            'PaperPosition',[0 0 screenposition(3:4)],...
            'PaperSize',[screenposition(3:4)]);
        saveas(gcf,[figureOutFolder '\' dajo_datamap.neurophysInfo{sessionIdx}.spkFile{1}(1:end-8) ' - ' clusters.dsp{clusterIdx}  '.pdf'])
        close gcf
        
    end
end
