function [spikes, LFP, chanSEVs] = tdtGetChanv1(inFile,channel,Task)

if ~exist('events','var'),
    events=TEMPO_EV_cosman_rig028;
end
if ~exist('Task','var'),
    Task = tdtGetTaskv4(inFile,events);
end

% Set constants
lfpWind = [-500, 2500];
spkFreq = 1000/24414;
minRefract = .2;

chanSEVs = SEV2mat_kl(inFile,'CHANNEL',channel,'VERBOSE',0);

% Define some channel variables
nTrs = length(Task.trStarts);
lfpRate = (24000/chanSEVs.Lfp1.fs);
lfpTimes = 0:lfpRate:(lfpRate*(size(chanSEVs.Lfp1.data,2)-1));
spkTimesRaw = 0:spkFreq:(spkFreq*(size(chanSEVs.Wav1.data,2)-1)); % 1000x multiplier converts to ms

 % Set a threshold or load sort data
fprintf('Getting spike times...');
if exist('sortedChans','var'),
    spkTimes = sortedChans{channel};
else
    [spkTimes,spikes.spkWaves,spikes.spkThresh] = klThreshCrossv3(chanSEVs.Wav1.data,'times',spkTimesRaw,'-m',minRefract);
end

for ib = 1:length(['Getting spike times...']), fprintf('\b'); end
fprintf('Counting spikes...');
% Figure out how big the matrix will be
nSpks = nan(nTrs,1);
for it = 1:nTrs,
    nSpks(it) = sum(spkTimes >= Task.trStarts(it) & spkTimes <= Task.trEnds(it));
end
maxSpk = max(nSpks(:));
spikes.spiketimes = nan(nTrs,maxSpk);

for ib = 1:length(['Counting spikes...']), fprintf('\b'); end
fprintf('Placing spikes...');
% Place spikes in the matrix
for it = 1:nTrs,
    spikes.spiketimes(it,1:nSpks(it)) =  spkTimes(spkTimes >= Task.trStarts(it) & spkTimes <= Task.trEnds(it));
end
spikes.spiketimes = spikes.spiketimes-repmat(Task.AlignTimes,1,size(spikes.spiketimes,2));

for ib = 1:length(['Placing spikes...']), fprintf('\b'); end
fprintf('Getting visually aligned LFP...');

% Now get LFP
LFP.vTimes = ((1:((length(lfpWind(1):lfpRate:lfpWind(2)))+1))+lfpWind(1)).*lfpRate;
for it = 1:nTrs,
    LFP.vis(it,1:sum(lfpTimes >= (Task.AlignTimes(it)+lfpWind(1)) & lfpTimes <= (Task.AlignTimes(it)+lfpWind(2)))) = chanSEVs.Lfp1.data(1,lfpTimes >= (Task.AlignTimes(it)+lfpWind(1)) & lfpTimes <= (Task.AlignTimes(it)+lfpWind(2)));
end

% Now get it shifted and aligned on SRT
for ib = 1:length(['Getting visually aligned LFP...']), fprintf('\b'); end
fprintf('Getting LFP aligned on saccade...');

for it = 1:nTrs,
    shiftInds(it) = max([0,find(LFP.vTimes >= (Task.SRT(it)+Task.GoCue(it)),1)]);
end
tmpCell = mat2cell(LFP.vis,ones(size(LFP.vis,1),1),size(LFP.vis,2));
[LFP.mov, newZero] = klAlignv5(tmpCell,shiftInds');

tmpFront = -1.*fliplr((0:1:newZero).*lfpRate);
tmpBack = (1:(size(LFP.mov,2)-newZero-1)).*lfpRate;
LFP.mTimes = [tmpFront,tmpBack];
