

%% See paper ref below
% see: https://elifesciences.org/articles/46323
% for definitions
goTrial = TaskInfos.TrialType == 0;
stopTrial = TaskInfos.TrialType == 1;
% Not in paper...??
successfulGoTrial = TaskInfos.TrialType == 0 &  TaskInfos.IsGoCorrect==1;
successfulStopTrial = TaskInfos.TrialType == 1 & TaskInfos.IsCancelledNoBrk == 1;
% successfulStopTrial2 = TaskInfos.TrialType == 1 & Task.OutcomeNogoCancelNoBrk_ > 0;
unsuccessfulStopTrial = TaskInfos.IsStopSignalOn == 1 & (TaskInfos.IsNonCancelledBrk==1 | TaskInfos.IsNonCancelledNoBrk==1);
goOmission = TaskInfos.TrialType == 0 & TaskInfos.IsTargetOn == 1 & Task.NoSaccade_>0;
% we dont save tyhis as a event, maybe we should....
goTrialsChoiceErr = NaN;
% not applicable?
goTrialPrematureResp= NaN;

% p(respond|signal)
pRespondSignal = inh_pNC;

% Choice Err on unsuccessful stop trials - Not applicable?
choiceErrOnUnsuccessfulStopTrl = NaN;
% This is a special case of unsuccessful stop trials, referring to
% responses executed before the presentation of the go stimulus on stop
% trials (see description premature responses on go trials). In some
% studies, this label is also used for go responses executed after the
% presentation of the go stimulus but before the presentation of the stop signal 
prematRespUnsuccesfulStop_preSSD =   TaskInfos.IsStopSignalOn == 0 & (TaskInfos.IsNonCancelledBrk==1 | TaskInfos.IsNonCancelledNoBrk==1);

%%






inh_SSD = beh.raceModel.inh_SSD;
inh_pNC = beh.raceModel.inh_pNC;
inh_nTr = beh.raceModel.inh_nTr;


W.raceModel = fitWeibull(inh_SSD,inh_pNC,inh_nTr);


%% drop points....

minTr = nanmin(inh_nTr);
maxSsd = nanmax(inh_SSD)+100;

% add (ssd,pNC) (0,0) and (2000,1)
W.raceModel_add_01 = fitWeibull([0;inh_SSD;maxSsd],[0;inh_pNC;1],[min(inh_nTr);inh_nTr;minTr]);
% use (ssd,pNC) that are >0 or <1
no_01_idx=inh_pNC>0 & inh_pNC<1;
W.raceModel_no_01 = fitWeibull(inh_SSD(no_01_idx),inh_pNC(no_01_idx),inh_nTr(no_01_idx));
% add back (0,0) and (2000,1)
W.raceModel_no_01_add_01 = fitWeibull([0;inh_SSD(no_01_idx);maxSsd],[0;inh_pNC(no_01_idx);1],[minTr;inh_nTr(no_01_idx);minTr]);
% use (ssd,pNC) that are >0
no_0_idx = inh_pNC>0;
W.raceModel_no_0 = fitWeibull(inh_SSD(no_0_idx),inh_pNC(no_0_idx),inh_nTr(no_0_idx));
% add back (0,0)
W.raceModel_no_0_add_0 = fitWeibull([0;inh_SSD(no_0_idx)],[0;inh_pNC(no_0_idx)],[minTr;inh_nTr(no_0_idx)]);
% use (ssd,pNC) that are < 1
no_1_idx=inh_pNC<1;
W.raceModel_no_1 = fitWeibull(inh_SSD(no_1_idx),inh_pNC(no_1_idx),inh_nTr(no_0_idx));
% add back (2000,1)
W.raceModel_no_1_add_1 = fitWeibull([inh_SSD(no_1_idx);maxSsd],[inh_pNC(no_1_idx);1],[inh_nTr(no_0_idx);minTr]);

fn = fieldnames(W);
figure
for ii = 1:numel(fn)
    h = plot(W.(fn{ii}).PredY,'MarkerIndices',ii);
    hold on
    %scatter(W.(fn{ii}).inh_SSD,W.(fn{ii}).inh_pNC,'Marker',h.Marker,'MarkerFaceColor',h.Color,'MarkerSize',ii*2)
end
xlim([0 maxSsd+50])
hold off
legend([fn],'Location','northwest','Interpreter','none', 'Box','off');
