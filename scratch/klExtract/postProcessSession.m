function success = postProcessSession(monk,date,varargin)

clustType = 'jrc';


doMerge = 1;
subSess = 1;
isPoly2 = 0;
chanSpacing = 150;
doBehav = 1;
doExtract = 1;
waitForManual = 1;

varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'-c'}
            clustType = varargin{varStrInd(iv)+1};
        case {'-s'}
            subSess = varargin{varStrInd(iv)+1};
        case {'-m'}
            doMerge = varargin{varStrInd(iv)+1};
        case {'-p'}
            isPoly2 = varargin{varStrInd(iv)+1};
        case {'-cs'}
            chanSpacing = varargin{varStrInd(iv)+1};
        case {'-w'}
            waitForManual = varargin{varStrInd(iv)+1};
        case {'-e'}
            doExtract = varargin{varStrInd(iv)+1};
        case {'-b'}
            doBehav = varargin{varStrInd(iv)+1};
    end
end

if ~exist('rawFold','var')
    switch lower(monk)
        case 'darwin'
            rawFold = [tebaMount,'/data/Darwin/proNoElongationColor_physio/'];
        case 'leonardo'
            rawFold = [tebaMount,'/data/Leonardo/proNoElongationColor_physio/'];
    end
end

% Get session folder
sessFolds = dir([rawFold,'*',date,'*']);
if length(sessFolds) > 1
    if doMerge
        fprintf('Found multiple sessions for this date...');
        sessNames = {sessFolds.name};
        isMerged = cellfun(@(x) contains(x,'Merged'),sessNames);
        if ~any(isMerged)
            warning('This session has not been merged... Sorting session %s only\n');
            sessFolds = sessFolds(subSess);
        else
            fprintf(' Found merged folder. Sorting on merged session\n');
            sessFolds = sessFolds(isMerged);
        end
    else
        sessFolds = sessFolds(subSess);
    end
elseif isempty(sessFolds)
    fprintf('No sessions found for %d on date %d\n');
    return
end

% Do clustering
switch clustType
    case 'jrc'
        masterJrClust_wrapper(sessFolds(1).name,'-p',isPoly2,'-s',chanSpacing,'-e',doExtract,'-w',waitForManual);
        if doExtract
            klConvertJR(sessFolds(1).name);
        end
        if doBehav
            klGetSession(monk,date,'-r',rawFold,'-p',[tebaMount,'/Users/Kaleb/proNoElongationColor_physio'],'-s',1);
        end
    case {'ks','kilosort'}
        tdtExtractShell(sessFolds(1).name);
end
