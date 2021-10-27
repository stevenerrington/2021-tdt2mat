clear all; clc

%% Parameters
monkey = 'joule'; ctxArea = 'ACC';
ephysLog = importOnlineEphysLog(monkey);

primaryDataFolder = 'C:\\Users\\Steven\\Desktop\\TDT convert\\cmandOutput\';
fileInfo = '\\JRclust\\master_jrclust_res.mat';

% Limit files to monkey and cortical area
primaryFolderInfo = dir(fullfile(primaryDataFolder,'*'));
sessionList = setdiff({primaryFolderInfo([primaryFolderInfo.isdir]).name},{'.','..'});
sessionList = sessionList(contains(sessionList,ctxArea));



%% Extract isolation data from JRclust mat files
for sessionIdx = 1:length(sessionList)
    session = sessionList{sessionIdx};
    fprintf(['Analysing session ' session '...\n'])
    
    session_jrClustDir = [];
    session_jrClustDir = [primaryDataFolder session fileInfo];
    
    try
        jrSpkInfo = [];
        [jrSpkInfo] = getJRclustSpkInfo(session_jrClustDir);
        jrSpkInfo_session{sessionIdx} = jrSpkInfo;
        
        
        % Get session info for easier matching
        logIdx = find(not(cellfun('isempty',strfind(ephysLog.Session,session))));
        
        
        session_number{sessionIdx} = repmat(ephysLog.SessionN{logIdx},size(jrSpkInfo,1),1);
        session_name{sessionIdx} = repmat(convertCharsToStrings(session),size(jrSpkInfo,1),1);
        session_date{sessionIdx} = repmat(ephysLog.Date(logIdx),size(jrSpkInfo,1),1);
        session_monkey{sessionIdx} = repmat(convertCharsToStrings(ephysLog.Monkey{logIdx}),size(jrSpkInfo,1),1);
        session_electrode{sessionIdx} = repmat(convertCharsToStrings(ephysLog.Electrode_Serial{logIdx}),size(jrSpkInfo,1),1);
        session_depth{sessionIdx} = repmat(str2num(ephysLog.ElectrodeRelativeDepth{logIdx}),size(jrSpkInfo,1),1);
        session_AP{sessionIdx} = repmat(str2num(ephysLog.AP_Grid{logIdx}),size(jrSpkInfo,1),1);
        session_ML{sessionIdx} = repmat(str2num(ephysLog.ML_Grid{logIdx}),size(jrSpkInfo,1),1);
        
    catch error
        fprintf(['    ***** ERROR ****: ' session '... \n' ...
            'Message: ' error.message '\n'])
    end
end

%% Compile data table
jrSpkInfo_main = table();
for sessionIdx = find(cellfun(@isempty,session_number) == 0)
    try
        sessNum = session_number{sessionIdx};
        sessName = session_name{sessionIdx};
        date = session_date{sessionIdx};
        monkey = session_monkey{sessionIdx};
        electrode = session_electrode{sessionIdx};
        depth = session_depth{sessionIdx};
        AP = session_AP{sessionIdx};
        ML = session_ML{sessionIdx};
        
        infoTable_session = table(sessNum,sessName,date,monkey,electrode,depth,AP,ML,...
            'VariableNames',{'sessionNum','sessionName','date','monkey','electrode','depth','AP','ML'});
        allTable_session = [infoTable_session, jrSpkInfo_session{sessionIdx}];
        
        
        jrSpkInfo_main = [jrSpkInfo_main; allTable_session];
    catch error
        fprintf(['    ***** ERROR ****: ' sessionList{sessionIdx} '...' error.message '\n'])
    end
    
end

%% Output data table
writetable(jrSpkInfo_main,'C:\Users\Steven\Desktop\TDT convert\cmandOutput\cmand_neuronIsolationInfo_jo -- 2021-05-18.csv', 'WriteVariableNames', true)


%% Look at distributions of signal quality measures
figure('Renderer', 'painters', 'Position', [100 100 1500 300]);
subplot(1,6,1); histogram(jrSpkInfo_main.ISIratio,'LineStyle','none'); xlabel('ISI ratio')
subplot(1,6,2); histogram(jrSpkInfo_main.isoDistance,'LineStyle','none'); xlabel('Isolation distance')
subplot(1,6,3); histogram(jrSpkInfo_main.Lratio,'LineStyle','none'); xlabel('L Ratio')
subplot(1,6,4); histogram(jrSpkInfo_main.SNR,'LineStyle','none'); xlabel('Signal Noise Ratio');
subplot(1,6,5); histogram(jrSpkInfo_main.Vpp,'LineStyle','none'); xlabel('Vpp')
subplot(1,6,6); histogram(jrSpkInfo_main.nSpikes,'LineStyle','none'); xlabel('NSpikes')

%% Find high SNR neurons
neuron_criteria = find(jrSpkInfo_main.ISIratio >  prctile(jrSpkInfo_main.ISIratio, 10) & ...
    jrSpkInfo_main.SNR > prctile(jrSpkInfo_main.SNR, 10));

neuron_criteria = find(jrSpkInfo_main.nSpikes > 35000);

[jrSpkInfo_main.sessionName(neuron_criteria) jrSpkInfo_main.DSP_id(neuron_criteria)]

