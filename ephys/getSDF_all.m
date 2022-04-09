% Load in data map
load('C:\Users\Steven\Desktop\2021-tdt2mat\2021-dajo-datamap.mat')

% Define data directories
dirs.rawData = 'S:\Users\Current Lab Members\Steven Errington\2021_DaJo\mat\';
dirs.procData = 'S:\Users\Current Lab Members\Steven Errington\temp\dajo_sdf\';

% Looping through sessions
for sessionIdx = 116:size(dajo_datamap,1)
    fprintf('Analysing session %i of %i  |  %s    \n',...
        sessionIdx,size(dajo_datamap,1),dajo_datamap(sessionIdx,:).behInfo.dataFile)
    
    % Behaviour %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load behaviour file
    beh_data = load(fullfile(dirs.rawData, dajo_datamap.behInfo(sessionIdx).dataFile));
    
    % Get event timings
    [~, ~, trialEventTimes] = processSessionTrials...
        (beh_data.events.stateFlags_, beh_data.events.Infos_);
    
    nElectrodes = dajo_datamap.nElectrodes(sessionIdx);
    
    % For each electrode within the given session
    parfor electrodeIdx = 1:nElectrodes
        try
            % Determine whether the session yielded spike data
            if dajo_datamap.neurophysInfo{sessionIdx}.spk_flag(electrodeIdx) == 1
                % Define the spike file and load the data
                spk_file = dajo_datamap.neurophysInfo{sessionIdx}.spkFile{electrodeIdx};
                spk_data = load(fullfile(dirs.rawData, spk_file));
                % Convolve the spikes and align on events
                tdtSpk_aligned = alignSDF(trialEventTimes(:,[2,3,4,5,6,7]),...
                    beh_data.events.Infos_,...
                    spk_data.spikes.time, [-2500 2500]);
                % After this, get a list of all the ID'd units in this session
                unitLabels = fieldnames(tdtSpk_aligned);
                
                % Save the SDF array for each ID'd unit, individually.
                for unitIdx = 1:length(unitLabels)
                    SDF = [];
                    SDF = tdtSpk_aligned.(unitLabels{unitIdx});
                    
                    sdf_file = [spk_file(1:end-8) '-' unitLabels{unitIdx}];
                    
                    parsave_sdf(fullfile(dirs.procData, sdf_file), SDF)
                end
            end
        catch
        end
        
    end
end
