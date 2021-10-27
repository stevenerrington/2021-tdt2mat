function [tdtEvs,tdtEvTms] = klGetEvsTDT(sessName, varargin)

% Set defaults
fresh = 1;
print = 1;
rawDir = '/mnt/teba/data/Kaleb/antiSessions/';
% rawDir = '/mnt/teba/Users/Kaleb/proAntiRaw';
procDir = '/mnt/teba/Users/Kaleb/proAntiProcessed/';
doSave = 0;

% Decode varargin
varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'-p','print'}
            print = varargin{varStrInd(iv)+1};
        case {'-f','fresh'}
            fresh = varargin{varStrInd(iv)+1};
        case {'-r','rawDir','rawdir'}
            rawDir = varargin{varStrInd(iv)+1};
        case {'-proc'}
            procDir = varargin{varStrInd(iv)+1};
        case {'-s','save'}
            doSave = varargin{varStrInd(iv)+1};
    end
end

% Set up directory stuff
if ~ismember(sessName(end),['/','\']), sessName(end+1) = filesep;  end
if ismember(rawDir(end),['/','\']), fileName = [rawDir,sessName]; else fileName = [rawDir,filesep,sessName]; end
if ismember(procDir(end),['/','\']), saveDir = [procDir,sessName]; else saveDir = [procDir,filesep,sessName]; end

% Determine which TDT function to use
% if ispc
%     getFun = @TDT2mat;
% elseif isunix
    getFun = @TDTbin2mat;
% end

% Set up taskHeaders
taskHeaders = [1500:1515];

% Pull out event codes and times
if exist(sprintf('%sevsRaw.mat',saveDir),'file') && ~fresh
   load(sprintf('%sevsRaw.mat',saveDir));
else
    if print
        printStr = 'Getting Events...';
        fprintf(printStr);
    end

    tdtEvRaw = getFun(fileName,'TYPE',{'epocs','scalars'},'VERBOSE',0);
    if isfield(tdtEvRaw.epocs,'STRB')
        tdtEvs = tdtEvRaw.epocs.STRB.data;
        if any(tdtEvs > 2^15)
            tdtEvs = tdtEvs-2^15;
        end
        tdtEvTms = tdtEvRaw.epocs.STRB.onset.*1000;
        tdtEvTms(tdtEvs <= 0) = [];
        tdtEvs(tdtEvs <= 0) = [];
    elseif isfield(tdtEvRaw.epocs,'EVNT')
        tdtEvs = tdtEvRaw.epocs.EVNT.data;
        if any(tdtEvs > 2^15)
            tdtEvs = tdtEvs-2^15;
        end
        if ~any(ismember(tdtEvs,taskHeaders))
            tdtEvs = tdtEvs./2;
        end
        tdtEvTms = tdtEvRaw.epocs.EVNT.onset.*1000;
        tdtEvTms(tdtEvs <= 0) = [];
        tdtEvs(tdtEvs <= 0) = [];

    else
    %     tdtEvRaw = getFun(fileName,'TYPE',{'scalars'},'VERBOSE',0);
        if isempty(tdtEvRaw.scalars)
            tdtEvs = nan; tdtEvTms = nan;
            return
        end
        tdtEvs = tdtEvRaw.scalars.EVNT.data;
        if any(tdtEvs >= (2^15))
            tdtEvs = tdt2EvShft(tdtEvs);
        end
        if any(mod(tdtEvs,1)) ~= 0
            tdtEvs = tdtEvRaw.scalars.EVNT.data - (2^15);
        end
        tdtEvTms = tdtEvRaw.scalars.EVNT.ts.*1000;
        tdtEvTms(tdtEvs < 0) = [];
        tdtEvs(tdtEvs < 0) = [];
    end
    if doSave
        save(sprintf('%sevsRaw.mat',saveDir),'tdtEvs','tdtEvTms');
    end
end