classdef RawBinAdapter < interface.IDataAdapter
    %BINARYADAPTER Adapter for TD recordings
    %   
    
    properties (Hidden, SetAccess=protected, SetObservable, Transient)
        memmapDataFiles = {};         % memmamfile of all data files
        lastSampleRead  = 0;          % same as (readOffsetInbytes-headerBytes)/dataWidth
        channelOffset = 0;            % channel offset to use for reading, useful when there are 2 probes 
                                      % or splitting analysis?
    end
    
    %% Public methods
    methods
         function obj = RawBinAdapter(source,varargin)
            obj.recordingSystem = 'bin';
            try
                d = dir(source);
                % sort by channel number
                % expecte only 1 binary file for all channnel data
                obj.dataFiles{1} = source;
                [obj.dataPath,obj.session] = fileparts(fileparts(obj.dataFiles{1}));
                % there is no header offset, data begins at bof
                obj.headerOffset = 0;
                obj.fileSizeBytes = d(1).bytes;
                obj.dataForm = 'int16';
                obj.dataWidthBytes = 2;
                
                parser = getArgParser(obj);
                parse(parser,varargin{:});
                
               obj.dataSize = [parser.Results.nChannels, ... % nChannels
                                (obj.fileSizeBytes-obj.headerOffset)/obj.dataWidthBytes/parser.Results.nChannels...% nSamplesPerChannel
                               ]; 
                obj.rawDataScaleFactor = parser.Results.rawDataScaleFactor;
                obj.dataFs = parser.Results.fs;
                obj.nProbes = 1;
                obj.nShanks = 1;
            catch ME
                disp(ME);
            end
         end
         
        % Batch read datapoints
        function [ buffer ] = batchRead(obj, readOffsetAllChan, nChannels, nSamples, dataTypeString, channelOffset)
            %batchRead(offset,nChanToT,NTBuff,dataTypeStr)
            % readOffsetAllChan (in bytes): from where to read next set of nSamples (in samples)                 
            obj.lastSampleRead = readOffsetAllChan/obj.dataWidthBytes;
            obj.channelOffset=channelOffset;
            buffer = obj.readRaw(nChannels, nSamples);
        end
    end
        
    %% Private methods
    methods (Access=private)
        
        function [parser] = getArgParser(~)
            parser = inputParser;
            %fx_posScalar = @(x) isnumeric(x) && isscalar(x) && (x > 0);
            %fx_posInt = @(x) (x>=16);% minimum 16 channels
           parser.addOptional('nChannels',1);
           parser.addOptional('rawDataScaleFactor',1.0);
           parser.addOptional('fs',30000);
        end
    end
    
    %% end class  
end

