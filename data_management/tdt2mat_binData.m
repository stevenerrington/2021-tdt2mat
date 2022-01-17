%% Clear environment
clear; clc;
dirs.masterData = 'S:\DATA\Current Subjects\';
dirs.binDir = 'S:\Users\Current Lab Members\Steven Errington\temp\dajo_bin\';

%% Get Session Information
% Get Ephys log and tidy
ephysLog = importOnlineEphysLogMaster;

for sessionIdx = 1:size(ephysLog,1)
    
    fprintf('%s  |  session %i/%i \n',ephysLog.Session{sessionIdx},sessionIdx,size(ephysLog,1))
    
    date = datestr(ephysLog.Date{sessionIdx},'yymmdd');
    
    % Set raw TDT input directory
    if strcmp(ephysLog.Monkey{sessionIdx},'Jo'); ops.dataDir = [dirs.masterData ephysLog.Monkey{sessionIdx} '\Experimental\Countermanding\Neurophysiology\Joule-' date '\' ephysLog.TDTfilename{sessionIdx} '\']; end
    if strcmp(ephysLog.Monkey{sessionIdx},'Da'); ops.dataDir = [dirs.masterData ephysLog.Monkey{sessionIdx} '\Experimental\Countermanding\Neurophysiology\Darwin-' date '\' ephysLog.TDTfilename{sessionIdx} '\']; end
    
    % Set binary file output file
    ops.fbinary = fullfile(dirs.binDir,[ephysLog.Session{sessionIdx} '.bin']); % will be created for 'openEphys'
    
    % Determine which WAV to reference (multi-electrode penetrations)
    ops.wav = ephysLog.ProbeIdx{sessionIdx};
    
    ds = fullfile(ops.dataDir,['*_Wav' ops.wav '_*.sev']);
    T = interface.IDataAdapter.newDataAdapter('sev',ds);
    
    if length(T.dataFiles) == 32
        try
            convertTdt2Bin_multi(ops); % Run conversion code
        catch
            errorSession{sessionIdx,:} = {sessionIdx,ephysLog.Session{sessionIdx}};
        end
    else
        errorSession{sessionIdx,:} = {sessionIdx,ephysLog.Session{sessionIdx}};
    end
    
    
end

