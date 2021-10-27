function [Task, TaskInfos, TrialEyes, EventCodec, InfosCodec, SessionInfos] = runExtraction(sessionDir,saveBaseDir,eventDefFile,infosDefFile,splitEyeIntoTrials,edfOptions, varargin)
%RUNEXTRACTION Summary of this function goes here
%   Detailed explanation goes here

    saveOutput = 0;
    useSessionNamePrefix = 1;
    if numel(varargin) == 1
        useSessionNamePrefix = varargin{1};
        evtTranslateOptions = {};
    end
    if numel(varargin) == 2
        useSessionNamePrefix = varargin{1};
        evtTranslateOptions = varargin{2};
    end
        
    sessionName = regexp(sessionDir,'[-\w]+$','match');
    sessionName = sessionName{1};    
    
    if useSessionNamePrefix
        saveFilePrefix = [sessionName '_'];
    else
        saveFilePrefix = '';
    end
    
    [Task, TaskInfos, EventCodec, InfosCodec, SessionInfos] = tdtExtractEvents(sessionDir,eventDefFile,infosDefFile,evtTranslateOptions);

    % Save translated mat file if needed
    if saveOutput
        saveFile = fullfile(saveBaseDir,sessionName,[saveFilePrefix 'Events.mat']);
        [oDir,~] = fileparts(saveFile);
        if ~exist(oDir,'dir')
            mkdir(oDir);
        end
        fprintf('Saving Event data to file %s\n',saveFile);
        save(saveFile,'Task','TaskInfos','EventCodec', 'InfosCodec', 'SessionInfos');
    end
    fprintf('Extracting Eye data...\n');
    if(splitEyeIntoTrials)
        [TrialEyes] = tdtExtractEyes(sessionDir, Task.TrialStart_, Task.Eot_, edfOptions); 
    else
        [TrialEyes] = tdtExtractEyes(sessionDir,[],[],edfOptions); 
    end
    
    if saveOutput
        saveFile = fullfile(saveBaseDir,sessionName,[saveFilePrefix 'Eyes.mat']);
        [oDir,~] = fileparts(saveFile);
        if ~exist(oDir,'dir')
            mkdir(oDir);
        end
        fprintf('Saving Eye data to file %s\n',saveFile);
        save(saveFile, '-struct', 'TrialEyes');
    end
    

end