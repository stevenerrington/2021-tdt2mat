function [Task,spikes] = tdtLoadRow(row,varargin)
    
% Set defaults
file = 'klTDTBookKeeping.xlsx';
monk = 'Darwin';
path = 'Y:/Users/Kaleb/dataProcessed';
fType = 'DSP';
wave = 0;
doLFP = 0;
reload = 0;
doTask = 0;

% Decode varargin
varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd),
    switch varargin{varStrInd(iv)}
        case {'file','-f'}
            file = varargin{varStrInd(iv)+1};
        case {'monk','-m'}
            monk = varargin{varStrInd(iv)+1};
        case {'task','-t'}
            doTask = varargin{varStrInd(iv)+1};
        case {'ftype'}
            fType = varargin{varStrInd(iv)+1};
        case {'wave','-w'}
            wave  = varargin{varStrInd(iv)+1};
            if wave, doLFP = 0; end
        case {'-r','reload'}
            reload = varargin{varStrInd(iv)+1};
        case {'-l','lfp'},
            doLFP = varargin{varStrInd(iv)+1};
            if doLFP, wave = 0; end
    end
end

global excelNum excelAll
if isempty(excelNum) || isempty(excelAll) || reload
    [excelNum,~,excelAll] = xlsread(file,monk);
end

% Get spikes
[path,file] = tdtRowToFile(row,'-m',monk,'-r',reload,'-t',0);
load([path,file{1}]);
% Get Task
[path,file] = tdtRowToFile(row,'-m',monk,'-r',reload,'-t',1);
load([path,file{1}]);

if ~isfield(Task,'trStarts'),
    Task.trStarts = trStarts;
    Task.trEnds = trEnds;
end