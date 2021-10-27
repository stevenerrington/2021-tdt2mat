classdef TdtRecording < jrclust.interfaces.RawRecording
    %TDTRECORDING Model for TDT recording
    %% TDT-SPECIFIC PROPERTIES
    properties (Hidden, SetAccess=protected, SetObservable, Transient)
        memmapDataFiles = {};         % memmamfile of all data files
        lastSampleRead  = 0;          % same as (readOffsetInbytes-headerBytes)/dataWidth
        channelOffset = 0;            % channel offset to use for reading, useful when there are 2 probes 
                                      % ex. 64 channel, 1-32 on probe1 and 33-64 on probe2
    end
     properties (SetAccess=protected, SetObservable)
        dataPath;          % Path to raw recording file(s)
        session;           % Session name
        dataFiles;         % raw data file(s), full path
        header;            % file header, if any

        fileSizeBytes;     % Size of each dataFile in dataFiles, including header
        dataForm;          %'int16','single'...
        dataWidthBytes;    % number of bytes for each sample data point
        dataSize;          % [nChannels x nSamples]
        dataFs;            % data sampling frequency
        nShanks;           % no of arrays on a single probes for (neupixel type...)
        nProbes;           % no of probes in a single session
        chanMinMaxV;       % [nChannel, 2] min, max valuses for each channel
     end
    
    %% LIFECYCLE
    methods
        function obj = TdtRecording(filename, hCfg) % dataType, nChans, headerOffset,
            %RECORDING Construct an instance of this class
            % check filename exists
            obj = obj@jrclust.interfaces.RawRecording(filename, hCfg);
            if obj.isError
                return;
            end
            
            % set a filtered path
            [~, ~, ext] = fileparts(obj.rawPath);
            obj.filtPath = jrclust.utils.subsExt(obj.rawPath, ['.filtered' ext]);
            obj.filteredFid = -1;
            
            % set object data type
            obj.dataType = hCfg.dataType;
            
            % set headerOffset
            obj.headerOffset = hCfg.headerOffset;

            if exist(obj.rawPath,'file')            
                [rPath,rFile,~] = fileparts(obj.rawPath);
                obj.rawPath = rPath;
                % rewrite rawRecordings
                hCfg.rawRecordings = {rPath};
            else
                obj.errMsg = 'TDTRecording unable to determine raw files to use. Check your rawRecordings value?';
                obj.isError = 1;
                return;
            end
            
            if contains(rFile,'_Wav1_')
                d = dir(fullfile(obj.rawPath,'*_Wav1_*.sev'));
            elseif contains(rFile,'_Wav2_')
                d = dir(fullfile(obj.rawPath,'*_Wav2_*.sev'));
            elseif contains(rFile,'_RSn1_')
                d = dir(fullfile(obj.rawPath,'*_RSn1_*.sev'));               
            else
                obj.errMsg = 'TDTRecording unknown raw file pattern. Check your rawRecordings value?';
                obj.isError = 1;
                return;
            end   

            % sort by channel number
            if contains([d.name],'ch1.sev')
                [~,chNos]=sort(cellfun(@(x) str2double(x{1}),regexp( {d.name}, '_ch(\d+)', 'tokens' )));
            else
                [~,chNos]=sort(cellfun(@(x) str2double(x{1}),regexp( {d.name}, '_Ch(\d+)', 'tokens' )));
            end
            
            obj.dataFiles = strcat({d(chNos).folder},filesep,{d(chNos).name})';
            [obj.dataPath,obj.session] = fileparts(fileparts(obj.dataFiles{1}));
            obj.header = readHeader(obj);
            
            
            obj.fileSizeBytes = obj.header.fileSizeBytes;
            obj.dataForm = obj.header.dForm;
            obj.dataWidthBytes = obj.header.sampleWidthBytes;
            obj.dataFs = obj.header.fs;
            obj.dataSize = [obj.header.totalNumChannels, ... % nChannels
                (obj.fileSizeBytes-obj.headerOffset)/obj.dataWidthBytes...% nSamplesPerChannel
                ];
            
            obj.headerOffset = 40;
            obj.fSizeBytes = obj.headerOffset + (obj.fileSizeBytes-obj.headerOffset)*obj.header.totalNumChannels;
            
            obj.dshape = obj.dataSize;
            
            obj.rawIsOpen = 0;
            obj.filtIsOpen = 0;
        end
    end

    %% GETTERS/SETTERS
    methods
     end
end

