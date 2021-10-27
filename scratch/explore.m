%% Photodiode data... %%%%

    sess='data/Joule/tdtData/troubleshootEventCodes/Joule-180726-153819';
    
    rawStream = TDTbin2mat(sess,'TYPE',{'streams'},'VERBOSE',0);
    
    
%     pdRaw = TDTbin2mat(fullfile(rawDir,sessName),'TYPE',{'streams'},'STORE',{'PD__'},'VERBOSE',0);
%     pdStream = pdRaw.streams.PD__.data;
%     % for some reason, pdTime, if turned into milliseconds, gives 0 dt
%     % values which really mess with the saccade detector... I guess all of
%     % this will need to be done post-detection
%     if pdRaw.streams.PD__.fs > 2000
%         load('slowSamplingRate.mat');
%         pdTime = (0:(length(pdStream)-1)).*(1/sampRate);
%     else
%         pdTime = (0:(length(pdStream)-1)).*(1/pdRaw.streams.PD__.fs);
%     end
% 




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
taskCodes = [1500:1510]';
trialStartCode = 1666;
eotCode = 1667;
endInfosCode = 2999;

tdtEvents=[];
tdtEventTimes=[];



% Now check for trial blocks that are valid...(?)
nEvents = numel(tdtEvents);
iTaskStart =  find(ismember(tdtEvents,taskCodes));% all TaskType find(ismember(tdtEvs,[1501:1503]'));
iTaskEnd = [iTaskStart(2:end);length(tdtEvents)];

% Split event codes and times into task chunks
[evCodes, evTimes]=arrayfun(@(i) deal(...
                   tdtEvents(iTaskStart(i):iTaskEnd(i)),...
                   tdtEventTimes(iTaskStart(i):iTaskEnd(i))),...
                   (1:length(iTaskStart))','UniformOutput',false);

% Add an extra Event at the end to help in arryfun below
iTrialStartTemp = [find(tdtEvents==trialStartCode);nEvents+1];% all TrialStart_
iEotTemp = [find(tdtEvents==eotCode);nEvents+1];% all Eot_
iEndInfosTemp = [find(tdtEvents==endInfosCode);nEvents+1];% all endInfos

% find iTrialStart,iEot,iEndInfos between currTask and nextTask
% It is possible that more than 1 of the same eventCXode is sent
% successively, hence take the minimum of such index. If empty, min() will use the lastIndex   

% example
% iEot = arrayfun(@(i) min([find(iEotTemp>iTask(i) & iEotTemp<iTaskTemp(i));NaN]),[1:length(iTask)]');

iTrialStart = iTrialStartTemp(arrayfun(@(i) min([find(iTrialStartTemp>iTaskStart(i) & iTrialStartTemp<iTaskEnd(i));numel(iTrialStartTemp)]),...
              (1:length(iTaskStart))'));

iEot = iEotTemp(arrayfun(@(i) min([find(iEotTemp>iTaskStart(i) & iEotTemp<iTaskEnd(i));numel(iEotTemp)]),...
              (1:length(iTaskStart))'));

iEndInfos = iEndInfosTemp(arrayfun(@(i) min([find(iEndInfosTemp>iTaskStart(i) & iEndInfosTemp<iTaskEnd(i));numel(iEndInfosTemp)]),...
              (1:length(iTaskStart))'));
 
 iTrialStart(iTrialStart>nEvents) = NaN;
 iEot(iEot>nEvents) = NaN;
 iEndInfos(iEndInfos>nEvents) = NaN;

% Get the augmented index into the codeIndex above.  These are indices into
% tdtEvs/tdtEvTms, the row number will be putative trial that corresponds
% to the evCodeTimeCellArr above
augmented = [iTrialStart iEot iEndInfos];

% Find indices into the augmented above where 
% the indices for iTrialStart, iEot, iEndInfos are NOT GREATER than
% (nEvents-1) for the trial/row 
% aka complete cases, but we are using only those trials where InfosEnd
% code is written
trialsWithEndInfos = find(sum(isnan(augmented(:,3)),2)==0);
%validEndInfosIndices = iEndInfos(trialsWithEndInfos);
validTrials = trialsWithEndInfos;
% prune evCodes and evTimes to valid task chunks
evCodes = evCodes(validTrials);
evTimes = evTimes(validTrials);


%% Read Rig event codes %%
eventFile = 'data/Joule/tdtSetup/TEMPO_EV_SEAS_rig029.m';

matchExpr = '(EV\.[A-Z]\w*)\s*=\s*(\d{1,4});';

rFid = fopen(eventFile,'r');
count = 0;
while ~feof(rFid)
    toks = regexp(fgetl(rFid),matchExpr,'tokens');
    if ~isempty(toks)
        count = count + 1;
        ev.name{count,1} = toks{1}{1};
        ev.code{count,1} = str2double(toks{1}{2});
    end
end
fclose(rFid);
evCode2Name = containers.Map(ev.code, ev.name);
evName2Code = containers.Map(ev.name, ev.code);


%% Read INFOS.pro for InfosCodec %%
eventFile = 'data/Joule/INFOS.pro';
% Event_fifo[Set_event] = InfosZero + Allowed_fix_time;
% or
% Event_fifo[Set_event] = InfosZero + (Stop_weight * 100);
% or 
% Event_fifo[Set_event] = InfosZero + (Y_Gain * 100) + 1000;
matchExpr = 'InfosZero\s*\+\s*\(*(\w*)\s*.*;';

rFid = fopen(eventFile,'r');
count = 0;
while ~feof(rFid)
    l = fgetl(rFid);
    toks = regexp(l,matchExpr,'tokens');
    if ~isempty(toks)
        count = count + 1;
        ev.name{count,1} = toks{1}{1};
        ev.code{count,1} = count;
    end
end
fclose(rFid);
evCode2Name = containers.Map(ev.code, ev.name);
evName2Code = containers.Map(ev.name, ev.code);


% Check evCodes from new and old....
old=load('oldEvCodesEvTimes.mat');
new=load('myEvCodesEvTimes.mat');

nTrialsOld = numel(old.trialCodes);
nTrialsNew = numel(new.trialCodes);
compareCodes = cell(max(nTrialsOld,nTrialsNew),1);

for ii = 1:max(nTrialsOld, nTrialsNew)
    o = NaN; ot = NaN;
    n = NaN; nt = NaN;
    if ii <= nTrialsOld
        o = old.trialCodes{ii};
        ot = old.trialTimes{ii};
    end
    if ii <= nTrialsNew
        n = new.trialCodes{ii};
        nt = new.trialCodes{ii};
    end
    z = nan(max(numel(o),numel(n)),1);
    oCodes = z; oCodes(1:length(o)) = o;
    nCodes = z; nCodes(1:length(n)) = n;
    oMinusNCodes = oCodes - nCodes;
    oTimes = z; oTimes(1:length(ot)) = ot;
    nTimes = z; nTimes(1:length(nt)) = nt;
    oMinusNTimes = oTimes - nTimes;
    compareCodes{ii,1} = [oCodes nCodes oMinusNCodes oTimes nTimes oMinusNTimes];
    
end

%% Convert cell array of eventCodes and eventTimeStamps to trialEventTimesTbl %%
nTrials = numel(trialCodes);
names = evCodec.name2Code.keys';
codes = cell2mat(evCodec.name2Code.values');
nNames = numel(names);
trialEventTimesTbl = array2table(nan(nTrials,nNames));
trialEventTimesTbl.Properties.VariableNames = names;

% convert cods to chr vector for finding index into code and thereby the
% right column for event time
charCodes = cellstr(num2str(codes,'%04d'));

trlColIndices = arrayfun(@(x) find(contains(charCodes,cellstr(num2str(trialCodes{x},'%04d')))),...
                        (1:nTrials)','UniformOutput',false);
  tic               
unknownCodes = [];
unknownCodeCount = 0;
for trlNo = 1:nTrials
    tCodes = unique(trialCodes{trlNo},'stable'); tCodes(tCodes>=3000)=[];
    for jj = 1:numel(tCodes)
        code = tCodes(jj);
        try
            TT.(evCodec.code2Name(code))(trlNo) = trialTimes{trlNo}(find(trialCodes{trlNo} == code,1,'first'));
        catch me
            warning('*** Trial# %d --> unknown code %d\n',trlNo,code);
            unknownCodeCount = unknownCodeCount + 1;
            unknownCodes(unknownCodeCount) = code;
        end
    end
end
 
 toc
 
 
 tTimes = arrayfun(@(c) trialTimes{1}(find(trialCodes{1}==c,1,'first')),tCodes);
 tCodesInd = find(contains(charCodes,cellstr(num2str(tCodes,'%04d'))))
 
 
%%% Kaleb stuff testing %%

tdtFun = @TDTbin2mat;
normFilepath = @(x) regexprep(x,'[/\\]',filesep);

tdtRaw = tdtFun(fileName,'TYPE',{'epocs','scalars'},'VERBOSE',0);
%> read up to t=14395.19s
tEv = tdtRaw.epocs.STRB.data;
tTm = tdtRaw.epocs.STRB.onset.*1000;
tTm(tEv==0)=[];
tEv(tEv==0)=[];

%%%%%
t1666 = find(tEv==1666); 
t1667 = find(tEv==1667);
t2999 = find(tEv==2999);
clear endInfosCS2
tic
% endInfosCS2 = arrayfun(@(x) t2999(find(t2999 > t1667(x) & t2999 < t1666(x+1),1,'first')),(1:numel(t1666)-1)');
endInfosCS2 = arrayfun(@(x) t2999(find(t2999 > t1667(x) & t2999 < t1666(x+1),1)),(1:numel(t1666)-1)');
 try
     endInfosCS2(end+1) = t2999(t2999 > t1667(end) & t2999 < numel(tEv));
     %endInfosCS(end+1) = t2999(find(t2999 > t1667(end) & t2999 < numel(tEv)));
 catch
     endInfosCS2(end+1) = NaN;
 end
toc

%% Infos reading form INFOS is not correct...
infosDefFile = 'data/Joule/TEMPO/currentProcLib/INFOS.pro';
fid = fopen(infosDefFile,'r');
% Clean codelines
lines = {''};
while ~feof(fid)
    l = fgetl(fid);
    l = regexprep(l,'[ \t]+',' ');
    l = regexprep(l,'^ | $','');
    lines = [lines;l];
end
fclose(fid);
codeLines = {''};

inCommentBloc = false;
isCommented = zeros(numel(lines),1);
for ii = 1:numel(lines)    
    isCommented(ii) = startsWith(lines{ii},'//') ;
    
end


%% Comments for TDTbin2mat
%TDTBIN2MAT  TDT tank data extraction.
%   data = TDTbin2mat(BLOCK_PATH), where BLOCK_PATH is a string, retrieves
%   all data from specified block directory in struct format.  This reads
%   the binary tank data and requires no Windows-based software.
%
%   data.epocs      contains all epoc store data (onsets, offsets, values)
%   data.snips      contains all snippet store data (timestamps, channels,
%                   and raw data)
%   data.streams    contains all continuous data (sampling rate and raw
%                   data)
%   data.scalars    contains all scalar data (samples and timestamps)
%   data.info       contains additional information about the block
%
%   'parameter', value pairs
%        'T1'         scalar, retrieve data starting at T1 (default = 0 for
%                         beginning of recording)
%        'T2'         scalar, retrieve data ending at T2 (default = 0 for end
%                         of recording)
%        'SORTNAME'   string, specify sort ID to use when extracting snippets
%        'TYPE'       array of scalars or cell array of strings, specifies
%                         what type of data stores to retrieve from the tank
%                     1: all (default)
%                     2: epocs
%                     3: snips
%                     4: streams
%                     5: scalars
%                     TYPE can also be cell array of any combination of
%                         'epocs', 'streams', 'scalars', 'snips', 'all'
%                     examples:
%                         data = TDTbin2mat('MyTank','Block-1','TYPE',[1 2]);
%                             > returns only epocs and snips
%                         data = TDTbin2mat('MyTank','Block-1','TYPE',{'epocs','snips'});
%                             > returns only epocs and snips
%      'RANGES'     array of valid time range column vectors
%      'NODATA'     boolean, only return timestamps, channels, and sort 
%                       codes for snippets, no waveform data (default = false)
%      'STORE'      string, specify a single store to extract
%      'CHANNEL'    integer, choose a single channel, to extract from
%                       stream or snippet events. Default is 0, to extract
%                       all channels.
%      'BITWISE'    string, specify an epoc store or scalar store that 
%                       contains individual bits packed into a 32-bit 
%                       integer. Onsets/offsets from individual bits will
%                       be extracted.
%      'HEADERS'    var, set to 1 to return only the headers for this
%                       block, so that you can make repeated calls to read
%                       data without having to parse the TSQ file every
%                       time. Or, pass in the headers using this parameter.
%                   example:
%                       heads = TDTbin2mat(BLOCK_PATH, 'HEADERS', 1);
%                       data = TDTbin2mat(BLOCK_PATH, 'HEADERS', heads, 'TYPE', {'snips'});
%                       data = TDTbin2mat(BLOCK_PATH, 'HEADERS', heads, 'TYPE', {'streams'});
%      'COMBINE'    cell, specify one or more data stores that were saved 
%                       by the Strobed Data Storage gizmo in Synapse (or an
%                       Async_Stream_Store macro in OpenEx). By default,
%                       the data is stored in small chunks while the strobe
%                       is high. This setting allows you to combine these
%                       small chunks back into the full waveforms that were
%                       recorded while the strobe was enabled.
%                   example:
%                       data = TDTbin2mat(BLOCK_PATH, 'COMBINE', {'StS1'});
%

% Base dir for data
baseDir = '/Volumes/schalllab/data/Joule/tdtData/troubleshootEventCodes';
saveDir = fullfile(baseDir,'processed');
eventDefFile = '/Volumes/schalllab/data/Joule/TEMPO/ProcLib_7/EVENTDEF.pro';
infosDefFile = '/Volumes/schalllab/data/Joule/TEMPO/ProcLib_7/CMD/INFOS.pro';

jLong = load('/Volumes/schalllab/data/Joule/tdtData/troubleshootEventCodes/processed/Joule-180727-133314/Behav.mat');
Task = jLong.Task;

%Dirs
jDatedSessions=dir(fullfile(baseDir,'Joule-180727-13331*'));

%blocks
blockPaths=strcat({jDatedSessions.folder}',filesep,{jDatedSessions.name}');

BLOCK_PATH = blockPaths{1};

heads = TDTbin2mat(BLOCK_PATH, 'HEADERS', 1);

tdtRaw = TDTbin2mat(BLOCK_PATH,'TYPE',{'epocs','scalars'},'VERBOSE',0);
 
pdLRaw = TDTbin2mat(BLOCK_PATH,'TYPE',{'streams'},'STORE','PhoL','VERBOSE',0);
pdRRaw = TDTbin2mat(BLOCK_PATH,'TYPE',{'streams'},'STORE','PhoR','VERBOSE',0);

% Sampling freq
pdFs = pdLRaw.streams.PhoL.fs;
pdStartTimeL = pdLRaw.streams.PhoL.startTime;
pdStartTimeR = pdRRaw.streams.PhoR.startTime;

% make into column
pdL = pdLRaw.streams.PhoL.data';
pdR = pdRRaw.streams.PhoR.data';

% PDBin
pdTbinMs = 1000.0/pdFs;
pdTs = ((0:numel(pdL)-1)'.*pdTbinMs) + pdStartTimeL; 

% to find closest index into photodiode timestamps
%edges = [-Inf; mean([pdTs(2:end) pdTs(1:end-1)],1); +Inf];
edges = [-Inf; pdTs; +Inf];
closestIdx = @(x) discretize(x, edges);
% edges = [-Inf, mean([pdTs(2:end); pdTs(1:end-1)]), +Inf];
% I = discretize(aTest, edges);


% Find closest index into PD timestamps for FixSPotOn_
[closeFixOnIdx, closeFixOnMeanTs] = closestIdx(jLong.Task.FixSpotOn_);
% Tabulate
fixTab=table();
fixTab.fixSpotOn=Task.FixSpotOn_;
fixTab.fixSpotOnClosestIdx=closeFixOnIdx;
fixTab.fixSpotOnClosestMeans=edges(closeFixOnIdx);
fixTab.fixSpotOnClosestLeft=pdL(closeFixOnIdx);
fixTab.fixSpotOnClosestRight=pdR(closeFixOnIdx);

%% figureout the PD signal
pdL5Avg = movmean(pdL,[4 0]);

above_0_2L=find(pdL>0.15);
idxThr = above_0_2L;
pdLP.above_0_2.idxThr = idxThr;
% Half window for the signal
hw = 40;
% Find index for rise time : time to rise from 10% range to 90% range
riseTime = @(x) min(find(x>=range(x)*0.90)); %#ok<MXFND>
pdLP.above_0_2.riseTime = arrayfun(@(x) riseTime(pdL5Avg(x-40:x+40)), idxThr);
% shift center index to rise time
idxOnRiseTime = idxThr + pdLP.above_0_2.riseTime - hw;
pdLP.above_0_2.idxOnRiseTime = idxOnRiseTime;

pdLP.above_0_2.x = cell2mat(arrayfun(@(x) [(-hw:hw)';NaN], idxThr,'UniformOutput', false));
pdLP.above_0_2.y = cell2mat(arrayfun(@(x) [pdL5Avg(x-hw:x+hw);NaN], idxThr,'UniformOutput', false));
pdLP.above_0_2.yOnRiseTime = cell2mat(arrayfun(@(x) [pdL5Avg(x-hw:x+hw);NaN], idxOnRiseTime,'UniformOutput', false));

figure
plot(pdLP.above_0_2.x,pdLP.above_0_2.yOnRiseTime)
figure
plot(pdLP.above_0_2.x,pdLP.above_0_2.y)

figure
plot(pdLP.above_0_2.x.*pdTbinMs,pdLP.above_0_2.yOnRiseTime)
grid on
xlabel({'Photodiode Signal centered on rise-time (reach 90% of range for each cycle)'; 'Relative Time (ms)'})
ylabel('Phootodiode Signal Volts? or mVolts?')


%% Check PD function
[pdSignalL] = getPhotoDiodeEvents(pdL,pdFs);

[pdSignalR] = getPhotoDiodeEvents(pdR,pdFs);


sess = 'tdtData/troubleshootEventCodes/Joule-180801-154239';

sess = 'tdtData/troubleshootEventCodes/Joule-180731-110124';%Joule-180801-122935';
sess = 'tdtData/Countermanding/Joule-180801-122935';
sessDir = fullfile('/Volumes/schalllab/data/Joule',sess);
%Joule-180806-114038
sessDir = 'data/Joule/tdtData/troubleshootEventCodes/Joule-180806-115158';
sessDir = 'data/Joule/tdtData/troubleshootEventCodes/Joule-180806-114038';
sessDir = 'data/Joule/tdtData/troubleshootEventCodes/Joule-180806-122858';
sessDir = 'data/Joule/tdtData/troubleshootEventCodes/Joule-180806-134425';


pdL = TDTbin2mat(sessDir,'TYPE',{'streams'},'STORE','PhoL','VERBOSE',0);
pdR = TDTbin2mat(sessDir,'TYPE',{'streams'},'STORE','PhoR','VERBOSE',0);

pdFs = pdL.streams.PhoL.fs;

tic
[photodiodeEvents, pdFirstSignal, pdLastSignal] = processPhotodiode({pdL.streams.PhoL.data, pdR.streams.PhoR.data}, pdFs);
toc



% 
% %% Check for Kaleb's data
% kl19Sess='data/Kaleb/antiSessions/Darwin-180720-093619';
% klPdRaw = TDTbin2mat(kl19Sess,'TYPE',{'streams'},'STORE','PD__','VERBOSE', 0);
% pdFs = klPdRaw.streams.PD__.fs;
% tic
% [klPhotodiodeEvents, klPdFirstSignal] = processPhotodiode({klPdRaw.streams.PD__.data}, pdFs);
% toc

%% plot photodiode orphan signals in gray...





pdFirstVolts = pdFirstSignal.pdVolts;
pdLastVolts = pdLastSignal.pdVolts;

nTimeBins = size(pdFirstVolts,2);
signalTimeMs = (-floor(nTimeBins/2):floor(nTimeBins/2))';

nFirst = size(pdFirstVolts,1);
nLast = size(pdLastVolts,1);

orphanVolts = [];
orphansInFirst = false;

if nFirst > nLast
    orphansInFirst = true;
    orphanVolts = pdFirstVolts(nLast+1:end,:);    
elseif nLast > nFirst
    orphansInFirst = false;
    orphanVolts = pdLastVolts(nFirst+1:end,:);
else %both are same size
end

nOrphans = size(orphanVolts,1);
orphansY = [orphanVolts';nan(1,nOrphans)];
orphansX = repmat([signalTimeMs;NaN],1,nOrphans);

figure
plot(orphansX(:),orphansY(:),'g')


pdLsmooth = movmean(pdL.streams.PhoL.data,[2 0]);
pdRsmooth = movmean(pdR.streams.PhoR.data,[2 0]);

beh = load('dataProcessed/data/Joule/tdtData/troubleshootEventCodes/Joule-180806-122858/Behav.mat');
pdFirstMs = photodiodeEvents.PD_First_Ms;
pdLastMs = photodiodeEvents.PD_Last_Ms_Paired;

eventName = 'PDtrigger_';
%eventName = 'FixSpotOn_';
eventTime = beh.Task.(eventName);

% to find closest index into photodiode timestamps
% edges = [-Inf; pd1Start; +Inf];
% closestIdx = @(x) discretize(x, edges);
% Find closest index into PD timestamps for FixSPotOn_
% [closeFixOnIdx, closeFixOnMeanTs] = closestIdx(fixSpotOn);
closestIdx = nan(numel(eventTime,1));

for ii = 1:numel(eventTime)
    d = abs(pdLastMs-eventTime(ii));
    closestIdx(ii,1) = find(d==min(d),1);
end
figure
nTimeBins = size(pdFirstVolts,2);
xTimeInTicks = (-floor(nTimeBins/2):floor(nTimeBins/2))';
xTimeMs = xTimeInTicks*1000/pdFs;
tMinusF = nan(numel(closestIdx),1);
for ii = 1:numel(closestIdx)
    t = pdLastMs(closestIdx(ii));
    x =  t + xTimeMs;
    y = pdLastVolts(closestIdx(ii),:);
    f = eventTime(ii);
    tMinusF(ii,1) = t - f;
    plot(x,y);
    line([t t],ylim)
    line([f f],ylim,'color','r')
    text(x(10),double(y(50)),sprintf('Photodiode first (ms) = %.3f\n [%s] event (ms) = %.3f',t,eventName,f))
    
    drawnow
end

