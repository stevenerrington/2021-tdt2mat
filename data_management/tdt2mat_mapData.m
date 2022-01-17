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
for sessionLoopIdx = 1:length(uniqueSessionList)
       
    sessionIdx = find(sessionList == sessionLoopIdx);
    sessionIdx = sessionIdx(1);
    
    % Print statement to show progress in loop
    fprintf('Analysing session %i of %i | %s.          \n',...
        sessionLoopIdx,length(uniqueSessionList),ephysLog.Session{sessionIdx});
    
    % Load in information stored in first-pass conversion (now defunct)
    tempData = load(['S:\Users\Current Lab Members\Steven Errington\archive\mat3\'...
        ephysLog.Session{sessionIdx}],'SessionInfo','Behavior');
    

    %% Get session/animal related information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    %%% monkey
    if strcmp(ephysLog.Monkey{sessionIdx},'Jo');...
            animalInfo.monkey = 'joule'; animalInfo.id = 'v198'; animalInfo.sex = 'male'; animalInfo.species = 'macaca mulatta';
    elseif strcmp(ephysLog.Monkey{sessionIdx},'Da');...
            animalInfo.monkey = 'darwin'; animalInfo.id = 'da38'; animalInfo.sex = 'male'; animalInfo.species = 'macaca radiata';
    end
    
    %%% date:
    sessionInfo.date = datestr(ephysLog.Date{sessionIdx},'yyyymmdd');
    %%% time    
    sessionInfo.starttime = tempData.SessionInfo.tdt_.utcStartTime;
    sessionInfo.endtime = tempData.SessionInfo.tdt_.utcStopTime;
    
    %%% duration
    [~, ~, ~, H, M, S] = datevec(tempData.SessionInfo.tdt_.duration);
    sessionInfo.duration = (H*3600)+(M*60)+S;

    %%% task:
    sessionInfo.task = 'cmand1DR';
    %%% investigator
    sessionInfo.investigator = ephysLog.Exp{sessionIdx};
    %%% location
    sessionInfo.location = ['VU | WH' ephysLog.Rig{sessionIdx}];
        
    %%% generate overall label for session
    sessionName = [animalInfo.monkey(1:3) '-' sessionInfo.task '-' sessionInfo.date];
    
   
     %% Get behavior related information %%%%
     behInfo.dataFile = [sessionName '-beh.mat'];
     behInfo.eyeTrackingSystem = 'Eyelink 1000 Plus';
     behInfo.eyeTrackingFs = '1000';
     behInfo.expControlSystem = 'TEMPO';
     
     behInfo.nTrials = max(tempData.Behavior.stateFlags_.TrialNumber);
     behInfo.nBlocks = max(tempData.Behavior.stateFlags_.BlockNum);
     
     behInfo.engage_perc = sum(~isnan(tempData.Behavior.stateFlags_.IsTargetOn))./behInfo.nTrials*100;
     
     behInfo.toneCondition = mode(tempData.Behavior.stateFlags_.UseToneFreq...
         (tempData.Behavior.stateFlags_.IsCancel == 1)) < ...
         mode(tempData.Behavior.stateFlags_.UseToneFreq...
         (tempData.Behavior.stateFlags_.IsNonCancelledNoBrk == 1)); % Noncanc high freq = 1;

    %% %% Neurophysiology information %%%%
    %%% number of penetrations
    nPenetrations = sum(sessionList == sessionLoopIdx);
    penLogIdx = find(sessionList == sessionLoopIdx);
    
    %%% for each penetration, get the recording info
    clear penTable
    for penIdx = 1:nPenetrations
        if strcmp(ephysLog.DMFC{penLogIdx(penIdx)},'1')
            area = 'DMFC';
        elseif strcmp(ephysLog.dACC{penLogIdx(penIdx)},'1') |...
                strcmp(ephysLog.vACC{penLogIdx(penIdx)},'1')
            area = 'ACC';
        end
        
        dataFilename = ephysLog.Session{penLogIdx(penIdx)};
        
        % Get site specific penetration info
        gridLoc = [str2num(ephysLog.AP_Grid{penLogIdx(penIdx)}),...
            str2num(ephysLog.ML_Grid{penLogIdx(penIdx)})];
        recDepth = str2num(ephysLog.ElectrodeRelativeDepth{penLogIdx(penIdx)});
        recAngle = str2num(ephysLog.ElectrodeAngle{penLogIdx(penIdx)});
        electrode = ephysLog.Electrode_Serial{penLogIdx(penIdx)};
        spacing = str2num(ephysLog.ElectrodeSpacing{penLogIdx(penIdx)});
        
        
        lfpDatafile = [dataFilename '-lfp.mat']; spkDatafile = [dataFilename '-spk.mat'];
        
        lfpInfo.fs = 1017.2526 ; lfpInfo.filter = [3 300];
        spkInfo.fs = 24414.0625; spkInfo.filter = [300 5000];
        
        spkInfo.spkSorting.method = 'kilosort 2.0';
        spkInfo.spkSorting.format = 'phy';
        spkInfo.spkSorting.sorter = 'SE';
        
        
        % Collate into one table to reference
        penTable(penIdx,:) = ...
            table({dataFilename}, {area}, gridLoc, recDepth, {recAngle}, {electrode}, spacing,...
            {lfpDatafile}, {spkDatafile}, lfpInfo, spkInfo,...
            'VariableNames', {'dataFilename','area','grid','depth','angle','electrode','spacing',...
            'lfpFile','spkFile','lfpInfo','spkInfo'});
        
    end
    

    %% Prepare output table
    
    dajo_datamap(sessionLoopIdx,:) = ...
        table(sessionLoopIdx, {sessionName}, sessionInfo, animalInfo,...
        behInfo, nPenetrations, {penTable}, 'VariableNames',...
        {'sessionN','session','sessionInfo','animalInfo','behInfo','nElectrodes','neurophysInfo'});
    
end

clearvars -except dajo_datamap

