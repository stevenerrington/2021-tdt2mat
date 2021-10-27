DMFCFlag = not(cellfun('isempty',strfind(jrSpkInfo.sessionName,'DMFC')));
dorsalFlag = DMFCFlag+SEFFlag;

accFlag = not(cellfun('isempty',strfind(jrSpkInfo.sessionName,'ACC')));

jrSpkInfo.dorsalFlag = dorsalFlag;
jrSpkInfo.accFlag = accFlag;

dorsalNeurons = find(jrSpkInfo.dorsalFlag == 1);
accNeurons = find(jrSpkInfo.accFlag == 1);

sessionNums = str2num(jrSpkInfo.sessionNum);
DMFC_sessions = unique(sessionNums(dorsalNeurons));
ACC_sessions = unique(sessionNums(accNeurons));

nSessions.all = length(unique(str2num(jrSpkInfo.sessionNum)));
nSessions.DMFC = length(DMFC_sessions);
nSessions.ACC = length(ACC_sessions);

nNeurons.all = length(jrSpkInfo.dorsalFlag);
nNeurons.DMFC = sum(jrSpkInfo.dorsalFlag);
nNeurons.ACC = sum(jrSpkInfo.accFlag);


figure('Renderer', 'painters', 'Position', [100 100 600 900]);
subplot(3,2,1)
histogram(jrSpkInfo.Lratio(dorsalNeurons),0:5:50,'LineStyle','none')
xlim([-5 50]); ylabel('Frequency: DMFC Neurons'); box off
vline(median(jrSpkInfo.Lratio(dorsalNeurons)),'r-')

subplot(3,2,2)
histogram(jrSpkInfo.isoDistance(dorsalNeurons),0:10:200,'LineStyle','none')
xlim([-5 200]); box off
vline(nanmedian(jrSpkInfo.isoDistance(dorsalNeurons)),'r-')

subplot(3,2,3)
histogram(jrSpkInfo.Lratio(accNeurons),0:5:50,'LineStyle','none')
xlim([-5 50]); xlabel('L Ratio'); ylabel('Frequency: ACC Neurons'); box off
vline(median(jrSpkInfo.Lratio(accNeurons)),'r-')

subplot(3,2,4)
histogram(jrSpkInfo.isoDistance(accNeurons),0:10:200,'LineStyle','none')
xlim([-5 200]); xlabel('Iso Distance'); box off
vline(nanmedian(jrSpkInfo.isoDistance(accNeurons)),'r-')

subplot(3,2,5)
scatter(jrSpkInfo.Lratio(dorsalNeurons),jrSpkInfo.isoDistance(dorsalNeurons),'Filled','MarkerFaceAlpha',0.25)
xlim([-5 75]); ylim([-5 200]); xlabel('L ratio'); ylabel('Iso distance');
title('DMFC')

subplot(3,2,6)
scatter(jrSpkInfo.Lratio(accNeurons),jrSpkInfo.isoDistance(accNeurons),'Filled','MarkerFaceAlpha',0.25)
xlim([-5 75]); ylim([-5 200]); xlabel('L ratio'); ylabel('Iso distance');
title('ACC')

%% ------------------------------------------------------------
sessionNumList = str2num(jrSpkInfo.sessionNum);
sessionIDs = unique(str2num(jrSpkInfo.sessionNum));
grid_DMFC_sessions = zeros(15,15);
grid_ACC_sessions = zeros(15,15);
grid_DMFC = zeros(15,15);
grid_ACC = zeros(15,15);
zeroCenter = 8;

jrSpkInfo.AP = round(jrSpkInfo.AP);
jrSpkInfo.ML = round(jrSpkInfo.ML);

%% Get N penetrations at site
for ii = 1:length(sessionIDs)
    sessionRows = find(sessionNumList == sessionIDs(ii));
    if dorsalFlag(sessionRows(1)) == 1
        grid_DMFC_sessions(jrSpkInfo.AP(sessionRows(1))+zeroCenter,...
            jrSpkInfo.ML(sessionRows(1))+zeroCenter) =...
            grid_DMFC_sessions(jrSpkInfo.AP(sessionRows(1))+zeroCenter,...
            jrSpkInfo.ML(sessionRows(1))+zeroCenter) + 1;
    else
        grid_ACC_sessions(jrSpkInfo.AP(sessionRows(1))+zeroCenter,...
            jrSpkInfo.ML(sessionRows(1))+zeroCenter) =...
            grid_ACC_sessions(jrSpkInfo.AP(sessionRows(1))+zeroCenter,...
            jrSpkInfo.ML(sessionRows(1))+zeroCenter) + 1;
    end
    
end


%% Get N neurons at site
for ii = 1:length(dorsalNeurons)
    grid_DMFC(jrSpkInfo.AP(dorsalNeurons(ii))+zeroCenter,...
        jrSpkInfo.ML(dorsalNeurons(ii))+zeroCenter) =...
        grid_DMFC(jrSpkInfo.AP(dorsalNeurons(ii))+zeroCenter,...
        jrSpkInfo.ML(dorsalNeurons(ii))+zeroCenter) + 1;
    
end

for ii = 1:length(accNeurons)
    grid_ACC(jrSpkInfo.AP(accNeurons(ii))+zeroCenter,...
        jrSpkInfo.ML(accNeurons(ii))+zeroCenter) =...
        grid_ACC(jrSpkInfo.AP(accNeurons(ii))+zeroCenter,...
        jrSpkInfo.ML(accNeurons(ii))+zeroCenter) + 1;
end

figure('Renderer', 'painters', 'Position', [100 100 1175 800]);
subplot(2,2,1); hold on
imagesc([-7:1:7],[-7:1:7],grid_DMFC); circle_plot(0,0,7.5)
colormap(flipud(gray)); colorbar;
hline(0,'k--'); vline(0,'k--')
ax = gca; ax.CLim = [0 30];

subplot(2,2,2); hold on
imagesc([-7:1:7],[-7:1:7],grid_DMFC_sessions); circle_plot(0,0,7.5)
colormap(flipud(gray)); colorbar;
hline(0,'k--'); vline(0,'k--')
ax = gca; ax.CLim = [0 5];

subplot(2,2,3); hold on
imagesc([-7:1:7],[-7:1:7],grid_ACC); circle_plot(0,0,7.5)
colormap(flipud(gray)); colorbar;
hline(0,'k--'); vline(0,'k--')
ax = gca; ax.CLim = [0 30];

subplot(2,2,4); hold on
imagesc([-7:1:7],[-7:1:7],grid_ACC_sessions); circle_plot(0,0,7.5)
colormap(flipud(gray)); colorbar;
hline(0,'k--'); vline(0,'k--')
ax = gca; ax.CLim = [0 5];









