clear all; clc

% Get log and fine mat logged files
ephysLog = importOnlineEphysLogMaster;
dir.matFiles = 'S:\Users\Current Lab Members\Steven Errington\2021_DaJo\mat\';

% Find all the sessions that have been logged, and find the number of total
% sessions (/independent of the number of penetrations)
sessionList = cellfun(@str2num,ephysLog.SessionN);
uniqueSessionList = unique(sessionList);

%% Session-level extraction
% For each session, loop through and collate the relevant details.
for sessionIdx = 1:length(uniqueSessionList)
    
    % Print statement to show progress in loop
    fprintf('Analysing session %i of %i | %s.          \n',...
        sessionIdx,length(uniqueSessionList),ephysLog.Session{sessionIdx});
    
    % Get session related information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% monkey
    if strcmp(ephysLog.Monkey{sessionIdx},'Jo'); sessionInfo.monkey = 'joule';
    elseif strcmp(ephysLog.Monkey{sessionIdx},'Da'); sessionInfo.monkey = 'darwin';
    end
    %%% date:
    sessionInfo.date = datestr(ephysLog.Date{sessionIdx},'yyyymmdd');
    %%% task:
    sessionInfo.task = 'cmand1DR';
    %%% generate overall label for session
    sessionName = [sessionInfo.monkey(1:3) '-' sessionInfo.task '-' sessionInfo.date];
    
    %%%% Neurophysiology information %%%%
    %%% number of penetrations
    nPenetrations = sum(sessionList == sessionIdx);
    penLogIdx = find(sessionList == sessionIdx);
    
    %%% for eac
    clear penTable
    for penIdx = 1:nPenetrations
        if strcmp(ephysLog.DMFC{penLogIdx(penIdx)},'1')
            sessionInfo.area = 'DMFC';
        elseif strcmp(ephysLog.dACC{penLogIdx(penIdx)},'1') |...
                strcmp(ephysLog.vACC{penLogIdx(penIdx)},'1')
            sessionInfo.area = 'ACC';
        end
        
        dataFilename = ephysLog.Session{penLogIdx(penIdx)};
        
        % Get site specific penetration info
        gridLoc = [str2num(ephysLog.AP_Grid{penLogIdx(penIdx)}),...
            str2num(ephysLog.ML_Grid{penLogIdx(penIdx)})];
        recDepth = str2num(ephysLog.ElectrodeRelativeDepth{penLogIdx(penIdx)});
        recAngle = str2num(ephysLog.ElectrodeAngle{penLogIdx(penIdx)});
        electrode = ephysLog.Electrode_Serial{penLogIdx(penIdx)};
        spacing = str2num(ephysLog.ElectrodeSpacing{penLogIdx(penIdx)});
        
        penTable(penIdx,:) = ...
            table({dataFilename}, {sessionInfo.area}, gridLoc, recDepth, {recAngle}, {electrode}, spacing,...
            'VariableNames', {'dataFilename','area','grid','depth','angle','electrode','spacing'});
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    clear Behavior
    load([dir.matFiles penTable.dataFilename{1} '.mat'],'Behavior')
    
    dajo_datamap(sessionIdx,:) = ...
        table(sessionIdx, {sessionName}, {sessionInfo.date}, {sessionInfo.monkey},...
        Behavior, nPenetrations, {penTable}, 'VariableNames',...
        {'sessionN','session','date','monkey','behavior','nElectrodes','neurophysInfo'});
    
end

clearvars -except dajo_datamap

