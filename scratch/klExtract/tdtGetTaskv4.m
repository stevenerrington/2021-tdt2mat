function [Task, trStarts, trEnds] = tdtGetTaskv4(inFile,events)

%% Get the TDT structure using their TDT2mat

if ispc
    getFun = @TDT2mat;
else
    getFun = @TDTbin2mat;
end

% First events
tdtEvsRaw = getFun(inFile,'TYPE',{'epocs'},'VERBOSE',false);
if isfield(tdtEvsRaw.epocs,'TEVT'),
    tdtEvs = tdt2EvShft(tdtEvsRaw.epocs.TEVT.data);
    tdtEvTms = tdtEvsRaw.epocs.TEVT.onset.*1000; % Multiplication converts to ms
elseif ~isfield(tdtEvsRaw.epocs,'EVNT'),
    tdtEvsRaw = getFun(inFile,'TYPE',{'scalars'},'VERBOSE',false);
    tdtEvs = tdt2EvShft(tdtEvsRaw.scalars.EVNT.data)';
    tdtEvTms = tdtEvsRaw.scalars.EVNT.ts'.*1000; % Multiplication converts to ms
else
    tdtEvs = tdt2EvShft(tdtEvsRaw.epocs.EVNT.data);
    tdtEvTms = tdtEvsRaw.epocs.EVNT.onset.*1000; % Multiplication converts to ms
end

% Cut out weird zeros
tdtEvTms(tdtEvs <= 0) = [];
tdtEvs(tdtEvs <= 0) = [];

% Cut out codes that seem to just mess things up...
cutCodes = [3063, 4232, 8872, 4200, 128, 3997, 4032, 8064, 3976, 4224, 1024, 1094, 2176, 2944, 3072, 3968, 3584, 7936, 3456, 3328, 4096, 8832, 8192];
% cutCodes = [2176, 2944, 3072, 3584, 7936, 3456, 3328, 8832, 8192];
% cutCodes = [];

% Cut out duplicate codes that shouldn't be doubles...
keepDoubles = [8888,8200,8100];
tdtEvsShft = [tdtEvs(2:end);nan];
tdtEvs(tdtEvs==tdtEvsShft & ~ismember(tdtEvs,keepDoubles)) = nan;
tdtEvTms(isnan(tdtEvs)) = [];
tdtEvs(isnan(tdtEvs)) = [];
tdtEvTms(ismember(tdtEvs,cutCodes)) = [];
tdtEvs(ismember(tdtEvs,cutCodes)) = [];

%% Loop through trials to get trial info and make a trial info matrix (as per PLX conversion...)
% First get appropriate indices
cutTrs = [];
startInds = find(tdtEvs == events.StartInfos_)+1;
endInds = find(tdtEvs == events.EndInfos_)-1;
trTypeInds = find(tdtEvs >= 1500 & tdtEvs < 1510);
trStartInds = find(tdtEvs == events.TrialStart_);
trStopInds  = find(tdtEvs == events.Eot_);
trStarts = tdtEvTms(trStartInds);
trEnds   = [tdtEvTms(trStartInds(2:end));length(tdtEvTms)];
nTrs = length(trStopInds);%length(trStartInds);

%% Added recently...
trStartInds(trStartInds > trStopInds(end)) = [];

%% Back to the usual
for it = 1:nTrs,
    
    if it < nTrs,
        tmpStart = find(startInds > trStopInds(it) & startInds < trStartInds(it+1),1,'first');
        tmpEnd   = find(endInds > trStopInds(it) & endInds < trStartInds(it+1),1,'first');
    else
        tmpStart = find(startInds > trStopInds(it),1,'first');
        tmpEnd = find(endInds > trStopInds(it),1,'first');
    end
    if isempty(tmpStart) || isempty(tmpEnd),
        cutTrs = [cutTrs;it];
    else
        iStart(it) = startInds(tmpStart);
        iEnd(it) = endInds(tmpEnd);
    end
    clear tmpStart tmpEnd
