%% Clear environment
clear; clc;
dirs.masterData = 'S:\DATA\Current Subjects';

%% Get Session Information
% Get Ephys log and tidy
ephysLog = importOnlineEphysLogMaster;

% Get usable session IDs for looping
sessionList = cellfun(@str2num,ephysLog.SessionN);
uniqueSessionList = unique(sessionList);

for sessionIdx = 1:length(uniqueSessionList)
    sessionLogIdx = find(sessionList == uniqueSessionList(sessionIdx));
    
    fprintf('Analysing session %i of %i | %s.          \n',...
        sessionIdx,length(uniqueSessionList),ephysLog.TDTfilename{sessionLogIdx(1)});
    
    % Get session related information
    %%% monkey
    if strcmp(ephysLog.Monkey{sessionLogIdx(1)},'Jo'); sessionInfo.monkey = 'joule';
    elseif strcmp(ephysLog.Monkey{sessionLogIdx(1)},'Da'); sessionInfo.monkey = 'darwin';
    end
    
    %%% date
    sessionInfo.date = datestr(ephysLog.Date{sessionLogIdx(1)},'yyyymmdd');
    
    %%% task
    sessionInfo.task = 'cmand1DR';
    
    %%% tdtFile
    sessionInfo.tdtFile = ephysLog.TDTfilename{sessionLogIdx(1)};
    
    %%% area
    for subsessionIdx = 1:length(sessionLogIdx)
        if strcmp(ephysLog.DMFC{sessionLogIdx(subsessionIdx)},'1')
            areaList{subsessionIdx} = 'DMFC';
        elseif strcmp(ephysLog.dACC{sessionLogIdx(subsessionIdx)},'1') |...
                strcmp(ephysLog.vACC{sessionLogIdx(subsessionIdx)},'1')
            areaList{subsessionIdx} = 'ACC';
        end
    end
    
    %% Define Extraction Parameters
    ops.doSecondary = 1; ops.EEGrecorded = strcmp(ephysLog.EEG{sessionLogIdx(1)},'1');
    ops.saveOutput = 0; ops.makeSingleMAT = 1;
    ops.getLFP = 1; ops.getSpk = 1;
    
    %% Run Extraction
    for electrodeIdx = 1:length(areaList)
        clearvars -except ops areaList electrodeIdx sessionInfo ephysLog uniqueSessionList...
            sessionLogIdx
        
        if electrodeIdx == 1 && ops.EEGrecorded  == 1; ops.getEEG = 1; else ops.getEEG = 0; end
        
        %% Input session information
        sessionInfo.area = areaList{electrodeIdx}; % fef, sef, acc, beh
        sessionInfo.grid = [str2num(ephysLog.AP_Grid{sessionLogIdx(electrodeIdx)}),...
            str2num(ephysLog.ML_Grid{sessionLogIdx(electrodeIdx)})];
        
        
        if length(areaList) > 1 && strcmp(areaList{1},areaList{2})
            if electrodeIdx == 1; tag = 'a'; elseif electrodeIdx == 2; tag = 'b'; end
            outFilename = [sessionInfo.monkey(1:3) '-' sessionInfo.task '-'...
                sessionInfo.area '-' sessionInfo.date tag];
        else
            outFilename = [sessionInfo.monkey(1:3) '-' sessionInfo.task '-'...
                sessionInfo.area '-' sessionInfo.date];
        end
        
        
        %% Get online ephys data log
        logIdx = find(not(cellfun('isempty',strfind(ephysLog.TDTfilename,sessionInfo.tdtFile))));
        if isempty(logIdx); logIdx = 1; else; logIdx = logIdx(electrodeIdx); end
        
        
        %% Set directories
        dirs.rawDir = [dirs.masterData '\' [upper(sessionInfo.monkey(1)) sessionInfo.monkey(2)]...
            '\Experimental\Countermanding\Neurophysiology\'...
            [upper(sessionInfo.monkey(1)) sessionInfo.monkey(2:end)] '-' sessionInfo.date(3:end)];
        
        dirs.outputDir = ['S:\Users\Current Lab Members\Steven Errington\cmand1DR_dataExtraction\'];
        dirs.processedDir = [dirs.outputDir '\output\' outFilename];
        dirs.experimentName = sessionInfo.tdtFile;
        dirs.figureFolder = [dirs.processedDir,'\figures'];
        
        if ~exist(dirs.figureFolder);  mkdir(dirs.figureFolder); end
        if ~exist(dirs.processedDir); mkdir(dirs.processedDir); end
        
        %% Run TDT translation
        % Extract data from TDT format into Matlab
        warning off
        tdtOptions = getTDTopts(getTDTdir(dirs.rawDir,dirs.processedDir),dirs.experimentName);
        [Infos, stateFlags, TrialEyes, ~, ~, tdtInfo] = TDTTranslator(tdtOptions).translate(0);
        
        % Clean out error transfer trials
        [stateFlags,Infos] = cleanTranslateError(stateFlags,Infos);
        
        % Extract behavior
        [ttx, ttx_history, trialEventTimes] = processSessionTrials (stateFlags, Infos);
        [stopSignalBeh, RTdist] = extractStopBeh(stateFlags,Infos,ttx);
        [valueBeh] = extractValueBeh(Infos,ttx);
        [valueStopSignalBeh, valueRTdist] = extractValueStopBeh(stateFlags,Infos,ttx);
        [ttm] = processTrialMatching(stopSignalBeh, ttx, trialEventTimes);
        
        % Get Eyes Data
        %%%%%%%%%% to be complete: saccade dynamics, alignedEyeTrace
        tdtEyes = alignEyes(trialEventTimes,TrialEyes, [-1000 2000]); % <- This needs checking!
        
        % Get Ephys data
        [tdtLFP, tdtSpk, tdtEEG] = getTDTephys_dual(dirs, ops, electrodeIdx);
        
        
        %% Secondary extractions
        % Align Ephys
        if ops.doSecondary
            timeWin = [-1000 2000];
            tdtLFP_aligned = alignLFP(trialEventTimes,tdtLFP, timeWin);
            tdtSpk_aligned = alignSDF(trialEventTimes, Infos, tdtSpk, timeWin);
            
            % Get CSD
            CSDanalysis = getSessionCSD(tdtLFP_aligned, [900:1250]);
        end
        
        %% Print output
        produceBehFigures % Produce behavioral figures
        
        if ops.doSecondary
            produceCSDFigures(dirs, outFilename, tdtInfo, sessionInfo, ephysLog, logIdx, ttx, CSDanalysis)
            produceSpkFigures(dirs, outFilename, tdtInfo, sessionInfo, ephysLog, logIdx,...
                tdtSpk, tdtSpk_aligned, Infos, ttx, stopSignalBeh)
        end
        
        %% Save output
        % save Spike times and waveforms
        if ops.saveOutput
            extractOutFolder = [dirs.processedDir,'\mat'];
            
            if ~exist(extractOutFolder); mkdir(extractOutFolder); end
            
            spkfileName = fullfile(extractOutFolder,'Spikes.mat');
            lfpfileName = fullfile(extractOutFolder,'LFP.mat');
            behfileName = fullfile(extractOutFolder,'Behavior.mat');
            eyesfileName = fullfile(extractOutFolder,'Eyes.mat');
            
            fprintf('Saving spike data... \n');save('-v7.3', spkfileName, 'tdtSpk');
            fprintf('Saving LFP data... \n');save('-v7.3', lfpfileName, 'tdtLFP');
            fprintf('Saving behavioral data... \n'); save(behfileName, 'RTdist', 'sessionInfo',...
                'stateFlags', 'stopSignalBeh','tdtInfo', 'trialEventTimes',...
                'ttm', 'ttx', 'ttx_history', 'valueBeh', 'valueRTdist',...
                'valueStopSignalBeh');
            fprintf('Saving eye data... \n'); save(eyesfileName, 'tdtEyes', 'TrialEyes');
            
        end
        
        if ops.makeSingleMAT
            fprintf('Saving single session datafile... \n');
            
            extractOutFolder = [dirs.outputDir '\mat'];
            sessionFileName = fullfile(extractOutFolder,[outFilename '.mat']);
            
            Spikes = tdtSpk; LFP = tdtLFP; Eyes = TrialEyes.tdt;
            SessionInfo = struct('general',sessionInfo,'tdt_',tdtInfo');
            Behavior = struct('stateFlags_',stateFlags,'Infos_',Infos);
            Trials = struct('ttx',ttx,'ttm',ttm,'ttx_history',ttx_history);
            Behavior.Value = struct('valueBeh',valueBeh,'valueStopBeh',valueStopSignalBeh,'valueRTdist',valueRTdist);
            Behavior.Stopping = stopSignalBeh;
            
            if ops.EEGrecorded == 1
                EEG = tdtEEG;
                save('-v7.3', sessionFileName, 'Spikes','LFP','EEG','Eyes','SessionInfo','Behavior','Trials');
            else
                save('-v7.3', sessionFileName, 'Spikes','LFP','Eyes','SessionInfo','Behavior','Trials');
            end
            
            clear Spikes LFP Eyes SessionInfo Behavior Trials
        end
        
    end
end