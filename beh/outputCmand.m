function outputCmand(sessionInfo,tdtInfo,stateFlags,Infos,stopSignalBeh,outFilename)

monkey = {sessionInfo.monkey};
area = {sessionInfo.area};
task = {sessionInfo.task};
file = {outFilename};

sessionDate = {tdtInfo.date};
sessionStart = {tdtInfo.utcStartTime};
sessionEnd = {tdtInfo.utcStopTime};
sessionLength = (Infos.TaskEnd_(end) - Infos.TrialStart_(1))./1000/60;

nTrls_logged = max(stateFlags.TrialNumber);
nTrls_fixated = nansum(stateFlags.IsFixAcquired);
nTrls_initated = nansum(stateFlags.IsTargetOn);

n_STOP = nansum(stateFlags.TrialType == 1 & stateFlags.IsTargetOn == 1);
n_NOSTOP = nansum(stateFlags.TrialType == 0 & stateFlags.IsTargetOn == 1);

canceled = nansum(stateFlags.IsCancel == 1);
noncanceled = nansum(stateFlags.IsNonCancelledBrk == 1 | stateFlags.IsNonCancelledNoBrk == 1);
goCorrect = nansum(stateFlags.IsGoCorrect == 1);
goWrong = nansum(stateFlags.IsGoErr == 1);

nValidOutcomes = canceled+noncanceled+goCorrect+goWrong;

p_StopCorrect = (canceled./n_STOP)*100; 
p_GoCorrect = (goCorrect./n_NOSTOP)*100;

sys_pSTOP = mean(stateFlags.TrialType)*100;
obs_pSTOP = (canceled+noncanceled)./(nValidOutcomes)*100;

go_RT = mean(Infos.TargetAcquired_(stateFlags.IsGoCorrect == 1) - Infos.Target_(stateFlags.IsGoCorrect == 1));
nc_RT = mean(Infos.TargetAcquired_(stateFlags.IsNonCancelledBrk == 1 | stateFlags.IsNonCancelledNoBrk == 1) - Infos.Target_(stateFlags.IsNonCancelledBrk == 1 | stateFlags.IsNonCancelledNoBrk == 1));

SSD = {stopSignalBeh.inh_SSD};
pnc = {stopSignalBeh.inh_pnc};
ntr = {stopSignalBeh.inh_nTr};
ssrt = stopSignalBeh.ssrt.integrationWeighted;

output = ...
    table(file, monkey, area, task, sessionDate, sessionStart, sessionEnd, sessionLength,...
    nTrls_logged, nTrls_fixated, nTrls_initated, n_STOP, n_NOSTOP,...
    nValidOutcomes, canceled, noncanceled, goCorrect, goWrong,...
    p_StopCorrect, p_GoCorrect, sys_pSTOP, obs_pSTOP, go_RT, nc_RT,...
    ssrt, SSD, pnc, ntr);

writetable(output,['C:\Users\Steven\Desktop\TDT convert\tdt2excel\' outFilename '.csv'],'WriteRowNames',true) 

end
