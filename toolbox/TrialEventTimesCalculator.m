function [TrialEventTimes_all] = TrialEventTimesCalculator(TrialStart_ , Target_ , StopSignal_ , Sacc_of_interest , SaccEnd , Tone_ , Reward_ , SecondSacc, SaccBegin, SaccAmplitude, Infos_)

% This is written for analysis of Godlove's data. 
% He has already extracted TrialStart_, Target_, StopSignal_,
% Sacc_of_interest, SaccEnd, Tone_, Reward_, Second_Sacc  (which are the
% inputs) in the .Mat datafile. In order for me to process it, I'm
% converting this data into a single matrix, called TrialEventTimes_all,
% which gives all the times in absolute sense (relative to the same
% reference point: start of the session). 


% Defining important times within the task. All the information is also
% present in the .mat file. I'm rearranging them into a format usable by
% myself:
% Matrix that's generated from this section is TrialEventTimes_all which
% includes all relevant task events, time-tagged relative to the start of
% the session (so times are absolute, not relative).
% The number of rows in this matrix corresponds to the number of trials
% and the number of columns is 8 for the 8 events listed below (matrix
% names are self-explanatory).

tr_total = size(TrialStart_,1);    % Total number of trials.
fprintf('Total number of trials = %d.\n',tr_total);
SecondSaccCutoff = 2;  % any sacc larger than this qualifies for second saccade identification.

Sacc_Start = Sacc_of_interest(:,1);


Sacc_End=nan(tr_total,1);
Second_Sacc=nan(tr_total,1);
for tr = 1:tr_total     % This for-loop is probably an inefficient way to calculate Sacc_End. don't confuse this with SaccEnd that's ALREADY present in the raw .mat files. This contains end-time of the saccade of interest.
    if isnan( Sacc_of_interest(tr,2) ) == 0
        Sacc_End(tr,1) = SaccEnd( tr,   Sacc_of_interest(tr,2) );
        if sum(SaccAmplitude(tr, (Sacc_of_interest(tr,2)+1):size(SaccBegin,2))  >  SecondSaccCutoff) > 0
        Second_Sacc(tr,1) = SaccBegin(  tr,   Sacc_of_interest(tr,2) + find( SaccAmplitude(tr, (Sacc_of_interest(tr,2)+1):size(SaccBegin,2))  >  SecondSaccCutoff  , 1   )) ;
        else
            Second_Sacc(tr,1) = NaN;
        end
    end
end

% Second_Sacc = SecondSacc(:,1);    % On Jan 05, 2017 I found that the SecondSaccades that are present in the .mat data file are actually NOT the saccades that are used for abording the trial. So, I'm going to comment out this line and instead, come up with a saccade amplitude cut off.


StopSignal = StopSignal_;             % So, now we have the same thing as StopSignal_, which is NaN when no Stop signal was presented. 
   % but I want to use the "fake" SSD for Go trials to plot an SSD-aligned
   % activity for this trial type. So:
   
    StopSignal (find (isnan(StopSignal) == 1)) = Target_ (find (isnan(StopSignal) == 1)) + Infos_.Curr_SSD (find (isnan(StopSignal) == 1));   % turn the elements in StopSignal array that's NaN (i.e., Go-trials) into values defined by Infos_.Curr_SSD (which assigns a SSD for every trial). 
     
    % Note, the Target + Infos_.Curr_SSD is not EXACTLY the same as
    % StopSignal_ (not sure why, by probably related to program delays
    % etc). So, here I am using StopSignal_ for all the trials that
    % ACTUALLY had stop signal, and only use Infos_CurrSSD for strials in
    % which no SS was presented.
    



TrialEventTimes_all = [TrialStart_    TrialStart_+Target_     TrialStart_+StopSignal    TrialStart_+Sacc_Start    TrialStart_+Sacc_End       TrialStart_+Tone_      TrialStart_+Reward_    TrialStart_+Second_Sacc];
% This is the matrix that contains all timing info for all trials. NaN
% means that that event did not exist for that trial. The time (in ms) in
% TrialEventTimes_all are all relative to the start of the session
% (absolute time).