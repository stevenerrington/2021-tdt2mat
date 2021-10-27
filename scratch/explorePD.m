% %% Joule setup
joule.sess = 'Joule-180817-125007';
joule.sessDir = fullfile('data/Joule/tdtData/troubleshootEventCodes',joule.sess);
joule.behavFile = fullfile('dataProcessed/data/Joule/tdtData/troubleshootEventCodes',joule.sess,'Behav.mat');

joule.eventDefFile = 'data/Joule/TEMPO/ProcLib/EVENTDEF.pro';
joule.infosDefFile = 'data/Joule/TEMPO/ProcLib/CMD/INFOS.pro';
joule.pdStreamNames = {'PhoL';'PhoR'};

% %% Darwin setup
% darwin.sess = 'Darwin-180808-105638';
% darwin.sessDir = fullfile('data/Kaleb/antiSessions',darwin.sess);
% darwin.behavFile = fullfile('dataProcessed/data/Kaleb/antiSessions',darwin.sess,'Behav.mat');
% 
% darwin.eventDefFile = 'KalebCodes/EVENTDEF.pro';
% darwin.infosDefFile = '';
% darwin.pdStreamNames = {'PD2_';'PD__'};
% 
% %% Leonardo setup
% leonardo.sess = 'Leonardo-180810-163127';
% leonardo.sessDir = fullfile('data/Leonardo/ColorDetectionTraining',leonardo.sess);
% leonardo.behavFile = fullfile('dataProcessed/data/Leonardo/ColorDetectionTraining',leonardo.sess,'Behav.mat');
% 
% leonardo.eventDefFile = 'KalebCodes/EVENTDEF.pro';
% leonardo.infosDefFile = '';
% leonardo.pdStreamNames = {'PhoL';'PhoR'};

%% Check for Behavior file....
monk = joule;

sessDir = monk.sessDir;
behavFile = monk.behavFile;
eventDefFile = monk.eventDefFile;
infosDefFile = monk.infosDefFile;
pdStreamNames = monk.pdStreamNames;

if ~exist(behavFile,'file')
    fprintf('Behav.mat file not found, translating TDT acquired data\n');
    [temp,temp2] = runExtraction(sessDir,behavFile,eventDefFile,infosDefFile);
    
end
% First to get signal, Last to get signal. Always triggered on Last
pdFirstName = pdStreamNames{1};
pdLastName = pdStreamNames{2};

% Read PhotoDiode data
heads = TDTbin2mat(sessDir, 'HEADERS', 1);

pdFirstStream = TDTbin2mat(sessDir,'TYPE',{'streams'},'STORE',pdFirstName,'VERBOSE',0);
pdLastStream = TDTbin2mat(sessDir,'TYPE',{'streams'},'STORE',pdLastName,'VERBOSE',0);

pdFs = pdFirstStream.streams.(pdFirstName).fs;

% Process PhotoDiode data
tic
[photodiodeEvents, pdFirstSignal, pdLastSignal] = processPhotodiode({pdFirstStream.streams.(pdFirstName).data, pdLastStream.streams.(pdLastName).data}, pdFs);
toc
% add title to 2 figs
fh = gcf;
figure(fh.Number-1);
title(monk.sess);
figure(fh.Number);
title(monk.sess);

pdFirstVolts = pdFirstSignal.pdVolts;
pdLastVolts = pdLastSignal.pdVolts;

nTimeBins = size(pdFirstVolts,2);
signalTimeMs = (-floor(nTimeBins/2):floor(nTimeBins/2))';

nFirst = size(pdFirstVolts,1);
nLast = size(pdLastVolts,1);

orphanVolts = [];
orphansInFirst = false;

if nFirst > nLast
    orphansInFirst = true;
    orphanVolts = pdFirstVolts(nLast+1:end,:);    
elseif nLast > nFirst
    orphansInFirst = false;
    orphanVolts = pdLastVolts(nFirst+1:end,:);
else %both are same size
end

nOrphans = size(orphanVolts,1);
orphansY = [orphanVolts';nan(1,nOrphans)];
orphansX = repmat([signalTimeMs;NaN],1,nOrphans);

figure
if nOrphans > 0
   plot(orphansX(:),orphansY(:),'g')
else
    plot(1:10, 1:10);
    text(2, 5, 'No Orphans');
end


pdLsmooth = movmean(pdFirstStream.streams.(pdFirstName).data,[2 0]);
pdRsmooth = movmean(pdLastStream.streams.(pdLastName).data,[2 0]);

beh = load(behavFile);
pdFirstMs = photodiodeEvents.PD_First_Ms;
pdLastMs = photodiodeEvents.PD_Last_Ms_Paired;

eventName = 'PDTrigger_';
eventName = 'FixSpotOn_';
eventTime = beh.Task.(eventName);

% to find closest index into photodiode timestamps
% edges = [-Inf; pd1Start; +Inf];
% closestIdx = @(x) discretize(x, edges);
% Find closest index into PD timestamps for FixSPotOn_
% [closeFixOnIdx, closeFixOnMeanTs] = closestIdx(fixSpotOn);
closestIdx = nan(numel(eventTime),1);

for ii = 1:numel(eventTime)
    d = abs(pdLastMs-eventTime(ii));
    closestIdx(ii,1) = min([find(d==min(d),1);NaN]);
end
closestIdx = closestIdx(~isnan(closestIdx));
xTimeMs = pdFirstSignal.xTimeInMs(1:find(isnan(pdFirstSignal.xTimeInMs),1)-1);
evRelT = nan(numel(closestIdx),1);
% Vectorized plotting
% Plot PD signal
xTempPd = repmat([xTimeMs;NaN],numel(closestIdx),1);
yTempPd = cell2mat(arrayfun(@(x) [pdLastVolts(x,:) NaN]',closestIdx,'UniformOutput',false));
figure
plot(xTempPd,yTempPd);
hold on
line([0 0],ylim);
% Relative Event Time
evRelTime = eventTime-pdLastMs(closestIdx);
xTempEvRelTime = cell2mat(arrayfun(@(x) [evRelTime(x);evRelTime(x);NaN],(1:numel(closestIdx))','UniformOutput',false));
yTempEvRelTime = repmat([ylim';NaN],numel(closestIdx),1);
plot(xTempEvRelTime,yTempEvRelTime,'color','r');
% Event line
xl = xlim;
yl = ylim;
line([xl(1)+0.05*range(xl) xl(1)+0.10*range(xl)], [yl(2)-0.1*range(yl), yl(2)-0.1*range(yl)], 'color','r');
% Event text
text(xl(1)+0.12*range(xl), yl(2)-0.1*range(yl),sprintf('Event : %s',eventName), 'Interpreter','none');

xlabel('PD signal Relative time (millisec)');
ylabel('PD signal');

% add title to 2 figs
fh = gcf;
figure(fh.Number-1);
title(monk.sess);
figure(fh.Number);
title(monk.sess);
