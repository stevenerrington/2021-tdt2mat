function [trialEvents, trialInfos, evCodec, infosCodec, tdtInfos ] = tdtExtractEvents(sessionDir, eventCodecFile, infosCodecFile, varargin)
%TDTEXTRACTEVENTS Extract Event data from TDT session
%
%   sessionDir: Location where TDT data files are saved
%   eventCodecFile : File that contains the event code definitions.  This
%                    can be one of the following files:
%                    (1) EVENTDEF.pro file used to acquire data (preferred) OR
%                    (2) [not tested] TEMPO_XXXX_rigDDD.m file used for translation
%   infosdCodecFile : The INFOS.pro file that has Names for InfoCodes
%   varargin        : Options for translation.  This is a struct with
%                     following fields. Fields if not present or if
%                     varargin is absent, then default values will be used
%   opts.useTaskStartEndCodes : [false] If true used event codes for
%                               TaskStart_ and TaskEnd_ from the
%                               eventCodecFile
%   opts.dropNaNTrialStartTrials : [true] After processing, drop all trials
%                                  and trialInfos where TrialStart_ is NaN  
%   opts.dropEventAllTrialsNaN   : [true] After processing, drop Events
%                                  where *all trials* for the event is NaN 
%   opts.infosOffsetValue : [3000] Value to be subtracted from translated
%                           Infos values. Note for negative values a
%                           different approach is used
%   opts.infosHasNegativeValues : [false] If true, then all info_values
%                                 (>= infosNegativeValueOffset) = 
%                                 infosNegativeValueOffset - info_values 
%                                 resulting -1 values are replaced with NaN
%                                 info_values(<infosNegativeValueOffset) =
%                                 info_values - infosOffsetValue
%  opts.infosNegativeValueOffset : [32768] If infosHasNegativeValue is set,
%                                  then this value is used as 0 and
%                                  anything higher is subtracted from this
%                                  value to get the negative value 
%
% Example:
%    sessDir = 'data/Joule/Joule-session';
%    evDefFile = 'data/Joule/Joule-session/ProcLib/CMD/EVENTDEF.PRO';
%    infosDefFile = 'data/Joule/Joule-session/ProcLib/CMD/INFOS.PRO';
%    opts = as explained above...
%    [trialEvents, trialInfos, evCodec, infosCodec, tdtInfos ] = ...
%            tdtExtractEvents(sessDir, evDefFile, infosDefFile);
%
%    [trialEvents, trialInfos, evCodec, infosCodec, tdtInfos ] = ...
%            tdtExtractEvents(sessDir, evDefFile, infosDefFile, opts);
%
% See also GETCODEDEFS

