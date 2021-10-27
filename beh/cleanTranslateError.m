function [stateFlags,Infos] = cleanTranslateError(stateFlags,Infos)

stateFlags = struct2table(stateFlags);
Infos = struct2table(Infos);

translateErrorIdx = find(stateFlags.numberOfInfoCodeValuesLowerThanOffset == 1 |...
    stateFlags.NInfos < 77);

stateFlags(translateErrorIdx,:) = [];
Infos(translateErrorIdx,:) = [];

end

