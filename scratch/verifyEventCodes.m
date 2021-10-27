function [tblEventCount, tblCountCodes] = verifyEventCodes(sessionDir, eventCodecFile, varargin)
%VERIFYEVENTCODES Check of eventCodes for task/trial integrity of TEMPT ->
%TDT Event code communication.
%
%   sessionDir: Location where TDT data files are saved
%   eventCodecFile : File that contains the event code definitions.  This
%                    can be one of the following files:
%                    (1) EVENTDEF.pro file used to acquire data (preferred) OR
%                    (2) TEMPO_XXXX_rigDDD.m file used for translation
%
%   tblEventCount : A table of all event counts, excluding codes 0 and any
%                   codes >=3000 (only EVENTDEF codes
% Example:
%    sessDir = 'data/Joule/tdtData/Countermanding/Joule-180714-093508';
%    sessDir10 = ...
%    'data/Joule/tdtData/troubleshootEventCodes/Joule-180720-121327'; %//<10
%    sessDir5 = ...
%    'data/Joule/tdtData/troubleshootEventCodes/Joule-180720-120340'; %//<5
%    sessDir2 = ...
%    'data/Joule/tdtData/troubleshootEventCodes/Joule-180720-120804'; %//<2
%    outDir = 'dataProcessed/Joule/Countermanding';
%    evDefFile = 'data/Joule/TEMPO/currentProcLib/EVENTDEF.pro';%...TEMPO_EV_SEAS_rig029.m
%    infosDefFile = 'data/Joule/TEMPO/currentProcLib/CMD/INFOS.pro';

% T=verifyEventCodes(sessDir,evDefFile);
% Output:
% read up to t=5581.44s
% 
% ********************************
% data/Joule/tdtData/Countermanding/Joule-180714-093508
% data/Joule/tdtSetup/TEMPO_EV_SEAS_rig029.m
% 
% tblEventCount =
% 
%   7×3 table
% 
%                   evName                  evCode    evCount
%     __________________________________    ______    _______
% 
%     'CmanHeader_'                         1501       1640  
%     'UNKNOWN_CODE_NOT_IN_EVENT_STREAM'     NaN          0  
%     'TrialStart_'                         1666       1614  
%     'Eot_'                                1667       1632  
%     'StartInfos_'                         2998       1626  
%     'EndInfos_'                           2999       1612  
%     'UNKNOWN_CODE_IN_EVENT_STREAM'           0      29282  
% 
% 
% ********************************


    codes2Verify =[ 2681, 1501, 1502, 1509, 2680, 1666, 1667, 2998, 2999, 2776, 2777];
    
    tdtFun = @TDTbin2mat;
    if ispc
        tdtFun = @TDT2mat;
    end
    % Normalize filepaths
    normFilepath = @(x) regexprep(x,'[/\\]',filesep);

    %%  Process Rig specific event codes and event names   %
     eventCodecFile = normFilepath(eventCodecFile);
    [evCodec.code2Name, evCodec.name2Code] = ...
        getCodeDefs(eventCodecFile);

    %% Read events form TDT tank/block path %%
    % Get raw TDT events codes and event times
    sessionDir = normFilepath(sessionDir);
    tdtRawEpocs = tdtFun(sessionDir,'TYPE',{'epocs'},'VERBOSE',0); 
    tdtRawsScalars = tdtFun(sessionDir,'TYPE',{'scalars'},'VERBOSE',0); 
    
    tdtRaw = tdtRawEpocs;
    % Assume STRB data
    events = tdtRaw.epocs.STRB.data;
    events(events==0) = [];
    events(events>=3000) = []; 
    
    tblEventCount = struct();
    nonZeroEvCodes = 0;
    for ii = 1:numel(codes2Verify)
        code = codes2Verify(ii);
        evCount = 0;
        if evCodec.code2Name.isKey(code) 
            evName = evCodec.code2Name(code);
            evCode = code;
            evCount = sum(events == code);
        elseif sum(events==code)
            evName = 'UNKNOWN_CODE_IN_EVENT_STREAM';
            evCode = code;
            evCount = sum(events == code);                
        end
        if evCount > 0
            nonZeroEvCodes = nonZeroEvCodes + 1;            
            tblEventCount(nonZeroEvCodes).evName = evName;
            tblEventCount(nonZeroEvCodes).evCode = evCode;
            tblEventCount(nonZeroEvCodes).evCount = evCount;
        end
    end
    % table of codes
    tblEventCount = struct2table(tblEventCount);
    sortrows(tblEventCount,'evCode');
    fprintf('\n********************************');
    fprintf('%s\n%s\n',sessionDir,eventCodecFile);
    display(tblEventCount);
    
    
  doRelCodes = false;
  if doRelCodes
    for ii = 1: numel(codes2Verify)
        c = codes2Verify(ii);
        if find(events==c,1,'first')
            try
                fName = [evCodec.code2Name(c) num2str(c,'_%d')];
            catch
               fName = ['UNK_CODE_EVENTDEF_pro' num2str(c,'_%d')];
            end
            tblCountCodes.(fName) = getRelCodes(c,events,evCodec);
        end   
    end
    
    fns = fieldnames(tblCountCodes);
    for ii = 1:numel(fns)
        display(tblCountCodes.(fns{ii}));
    end
    
  end
    fprintf('\n********************************\n');

    
end

