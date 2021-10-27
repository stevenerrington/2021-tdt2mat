clear all; clc; getColors

%% Get online ephys data log
ephysLog = importOnlineEphysLog;
dataDir = 'C:\Users\Steven\Desktop\TDT convert\cmandMat';
sessionList = ephysLog.Session(strcmp(ephysLog.UseFlag,'1') & strcmp(ephysLog.Monkey,'Darwin'));

%% Instantiate all arrays
max_nSSDs = 10;
collatedData.all.inh_SSD = nan(length(sessionList),max_nSSDs);
collatedData.all.inh_pnc = nan(length(sessionList),max_nSSDs);
collatedData.all.inh_nTrl = nan(length(sessionList),max_nSSDs);
collatedData.all.SSRT = nan(length(sessionList),1);

collatedData.low.inh_SSD = nan(length(sessionList),max_nSSDs);
collatedData.low.inh_pnc = nan(length(sessionList),max_nSSDs);
collatedData.low.inh_nTrl = nan(length(sessionList),max_nSSDs);
collatedData.low.SSRT = nan(length(sessionList),1);

collatedData.high.inh_SSD = nan(length(sessionList),max_nSSDs);
collatedData.high.inh_pnc = nan(length(sessionList),max_nSSDs);
collatedData.high.inh_nTrl = nan(length(sessionList),max_nSSDs);
collatedData.high.SSRT = nan(length(sessionList),1);

tempRT.low.nostop = []; tempRT.high.nostop = [];
tempRT.low.noncanc = []; tempRT.high.noncanc = [];

%% Collect data across sessions

