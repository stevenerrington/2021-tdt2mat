%% Clear environment
clear; clc;
dirs.masterData = 'S:\Users\Current Lab Members\Steven Errington\2021_DaJo\mat\';
dirs.outDir = 'S:\Users\Current Lab Members\Steven Errington\temp\dajo_ksSpkTable\';
load('2021-dajo-datamap.mat')

%% Get Session Information
% Get Ephys log and tidy
ephysLog = importOnlineEphysLogMaster;
spkdata_table_all = table();
% For each logged session
for logIdx = 1:size(ephysLog,1)
    try
        fprintf('Analysing electrode %i of %i | %s.          \n',...
            logIdx,size(ephysLog,1),ephysLog.Session{logIdx});
        
        clearvars -except ephysLog dirs dajo_datamap logIdx spkdata_table_all
        % Define data directories and files
        beh_file = dajo_datamap.behInfo(str2num(ephysLog.SessionN{logIdx})).dataFile;
        spk_file = dajo_datamap.neurophysInfo{str2num(ephysLog.SessionN{logIdx})}.spkFile{1};
        
        % Load in spike and behavioral data
        beh_data = load([dirs.masterData beh_file]);
        spk_data = load([dirs.masterData spk_file]);
        
        %% Get cluster names
        clusters.dsp = fieldnames(spk_data.spikes.time);
        clusters.wav = fieldnames(spk_data.spikes.waveform);
        
        for clusterIdx = 1:length(clusters.dsp)
            
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
        end
        
        %%%%%%%%% NEEDS FIXING 
        clusterInfo_in = tdfread(['S:\Users\Current Lab Members\Steven Errington\2021_DaJo\spk\'...
            ephysLog.Session{logIdx} '\cluster_info.tsv']);
        contamPct = clusterInfo_in.ContamPct(strcmp(clusterInfo_in.group;
        Amplitude = clusterInfo_in.Amplitude;
        
        sessionName = repmat(ephysLog.Session(str2num(ephysLog.SessionN{logIdx})),length(clusters.dsp),1);
        sessionIdx = repmat(str2num(ephysLog.SessionN{logIdx}),length(clusters.dsp),1);
        logIdxN =  repmat(logIdx,length(clusters.dsp),1);
        
        spkdata_table_session = table();
        spkdata_table_session = table(sessionName, sessionIdx, logIdxN, clusters.dsp,clusters.wav,wf_width,contamPct,Amplitude,...
            'VariableNames',{'sessionName','sessionIdx','logIdx','DSP','WAV','wf_width','contamPct','Amplitude'});
        spkdata_table_all = [spkdata_table_all; spkdata_table_session];
        
    catch
        fprintf('         ERROR: Analysing electrode %i of %i | %s.          \n',...
            logIdx,size(ephysLog,1),ephysLog.Session{logIdx});
    end
end


writetable(spkdata_table_all,...
    ['S:\Users\Current Lab Members\Steven Errington\temp\dajo_datacuration\'...
    '2021-dajo-spkLabels_short.csv'],'WriteRowNames',true)
