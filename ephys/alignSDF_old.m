function [SDF] = alignSDF_old(trialEventTimes, Infos, tdtSpk, timeWin)

names = fieldnames( tdtSpk );
subStr = 'DSP';
DSPstruct = rmfield( tdtSpk, names( find( cellfun( @isempty, strfind( names , subStr ) ) ) ) );
DSPnames = fieldnames(DSPstruct);

for DSPidx = 1:length(DSPnames)
    DSPlabel = DSPnames{DSPidx};
    
    SessionSDF = SpkConvolver (tdtSpk.(DSPlabel), round(max(Infos.InfosEnd_)+10000), 'PSP');
    
    eventNames = fieldnames(trialEventTimes);
    eventNames = eventNames(1:length(eventNames)-3);
    
    parfor alignIdx = 1:length(eventNames)
        alignTimes = round(trialEventTimes.(eventNames{alignIdx})(:));
        
        alignedSDF_event = nan(length(alignTimes),range(timeWin)+1);
        
        for ii = 1:length(alignTimes)
            if isnan(alignTimes(ii))
                continue
            else
                alignedSDF_event(ii,:) = SessionSDF(alignTimes(ii)+timeWin(1):alignTimes(ii)+timeWin(end));
            end
        end
        
        alignedSDF{alignIdx} = alignedSDF_event;
        
    end
    
    for alignIdx = 1:length(eventNames)
        SDF.(DSPlabel).(eventNames{alignIdx}) = alignedSDF{alignIdx};
    end
    
    clear alignedSDF aligned_spkTimes
end

end