for ii = 1:length(sessionList)
    try
        data = load([dataDir '\' sessionList{ii}],'Behavior');
        fprintf([sessionList{ii} '\n'])
        [ttx, ttx_history, trialEventTimes] = processSessionTrials...
            (data.Behavior.stateFlags_, data.Behavior.Infos_);
        [ttm] = processTrialMatching(data.Behavior.Stopping, ttx, trialEventTimes);
        
        nSSDs = length(data.Behavior.Stopping.inh_SSD);
        collatedData.all.inh_SSD(ii,[1:nSSDs]) = data.Behavior.Stopping.inh_SSD;
        collatedData.all.inh_pnc(ii,[1:nSSDs]) = data.Behavior.Stopping.inh_pnc;
        collatedData.all.inh_nTrl(ii,[1:nSSDs]) = data.Behavior.Stopping.inh_nTr;
        collatedData.all.SSRT(ii,1) = data.Behavior.Stopping.ssrt.integrationWeighted;
        
        collatedData.low.inh_SSD(ii,[1:nSSDs]) = data.Behavior.Value.valueStopBeh.inh_SSD.lo;
        collatedData.low.inh_pnc(ii,[1:nSSDs]) = data.Behavior.Value.valueStopBeh.inh_pnc.lo;
        collatedData.low.inh_nTrl(ii,[1:nSSDs]) = data.Behavior.Value.valueStopBeh.inh_nTr.lo;
        collatedData.low.SSRT(ii,1) = data.Behavior.Value.valueStopBeh.ssrt.lo.integrationWeighted;
        
        collatedData.high.inh_SSD(ii,[1:nSSDs]) = data.Behavior.Value.valueStopBeh.inh_SSD.hi;
        collatedData.high.inh_pnc(ii,[1:nSSDs]) = data.Behavior.Value.valueStopBeh.inh_pnc.hi;
        collatedData.high.inh_nTrl(ii,[1:nSSDs]) = data.Behavior.Value.valueStopBeh.inh_nTr.hi;
        collatedData.high.SSRT(ii,1) = data.Behavior.Value.valueStopBeh.ssrt.hi.integrationWeighted;
        
        
        
        collatedData.low.RT.nostop{ii,:} = data.Behavior.Value.valueRTdist.lo.nostop;
        collatedData.low.RT.noncanc{ii,:} = data.Behavior.Value.valueRTdist.lo.noncanc;
        collatedData.high.RT.nostop{ii,:} = data.Behavior.Value.valueRTdist.hi.nostop;
        collatedData.high.RT.noncanc{ii,:} = data.Behavior.Value.valueRTdist.hi.noncanc;
        
        
        collatedData.all.RT.nostop{ii,:} = cumulDist([data.Behavior.Value.valueRTdist.lo.nostop(:,1);...
            data.Behavior.Value.valueRTdist.hi.nostop(:,1)]);
        collatedData.all.RT.noncanc{ii,:} = cumulDist([data.Behavior.Value.valueRTdist.lo.noncanc(:,1);...
            data.Behavior.Value.valueRTdist.hi.noncanc(:,1)]);
        
        tempRT.low.nostop = [tempRT.low.nostop; data.Behavior.Value.valueRTdist.lo.nostop(:,1)];
        tempRT.high.nostop = [tempRT.high.nostop; data.Behavior.Value.valueRTdist.hi.nostop(:,1)];
        tempRT.low.noncanc = [tempRT.low.noncanc; data.Behavior.Value.valueRTdist.lo.noncanc(:,1)];
        tempRT.high.noncanc = [tempRT.high.noncanc; data.Behavior.Value.valueRTdist.hi.noncanc(:,1)];
        
        
    catch
        fprintf([sessionList{ii} ' ***ERROR**** \n'])
        
    end
    
end

%% Figure configuration
histogramBins = [70:10:180]; histogramAlpha = 0.2;
lowColor = 'b'; highColor = 'r'; allColor = 'k';

%% Figure generation
figure('Renderer', 'painters', 'Position', [100 100 1000 600]);

% Standard inh function
subplot(2,3,1); hold on
for ii = 1:length(sessionList)
    inh_fun_session = plot(collatedData.all.inh_SSD(ii,:),...
        collatedData.all.inh_pnc(ii,:),allColor);
    inh_fun_session.Color = [inh_fun_session.Color, 0.1];
end
inh_fun_session = plot(nanmean(collatedData.all.inh_SSD),...
    nanmean(collatedData.all.inh_pnc),allColor);

% Standard RT dist
subplot(2,3,2); hold on
RTcumulDist.all.nostop = cumulDist([tempRT.low.nostop; tempRT.high.nostop]);
RTcumulDist.all.noncanc = cumulDist([tempRT.low.noncanc; tempRT.high.noncanc]);
plot(RTcumulDist.all.nostop(:,1),RTcumulDist.all.nostop(:,2),'color',allColor,'LineWidth',1,'LineStyle','-');
plot(RTcumulDist.all.noncanc(:,1),RTcumulDist.all.noncanc(:,2),'color',allColor,'LineWidth',1,'LineStyle','--');

% Standard SSRT dist
subplot(2,3,3); hold on
histogram(collatedData.all.SSRT,histogramBins,'FaceColor',allColor,'FaceAlpha',0.5,'LineStyle','None')
vline(nanmean(collatedData.all.SSRT),allColor)

% Value inh function
subplot(2,3,4); hold on
for ii = 1:length(sessionList)
    inh_fun_session_low = plot(collatedData.low.inh_SSD(ii,:),...
        collatedData.low.inh_pnc(ii,:),lowColor);
    inh_fun_session_low.Color = [inh_fun_session_low.Color, 0.1];
    
    inh_fun_session_high = plot(collatedData.high.inh_SSD(ii,:),...
        collatedData.high.inh_pnc(ii,:),highColor);
    inh_fun_session_high.Color = [inh_fun_session_high.Color, 0.1];
end
inh_fun_session_low = plot(nanmean(collatedData.low.inh_SSD),...
    nanmean(collatedData.low.inh_pnc),lowColor);
inh_fun_session_high = plot(nanmean(collatedData.high.inh_SSD),...
    nanmean(collatedData.high.inh_pnc),highColor);

% Value RT dist
subplot(2,3,5); hold on
RTcumulDist.low.nostop = cumulDist(tempRT.low.nostop); RTcumulDist.high.nostop = cumulDist(tempRT.high.nostop);
RTcumulDist.low.noncanc = cumulDist(tempRT.low.noncanc); RTcumulDist.high.noncanc = cumulDist(tempRT.high.noncanc);

plot(RTcumulDist.low.nostop(:,1),RTcumulDist.low.nostop(:,2),'color',[lowColor 0.65],'LineWidth',0.5);
plot(RTcumulDist.high.nostop(:,1),RTcumulDist.high.nostop(:,2),'color',[highColor 0.65],'LineWidth',0.5);
plot(RTcumulDist.low.noncanc(:,1),RTcumulDist.low.noncanc(:,2),'color',[lowColor 0.65],'LineWidth',0.5,'LineStyle','--');
plot(RTcumulDist.high.noncanc(:,1),RTcumulDist.high.noncanc(:,2),'color',[highColor 0.65],'LineWidth',0.5,'LineStyle','--');

% Value SSRT dist
subplot(2,3,6); hold on
histogram(collatedData.low.SSRT,histogramBins,'FaceColor',lowColor,'FaceAlpha',histogramAlpha','LineStyle','None')
histogram(collatedData.high.SSRT,histogramBins,'FaceColor',highColor,'FaceAlpha',histogramAlpha','LineStyle','None')
vline(nanmean(collatedData.low.SSRT),lowColor)
vline(nanmean(collatedData.high.SSRT),highColor)






























%% CUTTINGS

% for ii = 1:length(sessionList)
%     try
%     rt_cdf_session_low_nostop = plot(collatedData.low.RT.nostop{ii,:}(:,1),...
%         collatedData.low.RT.nostop{ii,:}(:,2),'color',colors.nostop,'LineWidth',1,'LineStyle',':');
%     rt_cdf_session_low_nostop.Color = [rt_cdf_session_low_nostop.Color, 0.1];
%     
%     rt_cdf_session_low_noncanc = plot(collatedData.low.RT.noncanc{ii,:}(:,1),...
%         collatedData.low.RT.noncanc{ii,:}(:,2),'color',colors.noncanc,'LineWidth',1,'LineStyle',':');    
%     rt_cdf_session_low_noncanc.Color = [rt_cdf_session_low_noncanc.Color, 0.1];
%     
%     rt_cdf_session_high_nostop = plot(collatedData.high.RT.nostop{ii,:}(:,1),...
%         collatedData.high.RT.nostop{ii,:}(:,2),'color',colors.nostop,'LineWidth',1);
%     rt_cdf_session_high_nostop.Color = [rt_cdf_session_high_nostop.Color, 0.1];
%     
%     rt_cdf_session_high_noncanc = plot(collatedData.high.RT.noncanc{ii,:}(:,1),...
%         collatedData.high.RT.noncanc{ii,:}(:,2),'color',colors.noncanc,'LineWidth',1);    
%     rt_cdf_session_high_noncanc.Color = [rt_cdf_session_high_noncanc.Color, 0.1];    
%     catch; end
% end
