function isExtract = tdtIsExtracted(thisFile)

isExtract = 1;
rawDir = 'Y:/Users/Kaleb/dataRaw';
procDir = 'Y:/Users/Kaleb/dataProcessed';

% Make sure behavior file is there
hasBehav = exist(sprintf('%s/%s/Behav.mat',procDir,thisFile),'file');
isExtract = isExtract && hasBehav;

% Make sure there are enough channel folders
numChans = length(dir(sprintf('%s/%s/*.sev',rawDir,thisFile)))/2;
numChanFolds = length(dir(sprintf('%s/%s/Channel*',procDir,thisFile)));
hasAllFolds = numChans == numChanFolds;

nMatsS = 0;
if hasAllFolds,
    for ic = 1:numChans,
        isDone = any(exist(sprintf('%s/%s/Channel%d/autoSort_noAudit.mat',procDir,thisFile,ic),'file')) || any(exist(sprintf('%s/%s/Channel%d/autoSortAgglom_noAudit.mat',procDir,thisFile,ic),'file')); 
        nMatsS = nMatsS + isDone;
    end
end

isExtract = isExtract && hasAllFolds && (nMatsS==numChans);
