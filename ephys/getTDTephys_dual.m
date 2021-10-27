function [tdtLFP, tdtSpk, tdtEEG] = getTDTephys_dual(dirs, ops, electrodeIdx)

tdtFun = @TDTbin2mat;
getLFP = ops.getLFP; getSpk = ops.getSpk; getEEG = ops.getEEG;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract LFP data
if getLFP
    
    lfpName = ['Lfp' int2str(electrodeIdx)];
    lfpData = tdtFun([dirs.rawDir '\' dirs.experimentName],...
        'TYPE',{'streams'},'STORE',lfpName,'VERBOSE',0);
    
    for channel = 1:length(lfpData.streams.(lfpName).channels)
        channellabel = ['LFP_' int2str(channel)];
        tdtLFP.data.(channellabel) = lfpData.streams.(lfpName).data(channel,:);
    end
    
    tdtLFP.info.samplingFreq = lfpData.streams.(lfpName).fs;
    tdtLFP.info.startTime = lfpData.streams.(lfpName).startTime;
    tdtLFP.info.channels = lfpData.streams.(lfpName).channels;
    
else
    tdtLFP = [];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract Spike data
if getSpk
    % Run main JRClust cluster extraction & analysis
    masterJrClust_wrapper_dual(dirs, electrodeIdx)
    %  Allow for manual curation of the detected clusters
%     jrc('manual','master_jrclust.prm');
%     fprintf('Sending to manual curation. Type dbcont to continue. \n')
%     keyboard
    %  Import clusters into .mat format to allow for further analysis
    tdtSpk = getJRclustSpks_dual(dirs, electrodeIdx);
else
    tdtSpk = [];
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract EEG data
if getEEG
    eegData = tdtFun([dirs.rawDir '\' dirs.experimentName],...
        'TYPE',{'streams'},'STORE','rEEG','VERBOSE',0);
    
    for channel = 1:size(eegData.streams.rEEG.data,1)
        channellabel = ['EEG_' int2str(channel)];
        
        bandpassFreq = [ 1 40 ];
        tdtEEG.data.(channellabel) = filterLFP(double(eegData.streams.rEEG.data(channel,:)),...
            bandpassFreq(1),bandpassFreq(2) ,eegData.streams.rEEG.fs);
    end
    
    tdtEEG.info.samplingFreq = eegData.streams.rEEG.fs;
    tdtEEG.info.startTime = eegData.streams.rEEG.startTime;
    
else
    tdtEEG = [];
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


end