%% Process options for translation, if any
    if ~isempty(varargin)
        opts = varargin{1};
    else
        opts = struct();
    end
    if isfield(opts,'useTaskStartEndCodes')
        useTaskStartEndCodes = opts.useTaskStartEndCodes;
    else
        useTaskStartEndCodes = false;
    end
    if isfield(opts,'dropNaNTrialStartTrials')
        dropNaNTrialStartTrials = opts.dropNaNTrialStartTrials;
    else
        dropNaNTrialStartTrials = false;
    end      
    if isfield(opts,'dropEventAllTrialsNaN')
        dropEventAllTrialsNaN = opts.dropEventAllTrialsNaN;
    else
        dropEventAllTrialsNaN = true;
    end      
    if isfield(opts,'infosOffsetValue')
        infosOffsetValue = opts.infosOffsetValue;
    else
        infosOffsetValue = 3000;
    end        
    if isfield(opts,'infosHasNegativeValues')
        infosHasNegativeValues = opts.infosHasNegativeValues;
    else
        infosHasNegativeValues = false;
    end        
    if isfield(opts,'infosNegativeValueOffset')
        infosNegativeValueOffset = opts.infosNegativeValueOffset;
    else
        infosNegativeValueOffset = 32768;
    end
    
    
    % Normalize input path and extract sessionName
    blockPath = regexprep(sessionDir,'[/\\]',filesep);
      
    %%  Process Rig specific event codes and event names   %
    [evCodec.code2Name, evCodec.name2Code, evCodec.evTable] = ...
        getCodeDefs(regexprep(eventCodecFile,'[/\\]',filesep));
    
  %%  Process Infos specific codes  %%
  infosCodec = struct();
  if ~isempty(infosCodecFile)
    [infosCodec.code2Name, infosCodec.name2Code, infosCodec.infosTable] = ...
        getCodeDefs(regexprep(infosCodecFile,'[/\\]',filesep));
  end 
  hasInfosCodec =  isfield(infosCodec, 'code2Name');
    %%  Read TDT events and event times   %%
    [tdtEvents, tdtEventTimes, tdtInfos] = getTdtEvents(blockPath);
    % TDT events have '0' for code due to the way the TEMPO ring buffer is
    % written to TDT. We do not send negative codes. 
    % Remove all eventCodes that are '0' or less and corresponding event
    % times from the raw data
    removeLtEq0 = true;
    if removeLtEq0
        tdtEventTimes(tdtEvents <= 0) = [];
        tdtEvents(tdtEvents <= 0) = [];
    end
    %%  Process TDT events and infoCodes into trials  %%
    decodeEvent = @(x)  evCodec.name2Code(x);
    taskHeaderCodes = (1501:1510)';
    
    % codes
    trialStartCode = decodeEvent('TrialStart_');
    eotCode = decodeEvent('Eot_');
    % Change to Infos event names
    if (evCodec.name2Code.isKey('StartInfos_'))
        startInfosCode = decodeEvent('StartInfos_');
    else
        startInfosCode = decodeEvent('InfosStart_');
    end
    if (evCodec.name2Code.isKey('EndInfos_'))
        endInfosCode = decodeEvent('EndInfos_');
    else
        endInfosCode = decodeEvent('InfosEnd_');
    end
    
    % Now check for valid TASK blocks
    if (useTaskStartEndCodes)
        iTaskStart =  find(tdtEvents==decodeEvent('TaskStart_'));
    else
        iTaskStart =  find(ismember(tdtEvents,taskHeaderCodes));
    end
    if useTaskStartEndCodes    
        iTaskEnd = find(ismember(tdtEvents,decodeEvent('TaskEnd_'))); %#ok<UNRCH>
        if(numel(iTaskStart) - numel(iTaskEnd)) == 1
            % happens when session ends before new trail is completed.
            % So taskEnd marker will NOT be present for the LAST trial
            % so remove LAST iTaskStart marker
            iTaskStart = iTaskStart(1:end-1);
        end
    else
        iTaskEnd = [iTaskStart(2:end)-1;nEvents];
    end
    % Split event codes and times into task chunks
    [evCodes, evTimes]=arrayfun(@(i) deal(...
        tdtEvents(iTaskStart(i):iTaskEnd(i)),...
        tdtEventTimes(iTaskStart(i):iTaskEnd(i))),...% convert to ms
        (1:length(iTaskStart))','UniformOutput',false);
    nTasks = size(evCodes,1);
    %% Create table for all Event Codes and set column name as Event_Name
    colNames = evCodec.name2Code.keys';
    colCodes = cell2mat(evCodec.name2Code.values'); 
    colNames = [colNames;'TaskBlock';'TaskType_';'GoodTrial';'HasInfosCodes';'HasTrialStartAndEot';'HasStartInfosAndEndInfos'];
    % Initialize trialEventsTbl to [number of task_rows x event_names]
    trialEventsTbl = array2table(nan(nTasks,numel(colNames)));
    trialEventsTbl.DuplicateEventCodes = cell(nTasks,1);
    trialEventsTbl.DuplicateEventCodesCounts = cell(nTasks,1);
    trialEventsTbl.DuplicateEventCodesTimes = cell(nTasks,1);
    trialEventsTbl.UniqueEventCodes = cell(nTasks,1);
    trialEventsTbl.UniqueEventCodesCounts = cell(nTasks,1);
    trialEventsTbl.Properties.VariableNames(1:end-5) = colNames;
           
    %% Create table for all Infos and set column name as Info_Name
    trialInfos = repmat(struct(),nTasks,1);
    if hasInfosCodec
    infoNames = infosCodec.code2Name.values';
    startInfosOffset = infosOffsetValue;
    end
    
    warning('OFF','MATLAB:table:RowsAddedExistingVars');
tic
    for t = 1:nTasks
        if (t == 9)
            fprintf('trialno [%d]...\n',t);
        end
        allC = evCodes{t};
        allT = evTimes{t};
        evCodesTemp = allC(allC < infosOffsetValue);
        % get all event codes, including event codes inside the
        % infos-block-of-codes (usually extra_juice code
        tmsTemp = allT(allC < infosOffsetValue);
        % Get unique Event codes, if duplicate get first occurrance
        [evs,iUniq] = unique(evCodesTemp,'stable');
        tms = tmsTemp(iUniq);
        % default some vars to be present
        trialEventsTbl.TaskBlock(t) = t;

        trialEventsTbl.HasInfosCodes(t) = 1;
        trialEventsTbl.HasTrialStartAndEot(t) = ismember(trialStartCode, evs) && ismember(eotCode, evs);
        trialEventsTbl.HasStartInfosAndEndInfos(t) = ismember(startInfosCode, evs) && ismember(endInfosCode, evs);
        trialEventsTbl.GoodTrial(t) = trialEventsTbl.HasTrialStartAndEot(t) && trialEventsTbl.HasStartInfosAndEndInfos(t);
        % Housekeeping
        [evGt0Counts,evsGt0] = hist(evs(evs>0),unique(evs(evs>0)));
        trialEventsTbl.UniqueEventCodes(t) = {evsGt0'}; 
        trialEventsTbl.UniqueEventCodesCounts(t) = {evGt0Counts'};       
        
        if numel(evs) ~= sum(evCodesTemp < infosOffsetValue)
            % In case we want to count zeros, using hist (as histc 
            % does not count zeros) by incrementing all codes by 1
            [dupsCount,uniqDups]= hist(evCodesTemp+1,unique(evs+1));
            uniqDups = uniqDups(dupsCount > 1) - 1;
            dupsCount = dupsCount(dupsCount > 1);
            uniqDups = uniqDups(:)';
            warning('Task block %d has duplicate event codes {%s}, counts{%s}\n',...
                t,num2str(uniqDups,'[%d], '),num2str(dupsCount,'[%d] '));
            trialEventsTbl.DuplicateEventCodes(t) = {uniqDups'}; 
            trialEventsTbl.DuplicateEventCodesCounts(t) = {dupsCount'}; 
            trialEventsTbl.DuplicateEventCodesTimes(t) = {arrayfun(@(x) tmsTemp(evCodesTemp==x),uniqDups(:),'UniformOutput',false)}; 
        end
        if hasInfosCodec
            if ~sum(allC >= infosOffsetValue)
                warning('Task block %d has NO INFO codes\n',t);
                trialEventsTbl.HasInfosCodes(t) = 0;
                trialEventsTbl.GoodTrial(t) = 0;
            end
        end
        if intersect(taskHeaderCodes, evs)
            trialEventsTbl.TaskType_(t) = intersect(taskHeaderCodes, evs);
        end
        % Events: Get indices to column names for codes
        iTblCols = arrayfun(@(x) min([find(colCodes==x,1),NaN]),evs);
        trialEventsTbl(t,iTblCols(~isnan(iTblCols))) = array2table(tms(~isnan(iTblCols))');
        % Process Infos for the task/trial
        if hasInfosCodec
            % for infoes always use code2name as info codes may be duplicated
            % in INFOS.pro (see tone_duration, trial_length)
            if ismember(startInfosCode, evs) && ismember(endInfosCode, evs)
                infos = allC(find(allC==startInfosCode)+1:find(allC==endInfosCode)-1);
             else % if there are startInfos_ and endInfos_ are sent
                 warning('****Cannot find StartInfos_ and EndInfos_. Check if they are sent by TEMPO*****\n');
                 warning('Using *ALL* codes above  >= startInfosOffset [%d] to get infos\n',startInfosOffset);
                 % auto filters all eventCodes
                 infos = allC(allC>=startInfosOffset);
            end            
             if(numel(infos)==0)
                 warning('****Trl [%d] Cannot find Infos. Check if they are sent by TEMPO*****\n',t);
             else
                fprintf('TrlNo = %d, Number of infos codes including start and end infos = %d of total: %d InfoCodec Codes\n',...
                    t,numel(infos),numel(infosCodec.code2Name.keys));
                % It is possible that user may have given manual juice reward which will send 
                %Juice start/stop codes that are always less than startInfosOffset, so remove these event codes 
                %if they occur between start and end infos, or any other eventCode
                %infos(infos<startInfosOffset) = [];  <== will also remove
                %any errors in tempo transmission hence only remove event
                %codes that were defined in Evenentdef.pro
                evCodesInInfosBlock = intersect(evCodec.evTable.code,infos);
                for ee = 1:numel(evCodesInInfosBlock)
                    infos(infos==evCodesInInfosBlock(ee))=[];
                end
                % InfoCode annot be less than startInfosOffset, after
                % filtering for all event codes
                trialInfos(t,1).numberOfInfoCodeValuesLowerThanOffset = 0;
                if find(infos < startInfosOffset) % Negative value for info codes??
                    trialInfos(t,1).numberOfInfoCodeValuesLowerThanOffset = sum(infos < startInfosOffset);
                    warning('****NOT...Removing %d InfoCodes that are SMALLER startInfosOffset of %d, before parsing InfoCodes into fields***\n',...
                        sum(infos < startInfosOffset),startInfosOffset);
                    %infos = infos(infos>=startInfosOffset);
                    infos(infos<startInfosOffset)
                end
                 
                if(infosHasNegativeValues)
                    infos(infos>=infosNegativeValueOffset) = infosNegativeValueOffset - infos(infos>=infosNegativeValueOffset);
                    infos(infos== -1) = NaN;
                    infos(infos > 0 & infos<infosNegativeValueOffset) = infos(infos > 0 & infos<infosNegativeValueOffset) - startInfosOffset;
                  else
                    infos = infos - startInfosOffset;
                end
                
                % If infos contains name:displayItemSize, then process
                % stimulus attributes
                if sum(contains(infoNames,'displayItemSize'))
                    displaySizeInfoIndex = find(contains(infoNames,'displayItemSize'));
                    nItemAttributesIndex = find(contains(infoNames,'nItemAttributes'));
                    nonArrayInfos = infos(1:displaySizeInfoIndex);
                    displaySize =  nonArrayInfos(end);
                    stimulusAttribNames = infoNames(displaySizeInfoIndex+1:nItemAttributesIndex-1);
                    nStimulusAttributes = numel(stimulusAttribNames);
                    % Includes includes nInfos and nItemAttributes
                    arrayInfos = infos((1:nStimulusAttributes*displaySize)+displaySizeInfoIndex);
                else
                    nonArrayInfos = infos;
                    arrayInfos = [];
                end
                
                % Parse non-stimulus array related infos into fields
                for kk = 1:numel(nonArrayInfos)
                    try
                        trialInfos(t,1).(infoNames{kk}) = nonArrayInfos(kk);
                    catch me
                        warning(me.message);
                        fprintf('No. of Infos %d of total %d\n',numel(infos),numel(infosCodec.code2Name.keys));
                    end
                end
                % Process stimulus Display array infos
                if ~isempty(arrayInfos)
                    displayItems = array2table(reshape(arrayInfos,nStimulusAttributes,displaySize)',...
                                   'VariableNames', stimulusAttribNames);
                    targItem = displayItems(displayItems.itemIsTarget==1,:);
                    for jj = 1: numel(stimulusAttribNames)
                         fn = stimulusAttribNames{jj};
                         trialInfos(t,1).(fn) = targItem.(fn);
                    end                   
                    trialInfos(t,1).displayItems = displayItems;
                end
                
            end
        end       
    end
   toc 
   if (dropEventAllTrialsNaN)
       % prune all NaN Columns (events), if the whole column is NaN
       trialEventsTbl = trialEventsTbl(:,any(~ismissing(trialEventsTbl)));
   end
   % Remove all rows (trials) where trialStart_ is NaN as we cannot use
   % these trials. Happens for 1st/0th trial where only room num is sent as
   % well as during cases where TEMPO's clock is stopped, while TDT is
   % passively acquiring. When TEMPO's clock is restarted, the trial Num is
   % reset to 0, as well as there will be no TrailStart_ since the trial 0
   % case repeats.
   if(dropNaNTrialStartTrials)
       nanTrialStarts = isnan(trialEventsTbl.TrialStart_);
       trialEventsTbl(nanTrialStarts,:) = [];
       trialInfos(nanTrialStarts) = [];
   end
   % Convert table to struct
   trialEvents = table2struct(trialEventsTbl,'ToScalar',true);
   
   % Add new field blockTrialNum (starts lowercase, as it is a derived
   % field)
   blkStart = diff([0 trialInfos.BlockNum]);
   for ii = 1:numel(blkStart)
       if blkStart(ii) == 1
           currTrl = 1;
       else
           currTrl = currTrl + 1;
       end
       trialInfos(ii,1).blockTrialNum = currTrl;
   end


   
end


%% Sub-functions %%
function [tdtEvents, tdtEventTimes, tdtInfos] = getTdtEvents(blockPath)
    % Using functions form TDTSDK for reading raw TDT files
    % 
    tdtFun = @TDTbin2mat;
    % Get raw TDT events codes and event times
    tdtRaw = tdtFun(blockPath,'TYPE',{'epocs','scalars'},'VERBOSE',0); 
    % Use STROBE data when available
    try
        fprintf('*** Trying tdtRaw.epocs.STRB field ***\n')
        tdtEvents = tdtRaw.epocs.STRB.data;
        tdtEventTimes = tdtRaw.epocs.STRB.onset.*1000;
    catch me
        fprintf('*** No tdtRaw.epocs.STRB field ***\n')
        fprintf('%s\n',getReport(me));
        try
            fprintf('*** Trying tdtRaw.scalars.EVNT field ***\n')
            tdtEvents = tdtRaw.scalars.EVNT.data;
            tdtEventTimes = tdtRaw.scalars.EVNT.ts.*1000;
        catch me
            fprintf('*** No tdtRaw.scalars.EVNT field ***\n');
            fprintf('%s\n',getReport(me));
            error('Exiting...See above messages');
        end
    end    
    % Always return rows
    tdtEvents = tdtEvents(:);
    tdtEventTimes = tdtEventTimes(:);
    fprintf('Successfully read TDT event data\n');
    % Info about the files etc
    %  info is struct with fields:
    % Example:
    %    tankpath: 'translateTdt/data/Joule/tdtData/Countermanding'
    %    blockname: 'Joule-180714-093508'
    %         date: '2018-Jul-14'
    % utcStartTime: '14:35:11'
    %  utcStopTime: '16:08:12'
    %     duration: '01:33:01'
    %streamChannel: 0
    %  snipChannel: 0
    tdtInfos = tdtRaw.info;
    % claim space
    clear tdtRaw
end