end
infoCnt = iEnd-iStart + 1;
evntCnt = trStopInds-trStartInds + 1;

% Now make the matrix
infoMat=nan(nTrs,max(infoCnt));
trialCodes = nan(nTrs,max(evntCnt));
trialTimes = nan(nTrs,max(evntCnt));
for it = 1:nTrs,
    clear thisTrInfos tmpTrCodes tempTrTms
    taskType(it) = tdtEvs(trTypeInds(find(trTypeInds < trStartInds(it),1,'last')));
    tmpTrCodes = tdtEvs(trStartInds(it):trStopInds(it));
    tmpTrTms = tdtEvTms(trStartInds(it):trStopInds(it));
    trialCodes(it,1:evntCnt(it)) = tdtEvs(trStartInds(it):trStopInds(it));
    trialTimes(it,1:evntCnt(it)) = tdtEvTms(trStartInds(it):trStopInds(it));
    thisTrInfos = tdtEvs(iStart(it):iEnd(it));
    
    if length(unique(tmpTrCodes >= 1500 & tmpTrCodes <= 1510)) > 1,
        keyboard
    end
    if taskType(it) - 1500 == 8,
        thisTrInfos = getSearchInfos(thisTrInfos);
        
    else
    
        % Cut out 2944 and 3072 which seems to be messing up the orders...
        thisTrInfos = thisTrInfos(~ismember(thisTrInfos,cutCodes)); 
        while sum(ismember(thisTrInfos(10:12),[8888,8200,8100])) == 3,
            if length(thisTrInfos) > 12,
                thisTrInfos = [thisTrInfos(1:11);thisTrInfos(13,:)];
            else
                thisTrInfos(12) = nan;
            end
        end
        trShift = [nan;thisTrInfos(1:(end-1))];
        thisTrInfos(thisTrInfos==trShift & ~ismember(thisTrInfos,[8888,8200,8100])) = [];
        if ismember(thisTrInfos(11),(0:45:315)+5000) && thisTrInfos(10) == 8888,
            thisTrInfos = [thisTrInfos(1:10);nan;thisTrInfos(11:end)];
        end
    end
    %     infoMat(it,1:infoCnt(it)) = tdtEvs(iStart(it):iEnd(it));
    infoMat(it,1:length(thisTrInfos)) = thisTrInfos;
    
end

%% loop over trials to get relevant timings.


% Get photo diode event as stimulus onset, keep this time relative to trial
% onset for later time adjustments.
Task = decodeEvents(trialCodes,trialTimes,events,infoMat);
Task.trStarts = trStarts;
Task.trEnds = trEnds;

function infoVect = getSearchInfos(infos)
    % We're gonna have to do this in a complicated way perhaps, but I
    % suppose it's worth it
    infosRaw = infos;
    infoVect = nan(1,length(infos));
    minVals = [3000,4000,4050,4060,4100,4150,4200,4250,8000,8000,5000,5500,3800,4650,4660,4670,4700,4800,4900,6000,3000];
    maxVals = [4000,5000,5000,5000,4200,4200,4300,4300,9000,9000,5500,6000,4500,4700,4700,4700,4800,4900,6000,10000,4000];
    for ic = 1:8,
        cutStuff = find(infos >= minVals(ic) & infos <= maxVals(ic),1);
        if isempty(cutStuff),
            infoVect(ic) = 1;
        else
            infoVect(ic) = infos(cutStuff); infos = infos((cutStuff+1):end);
        end
    end
    cutStuff = find(ismember(infos,[2222,1111]),1,'last');
    if isempty(cutStuff),
        infoVect(9) = nan;
    else
        infoVect(9) = infos(cutStuff); infos = infos((cutStuff+1):end);
    end
    for ic = 9:length(minVals),
        cutStuff = find(infos >= minVals(ic) & infos <= maxVals(ic),1);
        if isempty(cutStuff),
            infoVect(ic+1) = nan;
        else
            infoVect(ic+1) = infos(cutStuff); infos = infos((cutStuff+1):end);
        end
    end
    
end

end

