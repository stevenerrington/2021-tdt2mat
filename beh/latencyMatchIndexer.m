function [GO_matched_i, GO_matched_RT] = latencyMatchIndexer...
    (goIdx, SSD, SSRT, trialMatch, trialEventTimes)

timeCutOff = SSD + SSRT;

rt_GO = [goIdx  (trialEventTimes.saccade(goIdx) - trialEventTimes.target(goIdx))];

if strcmpi(trialMatch, 'C') == 1
    GO_matched_i = rt_GO(rt_GO(:,2) > timeCutOff, 1);
    GO_matched_RT = rt_GO(rt_GO(:,2) > timeCutOff, 2);
elseif strcmpi(trialMatch, 'NC') == 1
    GO_matched_i = rt_GO(rt_GO(:,2) <= timeCutOff, 1);
    GO_matched_RT = rt_GO(rt_GO(:,2) <= timeCutOff, 2);
end
end

