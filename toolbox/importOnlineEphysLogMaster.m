function ephysLog = importOnlineEphysLogMaster()

sessionSheet = GetGoogleSpreadsheet('12sKiqzLW4CCqG5wsXeBE8-CsN5np5Tw1iWWgm3h9nv8');
ephysLog = cell2table(sessionSheet(2:end,:),'VariableNames',sessionSheet(1,:));


end
