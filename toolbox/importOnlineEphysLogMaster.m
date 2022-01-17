function ephysLog = importOnlineEphysLogMaster()

sessionSheet = GetGoogleSpreadsheet('1pId2_DS36-fjQuQHEXPhR_HJVDHZGRswDG_t21qVeD4');
ephysLog = cell2table(sessionSheet(2:end,:),'VariableNames',sessionSheet(1,:));


end
