function [trialEyes] = tdtExtractEyes(sessionDir, trialStartTimes, trialEndTimes, varargin)
%TDTEXTRACTEYES Extract Eye data from TDT. If file [SESSION_NAME]_EDF.mat
%               is present in the sessionDir, align TDT Eye data with EDF
%               eye data and cut it into trials. 
%                For a given trisl if either trialStartTime or trialEndTime
%                is NaN, then the eye vector will be NaN
%
%   sessionDir: Location of TDT data files [and EDF data file translated
%               to .mat file see EDF-File* below] are saved 
%    *** Note** if trialStartTimes or TrialEntTimes are empty, then
%    processing stops and tdt eye vectors are returned, No alignment and
%    trial cutting is done.
%   trialStartTimes: [nx1] double vector of trial Start times in millisecs
%                    [NaN ok]. Use Task.TrialStart_ vector, got by running
%                    tdtExtractEvents or runExtraction
%     trialEndTimes: [nx1] double vector of trial end times in millisecs
%                    [NaN ok]. Use Task.Eot_ vector, got by running
%                    tdtExtractEvents or runExtraction
%   varargin       : edfOptions a struct with the following fields
%                    useEye : Which eye data to use X or Y
%                    voltRange : voltage range of ADC [-5 5]
%                    signalRange : signal range of Eyelink [-0.2 1.2]
%                    pixelRange : screen pixels in X or Y [0 1024]
%
%   EDF-File*: To use EDF data all of the followig had to be done: 
%              (a) Save eye data on Eyelink 
%              (b) Translate edf data to mat (see Edf2Mat
%                      https://github.com/uzh/edf-converter) 
%              (c) EDF mat full filepath sessionDir/dataEDF.mat
%          
%   **********ASSUMPTIONS of EDF file collection*********
%   Absolute time: ------------------------------------------------------->
%        EDF data: Start|---------------------------------------------|Stop
%        TDT data:       Start|----------------------------------|Stop
%      TEMPO data:             Start|-----------------------|Stop
%
%  TDT-Eye-data-Total-Time a subset of EDF-Eye-data-Total-Time
%
% Example: For using EDF data file:
%    Start to save data on Eyelink
%      Start TDT/Synapse
%         Start TEMPO
%           ....experiment running....
%         Stop TEMPO
%      Stop TDT/Synapse
%    Start saving data on Eyelink
%    Transfer the EDF file from Eyelink computer to the [loc-of-sessionDir]
%    and run Edf2Mat of the edf file.  Rename the converted file to
%    [SESSION_NAME]_EDF.mat
%
%    [trialEyes] = tdtExtractEyes(sessionDir, trialStartTimes)
% See also RUNEXTRACTION, TDTEXTRACTEVENTS, TDTALIGNEYEWITHEDF
%
    edfOptions = [];
    edfMatDataFile = 'dataEDF.mat';
    useEyeX = true;
    if numel(varargin)==1
        edfOptions = varargin{1};
        if ~isempty(edfOptions) && edfOptions.useEye == 'Y'
            useEyeX = false;
        end
    end
    % Normalize input path and extract sessionName
    blockPath = regexprep(sessionDir,'[/\\]',filesep);
    binsForTdtMovingAverage = 1; % no moving average
    % The number of bins the EDF Eye vector is moved for computing alignment
    % The value is given is Secs, which is converted later to ms,
    % assuming the ksampling rate of EDF data is 1000Hz.
    % In general this value should be about 6-10% of total session
    % duration in secs. Compute this using trialStartTimes
    maxWindowToSlideEdf = max([round(nanmax(trialStartTimes)*0.2/1000), 100]); % in seconds

    %% Function to parse data vector to trials omit 1st and last trial
    nTrials = numel(trialStartTimes);
%     splitEyeDataIntoTrialsFx = @(eyeVec,timeBins)...
%         [NaN;...
%         arrayfun(@(ii) eyeVec(timeBins(ii):timeBins(ii+1)-1),(2:nTrials-1)','UniformOutput',false);...
%         NaN];
    %% Omit last trial only
    splitEyeDataIntoTrialsFx = @(eyeVec,timeBinsStart, timeBinsEnd)...
        arrayfun(@(ii) eyeVec(timeBinsStart(ii):timeBinsEnd(ii)),(1:nTrials)','UniformOutput',false);    
    
    %% Initialize output
    trialEyes = struct();

    %% Read TDT Eye data
    fprintf('Reading TDT Eye Data...\n');
    [tdtX, tdtY, tdtEyePupil, tdtFsHz, tdtStartTime] = getTdtEyeData(blockPath);
    tdtBinWidthMs = 1000/tdtFsHz;
    
    % for output
    trialEyes.tdt.sessionDir = blockPath;
    trialEyes.tdt.StartTime = tdtStartTime;
    trialEyes.tdt.FsHz = tdtFsHz;
    trialEyes.tdt.BinWidthMs = tdtBinWidthMs;
    trialEyes.tdt.EyeDataBins = numel(tdtX);
    trialEyes.tdt.EyeX = tdtX;
    trialEyes.tdt.EyeY = tdtY;
    trialEyes.tdt.EyePupil = tdtEyePupil;

    if (isempty(trialStartTimes) || isempty(trialEndTimes))

       [trialEyes.DEFINITIONS, trialEyes.WHAT_IS] = addDefinitions(trialEyes);      
        return;       
    end
    
    % append NaN to the end of eye vector data to take care of NaN
    % trailStartTime or NaN trialEndTime for a given trial
    tdtX(end+1) = NaN;
    tdtY(end+1) = NaN;
    tdtEyePupil(end+1) = NaN;
    
    %% Parse TDT eye date into trials (before doing EDF), in case there is no EDF file
    eyeLookupTable = table();
    eyeLookupTable.trialStartMsFractional=trialStartTimes;
    eyeLookupTable.trialStartMs=round(trialStartTimes);
    eyeLookupTable.trialEndMsFractional=trialEndTimes;
    eyeLookupTable.trialEndMs=round(trialEndTimes);
    eyeLookupTable.trialDurationMsFractional=eyeLookupTable.trialEndMsFractional - eyeLookupTable.trialStartMsFractional;
    eyeLookupTable.trialDurationMs=round(eyeLookupTable.trialDurationMsFractional);
    eyeLookupTable.tdtTrialStartBinFractional=eyeLookupTable.trialStartMsFractional./tdtBinWidthMs;
    eyeLookupTable.tdtTrialStartBin=round(eyeLookupTable.trialStartMsFractional./tdtBinWidthMs);
    eyeLookupTable.tdtTrialEndBinFractional=eyeLookupTable.trialEndMsFractional./tdtBinWidthMs;
    eyeLookupTable.tdtTrialEndBin=round(eyeLookupTable.trialEndMsFractional./tdtBinWidthMs);
    % fix NaN indices
    nanIdx = find(isnan(eyeLookupTable.tdtTrialStartBin));
    %This value has been set to NaN previously when getting Eye data
    eyeLookupTable.tdtTrialStartBin(nanIdx) = length(tdtX);
    eyeLookupTable.tdtTrialEndBin(nanIdx) = length(tdtX);
     
    trialEyes.tdtEyeX = splitEyeDataIntoTrialsFx(tdtX,eyeLookupTable.tdtTrialStartBin,eyeLookupTable.tdtTrialEndBin);
    trialEyes.tdtEyeY = splitEyeDataIntoTrialsFx(tdtY,eyeLookupTable.tdtTrialStartBin,eyeLookupTable.tdtTrialEndBin);
    trialEyes.tdtEyePupil = splitEyeDataIntoTrialsFx(tdtEyePupil,eyeLookupTable.tdtTrialStartBin,eyeLookupTable.tdtTrialEndBin);
    % for output
    trialEyes.trialTimeTable = eyeLookupTable;
    
    fprintf('Done Extracting TDT Eye data\n');

    [trialEyes.DEFINITIONS, trialEyes.WHAT_IS] = addDefinitions(trialEyes);
    
    %% If Eyelink translated data is present 
    %  Align TDT Eye data with Eyelink eye data and parse into trials
    fprintf('Checking for EDF Eye Data...\n');
    edfMatFile = fullfile(sessionDir, edfMatDataFile);
    if ~exist(edfMatFile, 'file') || isempty(edfOptions)
        warning('EDF Eye Data File [%s] not found.', edfMatFile);
        return;
    end
    edfDataField = 'dataEDF';
    edf = load(edfMatFile);
    edfX = edf.(edfDataField).FSAMPLE.gx(1,:);
    edfY = edf.(edfDataField).FSAMPLE.gy(1,:);
    edfFsHz = 1000;
    edfBinWidthMs = 1000/edfFsHz;
    
    %% Clean EDF eye data
    fprintf('Cleaning EDF Eye Data...\n');
    MISSING_DATA_VALUE  = -32768;
    EMPTY_VALUE         = 1e08;
    edfX = replaceValue(edfX,MISSING_DATA_VALUE,nan);
    edfX = replaceValue(edfX,EMPTY_VALUE,nan);
    edfY = replaceValue(edfY,MISSING_DATA_VALUE,nan);
    edfY = replaceValue(edfY,EMPTY_VALUE,nan);
    
    %% Align start of tdt (Eye) recording with the start in EDF recording
    slidingWindowSecs = round(linspace(0,maxWindowToSlideEdf,4));
    slidingWindowSecs = slidingWindowSecs(2:end);
    % readjust proprtions of EDF and TDT data to use
    edfDataChunk = 2*maxWindowToSlideEdf*1000; 
    tdtDataChunk = 0.1*edfDataChunk; 
    fprintf('Finding start index for aligning EDF Eye Data to start of TDT Eye data...\n');
    if useEyeX
        partialEdf = edfX(1:edfDataChunk); 
        partialTdt = tdtX(1:tdtDataChunk);  
    else
        partialEdf = edfY(1:edfDataChunk); 
        partialTdt = tdtY(1:tdtDataChunk);  
    end
    startIndices = findAlignmentIndices(partialEdf,partialTdt,binsForTdtMovingAverage,edfFsHz,tdtFsHz,slidingWindowSecs,edfOptions);
    
    %% Align end of tdt (Eye) recording with the end in EDF recording
    % Basically do te reverse of previous
    fprintf('Finding end index for aligning EDF Eye Data to end of TDT Eye data...\n'); 
    if useEyeX
        partialEdf = fliplr(edfX(end-edfDataChunk:end)); 
        partialTdt = fliplr(tdtX(end-tdtDataChunk:end));  
    else
        partialEdf = fliplr(edfY(end-edfDataChunk:end)); 
        partialTdt = fliplr(tdtY(end-tdtDataChunk:end));  
    end
    endIndices = findAlignmentIndices(partialEdf,partialTdt,binsForTdtMovingAverage,edfFsHz,tdtFsHz,slidingWindowSecs,edfOptions); 
    if useEyeX
        endIndices = numel(edfX)-endIndices;
    else
        endIndices = numel(edfY)-endIndices;
    end
    %% Linear function to convert TDT - TrialStart_ time (ms) to index on Eyelink collectd EDF data
    edfStartBin = startIndices(end);
    edfEndBin = endIndices(end);
    % Number of EDF bins per ms
    totalTimeMs = (numel(tdtX)*tdtBinWidthMs);
    edfBinsPerTdtMs = (edfEndBin-edfStartBin)/totalTimeMs;    
    %% Values for synchronizing Eylelink data with TDT
    edfSyncValues = struct();
    edfSyncValues.slidingWindowSecs = slidingWindowSecs(:);
    edfSyncValues.edfTrialStartOffsets = startIndices;
    edfSyncValues.edfTrialEndOffsets = endIndices;
    edfSyncValues.edfStartOffset = edfStartBin;
    edfSyncValues.edfEndOffset = edfEndBin;
    edfSyncValues.nTdtBins = numel(tdtX);
    edfSyncValues.tdtBinWidthMs = tdtBinWidthMs;
    edfSyncValues.nEdfBins = numel(edfX);
    edfSyncValues.edfBinWidthMs = edfBinWidthMs;
    edfSyncValues.linear.edfBinsPerTdtMs = edfBinsPerTdtMs;
    edfSyncValues.linear.edfStartOffset = edfStartBin;
    edfSyncValues.linear.edfBinIndexFx =  @(timeMs) timeMs.*edfSyncValues.linear.edfBinsPerTdtMs + edfSyncValues.linear.edfStartOffset;
    edfSyncValues.edfDataChunkSize = repmat(edfDataChunk,numel(slidingWindowSecs),1);
    edfSyncValues.tdtDataChunkSize = repmat(tdtDataChunk,numel(slidingWindowSecs),1);
    % add to output
    trialEyes.edfSyncValues = edfSyncValues;
    
    %% Parse edf Data into trials 
    trialEyes.trialTimeTable.edfTrialStartBinFractional=edfSyncValues.linear.edfBinIndexFx(trialStartTimes);
    trialEyes.trialTimeTable.edfTrialStartBin=round(trialEyes.trialTimeTable.edfTrialStartBinFractional);
    trialEyes.trialTimeTable.edfTrialEndBinFractional=edfSyncValues.linear.edfBinIndexFx(trialEndTimes);
    trialEyes.trialTimeTable.edfTrialEndBin=round(trialEyes.trialTimeTable.edfTrialEndBinFractional);
    % fix NaN indices
    nanIdx = find(isnan(eyeLookupTable.edfTrialStartBin));
    edfX(end+1) = NaN;
    edfY(end+1) = NaN;    
    %This value has been set to NaN previously when getting Eye data
    eyeLookupTable.edfTrialStartBin(nanIdx) = length(edfX);
    eyeLookupTable.edfTrialEndBin(nanIdx) = length(edfX);
    
    trialEyes.edfEyeX = splitEyeDataIntoTrialsFx(edfX,trialEyes.trialTimeTable.edfTrialStartBin); 
    trialEyes.edfEyeY = splitEyeDataIntoTrialsFx(edfY,trialEyes.trialTimeTable.edfTrialStartBin); 
    
    % Fill other output fields
    trialEyes.edf.EdfMatFile = edfMatFile;
    trialEyes.edf.FsHz = edfFsHz;
    trialEyes.edf.BinWidthMs = edfBinWidthMs;
    trialEyes.edf.Header = edf.(edfDataField).HEADER;
    trialEyes.edf.Recordings = edf.(edfDataField).RECORDINGS;
    trialEyes.edf.Fevent = edf.(edfDataField).FEVENT;
   [trialEyes.DEFINITIONS, trialEyes.WHAT_IS] = addDefinitions(trialEyes);
        
end

%%
function [tdtEyeX, tdtEyeY, tdtEyePupil, tdtEyeFs, tdtEyeZeroTime] = getTdtEyeData(blockPath)
    % Read Eye_X stream, and Eye_Y Stream from TDT
    % assume STORE names are 'EyeX', 'EyeY'
    % assume the sampling frequency same for both X and Y
    tdtFun = @TDTbin2mat;
    % Get raw TDT EyeX data
    tdtEye = tdtFun(blockPath,'TYPE',{'streams'},'STORE','EyeX','VERBOSE',0);
    tdtEyeX = tdtEye.streams.EyeX.data;
    % Get raw TDT EyeX data
    tdtEye = tdtFun(blockPath,'TYPE',{'streams'},'STORE','EyeY','VERBOSE',0);
    tdtEyeY = tdtEye.streams.EyeY.data;
    % Get raw TDT EyeX data
    tdtEye = tdtFun(blockPath,'TYPE',{'streams'},'STORE','PDia','VERBOSE',0);
    tdtEyePupil = tdtEye.streams.PDia.data;
    % Get sampling frequency
    tdtEyeFs = tdtEye.streams.PDia.fs;
    % Usually very close to zero, but you never know
    tdtEyeZeroTime = tdtEye.streams.PDia.startTime; 
end

function vec = replaceValue(vec,val,subVal)
      vec(vec==val)=subVal;
end

function indices = findAlignmentIndices(partialEdf, partialTdt, nBoxcarBins,edfHz, tdtHz, slidingWindowSecs,edfOptionsStruct)
    indices = nan(numel(slidingWindowSecs),1);
    tic
    for ii = 1:numel(slidingWindowSecs)
        fprintf('Aligning with time win %d secs...\n',slidingWindowSecs(ii));
        indices(ii,1) = tdtAlignEyeWithEdf(partialEdf,movmean(partialTdt,nBoxcarBins),edfHz,tdtHz,slidingWindowSecs(ii),edfOptionsStruct);
    end
    toc
end

function [out,defMap] = addDefinitions(inStruct)
   defMap = getDefinitions();
   truncateFns = {'edf\.Recordings';'edf\.Fevent'};
   fns = getFieldnames(inStruct);
   for ii = 1:numel(truncateFns)
      fns = unique(regexprep(fns, [truncateFns{ii} '.*'],truncateFns{ii}));
   end
   out = {};
   for ii = 1:numel(fns)
       fn = fns{ii};
       if defMap.isKey(fn)
          out = [out; defMap(fn)]; %#ok<AGROW>
       end
   end
   remove(defMap, setdiff(defMap.keys,fns));
end

function [defMap] = getDefinitions()
    defs = {
        'trialTimeTable.trialStartMsFractional: (ms) Task.TrailStart_ time, fractional, cannot be used as index'
        'trialTimeTable.trialStartMs: (ms) Task.TrailStart_ time rounded'
        'trialTimeTable.trialDurationMsFractional: (ms) Trial duration, fractional'
        'trialTimeTable.trialDurationMs: (ms) Trial duration, rounded'
        'trialTimeTable.tdtTrialStartBinFractional: (count) Computed index of TDT Eye data bins for trial start, fractional, cannot be used as index'
        'trialTimeTable.tdtTrialStartBin: (count) Computed index of TDT Eye data bins for trial start, rounded, to be used as index'
        'trialTimeTable.edfTrialStartBinFractional: (count) Computed index of Eyelink EDF data bins for trial start, fractional, cannot be used as index'
        'trialTimeTable.edfTrialStartBin: (count) Computed index of Eyelink EDF data bins for trial start, rounded, to be used as index'
        'tdtEyeY: TDT EyeY data by trials (in ADC units)'
        'tdtEyeX: TDT EyeX data by trials (in ADC units)'
        'tdt.sessionDir: Directory where data files recorded during this session are archived'
        'tdt.StartTime: (s) The exact start time offset when TDT started recoring Eye data, close to 0 ms'
        'tdt.FsHz: (Hz) TDT sampling frequency for ADC of Eyelink data'
        'tdt.EyeDataBins: (count) Number of TDT EyeX or EyeY data points'
        'tdt.BinWidthMs: (ms) Size of each TDT Eye data bin'
        'edfSyncValues.tdtDataChunkSize: (count) Number of TDT Eye data points (from start or from end) used for aligning TDT Eye data with Eyelink EDF data'
        'edfSyncValues.tdtBinWidthMs: (ms) Size of each TDT Eye data bin'
        'edfSyncValues.slidingWindowSecs: (s) Vector, number of sec*1000 bins the Eyelink EDF data is shifted for alignment'
        'edfSyncValues.nTdtBins: (count) Total number of TDT Eye data bins'
        'edfSyncValues.nEdfBins: (count) Total number of Eyelink EDF Eye data bins'
        'edfSyncValues.linear.edfStartOffset: (intercept) In number of bins - Intercept of linear equation to convert time in ms on TDT to bin-number of Eyelink EDF eye data'
        'edfSyncValues.linear.edfBinsPerTdtMs: (slope) Slope of linear equation to convert time in ms on TDT to bin-number of Eyelink EDF eye data'
        'edfSyncValues.linear.edfBinIndexFx: (function) Linear function y = mx + c, to convert time in ms on TDT to bin-number of Eyelink EDF eye data'
        'edfSyncValues.edfTrialStartOffsets: (count) Vector, bin number on Eyelink EDF Eye data that aligns with the START-data-point of TDT Eye data. Values correspond to edfSyncValues.slidingWindowSecs values'
        'edfSyncValues.edfTrialEndOffsets: (count) Vector, bin number on Eyelink EDF Eye data that aligns with the END-data-point of TDT Eye data. Values correspond to edfSyncValues.slidingWindowSecs values'
        'edfSyncValues.edfStartOffset: (count) Eyelink EDF data alignment Start offset used for getting the edfSyncValues.linear.edfBinIndexFx function'
        'edfSyncValues.edfEndOffset: (count) Eyelink EDF data alignment End offset used for getting the edfSyncValues.linear.edfBinIndexFx function'
        'edfSyncValues.edfDataChunkSize: (count) Number of Eyelink EDF Eye data points (from start or from end) used for aligning TDT Eye data with Eyelink EDF data'
        'edfSyncValues.edfBinWidthMs: (ms) Size of each Eyelink EDF Eye data bin'
        'edfEyeY: Eyelink EDF EyeY data by trials (in pixels units) - (EDF data - gy split into trials)'
        'edfEyeX: Eyelink EDF EyeX data by trials (in pixels units) - (EDF data - gx split into trials)'
        'edf.Recordings: Eyelink RECORDINGS field (see dataEDF.mat file)'
        'edf.Header: Eyelink HEADER field (see dataEDF.mat file)'
        'edf.FsHz: (Hz) Eyelink frequency of ADC from Eyelink camera, data in dataEDF.mat filr translated from *.edf file native to Eyelink'
        'edf.Fevent: Eyelink FEVENT field (see dataEDF.mat file)'
        'edf.EdfMatFile: (char) The Eyelink EDF file that is translated to dataEDF.mat'
        'edf.BinWidthMs: (ms) Size of each Eyelink EDF Eye data bin'
        };
    
    
    temp = split(defs,':');
    defMap = containers.Map(temp(:,1),defs);
end

