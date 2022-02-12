
%% Clear environment
clear; clc;
dirs.masterData = 'S:\Users\Current Lab Members\Steven Errington\2021_DaJo\mat\';
dirs.outDir = 'S:\Users\Current Lab Members\Steven Errington\temp\dajo_ksSpkTable\';
load('2021-dajo-datamap.mat')
getColors

%% Get Session Information
% Get Ephys log and tidy
ephysLog = importOnlineEphysLogMaster;
% ephysLog = ephysLog(strcmp(ephysLog.dACC,'1')| strcmp(ephysLog.vACC,'1'),:);

% For each logged session
for logIdx = 1:size(ephysLog,1)
    try
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
        
        if exist([dirs.masterData spk_file]) == 2
            
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
            
            %%
            clusters.dsp = fieldnames(spk_data.spikes.time);
            clusters.wav = fieldnames(spk_data.spikes.waveform);
            
            %%
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
                f_h = figure('Renderer', 'painters', 'Position', [100 100 800 600]);
                ax = subplot(9,10,[1 2 11 12]);
                
                % Session information and text %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                text(-0.5,1.0,[ephysLog.Session{logIdx} ' / ' clusters.dsp{clusterIdx}], 'FontSize',15, 'Interpreter', 'none');
                text(-0.5,0.8,['Monkey: ' ephysLog.Monkey{logIdx} ' / Date: '...
                    ephysLog.Date{logIdx} ' / Site: ' char(ephysLog.AP_Grid(logIdx))...
                    ' , ' char(ephysLog.ML_Grid(logIdx))],'FontWeight','bold','FontSize',15, 'Interpreter', 'none');
                set ( ax, 'visible', 'off')
              
                text(-0.5,0.6,'Session Information','FontWeight','bold');
                text(-0.5,0.45,['Session: ' ephysLog.Session{logIdx}],'Interpreter', 'none');
                text(-0.5,0.3,['Date: ' dajo_datamap.sessionInfo(sessionIdx).date]);
                text(-0.5,0.15,['Duration: ' int2str(dajo_datamap.sessionInfo(sessionIdx).duration) ' seconds']);
                text(-0.5,0.0,['Electrode: ' ephysLog.Electrode_brand{logIdx} ' ' ephysLog.Electrode_Serial{logIdx}]);
                text(-0.5,-0.15,['Location: ' [dajo_datamap.neurophysInfo{sessionIdx}.area{penIdx} ': AP, '] char(ephysLog.AP_Grid(logIdx))...
                    '; ML, ' char(ephysLog.ML_Grid(logIdx)) '']);
                text(-0.5,-0.3,['Electrode Settle Time: ' ephysLog.ElectrodeSettleTime{logIdx}]);
                text(-0.5,-0.45,['Electrode Settle Depth: ' ephysLog.ElectrodeSettleDepth{logIdx}]);
                set ( ax, 'visible', 'off')
                

                % SSRT Aligned (conflict) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                ax = subplot(9,10, [16 17 18 19 20 26 27 28 29 30 36 37 38 39 40]); hold on   
                
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
                ax = subplot(9,10, [51 52 53 54 55 61 62 63 64 65 71 72 73 74 75]); hold on          
                plot(-1000:2000,eventSDF.ssrt.C.matchedSSD, 'color', colors.canceled)
                plot(-1000:2000,eventSDF.ssrt.GO.matchedSSD, 'color', colors.nostop)
                xlim([-200 600]); ylim([ymin ymax]); vline(0,'k')
                xlabel('Time from SSRT (ms)'); ylabel('FR (spks/sec)')
                title('Goal Maintenance & Timing Period')
                
                % Tone Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                ax = subplot(9,10, [56 57 58 59 60 66 67 68 69 70 76 77 78 79 80]); hold on          
                plot(-1000:2000,eventSDF.reward.C.matchedSSD, 'color', colors.canceled)
                plot(-1000:2000,eventSDF.reward.GO.matchedSSD, 'color', colors.nostop)
                xlim([-600 200]); ylim([ymin ymax]); vline(0,'k'); vline(-500,'k')
                xlabel('Time from Reward (ms)');        
                
                
                
                
                %% Figure out
                figureOutFolder = 'S:\Users\Current Lab Members\Steven Errington\temp\dajo_datacuration\SSRT_SPK-figures';
                set(gcf,'Units','inches');
                screenposition = get(gcf,'Position');
                set(gcf,...
                    'PaperPosition',[0 0 screenposition(3:4)],...
                    'PaperSize',[screenposition(3:4)]);
                saveas(gcf,[figureOutFolder '\' ephysLog.Session{logIdx} '-' clusters.dsp{clusterIdx} '.jpg'])
                close gcf
            end
        end
    catch
        continue
    end
    
end