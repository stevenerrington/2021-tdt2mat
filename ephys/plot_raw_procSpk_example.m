% Define session of interest (mat and tdt files)
sessionName_tdt = 'Cmand1DR_Ephys-210314-094500';
sessionName_mat = 'dar-cmand1DR-ACC-20210314';

% Define storage locations
dir_tdt = 'S:\DATA\Current Subjects\Da\Experimental\Countermanding\Neurophysiology\Darwin-210314\';
dir_mat = 'S:\Users\Current Lab Members\Steven Errington\2021_DaJo\mat\';

% Define unit of interest (manually defined after looking at SDFs)
chan = 12; unit = 'a'; label = ['DSP' int2str(chan) unit];
chan = 23; unit = 'a'; label = ['DSP' int2str(chan) unit];

% Load raw and processed data
data_raw = TDTbin2mat([dir_tdt sessionName_tdt], ...
    'STORE', 'Wav1', 'CHANNEL', 12);
data_mat = load([dir_mat sessionName_mat '-spk.mat']);

% Get raw signal
signal_length = 10; % Secs
fs = 24414.0625; % Hz
sample_length = round(fs*signal_length); % Samples
sample_start = 800000;
sample_end = sample_start + sample_length;
sample_data = data_raw.streams.Wav1.data(sample_start:sample_end);

% Get Kilosort derived spike times
sample_spkTimes_ms = data_mat.spikes.time.(label); % ms
sample_spkTimes_sample = sample_spkTimes_ms * (fs/1000); % ms
sample_spkTimes_sample = sample_spkTimes_sample...
    (sample_spkTimes_sample >= sample_start & sample_spkTimes_sample <= sample_end)-sample_start;

sample_spkTimes_range = sample_spkTimes_ms...
    (sample_spkTimes_ms >= sample_start & sample_spkTimes_ms <= sample_end);

sample_waveform = nanmean(data_mat.spikes.waveform.(['WAV' int2str(chan) unit]));
 
wf_min = find(sample_waveform == min(sample_waveform));
wf_max = find(sample_waveform == max(sample_waveform));
wf_width = round(abs(wf_max-wf_min)*(24414.14/1000));

% Produce figure
figure('Renderer', 'painters', 'Position', [100 100 500 500]);
subplot(3,2,[1 2]); hold on
plot(sample_data)
xlim([0 length(sample_data)])

subplot(3,2,[3 4]); hold on
vline(sample_spkTimes_sample,'k-')
xlim([0 length(sample_data)])

subplot(3,2,6)
% hold on
% for sample = 1:size(data_mat.spikes.waveform.(['WAV' int2str(chan) unit]),1)
%     plot(data_mat.spikes.waveform.(['WAV' int2str(chan) unit])(sample,:),'color',[0 0 0 0.002])
% end
plot(sample_waveform,'k','LineWidth',2)

ylim([-12000 6000])
xlim([20 80])


%%
spkwidth_data = readtable('S:\Users\Current Lab Members\Steven Errington\temp\dajo_datacuration\2021-dajo-spkLabels.csv');

figure('Renderer', 'painters', 'Position', [100 100 500 250]);
histogram(spkwidth_data.wf_width,0:25:750,'DisplayStyle','Stairs')
vline(250,'r--')


%% 
% 
% data_raw_all = TDTbin2mat([dir_tdt sessionName_tdt], ...
%     'STORE', 'Wav1', 'T1', 1000, 'T2', 1010);
% 
% 
% figure('Renderer', 'painters', 'Position', [100 100 500 800]);
% for ch = 1:32
% plot(data_raw_all.streams.Wav1.data(ch,(1:length(data_raw_all.streams.Wav1.data(ch,:))/2))+0.25*ch,'k','LineWidth',0.01)
%     hold on
%     
%     xlim([0 length(data_raw_all.streams.Wav1.data(ch,:))/2])
% end
% 
% set(gca,'YDir','Reverse')
% 
