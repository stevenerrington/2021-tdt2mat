function spkLog = importOnlineSpkCuration()
sessionSheet = GetGoogleSpreadsheet('1KcP6jQw6S-8ntoBn2Z_tjyhbFDrA8S25GBUDvrb1J70');
spkLog = cell2table(sessionSheet(2:end,:),'VariableNames',sessionSheet(1,:));
end
