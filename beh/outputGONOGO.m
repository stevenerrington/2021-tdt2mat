function outputGONOGO(sessionInfo,tdtInfo,stateFlags,Infos,outFilename)

stateFlags = struct2table(stateFlags);

SSDs = unique(stateFlags.UseSsdVrCount(~isnan(stateFlags.UseSsdVrCount)));

monkey = {sessionInfo.monkey};
area = {sessionInfo.area};
task = {sessionInfo.task};

sessionDate = {tdtInfo.date};
sessionStart = {tdtInfo.utcStartTime};
sessionEnd = {tdtInfo.utcStopTime};
sessionLength = (Infos.TaskEnd_(end) - Infos.TrialStart_(1))./1000/60;

nTrls_logged = max(stateFlags.TrialNumber);
nTrls_fixated = nansum(stateFlags.IsFixAcquired);
nTrls_initated = nansum(stateFlags.IsTargetOn);

n_nogo = nansum(stateFlags.TrialType == 1 & stateFlags.IsTargetOn == 1);
n_go = nansum(stateFlags.TrialType == 0 & stateFlags.IsTargetOn == 1);

nogoCorrect = nansum(stateFlags.IsCancel == 1);
nogoWrong = nansum(stateFlags.IsNonCancelledBrk == 1 | stateFlags.IsNonCancelledNoBrk == 1);
goCorrect = nansum(stateFlags.IsGoCorrect == 1);
goWrong = nansum(stateFlags.IsGoErr == 1);

nValidOutcomes = nogoCorrect+nogoWrong+goCorrect+goWrong;

p_nogoCorrect = (nogoCorrect./n_nogo)*100; 
p_goCorrect = (goCorrect./n_go)*100;

sys_p_nogo = mean(stateFlags.TrialType)*100;
obs_p_nogo = (nogoCorrect+nogoWrong)./(nValidOutcomes)*100;

go_RT = mean(Infos.TargetAcquired_(stateFlags.IsGoCorrect == 1) - Infos.Target_(stateFlags.IsGoCorrect == 1));
nogo_RT = mean(Infos.TargetAcquired_(stateFlags.IsNonCancelledBrk == 1 | stateFlags.IsNonCancelledNoBrk == 1) - Infos.Target_(stateFlags.IsNonCancelledBrk == 1 | stateFlags.IsNonCancelledNoBrk == 1));

output = ...
    table(monkey, area, task, sessionDate, sessionStart, sessionEnd, sessionLength,...
    nTrls_logged, nTrls_fixated, nTrls_initated, n_nogo, n_go,...
    nValidOutcomes, nogoCorrect, nogoWrong, goCorrect, goWrong,...
    p_nogoCorrect, p_goCorrect, sys_p_nogo, obs_p_nogo, go_RT, nogo_RT);

writetable(output,['C:\Users\Steven\Desktop\TDT convert\tdt2excel\' outFilename '.csv'],'WriteRowNames',true) 

end
