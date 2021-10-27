function [photodiodeEvents, pdFirstSignal, pdLastSignal] = processPhotodiode(pdFirst_Last, samplingFreq)
%PROCESSPHOTODIODE Processes both the First and the Last PD analog signals
%from TDT streams.
%
% See also GETPHOTODIODEEVENTS

    thresholdPercentile = 99.9;
    tickWidthMs = 1000.0/samplingFreq;
        
    if numel(pdFirst_Last)==1
        pdFirst = pdFirst_Last{1};
        pdLast = [];
    else % use only 1st and last
       pdFirst = pdFirst_Last{1};
       pdLast = pdFirst_Last{end};        
    end
    
    if ~isempty(pdFirst)
        if ~isempty(pdLast)
            fprintf('Processing first photodiode...\n');
        else
            fprintf('Processing *single* photodiode...\n');
        end
        [pdFirstSignal] = getPhotodiodeEvents(pdFirst,samplingFreq,thresholdPercentile);
        pdFirstUniqIdx = unique(pdFirstSignal.idxOnRiseEndTime);
        nRows = numel(pdFirstUniqIdx);
    end
    
    if ~isempty(pdLast)
        fprintf('Processing last photodiode...\n');
        [pdLastSignal] = getPhotodiodeEvents(pdLast,samplingFreq,thresholdPercentile);
        pdLastUniqIdx = unique(pdLastSignal.idxOnRiseEndTime);
        nRows = max(numel(pdLastUniqIdx),nRows);
    end

    if isempty(pdLast) && ~isempty(pdFirst)
       photodiodeEvents = array2table(nan(nRows,1));
       photodiodeEvents(1:numel(pdFirstUniqIdx),1)=array2table(pdFirstUniqIdx);
       photodiodeEvents.Properties.VariableNames={'PD_First_Ticks'};
       photodiodeEvents.PD_First_Ms = photodiodeEvents.PD_First_Ticks.*tickWidthMs;
       photodiodeEvents.PD_Ms = photodiodeEvents.PD_First_Ticks.*tickWidthMs;
       pdLastSignal = struct();
       return;
    end
    
    photodiodeEvents = array2table(nan(nRows,2));
    photodiodeEvents(1:numel(pdFirstUniqIdx),1)=array2table(pdFirstUniqIdx);
    photodiodeEvents(1:numel(pdLastUniqIdx),2)=array2table(pdLastUniqIdx);
    photodiodeEvents.Properties.VariableNames={'PD_First_Ticks','PD_Last_Ticks'};
    photodiodeEvents.PD_First_Ms = photodiodeEvents.PD_First_Ticks.*tickWidthMs;
    photodiodeEvents.PD_Last_Ms = photodiodeEvents.PD_Last_Ticks.*tickWidthMs;
    
    % Pair the PD_First event tick with corresponding *next* PD_Last event tick for
    % all PD_First event ticks
    
    pairedLast = arrayfun(@(x) min([find(pdLastUniqIdx > x, 1), NaN]), pdFirstUniqIdx);
    % Avoid NaN index
    pdLastUniqIdx(end+1) = NaN;
    pairedLast(isnan(pairedLast)) = numel(pdLastUniqIdx);
    
    photodiodeEvents.PD_Last_Ticks_Paired = [pdLastUniqIdx(pairedLast);nan(nRows-numel(pairedLast),1)];
    photodiodeEvents.PD_Last_Ms_Paired = photodiodeEvents.PD_Last_Ticks_Paired.*tickWidthMs;
    photodiodeEvents.PD_Last_Minus_First_Ticks_Paired = ...
        photodiodeEvents.PD_Last_Ticks_Paired - photodiodeEvents.PD_First_Ticks;
    photodiodeEvents.PD_Last_Minus_First_Ms_Paired = ...
        photodiodeEvents.PD_Last_Minus_First_Ticks_Paired.*tickWidthMs;
    
    photodiodeEvents.PD_Ms = ...
        (photodiodeEvents.PD_Last_Ticks_Paired + photodiodeEvents.PD_First_Ticks).*(tickWidthMs/2);
    
end

