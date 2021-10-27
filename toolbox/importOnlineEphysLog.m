function ephysLog = importOnlineEphysLog(monkey)

if strcmp(monkey,'joule')
    sessionSheet = GetGoogleSpreadsheet('158HZIw2Av0wZ86i8LkQwYbcpfd3zpSU6hmPswTy0R6g');
    ephysLog = cell2table(sessionSheet(2:end,:),'VariableNames',sessionSheet(1,:));
else
    sessionSheet = GetGoogleSpreadsheet('165f0AM1zW2jKYW0ktNByMq9rD4Umbrb0POYZkcyzhLw');
    ephysLog = cell2table(sessionSheet(2:end,:),'VariableNames',sessionSheet(1,:));
end

end
