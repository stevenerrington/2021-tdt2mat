function Task = decodeEvents(trialCodes, trialTimes, events,  infoMat)

nTrs = size(trialCodes,1);

%% Initialize vectors
Task.AlignTimes = nan(nTrs,1);
Task.Correct = nan(nTrs,1);
Task.Outcome = nan(nTrs,1);
Task.DelayDur = nan(nTrs,1);
Task.ErrorTone = nan(nTrs,1);
Task.FixSpotOff = nan(nTrs,1);
Task.FixSpotOn = nan(nTrs,1);
Task.Gains_EyeX = nan(nTrs,1);
Task.Gains_EyeY = nan(nTrs,1);
Task.Gains_XYF = nan(nTrs,1);
Task.Gains_YXF = nan(nTrs,1);
Task.GoCue = nan(nTrs,1);
Task.MGcolor = nan(nTrs,1);
Task.MaxSaccDur = nan(nTrs,1);
Task.MaxSaccTime = nan(nTrs,1);
Task.Reward = nan(nTrs,1);
Task.RewardDur = nan(nTrs,1);
Task.RewardOffset = nan(nTrs,1);
Task.RewardTone = nan(nTrs,1);
Task.SRT = nan(nTrs,1);
Task.SaccEnd = nan(nTrs,1);
Task.StimOnset = nan(nTrs,1);
Task.StimOnsetToTrial = nan(nTrs,1);
Task.TargetHold = nan(nTrs,1);
Task.TargetLoc = nan(nTrs,1);
Task.TaskType = cell(nTrs,1);
Task.TimeOut = nan(nTrs,1);
Task.Tone = nan(nTrs,1);
Task.error = nan(nTrs,1);
Task.ArrayStruct = nan(nTrs,1);
Task.DistHomo = nan(nTrs,1);
Task.SingMode = nan(nTrs,1);
Task.SetSize = nan(nTrs,1);
Task.TargetType = nan(nTrs,1);
Task.TrialType = nan(nTrs,1);
Task.Eccentricity = nan(nTrs,1);
Task.Singleton = nan(nTrs,1);
Task.DistLoc = nan(nTrs,1);
Task.IsCatch = nan(nTrs,1);
Task.SingleDistCol = nan(nTrs,1);
Task.DistOri = nan(nTrs,1);
Task.TargetOri = nan(nTrs,1);
Task.PercSgl = nan(nTrs,1);
Task.PercCatch = nan(nTrs,1);
Task.BlockNum = nan(nTrs,1);
Task.SOA = nan(nTrs,1);
Task.TargetPos = nan(nTrs,1);
Task.DistPos = nan(nTrs,1);
Task.error_names = cell(1,7);
Task.trStarts = nan(nTrs,1);
Task.trEnds = nan(nTrs,1);

schOutComes = {'NoFix','BrokeFix','NoSacc','NoGoCorrect','Inaccurate','FixBreak','Correct'};
for it=1:nTrs,
%     tempoStimOn = PLXin_get_event_time(events.Target_, it);
%     cpd = find(plxMat.TrialMat_PDtimes(it,:) > tempoStimOn, 1, 'first');
%     
%     if(~isempty(cpd))
%         Task.StimOnsetToTrial(it) = plxMat.TrialMat_PDtimes(it,cpd); 
%     end

    %% Start  with timings
    
    Task.StimOnsetToTrial(it)      = getEvTime(trialCodes(it,:),trialTimes(it,:),events.Target_);
