function ephysLog = importOnlineEphysLogMaster()
sessionSheet = GetGoogleSpreadsheet('163v9YjcDqLu0V7RTkosaXIiW68eBbvZKFsRTO3CyquU');
ephysLog = cell2table(sessionSheet(2:end,:),'VariableNames',sessionSheet(1,:));


end
