clear all; clc

% Get log and fine mat logged files
ephysLog = importOnlineEphysLogMaster;
dir.matFiles = 'S:\Users\Current Lab Members\Steven Errington\2021_DaJo\mat\';
dir.outFiles = 'S:\Users\Current Lab Members\Steven Errington\2021_DaJo\mat2\';

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
    
    %%% for each penetration
    clear penTable
    for penIdx = 1:nPenetrations
        if strcmp(ephysLog.DMFC{penLogIdx(penIdx)},'1')
            sessionInfo.area = 'DMFC';
        elseif strcmp(ephysLog.dACC{penLogIdx(penIdx)},'1') |...
                strcmp(ephysLog.vACC{penLogIdx(penIdx)},'1')
            sessionInfo.area = 'ACC';
        end
        
        dataFilename = ephysLog.Session{penLogIdx(penIdx)};
        
        clear inputData
        inputData = load([dir.matFiles dataFilename '.mat']);
        
        
        if penIdx == 1
            Events = rmfield(inputData.Behavior,{'Value','Stopping'});
            fprintf('Saving behavioral data... \n');...
                save('-v7.3', [dir.outFiles sessionName '-beh.mat'], 'Events', 'Eyes')
        end
        
        if isfield(inputData,'EEG')
            clear eeg; eeg = inputData.EEG;
            fprintf('Saving EEG data... \n');...
                save('-v7.3', [dir.outFiles dataFilename '-eeg.mat'], 'eeg')
        end
        
        clear lfp; lfp = inputData.LFP;
        fprintf('Saving LFP data... \n');...
            save('-v7.3', [dir.outFiles dataFilename '-lfp.mat'], 'lfp')
        
        clear spk; spk = inputData.Spikes;
        fprintf('Saving SPK data... \n');...
            save('-v7.3', [dir.outFiles dataFilename '-spk.mat'], 'spk')        
        
    end
    
end


