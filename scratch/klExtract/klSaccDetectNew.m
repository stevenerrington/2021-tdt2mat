function [saccStart,saccEnds] = klSaccDetectNew(xVals,yVals,times,varargin)

% Set defaults
nRMSstart = .4;
nRMSstop = .05;
sampWind = 5;
alph = .05;
smoothAmnt = 10;
offset = 10;
doFilt = 1;
minSaccLen = 10;

% Decode varargin
varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd),
    switch varargin{varStrInd(iv)},
        case {'-s'}
            nRMSstart = varargin{varStrInd(iv)+1};
        case {'-o'}
            offset = varargin{varStrInd(iv)+1};
        case {'-a'}
            smoothAmnt = varargin{varStrInd(iv)+1};
        case {'-f'}
            if strcmp(class(varargin{varStrInd(iv)+1}),'digitalFilter')
                f=varargin{varStrInd(iv)+1};
                doFilt = 1;
            else
                doFilt = varargin{varStrInd(iv)+1};
            end
        case {'-r'}
            rmsH = varargin{varStrInd(iv)+1};
        case {'-w'}
            sampWind = varargin{varStrInd(iv)+1};
    end
end

sampWind = round(sampWind/(times(2)-times(1)));

% Filter X and Y
% if doFilt
%     f=designfilt('lowpassfir','FilterOrder',3,'PassbandFrequency',.00001,'SampleRate',1/nanmean(diff(times./1000)),'StopbandFrequency',50);
%     xVals = filter(f,xVals);
%     yVals = filter(f,yVals);
% end

% Get the hypotenuse of the x,y vector via Pythagorean theorem
hyp = sqrt(xVals.^2+yVals.^2);

% Now calculate the differences in x position, y position, and
% hypotenuse
deltX = diff(xVals);
deltY = diff(yVals);
deltT = diff(times);
deltH = diff(hyp);

% dx = deltX/deltT; same for y
dx = deltX./deltT;
dy = deltY./deltT;
dh = deltH./deltT;

% Smooth dh for better SNR
try
    dh = klRunningAvv2(dh,smoothAmnt);
catch MExc
    if strcmp(MExc.identifier,'MATLAB:nomem')
        % Here we need to down sample...
        downX = xVals(1:24:end);
        downY = yVals(1:24:end);
        downT = times(1:24:end);
        [saccStart,saccEnds] = klSaccDetectNew(downX,downY,downT,'-o',offset,'-s',nRMSstart);
        return;
    end        
end


% Overall velocity should be the change in the hypotenuse
% So, let's find times that dh > nRMS*rms
if ~exist('rmsH','var')
    rmsH = rms(dh(isfinite(dh)));
end

if doFilt
    if ~exist('f','var')
        f=designfilt('lowpassfir','FilterOrder',3,'PassbandFrequency',.00001,'SampleRate',1/nanmean(diff(times./1000)),'StopbandFrequency',50);
    end
    dh = filtfilt(f,dh);
%     dh = fliplr(filter(fliplr(dh)));
end

% Let's also make sure that the duration of the velocity increase is
% greater than the minimum saccade time
minSampDur = find((times-min(times)) > minSaccLen,1);
dhShift = [dh(2:end),nan];
overInds = find(klGetConsecutive(dh >= nRMSstart*rmsH) == 0 & klGetConsecutive(dhShift >= nRMSstart*rmsH) > 0 & klGetConsecutive(dhShift >= nRMSstart*rmsH) > minSampDur);
% overInds tends to grab too early, so let's shift them to put them in the
% middle of the putative saccade
overInds = overInds+offset;
overInds(overInds > length(hyp)) = [];

% overInds = find(dh >= nRMSstart*rmsH & dhShift < nRMSstart*rmsH);

% Let's do this the slow, painful way...
% Loop through overInds(v > crit)
startInds = nan(1,length(overInds));
endInds = nan(1,length(overInds));
% fprintf('Found %d potential saccades...\n\t',length(overInds));
printStr = [];

