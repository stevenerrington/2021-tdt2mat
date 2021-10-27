function [tdtLFP, tdtSpk, tdtEEG] = getTDTephys(dirs, ops)

tdtFun = @TDTbin2mat;
getLFP = ops.getLFP; getSpk = ops.getSpk; getEEG = ops.getEEG;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract LFP data
if getLFP
    lfpData = tdtFun([dirs.rawDir '\' dirs.experimentName],...
        'TYPE',{'streams'},'STORE','Lfp1','VERBOSE',0);
    
    for channel = 1:length(lfpData.streams.Lfp1.channels)
        channellabel = ['LFP_' int2str(channel)];
        tdtLFP.data.(channellabel) = lfpData.streams.Lfp1.data(channel,:);
    end
    
    tdtLFP.info.samplingFreq = lfpData.streams.Lfp1.fs;
    tdtLFP.info.startTime = lfpData.streams.Lfp1.startTime;
    tdtLFP.info.channels = lfpData.streams.Lfp1.channels;
    
else
    tdtLFP = [];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract Spike data
if getSpk
    % Run main JRClust cluster extraction & analysis
    masterJrClust_wrapper(dirs)
    %  Allow for manual curation of the detected clusters
%     jrc('manual','master_jrclust.prm');
    fprintf('Sending to manual curation. Type dbcont to continue. \n')
%     keyboard
    %  Import clusters into .mat format to allow for further analysis
    tdtSpk = getJRclustSpks(dirs);
else
    tdtSpk = [];
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract EEG data
if getEEG
    eegData = tdtFun([dirs.rawDir '\' dirs.experimentName],...
        'TYPE',{'streams'},'STORE','EEGx','VERBOSE',0);
    
    for channel = 1:size(eegData.streams.EEGx.data,1)
        channellabel = ['EEG_' int2str(channel)];
        tdtEEG.data.(channellabel) = eegData.streams.EEGx.data(channel,:);
    end
    
    tdtEEG.info.samplingFreq = eegData.streams.EEGx.fs;
    tdtEEG.info.startTime = eegData.streams.EEGx.startTime;
    
else
    tdtEEG = [];
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


end