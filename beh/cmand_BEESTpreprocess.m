function [stopDataBEESTS] = cmand_BEESTpreprocess(stateFlags,Infos)

    %% Accumulate all the relevant raw data

    rt = Infos.Decide_ - Infos.Target_;
    
    stopDataBEESTS = ...
        table(stateFlags.TrialType,... % No-stop (0) or stop trial (1)
        stateFlags.IsCancel,... % Trial outcome
        round(stateFlags.UseSsdVrCount.*((1/60).*1000)),... % Stop signal delay
        round(rt),...
        'VariableNames',{'ss_presented','inhibited','ssd','rt'}); % Reaction time

    %% Process and clean the data into the required format

    stopDataBEESTS.ssd(stopDataBEESTS.ss_presented == 0) = -999;
    stopDataBEESTS.inhibited(stopDataBEESTS.ss_presented == 0) = -999;
    stopDataBEESTS.rt(stopDataBEESTS.inhibited == 1) = -999;
    stopDataBEESTS(isnan(stopDataBEESTS.inhibited),:) = [];
    stopDataBEESTS((stopDataBEESTS.inhibited == 0 | stopDataBEESTS.inhibited == -999) & isnan(stopDataBEESTS.rt),:) = [];

end