%% Move backward to find beginnings of saccades
startDiff = 0;
nLoops = 0;
while sum(isfinite(startInds)) < length(startInds) && nLoops < 200/(times(2)-times(1))
%     if mod(abs(startDiff),20) == 0
%         fprintf(repmat('\b',1,length(printStr)));
%         printStr = sprintf('Scanning backwards %d steps for saccade starts (%d saccades to identify)...',abs(startDiff),sum(isnan(startInds)));
%         fprintf(printStr);
%     end
    % Get indices for to-be-done columns
    subInds = find(isnan(startInds));
    % Grab the matrix, columns are the times
    matInds = bsxfun(@plus,overInds(subInds)+startDiff,(-sampWind:sampWind)');
    matInds(matInds <= 0 | matInds > length(hyp)) = 1;
    hypCheck = hyp(matInds);
    % Special case where there's just one saccade left: make sure it's a
    % column
    if size(hypCheck,1) == 1, hypCheck = hypCheck'; end
    % Get correlations over time
    [~,p] = corr((1:size(hypCheck,1))',hypCheck);
    % If p > alph and startInds hasn't been assigned, assign it
    pCheck = nan(1,length(startInds));
    pCheck(subInds) = p;
    startInds(isnan(startInds) & pCheck >= alph) = overInds(isnan(startInds) & pCheck >= alph)+startDiff;
    startDiff = startDiff-1;
    nLoops = nLoops + 1;
end
% fprintf('\n\t'); printStr = [];

%% Move foward to find endings of saccades
endDiff = 0;
nLoops = 0;
while sum(isfinite(endInds)) < length(endInds) && nLoops < 200/(times(2)-times(1))
%     if mod(abs(endDiff),20) == 0
%         fprintf(repmat('\b',1,length(printStr)));
%         printStr = sprintf('Scanning forward %d steps for saccade starts (%d saccades to identify)...',abs(endDiff),sum(isnan(endInds)));
%         fprintf(printStr);
%     end
    % Get indices for to-be-done columns
    subInds = find(isnan(endInds));
    % Grab the matrix, columns are the times
    matInds = bsxfun(@plus,overInds(subInds)+endDiff,(-sampWind:sampWind)');
    matInds(matInds <= 0 | matInds > length(hyp)) = 1;
    hypCheck = hyp(matInds);
    % Special case where there's just one saccade left: make sure it's a
    % column
    if size(hypCheck,1) == 1, hypCheck = hypCheck'; end
    % Get correlations over time
    [~,p] = corr((1:size(hypCheck,1))',hypCheck);
    % If p > alph and startInds hasn't been assigned, assign it
    pCheck = nan(1,length(endInds));
    pCheck(subInds) = p;
    endInds(isnan(endInds) & pCheck >= alph) = overInds(isnan(endInds) & pCheck >= alph)+endDiff;
    endDiff = endDiff+1;
%     if ~isnan(endInds(795))
%         keyboard
%     end
    nLoops = nLoops + 1;
end

% for ii = 1:length(overInds)
%     if mod(ii,200) == 0
%         fprintf(repmat('\b',1,length(printStr)));
%         printStr = sprintf('Checking potential saccade %d...',ii);
%         fprintf(printStr);
%     end
%     if ~isnan(overInds(ii))
%         % Let's grab overInds(ii) +/- sampWind, check for monotonic increase in
%         % hyp (overInds(ii)-1) to correct for "diff" indexing...
%         hypCheck = hyp((overInds(ii)-1)+(-sampWind:sampWind));
%         % Get correlation over time...
%         [~,p] = corr(hypCheck',(1:length(hypCheck))');
%         pInit = p; % Save for end checking
%         % Initialize counter
%         startDiff = 0;
%         % Move backwards...
%         while p < alph
%             hypCheck = hyp((overInds(ii)-1+startDiff)+(-sampWind:sampWind));
%             [~,p] = corr(hypCheck',(1:length(hypCheck))');
%             startDiff = startDiff-1;
%         end
%         startDiff = startDiff+1;
%         startInds(ii) = overInds(ii)-1+startDiff;
% 
%         % Reverse, Reverse!
%         p = pInit;
%         endDiff = 0;
%         % Move forwards...
%         while p < alph
%             hypCheck = hyp((overInds(ii)-1+endDiff)+(-sampWind:sampWind));
%             [~,p] = corr(hypCheck',(1:length(hypCheck))');
%             endDiff = endDiff+1;
%         end
%         endDiff = endDiff-1;
%         endInds(ii) = overInds(ii)-1+endDiff;
%         
%         overInds(overInds > overInds(ii) & overInds <= endInds(ii)) = nan;
%         
%     else
%         startInds(ii) = nan;
%         endInds(ii) = nan;
%     end
%     
% end
% fprintf('\n');

% If the next saccade "starts" before the current one finishes, cut it out
endCheck=[[startInds(2:end),nan];endInds];
if length(endCheck) < 2
   saccStart = nan;
   saccEnds = nan;
   return
end
cutInds = find(endCheck(1,:) < endCheck(2,:))+1;
startInds(cutInds) = [];
endInds(cutInds) = [];

cutInds = (startInds <= 0) | (startInds > length(times)) | (endInds <= 0) | (endInds > length(times));
startInds(cutInds) = [];
endInds(cutInds) = [];

% % Shift to check for repeats
% startShift = [startInds(2:end),nan];
% endShift = [endInds(2:end),nan];
% 
% startRep = startInds==startShift;
% endRep = endInds==endShift;

saccStart = times(startInds(startInds <= length(times)));
saccEnds = times(endInds(endInds <= length(times)));


