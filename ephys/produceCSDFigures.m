function produceCSDFigures(dirs, outFilename, tdtInfo, sessionInfo, ephysLog, logIdx, ttx, CSDanalysis)


% Set trials/parameters to use from previous CSD extract
inTrials = [ttx.nostop.all.all; ttx.canceled.all.all; ttx.noncanceled.all.all];

CSD_target = CSDanalysis.target.all.CSD(:,:,inTrials);
CSD_tone = CSDanalysis.tone.all.CSD(:,:,inTrials);
CORR_target = CSDanalysis.target.all.CORRE(:,:);
PSD_target = CSDanalysis.target.all.PSD_NORM(:,:);

%% Open new figure window
f_h = figure('Renderer', 'painters', 'Position', [100 100 1500 600]);

%% Session Information
ax = subplot(2, 3, 1);
text(-0.25,1,'Session Information','FontWeight','bold');
text(-0.25,0.9,['Session: ' outFilename]);
text(-0.25,0.8,['TDT Blockname: ' tdtInfo.blockname],'Interpreter', 'none');
text(-0.25,0.7,['Date: ' tdtInfo.date]);
text(-0.25,0.6,['Duration: ' tdtInfo.duration]);
text(-0.25,0.4,['Electrode: ' ephysLog.Electrode_brand{logIdx} ' ' ephysLog.Electrode_Serial{logIdx}]);
text(-0.25,0.3,['Location: ' [sessionInfo.area ': AP, '] char(ephysLog.AP_Grid(logIdx))...
    '; ML, ' char(ephysLog.ML_Grid(logIdx)) '']);
text(-0.25,0.2,['Electrode Settle Time: ' ephysLog.ElectrodeSettleTime{logIdx}]);
text(-0.25,0.1,['Electrode Settle Depth: ' ephysLog.ElectrodeSettleDepth{logIdx}]);
set ( ax, 'visible', 'off')

%% All contacts
lfpCSDSubplot_all = subplot(2, 3, 2);
P_CSD_BASIC(nanmean(CSD_target(2:end-1, :, :),3),...
    [-100:250], [-100 250],...
    f_h, lfpCSDSubplot_all)
subplot(2, 3, 2); ylabel('Contact Index'); title('Current Source Density')
xlabel('Time from Target (ms)')

lfpCSDSubplotTone_all = subplot(2, 3, 3);
P_CSD_BASIC(nanmean(CSD_tone(2:end-1, :, :),3),...
    [-100:250], [-100 250],...
    f_h, lfpCSDSubplotTone_all)
subplot(2, 3, 3); ylabel('Contact Index'); title('Current Source Density')
xlabel('Time from Tone (ms)')

lfpCorrSubplot_all = subplot(2, 3, 5);
P_CORRE_BASIC(CORR_target, 1:32,...
    f_h, lfpCorrSubplot_all)
subplot(2, 3, 5); xlabel('Contact Index'); ylabel('Contact Index')
title('Cross-contact correlation')

lfpPSDSubplot_all = subplot(2, 3, 6);
P_PSD_BASIC(PSD_target,  CSDanalysis.target.all.PSD_F,...
    f_h, lfpPSDSubplot_all)
subplot(2, 3, 6); ylabel('Contact Index')
title('Power Spectral Density')

%%
set(gcf,'Units','inches');
screenposition = get(gcf,'Position');
set(gcf,...
    'PaperPosition',[0 0 screenposition(3:4)],...
    'PaperSize',[screenposition(3:4)]);
saveas(gcf,[dirs.figureFolder '\' outFilename '-cmandLFP_laminar.pdf'])
close gcf



end
