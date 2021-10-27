clear all; clc; getColors

%% Set parameters
dataDir = 'C:\Users\Steven\Desktop\TDT convert\cmandMat';
timeWin = [-1000 2000]; plotWin = [-100:600]; csdWin = [900:1250];
alignName = 'tone'; 

% Get perpendicular sessions information 
ephysLog = importOnlineEphysLog;
sessionList = ephysLog.Session(strcmp(ephysLog.PerpFlag,'1') & strcmp(ephysLog.DMFC,'1'));
ctxTop = ephysLog.CtxTopChannel(strcmp(ephysLog.PerpFlag,'1') & strcmp(ephysLog.DMFC,'1'));


figure('Renderer', 'painters', 'Position', [100 100 1000 700]);

tic
for ii = 1:length(sessionList)

% Load session data
data = parload([dataDir '\' sessionList{ii}]);

% Get session behavior
fprintf(['Analysing session: ' sessionList{ii} '\n'])
[ttx, ttx_history, trialEventTimes] = processSessionTrials...
    (data.Behavior.stateFlags_, data.Behavior.Infos_);
[ttm] = processTrialMatching(data.Behavior.Stopping, ttx, trialEventTimes);

% Align the LFPs from the session
% Depth x time x trial
tdtLFP = alignLFP(trialEventTimes, data.LFP, timeWin);

channelNames = fieldnames(tdtLFP.data);
clear LFP_CSD
for channelIdx = 1:32 % For each contact within the cortex
    channel = channelNames{channelIdx};
    fprintf(['Transforming LFP for CSD analysis on channel ' channel '... \n'])
    
    if channelIdx < str2num(ctxTop{ii})
        channel = channelNames{str2num(ctxTop{ii})};
        LFP_CSD.(alignName).CSDarray(:,:,channelIdx) =...
            tdtLFP.aligned.(channel).(alignName)(:,:);
    else
        LFP_CSD.(alignName).CSDarray(:,:,channelIdx) =...
            tdtLFP.aligned.(channel).(alignName)(:,:);
    end
end
LFP_CSD.(alignName).CSDarray = permute(LFP_CSD.(alignName).CSDarray, [3 2 1]);
LFP_CSD.(alignName).CSDarray = LFP_CSD.(alignName).CSDarray(:,csdWin,:);

% Perform CSD computation
fprintf(['Performing CSD analysis aligned on %s.\n'], alignName)
clear CSDcalc
CSDcalc.CSD = D_CSD_BASIC(LFP_CSD.(alignName).CSDarray, 'cndt', 0.0004, 'spc', 0.15);
CSD_toneAligned = CSDcalc.CSD(:,:,[ttx.nostop.all.all; ttx.canceled.all.all; ttx.noncanceled.all.all]);

clear plotCSD
plotCSD = nanmean(CSD_toneAligned(2:end-1, :, :),3); plotCSD = [plotCSD(1,:) ; plotCSD ; plotCSD(end,:)];
nele = size(plotCSD,1); plotCSD = H_2DSMOOTH(plotCSD); limi = nanmax(nanmax(abs(plotCSD)));

% Create figure
subplot(2,3,ii)
imagesc(csdWin+1000, 1:size(plotCSD,1), plotCSD);
for i = 1 : nele; labels{i} = num2str(i); end
set(gca,'ydir', 'rev','ylim', [1 size(plotCSD,1)], 'ytick', linspace(1, size(plotCSD,1), nele), 'yticklabel', labels)
caxis([-limi limi]); colormap('jet'); c1 = colorbar;
ylabel(c1, 'nA/mm3)')


CSDsession{ii} = plotCSD;
    
end
toc
