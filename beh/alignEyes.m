function tdtEyes = alignEyes(trialEventTimes, TrialEyes, timeWin)

Fs = TrialEyes.tdt.FsHz;

eventNames = fieldnames(trialEventTimes);
eventNames = eventNames(1:length(eventNames)-3);


for alignIdx = 1:length(eventNames)
    clear alignTimes alignedEyeX_event alignedEyeY_event alignedEyePD_event
    eventName = eventNames{alignIdx};
    alignTimes = trialEventTimes.(eventName);  
    
    alignedEyeX_event = nan(length(alignTimes),range(timeWin)+1);
    alignedEyeY_event = nan(length(alignTimes),range(timeWin)+1);
    alignedEyePD_event = nan(length(alignTimes),range(timeWin)+1);
    
    for ii = 1:length(alignTimes)
        if isnan(alignTimes(ii))
            continue
        else
            clear sampleWindow
            idx_1 = H_T2S(alignTimes(ii)- TrialEyes.tdt.StartTime, Fs) + timeWin(1) *2;
            idx_2 = H_T2S(alignTimes(ii)- TrialEyes.tdt.StartTime, Fs) + timeWin(2)*2;
            sampleWindow = idx_1:2:idx_2;
            
            alignedEyeX_event(ii,:) = TrialEyes.tdt.EyeX(sampleWindow);
            alignedEyeY_event(ii,:) = TrialEyes.tdt.EyeY(sampleWindow);
            alignedEyePD_event(ii,:) = TrialEyes.tdt.EyePupil(sampleWindow);
        end
    end
    
    tdtEyes.X.(eventName) = alignedEyeX_event;
    tdtEyes.Y.(eventName) = alignedEyeY_event;
    tdtEyes.Pupil.(eventName) = alignedEyePD_event;
end


end
