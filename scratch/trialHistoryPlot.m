clear all; clc

dataDir = 'C:\Users\Steven\Desktop\TDT convert\cmandMat';
load([dataDir '\dar-cmand1DR-DMFC-20210225.mat']);

[ttx, ttx_history, trialEventTimes] = processSessionTrials (Behavior.stateFlags_, Behavior.Infos_);
timeWin = [-1000:2000];

[SDF] = alignSDF(trialEventTimes(:,[1,2]), Behavior.Infos_, Spikes, timeWin);


%% THIS CAN BE A FUNCTION: GET FOREPERIOD TRIALS

foreperiod = trialEventTimes.target-trialEventTimes.fixation;
nbin = 3;
y = quantile(foreperiod,nbin-1);
[~, ~, binIdx] = histcounts(foreperiod,[-inf; y(:); inf]);


for bin = 1:3
    foreperiodTrials{bin} = find(binIdx == bin);
end



%% 

produceSpkFigures_foreperiod(foreperiodTrials, SDF, trialEventTimes)