%     Task.refresh_offset(it) = Task.StimOnsetToTrial(it) - tempoStimOn;
    Task.SRT(it)            = getEvTime(trialCodes(it,:),trialTimes(it,:),events.Saccade_);
    Task.SaccEnd(it)        = getEvTime(trialCodes(it,:),trialTimes(it,:),events.Decide_);
    Task.Reward(it)         = getEvTime(trialCodes(it,:),trialTimes(it,:),events.Reward_);
    Task.Tone(it)           = getEvTime(trialCodes(it,:),trialTimes(it,:),events.Tone_);    
    Task.RewardTone(it)     = getEvTime(trialCodes(it,:),trialTimes(it,:),events.Reward_tone);
    Task.ErrorTone(it)      = getEvTime(trialCodes(it,:),trialTimes(it,:),events.Error_tone);
    Task.FixSpotOn(it)      = getEvTime(trialCodes(it,:),trialTimes(it,:),events.FixSpotOn_);
    Task.FixSpotOff(it)     = getEvTime(trialCodes(it,:),trialTimes(it,:),events.FixSpotOff_);

    %% Trial Information
    cInf = infoMat(it,:);  % get the info codes corresponding to the current trial

    if(cInf(1) == 3000)
        Task.TaskType{it} = 'MG';
    elseif(cInf(1) == 3999)
        Task.TaskType{it} = 'Search';
    else
        Task.TaskType{it} = 'NA';
    end

    % the numerical values that are subtracted are defined in the tempo
    % configuration files. Unfortunately this has to be hard coded and is
    % arbitrary in its definition. Be careful and thouroughy double check.
    switch char(Task.TaskType(it))
        case 'MG'
            Task.TargetLoc(it) = cInf(15) - 3000;
            Task.MGcolor(it)   = cInf(16) - 3000;

            % get the delay duration based on fixation spot offset
            Task.DelayDur(it) = Task.FixSpotOff(it) - Task.StimOnsetToTrial(it);

        case 'Search'
            
            Task.ArrayStruct(it)   =  cInf(2) - 4001;
            Task.DistHomo(it)      =  cInf(3) - 4050;
            Task.SingMode(it)      =  cInf(4) - 4060;
            Task.SetSize(it)       =  cInf(5) - 4100;
            Task.TargetType(it)    =  cInf(6) - 4150;
            Task.TrialType(it)     =  cInf(7) - 4200;
            Task.Eccentricity(it)  =  cInf(8) - 4250;
            Task.Singleton(it)     = (cInf(9)- 1111)/1111;
            Task.TargetLoc(it)     =  cInf(12) - 5000;
            Task.DistLoc(it)       =  cInf(13) - 5500;
            Task.IsCatch(it)       =  cInf(14) - 4300; % make sure code is 0 for no catch and 1 for catch
            Task.SingleDistCol(it) =  cInf(15) - 4650;
            Task.DistOri(it)       =  cInf(16) - 4660;
            Task.TargetOri(it)     =  cInf(17) - 4670;
            Task.PercSgl(it)       =  cInf(18) - 4700;
            Task.PercCatch(it)     =  cInf(19) - 4800;
            Task.BlockNum(it)      =  cInf(20) - 4900;
            Task.SOA(it)           =  cInf(21) - 6000;
            Task.Outcome(it)       =  cInf(22) - 3000;
            if (Task.Outcome(it) == 7 || Task.Outcome(it) == 4),
                Task.Correct(it) = 1;
                Task.Error(it) = nan;
            else
                Task.Correct(it) = 0;
                Task.Error(it) = Task.Outcome(it);
            end
            if(cInf(10) == 8888)
                Task.TargetHemi(it) =  char('m');
            elseif(cInf(10) == 8200)
                Task.TargetHemi(it) =  char('r');
            elseif(cInf(10) == 8100)
                Task.TargetHemi(it) =  char('l');
            end

            if(cInf(11) == 8888)
                Task.DistHemi(it) = char('m');
            elseif(cInf(11) == 8200)
                Task.DistHemi(it) =  char('r');
            elseif(cInf(11) == 8100)
                Task.DistHemi(it) =  char('l');
            end

            if(Task.SetSize(it) == 1) % with only one item it is a detection task
                Task.TaskType{it} = 'Det';
            elseif(Task.SingMode(it) == 1)  % double check this one
                Task.TaskType{it} = 'Cap';
            end

        Task.TargetPos(it) = mod((360-Task.TargetLoc(it)+90)/45,8); % transform angle to index position
        Task.DistPos(it)   = mod((360-Task.DistLoc(it)  +90)/45,8);
    end

    Task.MaxSaccDur(it)   = cInf(21) - 3000;
    Task.MaxSaccTime(it)  = cInf(22) - 3000;
    Task.TimeOut(it)      = cInf(23) - 3000;
    Task.RewardDur(it)    = cInf(24) - 3000;
    Task.RewardOffset(it) = cInf(25) - 3000;
    Task.TargetHold(it)   = cInf(26) - 3000;
    Task.Gains_EyeX(it)   = cInf(28) - 1000;
    Task.Gains_EyeY(it)   = cInf(29) - 1000;
    Task.Gains_XYF(it)    = cInf(30) - 1000;
    Task.Gains_YXF(it)    = cInf(31) - 1000;
    
    % check for the ocurrence of stimulation
    if(isfield(Task, 'StimEV'))
        stimpos = find(trialCodes(it,:) == 666);
        if(~isempty(stimpos))  
            Task.StimTrial(it) = 1;
            Task.StimEV(it)    = plxMat.TrialMat_EVtimes(it,stimpos);
        else
            Task.StimTrial(it) = 0;
        end
    end
    
    
