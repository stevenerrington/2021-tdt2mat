classdef TDTTranslator < matlab.mixin.SetGetExactNames
    %TDTTRANSLATOR Translate TDT session data, including Elyelink EDF data 
    %   Requires the following options to be set on the constructor or when
    %   called with no arguments, will prompt user to provide the options.
    % 
    %   options: Is a struct that sets up data paths and processing options for eyedata.
    %   .sessionDir             - [char] Location of TDT session directory
    %   .baseSaveDir            - [char] Base location for saving translated TDT
    %                             session. Do not include session name, since
    %                             a sub-dir with session name is created 
    %   .eventDefFile           - [char] Full filepath to EVENTDEF.pro file 
    %                             used by TEMPO to acquire TDT session 
    %   .infosDefFile           - [char] Full filepath to INFOS.pro file 
    %                             used by TEMPO to acquirs TDT session
    %   .useTaskStartEndCodes   - [false] If true used event codes for
    %                             TaskStart_ and TaskEnd_ from the
    %                             eventDefFile 
    %  .dropNaNTrialStartTrials - [true] After processing, drop all trials
    %                             and trialInfos where TrialStart_ is NaN   
    %  .dropEventAllTrialsNaN   - [true] After processing, drop Events
    %                             where *all trials* for the event is NaN
    %  .infosOffsetValue         - [3000] Value to be subtracted from
    %                             translated Infos values. Note different
    %                             approach for negative values
    %  .infosHasNegativeValues   - [false] If true, then all 
    %                             info_values(>=infosNegativeValueOffset) =
    %                             infosNegativeValueOffset - info_values.
    %                             Resulting -1 values are replaced with NaN
    %                             info_values(<infosNegativeValueOffset) =
    %                             info_values - infosOffsetValue 
    %  .infosNegativeValueOffset - [32768] If infosHasNegativeValue is set,
    %                              then this value is used as 0 and anything
    %                              higher is subtracted from this value to
    %                              get the negative value
    %
    %   .splitEyeIntoTrials      - true/false
    %   .hasEdfDataFile          - [T|F] Does the sessionDir contain
    %                             'dataEDF.mat'.  This is edf-datafile
    %                             collected on EYELINK computer that is
    %                             transferred to the TDT session directory
    %                             and converted used third-party utility
    %   if .hasEdfDataFile is TRUE, then you would need to include the
    %   following nested stuct for translating edf eye data:
    %            .edf            - EDF options for merging ELYELINK data
    %            .edf.useEye     - [X|Y] Which component of Eye data for TDT
    %                               and EDF do you want to use for aligning? 
    %            .edf.voltRange  - [1x2 double] Volt range of TDT eye data.
    %                              Example [-5 5]
    %            .edf.signalRange - [1x2 double] Signal range of EDF eye data.
    %                               Example [-0.2 1.2]
    %            .edf.pixelRange - [1x2 double] Pixel range of EDF eye data.
    %                               Example [0 1024] for X or [0 768] for Y
    %
    %TDTTRANSLATOR Properties - Private
    %    optionFieldPrompts    - fieldnames and prompts for interactive
    %                            input for events/infos
    %    edfOptionFieldPrompts - fieldnames and prompts for interactive
    %                            input for edf
    %TDTTRANSLATOR Properties - Protected
    %    options               - Options used for processing
    %
    %TDTTRANSLATOR Methods:
    %
    %    TDTTRANSLTOR   - Constructor takes no args or options struct as
    %                     argument
    %    SETOPTIONS     - Setup options interactively
    %    TRANSLATE      - Methoid to be called for doing the translation
    %

    properties (Access = private)        
        optionFieldPrompts = {
            {'sessionDir', sprintf('Location of TDT session directory\n\t\t\t\t[string]')}
            {'baseSaveDir', sprintf('Base directory for saving translation results\n\t(will create dirctoty with session_name)\n\t\t\t\t[string]')}
            {'eventDefFile', sprintf('Full filepath to location of EVENTDEF.pro file used for session\n\t\t\t\t[string]')}
            {'infosDefFile', sprintf('Full filepath to location of INFOS.pro file used for session\n\t\t\t\t[string]')}
            {'useTaskStartEndCodes', sprintf('If true use TaskStart_ and TaskEnd_\n\t\t\t[false true|false]')}
            {'dropNaNTrialStartTrials',  sprintf('If true, after processing, drop all trialsband trialInfos where TrialStart_ is NaN\n\t\t\t[true true|false]' )}  
            {'dropEventAllTrialsNaN' sprintf('If true, after processing, drop Events where *all trials* for the event is NaN\n\t\t\t[true true|false]' )} 
            {'infosOffsetValue', sprintf('Value to be subtracted from translated Infos values. *Note* different approach for negative values\n\t\t\t[3000]')} 
            {'infosHasNegativeValues', sprintf('If true, then sending negative values from TEMPO\n\t\t\t\t[false true|false]')}
            {'infosNegativeValueOffset',sprintf('If infosHasNegativeValue is set, 0 and negative values are offset by this value.\n Example: 0 = 32768, -1 = 32769, .. etc\n\t\t\t\t\[32768]')}
            {'splitEyeIntoTrials', sprintf('Do you want the Eye data to be split into Trials?\n\t\t\t\t[true|false]')}
            {'hasEdfDataFile', sprintf('Does session directory above contain \''dataEDF.mat\'' file?\n\t(This file is data collected on EYELINK computer and translated to \''dataEDF.mat\'' by third-party utility)\n\t\t\t\t[true|false]')}
            };
               
        edfOptionFieldPrompts = {
            {'useEye', sprintf('Which component of Eye data for TDT and EDF do you want to use for aligning? \n\t\t\t\t [char X|Y]')}
            % ADC volt range of TDT
            {'voltRange', sprintf('What is the voltage range of Eyelink data sent to TDT?\n\tTypically the values are [-5 5]\n\t\t\t\t[2 element vector]')}
            % Signal range of EDF typically [-0.2 1.2]?
            {'signalRange', sprintf('What is the signal range of Eyelink data sent to TDT?\n\tTypically the values are [-0.5 1.2]\n\t\t\t\t[2 element vector]')}
            % Screen pixel range for EDF eye movement
            %     Screen dimensions: X:[0 1024] or Y: [0 768]%
            {'pixelRange', sprintf('What is the pixel range (Screen dimension in Pixels) of Eyelink data sent to TDT?\n\tTypically the values are [0 1024] for X or [0 768] for Y\n\t\t\t\t[2 element vector]')}
            };

    end
    properties (Access = protected)
        options;
    end
    
    methods
        function obj = TDTTranslator(varargin)
         %TDTTRANSLATOR Construct an instance of this class for translation
         %of TDT data
            if nargin==1
                obj.options = varargin{1};
                checkOptions(obj);
            else
                setOptions(obj);           
            end
            %translate(obj);
        end
        
        function setOptions(obj)
        %SETOPTIONS Interactive method that obtains user input for
        %different options fields, including EDF options to be used for
        %translation / aligning EYELINK-eye data to TDT-eye data
            if isempty(obj.options)
                obj.options = struct();
            end
            obj.options = processFields(obj,obj.optionFieldPrompts);
            if obj.options.hasEdfDataFile
                obj.options.edf = processFields(obj,obj.edfOptionFieldPrompts);                        
            end
        end
        
        function [Task, TaskInfos, TrialEyes, EventCodec, InfosCodec, SessionInfo] = translate(obj,varargin)
        %TRANSLATE Translate the TDT session data using processing options
        % OUTPUTS:
        %     Task       - A struct of all EVENT codes by trials
        %     TaskInfos  - A struct of all INFOS by trials
        %     TrialEyes  - A struct of Eye data from TDT [as well as EDF if
        %                  present] by trials 
        %     EventCodec - A containers.Map of all event-codes-by-names as
        %                  well as event-names-by-code. These are
        %                  event-name=code mapping in the EVENTDEF.pro file 
        %     InfosCodec - A containers.Map of all infos-codes-by-names as
        %                  well as infos-names-by-code. Code is the
        %                  sequential number of info-names occuring in
        %                  INFOS.pro file
        %     SessionInfo- A struct of session information from TDT file]
        % See also RUNEXTRACTION, TDTEXTRACTEVENTS, TDTEXTRACTEYES
        %
        
            checkOptions(obj);
            o = obj.options;
            e = [];
            if isfield(o,'edf')
                e = o.edf;
            end
            [Task, TaskInfos, TrialEyes, EventCodec, InfosCodec, SessionInfo] = runExtraction(o.sessionDir, o.baseSaveDir, o.eventDefFile, o.infosDefFile, o.splitEyeIntoTrials, e ,varargin{:},o);
        end
    end
    methods (Access = private)
        function checkOptions(obj)
            if isempty(obj.options) || ~isstruct(obj.options)
                warning('Processing options are not set');
                warning('Setup options for processing ');
                obj.setOptions();
            else
                [opts, edfOpts] = getEmptyOptions(obj);
                if isfield(obj.options,'edf')
                    emptyOpts = opts;
                    emptyOpts.edf = edfOpts;
                else
                    emptyOpts = opts;
                end
                if ~isempty(setdiff(getFieldnames(emptyOpts),getFieldnames(obj.options)))
                    warning('Incorrect field names for options'); 
                    error('TDTTranslator:OptionsFieldnamesMismatch \noptions must have the following fields:\n {%s}\n',char(join(getFieldnames(emptyOpts),', ')));
                end
            end
            verifyFileOptions(obj,obj.options);
            if isfield(obj.options, 'hasEdfDataFile') && obj.options.hasEdfDataFile
                verifyEdfOptions(obj,obj.options.edf); 
            else
                %obj.options.edf=[];
            end
        end
        
        function out = processFields(~,fieldnamePrompts)
            out = struct();
            for f = fieldnamePrompts'
                out.(f{1}{1}) = input([f{1}{2} ' = ']);
            end                       
        end
        
        function verifyFileOptions(~,optStruct)
            try
                if ~exist(optStruct.sessionDir,'dir')
                    throw(MException('TDTTranslator:DirectoryNotFound',sprintf('options.sessionDir [%s] does not exist!',optStruct.sessionDir)));
                end
                if ~exist(optStruct.baseSaveDir,'dir')
                    throw(MException('TDTTranslator:DirectoryNotFound',sprintf('options.baseSaveDir [%s] does not exist!',optStruct.baseSaveDir)));
                end
                if ~exist(optStruct.eventDefFile,'file')
                    throw(MException('TDTTranslator:FileNotFound',sprintf('options.eventDefFile [%s] does not exist!',optStruct.eventDefFile)));
                end
                if ~exist(optStruct.infosDefFile,'file')
                    throw(MException('TDTTranslator:FileNotFound',sprintf('options.infosDefFile [%s] does not exist!',optStruct.infosDefFile)));
                end
                if optStruct.hasEdfDataFile && ~exist(fullfile(optStruct.sessionDir,'dataEDF.mat'),'file')
                    throw(MException('TDTTranslator:FileNotFound',sprintf('options.hasEdfDataFile is set to true, but file [%s] does not exist!',fullfile(optStruct.sessionDir,'dataEDF.mat'))));
                end
            catch me
                error(me.message)
            end 
        end
        
        function verifyEdfOptions(~, optStruct)      
            try
                if isempty(regexp(optStruct.useEye,'(?<p>[XY])','names','ignorecase'))
                    throw(MException('TDTTranslator:IncorrectValue','options.edf.useEye must be [X or Y] but was [%s]!',optStruct.useEye));
                end              
                if iscell(optStruct.voltRange) || numel(optStruct.voltRange)~=2 || any(isnan(optStruct.voltRange)) ...
                        || any(isinf(optStruct.voltRange)) || range(optStruct.voltRange)<=0
                    throw(MException('TDTTranslator:IncorrectValue','options.edf.voltRange must be a 2 element non-NaN non-Inf numeric vector!'));
                end
                if iscell(optStruct.signalRange) || numel(optStruct.signalRange)~=2 || any(isnan(optStruct.signalRange)) ...
                        || any(isinf(optStruct.signalRange)) || range(optStruct.signalRange)<=0
                    throw(MException('TDTTranslator:IncorrectValue','options.edf.signalRange must be a 2 element non-NaN non-Inf numeric vector!'));
                end
                if iscell(optStruct.pixelRange) || numel(optStruct.pixelRange)~=2 || any(isnan(optStruct.pixelRange)) ...
                        || any(isinf(optStruct.pixelRange)) || range(optStruct.pixelRange)<=0
                    throw(MException('TDTTranslator:IncorrectValue','options.edf.pixelRange must be a 2 element non-NaN non-Inf numeric vector!'));
                end
            catch me
                error(me.message)
            end
        end
        
        function [opts, edfOpts] = getEmptyOptions(obj)
            fns = cellfun(@(x) x{1}, obj.optionFieldPrompts,'UniformOutput',false)';
            opts = table2struct(array2table(ones(1,numel(fns)),'VariableNames',fns));
            fns = cellfun(@(x) x{1}, obj.edfOptionFieldPrompts,'UniformOutput',false)';
            edfOpts = table2struct(array2table(ones(1,numel(fns)),'VariableNames',fns));
        end
        
    end
end

