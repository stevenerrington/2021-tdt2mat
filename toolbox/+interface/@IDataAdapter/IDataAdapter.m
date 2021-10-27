classdef (Abstract=true) IDataAdapter < handle
    %IDATAADAPTER Interface for raw data files
    %
    
    properties (SetAccess=protected, SetObservable)
        recordingSystem;   % Recording system : TDT, EMouse
        rawDataScaleFactor % Multiplication factor for raw data to convert sample-units to uV       
        dataPath;          % Path to raw recording file(s)
        session;           % Session name
        dataFiles;         % raw data file(s), full path
        header;            % file header, if any
        headerOffset;      % Number of header bytes before the first sample
        fileSizeBytes;     % Size of each dataFile in dataFiles, including header
        dataForm;          %'int16','single'...
        dataWidthBytes;    % number of bytes for each sample data point
        dataSize;          % [nChannels x nSamples]
        dataFs;            % data sampling frequency
        nShanks;           % no of arrays on a single probes for (neupixel type...)
        nProbes;           % no of probes in a single session
        chanMinMaxV;       % [nChannel, 2] min, max valuses for each channel
    end
    
    properties (SetAccess=protected, SetObservable, Transient, Dependent)
        nChannelsTotal;            % total number of channels
        nSamplesPerChannel;   % No of data points for each channel      
    end
    
    properties (Hidden, SetAccess=protected, SetObservable, Transient)
        isOpen = 0;           % Flag if dataset is ready for reading
    end
    
    
    %% Static factory method to get correct dataAdapter
    methods (Static)
        function adapter = newDataAdapter(recordingSystem, source, varargin)
            switch lower(recordingSystem)
                case 'bin'
                    %nChannels = 34; % default for KS1
                    adapter = datasource.RawBinAdapter(source,varargin{:});
                case 'sev'
                    adapter = datasource.TDTAdapter(source,varargin{:});
                otherwise
                    error('Type must be either emouse or tdt');
            end
        end
    end
    
    %% Abstract Methods for reading from raw file(s)
    methods (Abstract=true)
        data = readRaw(obj, nChannels, nSamples);
        data = readWaveforms(obj,wfSampleWin, wfTime);
    end
    
    %% Getter/Setter methods
    methods
        % nChannels
        function [val] = get.nChannelsTotal(obj)
            val = obj.dataSize(1);
        end
        
        % nSamplesPerChannel
        function [val] = get.nSamplesPerChannel(obj)
            val = obj.dataSize(2);
        end
        
        
    end
    
end

