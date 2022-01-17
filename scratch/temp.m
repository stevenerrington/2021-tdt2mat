clear all; clc
% Get log and fine mat logged files
ephysLog = importOnlineEphysLogMaster;
dir.matFiles = 'S:\Users\Current Lab Members\Steven Errington\archive\mat3\';
dir.outFiles = 'S:\Users\Current Lab Members\Steven Errington\archive\mat2\';
% Find all the sessions that have been logged, and find the number of total
% sessions (/independent of the number of penetrations)
sessionList = cellfun(@str2num,ephysLog.SessionN);
uniqueSessionList = unique(sessionList);


%% Session-level extraction
% For each session, loop through and collate the relevant details.
parfor sessionIdx = 1:length(uniqueSessionList)
    % Print statement to show progress in loop
    
    % Get session related information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% monkey
    monkey = [];
    if strcmp(ephysLog.Monkey{sessionIdx},'Jo'); monkey = 'joule';
    elseif strcmp(ephysLog.Monkey{sessionIdx},'Da'); monkey = 'darwin';
    end
    %%% date:
    date = datestr(ephysLog.Date{sessionIdx},'yyyymmdd');
    %%% task:
    task = 'cmand1DR';
    %%% generate overall label for session
    sessionName = [monkey(1:3) '-' task '-' date];
    %%%% Neurophysiology information %%%%
    %%% number of penetrations
    nPenetrations = sum(sessionList == sessionIdx);
    penLogIdx = find(sessionList == sessionIdx);
    dataFilename = ephysLog.Session{penLogIdx(1)};
    
    if ~isfile([dir.outFiles sessionName '-beh.mat'])
        
        fprintf('Analysing session %i of %i | %s.          \n',...
            sessionIdx,length(uniqueSessionList),ephysLog.Session{sessionIdx});
        
        %     clear inputData
        inputData = load([dir.matFiles dataFilename '.mat'],'Behavior','Eyes');
        %     clear Events
        events = rmfield(inputData.Behavior,{'Value','Stopping'});
        eyes = inputData.Eyes
        fprintf('Saving behavioral data... \n');
        try
            parsave_beh([dir.outFiles sessionName '-beh.mat'], events, eyes)
        catch
            fprintf('Error saving %s... \n', sessionName );
        end
        
    else
        continue
    end
    
end