end

%% Get Trial Outcomes
% Correct Trials:
% Task.Correct  = logical(sum(bsxfun(@eq, trialCodes, events.Correct_),2));
% 
% % Errors:
% % This needs to be checked and coded more dynamically
% Task.error_names = {'False', 'Early', 'Late', 'FixBreak', 'HoldError', ...
%     'CatchErrorGo', 'CatchErrorNoGo'};
% 
% Task.error = nan(nTrs,1);
% Task.error(Task.Correct == 1) = 0;
% 
% false_resp = logical(sum(bsxfun(@eq, trialCodes, events.Error_sacc),2));
% if(any(false_resp))
%     Task.error(false_resp) = 1;
% end
% 
% early_resp = logical(sum(bsxfun(@eq, trialCodes, events.EarlySaccade_),2));
% if(any(early_resp))
%     Task.error(early_resp) = 2;
% end
% 
% fix_break = logical(sum(bsxfun(@eq, trialCodes, events.FixError_),2));
% if(any(fix_break))
%     Task.error(fix_break) = 4;
% end
% 
% hold_err = logical(sum(bsxfun(@eq, trialCodes, events.BreakTFix_),2));
% if(any(hold_err))
%     Task.error(hold_err) = 5;
% end
% 
% catch_go = logical(sum(bsxfun(@eq, trialCodes, events.CatchIncorrectG_),2));
% if(any(catch_go))
%     Task.error(catch_go) = 6;
% end
% 
% catch_hold = logical(sum(bsxfun(@eq, trialCodes, events.CatchIncorrectG_),2));
% if(any(catch_hold))
%     Task.error(catch_hold) = 7;
% end


% define stimulus onset as zero
Task.AlignTimes = Task.StimOnsetToTrial;
Task.SaccEnd    = Task.SaccEnd          - Task.StimOnsetToTrial;
Task.Reward     = Task.Reward           - Task.StimOnsetToTrial;
Task.Tone       = Task.Tone             - Task.StimOnsetToTrial;
Task.RewardTone = Task.RewardTone       - Task.StimOnsetToTrial;
Task.ErrorTone  = Task.ErrorTone        - Task.StimOnsetToTrial;
Task.FixSpotOn  = Task.FixSpotOn        - Task.StimOnsetToTrial;
Task.FixSpotOff = Task.FixSpotOff       - Task.StimOnsetToTrial;
Task.StimOnset  = Task.StimOnsetToTrial - Task.StimOnsetToTrial; % should be all zero aferwards
Task.GoCue 		= Task.FixSpotOff;
Task.SRT        = Task.SRT              - Task.StimOnsetToTrial - Task.GoCue;


function outTime = getEvTime(codes,times,match),
    tmp = find(codes==match,1);
    if ~isempty(tmp),
        outTime = times(tmp);
    else
        outTime = nan;
    end
end

end
