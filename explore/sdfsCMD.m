TaskInfos = struct2table(TaskInfos);

% Find spikes that happen in the window around specic times

%% SDFs all trials where target is ON
trlIdx = find(~isnan(Task.Target_));
spkTimes = arrayfun(fx_times,Task.Target_(trlIdx),'UniformOutput',false);

spkTimesAligned = SpikeUtils.alignSpikeTimes(spkTimes,Task.Target_(trlIdx));

%spkRasters = SpikeUtils.rasters(spkTimesAligned',timeWin);
spkPsth = SpikeUtils.psth(spkTimesAligned,1,timeWin);
% plot it
PlotUtils.plotPsth(spkPsth.psth,spkPsth.psthBins)

%% Low vs Hi Reward
trlsHiRwdIdx = find(TaskInfos.UseRwrdDuration==320 & TaskInfos.IsGoCorrect==1);
trlsLoRwdIdx = find(TaskInfos.UseRwrdDuration==80 & TaskInfos.IsGoCorrect==1);

%% Low vs Hi Reward aligned on Saccade_
events2Align = {'Target_','Saccade_','AudioStart_','JuiceStart_'};
selTrls = struct();
selTrls.hiReward = trlsHiRwdIdx;
selTrls.loReward = trlsLoRwdIdx;
for ii = 1: numel(events2Align)
    evtName = events2Align{ii};
    out.(evtName) = plotAligned(selTrls, Task,evtName,DSP01a);
end
selTrls = struct();
for ii = 1: numel(events2Align)
    evtName = events2Align{ii};
    out2.(evtName) = plotAligned(selTrls,Task,evtName,DSP01c);
end
%close all

%% Cancelled trials
selTrls = struct();
cancelTrls = find(TaskInfos.IsCancel==1);
selTrls.cancelled = cancelTrls;
for ii = 1: numel(events2Align)
    evtName = events2Align{ii};
    out3.(evtName) = plotAligned(selTrls,Task,evtName,DSP01a);
end


