function [stopDataBEESTS] = cmand_DMCprocess(stateFlags,Infos)

trial = stateFlags.TrialNumber;
block = stateFlags.BlockNum;
blocktrial = stateFlags.blockTrialNum;

for trialIdx = 1:length(trial)
    
    % Get trial type (GO or STOP) (% target in Skippen CSV)
    if stateFlags.TrialType(trialIdx) == 1; trialType{trialIdx,1} = 'Stop';
    else; trialType{trialIdx,1} = 'Go';
    end
    
    % Target location (correctresponse in Skippen CSV)
    if stateFlags.CurrTargAngle(trialIdx) == 18000; targetlocation{trialIdx,1} = 'Left';
    else targetlocation{trialIdx,1} = 'Right';
    end
    
    % Response
    if stateFlags.IsCancel(trialIdx) == 1; response{trialIdx,1} = 'NoResponse';
    elseif stateFlags.IsTargAcquired(trialIdx) == 1 && stateFlags.CurrTargAngle(trialIdx) == 18000; response{trialIdx,1} = 'Left';
    elseif stateFlags.IsTargAcquired(trialIdx) == 1 && stateFlags.CurrTargAngle(trialIdx) == 0; response{trialIdx,1} = 'Right';
    elseif stateFlags.IsTargAcquired(trialIdx) == 0 || isnan(stateFlags.IsTargAcquired(trialIdx)); response{trialIdx,1} = 'NoStart';
    else response{trialIdx,1} = 'Elsewhere';
    end
    
    if stateFlags.IsHiRwrd(trialIdx) == 1; value{trialIdx,1} = 'High';
    else value{trialIdx,1} = 'Low';
    end    
end


rt = Infos.Decide_ - Infos.Target_;
ssd = round(stateFlags.UseSsdVrCount.*((1/60).*1000));


%%
stopDataBEESTS = ...
    table(trial,...
    block,...
    blocktrial,...
    trialType,... % No-stop (0) or stop trial (1)
    targetlocation,... % 
    round(stateFlags.UseSsdVrCount.*((1/60).*1000)),... % Stop signal delay
    response,...
    round(rt),...
    value,...
    'VariableNames',{'trial','block','blocktrial','trialType','targetLoc','ssd','response','rt','value'}); % Reaction time

%% Process and clean the data into the required format

stopDataBEESTS.ssd(stopDataBEESTS.ssd == 0) = 0;
stopDataBEESTS.rt(strcmp(stopDataBEESTS.response,'NoResponse')) = 0;
stopDataBEESTS.rt(strcmp(stopDataBEESTS.response,'NoStart')) = 0;
stopDataBEESTS.ssd(isnan(stopDataBEESTS.ssd),:) = 0;

end
