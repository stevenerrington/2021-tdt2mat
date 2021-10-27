classdef TDTAdapter < interface.IDataAdapter
    %TDTADAPTER Adapter for TD recordings
    %   
    
    properties (Hidden, SetAccess=protected, SetObservable, Transient)
        memmapDataFiles = {};         % memmamfile of all data files
        lastSampleRead  = 0;          % same as (readOffsetInbytes-headerBytes)/dataWidth
        channelOffset = 0;            % channel offset to use for reading, useful when there are 2 probes 
                                      % ex. 64 channel, 1-32 on probe1 and 33-64 on probe2
    end
    
    %% Public methods
    methods
        function obj = TDTAdapter(source,varargin)
            obj.recordingSystem = 'tdt';
            try
                d = dir(source);
                % sort by channel number
                [~,chNos]=sort(cellfun(@(x) str2double(x{1}),regexp( {d.name}, '_[cC]h(\d+)', 'tokens' )));
                obj.dataFiles = strcat({d(chNos).folder},filesep,{d(chNos).name})';
                [obj.dataPath,obj.session] = fileparts(fileparts(obj.dataFiles{1}));
                obj.header = readHeader(obj);
                obj.headerOffset = 40;
                obj.fileSizeBytes = obj.header.fileSizeBytes;
                obj.dataForm = obj.header.dForm;
                obj.dataWidthBytes = obj.header.sampleWidthBytes;
                obj.dataFs = obj.header.fs;
                obj.dataSize = [obj.header.totalNumChannels, ... % nChannels
                                (obj.fileSizeBytes-obj.headerOffset)/obj.dataWidthBytes...% nSamplesPerChannel
                               ]; 
                parser = getArgParser(obj);
                parse(parser,varargin{:});
                
                %obj.rawDataScaleFactor = parser.Results.rawDataScaleFactor;
                % user can scale the data if needed
                obj.rawDataScaleFactor = 1;
                
                obj.nProbes = parser.Results.nProbes;
                obj.nShanks = 1;
            catch ME
                disp(ME);
            end
        end

        % Batch read datapoints
        function [ buffer ] = batchRead(obj, readOffsetAllChan, nChannels, nSamples, dataTypeString, channelOffset)
            %batchRead(offset,nChanToT,NTBuff,dataTypeStr)
            % readOffsetAllChan (in bytes): from where to read next set of nSamples (in samples)                 
            % reset the lastSampleRead for readRaw
            obj.lastSampleRead = readOffsetAllChan/obj.nChannelsTotal/obj.dataWidthBytes;
            obj.channelOffset=channelOffset;
            buffer = obj.readRaw(nChannels, nSamples);
        end
        
        % Read single channel data
        function [ buffer ] = readChannel(obj,chanNo)
            nChannels = obj.dataSize(1);
            if chanNo > nChannels
                error('Channel no.[%d] is greater max channelNo [%d]\n',chanNo,nChannels);
            end
            if ~obj.isOpen
                obj.openDataset();
            end
            memFile = obj.memmapDataFiles{chanNo};
            buffer = memFile.Data;
        end
        
        
    end
    
    %% Private Methods
    methods (Access=private)
        
        function [parser] = getArgParser(~)
            parser = inputParser;
            fx_posScalar = @(x) isnumeric(x) && isscalar(x) && (x > 0);
            fx_posInt = @(x) isfinite(x) && isscalar(x) && x==floor(x) && (x > 0);
           addOptional(parser,'rawDataScaleFactor',1.0,fx_posScalar);
           addOptional(parser,'nProbes',1,fx_posInt);
        end
        
    end
    
end

