%% Clear environment
clear; clc;
dirs.masterData = 'S:\Users\Current Lab Members\Steven Errington\2021_DaJo\mat\';
dirs.outDir = 'S:\Users\Current Lab Members\Steven Errington\temp\dajo_ksSpkTable\';
load('2021-dajo-datamap.mat')

%% Get Session Information
% Get Ephys log and tidy
ephysLog = importOnlineEphysLogMaster;

% For each logged session
for logIdx = 1:size(ephysLog,1)
    try
        fprintf('Analysing electrode %i of %i | %s.          \n',...
            logIdx,size(ephysLog,1),ephysLog.Session{logIdx});
        
        clearvars -except ephysLog dirs dajo_datamap logIdx
        % Define data directories and files
        beh_file = dajo_datamap.behInfo(str2num(ephysLog.SessionN{logIdx})).dataFile;
        spk_file = dajo_datamap.neurophysInfo{str2num(ephysLog.SessionN{logIdx})}.spkFile{1};
        
        % Load in spike and behavioral data
        beh_data = load([dirs.masterData beh_file]);
        spk_data = load([dirs.masterData spk_file]);
        
        % Align spikes
        [ttx, ~, trialEventTimes] = processSessionTrials...
            (beh_data.events.stateFlags_, beh_data.events.Infos_);
        
        tdtSpk_aligned = alignSDF...
            (trialEventTimes, beh_data.events.Infos_, spk_data.spikes.time, [-1000 2000]);
        
        %%
        clusters.dsp = fieldnames(spk_data.spikes.time);
        clusters.wav = fieldnames(spk_data.spikes.waveform);
        
        %%
        events = fieldnames(tdtSpk_aligned.(clusters.dsp{1}));
        trialTypes = {'canceled','noncanceled','nostop'};
        
        for clusterIdx = 1:length(clusters.dsp)
            
            % Event aligned SDF
            for eventIdx = 1:length(events)
                for trialTypeIdx = 1:length(trialTypes)
                    eventSDF{clusterIdx,1}.(events{eventIdx}).(trialTypes{trialTypeIdx}) =...
                        nanmean(tdtSpk_aligned.(clusters.dsp{clusterIdx}).(events{eventIdx})...
                        (ttx.(trialTypes{trialTypeIdx}).all.all,:));
                end
            end
            
            % Waveform
            wf_mean{clusterIdx,1} = nanmean(spk_data.spikes.waveform.(clusters.wav{clusterIdx}));
            wf_ci{clusterIdx,1} = [wf_mean{clusterIdx,1} + (2*nanstd(spk_data.spikes.waveform.(clusters.wav{clusterIdx}))) ;...
                wf_mean{clusterIdx,1} - (2*nanstd(spk_data.spikes.waveform.(clusters.wav{clusterIdx})))];
            
            wf_min = ...
                find(wf_mean{clusterIdx,1} == min(wf_mean{clusterIdx,1}));
            wf_max = ...
                find(wf_mean{clusterIdx,1} == max(wf_mean{clusterIdx,1}));
            wf_width(clusterIdx,1) =...
                round(abs(wf_max-wf_min)*(24414.14/1000));
            
            % Amplitude x time
            amp_time{clusterIdx,1} = [spk_data.spikes.amplitudes.(clusters.dsp{clusterIdx}),...
                spk_data.spikes.time.(clusters.dsp{clusterIdx})];
            
            % unaligned SDF
            raw_sdf{clusterIdx,1} = SpkConvolver (spk_data.spikes.time.(clusters.dsp{clusterIdx}),...
                round(max(beh_data.events.Infos_.InfosEnd_)+10000), 'PSP');
            
            
        end
%         
% 
%         ks_clusterInfo = tdfread(['S:\Users\Current Lab Members\Steven Errington\2021_DaJo\spk\'...
%             ephysLog.Session{logIdx} '\cluster_info.tsv']);
%         
%         ks_validNeurons = find(strcmp(cellstr(ks_clusterInfo.group),'good'));
%         
%         ks_contamPct = ks_clusterInfo.ContamPct(ks_validNeurons);
%         ks_fr = ks_clusterInfo.fr(ks_validNeurons);
%         ks_amp = ks_clusterInfo.amp(ks_validNeurons);
%         
%         
        sessionName = repmat(ephysLog.Session(str2num(ephysLog.SessionN{logIdx})),length(clusters.dsp),1);
        sessionIdx = repmat(str2num(ephysLog.SessionN{logIdx}),length(clusters.dsp),1);
        logIdxN =  repmat(logIdx,length(clusters.dsp),1);
        
        spkdata_table = table(sessionName, sessionIdx, logIdxN, clusters.dsp,clusters.wav,eventSDF,wf_mean,wf_ci,wf_width,amp_time,raw_sdf,...
            'VariableNames',{'sessionName','sessionIdx','logIdx','DSP','WAV','eventSDF','wf_mean','wf_ci','wf_width','amp_time','raw_sdf'});
        
        save([dirs.outDir ephysLog.Session{str2num(ephysLog.SessionN{logIdx})} '-spkTable.mat'], "spkdata_table", '-v7.3');
    catch
        fprintf('         ERROR: Analysing electrode %i of %i | %s.          \n',...
            logIdx,size(ephysLog,1),ephysLog.Session{logIdx});
    end
end

%%

spkTable = table();
% For each logged session
for logIdx = 1:size(ephysLog,1)
    try
        fprintf('Analysing electrode %i of %i | %s.          \n',...
            logIdx,size(ephysLog,1),ephysLog.Session{logIdx});
        spkTable_i = load([dirs.outDir ephysLog.Session{str2num(ephysLog.SessionN{logIdx})} '-spkTable.mat']);
        
        spkTable = [spkTable; spkTable_i.spkdata_table(:,[1,2,3,4,7,9])];
        
    catch
        fprintf('         ERROR: Analysing electrode %i of %i | %s.          \n',...
            logIdx,size(ephysLog,1),ephysLog.Session{logIdx});
    end
end

    writetable(spkTable(:,[1,2,3,4,6]),...
        ['S:\Users\Current Lab Members\Steven Errington\temp\dajo_datacuration\'...
        '2021-dajo-spkLabels.csv'],'WriteRowNames',true)
