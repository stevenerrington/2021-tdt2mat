function plotCSD_LFPCorr(CSDanalysis, blockpath)


f_h = figure('Renderer', 'painters', 'Position', [100 100 1200 800]);

% All contacts
lfpSubplot_all = subplot(3, 3, 1);
P_LINEAR_LFP(CSDanalysis.linearLFP, 32,...
    1:32, f_h, lfpSubplot_all)
title(blockpath)

lfpCSDSubplot_all = subplot(3, 3, 2);
P_CSD_BASIC(nanmean(CSDanalysis.all.CSD(2:end-1, :, :),3),...
    1:32, [-100:250],...
     f_h, lfpCSDSubplot_all)

lfpCorrSubplot_all = subplot(3, 3, 3);
P_CORRE_BASIC(CSDanalysis.all.CORRE, 1:32,...
    f_h, lfpCorrSubplot_all)


% Upper contacts
lfpSubplot_upper = subplot(3, 3, 4);
P_LINEAR_LFP(CSDanalysis.linearLFP, 32,...
    1:16, f_h, lfpSubplot_upper)

lfpCSDSubplot_upper = subplot(3, 3, 5);
P_CSD_BASIC(nanmean(CSDanalysis.upper.CSD(2:end-1, :, :),3),...
    1:16, [-100:250],...
    f_h, lfpCSDSubplot_upper)

lfpCorrSubplot_upper = subplot(3, 3, 6);
P_CORRE_BASIC(CSDanalysis.upper.CORRE, 1:16,...
    f_h, lfpCorrSubplot_upper)

% Lower contacts
lfpSubplot_lower = subplot(3, 3, 7);
P_LINEAR_LFP(CSDanalysis.linearLFP, 32,...
    16:32, f_h, lfpSubplot_lower)

lfpCSDSubplot_lower = subplot(3, 3, 8);
P_CSD_BASIC(nanmean(CSDanalysis.lower.CSD(2:end-1, :, :),3),...
    16:32, [-100:250],...
    f_h, lfpCSDSubplot_lower)

lfpCorrSubplot_lower = subplot(3, 3, 9);
P_CORRE_BASIC(CSDanalysis.lower.CORRE, 16:32,...
    f_h, lfpCorrSubplot_lower)

end


