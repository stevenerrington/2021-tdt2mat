function sessSpks=tdtGetQuals(file)

if ~exist('myDir','var'),
    myDir = 'Y:/Users/Kaleb/dataProcessed';
end
compType = 'euc';

% Get number of channels for loop
chanDir = dir(sprintf('%s/%s/Channel*',myDir,file));
chanNames = {chanDir.name};
nChans = length(chanNames);
chans = nan(1,nChans);
for i = 1:nChans,
    chans(i) = str2num(chanNames{i}(8:end));
end
chans = sort(chans);

% Load task if necessary
if nChans > 0,
    load(sprintf('%s/%s/Behav.mat',myDir,file));
end

load(sprintf('%s/%s/sessSorts1.mat',myDir,file));

% sessSpks = struct;

% Start channel loop
for ic = 1:nChans,
%     fprintf('Starting channel %d...\n',chans(ic));
    chanFold = sprintf('%s/%s/Channel%d',myDir,file,chans(ic));
%     close all;
    clear sortAudit chanSorts subWaves
    
    if exist(sprintf('%s/%s/Channel%d/sortAudit1.mat',myDir,file,ic),'file'),
        fprintf('Loading Channel %d...',ic);
        load(sprintf('%s/%s/Channel%d/autoSort_noAudit.mat',myDir,file,chans(ic)));
        fprintf('Done!\n');
    else
        fprintf('Channel %d not yet sorted\n',ic);
        continue
    end
    
    sigSorts = find(sessSorts(ic).isSig);
    subAligned = chanSorts.alWaves(chanSorts.subInds,:);
    
    if ismember(sessSorts(ic).set,[1,2]),
        % If original data = score*coeff', then score =
        % data*inv(coeff')?
        allScores = chanSorts.alWaves*inv(chanSorts.pcaCoeffs');
        subScores = chanSorts.pca(:,1:2);
    else
        allScores = chanSorts.alWaves*chanSorts.lppEig;
        subScores = chanSorts.lpp(:,1:2);
    end
    
    fprintf('\tFound %d units: ',length(sigSorts));
    if ~isempty(sigSorts),
        for iu = 1:length(sigSorts),
            
            fprintf('Loading unit %d...',iu);

            clear spikes
            if exist(sprintf('%s/%s/Channel%d/Unit%d/Spikes.mat',myDir,file,ic,iu),'file'),
                load(sprintf('%s/%s/Channel%d/Unit%d/Spikes.mat',myDir,file,ic,iu));
            else
                fprintf('Unit not extracted  (likely too few spikes)... Moving on\n');
                continue
            end

            %% Start by getting SNR
            for ib = 1:length(sprintf('Loading unit %d...',iu)), fprintf('\b'); end;
            fprintf('Getting SNR...');
            qualStruct.snr = klGetSNRv1(subAligned(sessSorts(ic).idx==sigSorts(iu),:));

            %% Now get isolation scores based on PCA/LPP
            for ib = 1:length(sprintf('Getting SNR...')), fprintf('\b'); end;
            fprintf('Calculating similarity matrix and getting isolation...');
            [qualStruct.isoScore, simMat] = klGetISv2(subScores(sessSorts(ic).idx==sigSorts(iu),:),subScores(sessSorts(ic).idx~=sigSorts(iu),:));

            for ib = 1:length(sprintf('Calculating similarity matrix and getting isolation...')), fprintf('\b'); end;
            fprintf('Getting False Negatives...');
            qualStruct.fnScore = klGetFNv2(subScores(sessSorts(ic).idx==sigSorts(iu),:),subScores(sessSorts(ic).idx~=sigSorts(iu),:),'sim',simMat);

            for ib = 1:length(sprintf('Getting False Negatives...')), fprintf('\b'); end;
            fprintf('Getting False Positives...');
            qualStruct.fpScore = klGetFPv2(subScores(sessSorts(ic).idx==sigSorts(iu),:),subScores(sessSorts(ic).idx~=sigSorts(iu),:),'sim',simMat);

            for ib = 1:length(sprintf('Getting False Positives...')), fprintf('\b'); end;
            fprintf('Done! SNR=%.2f, Iso=%.3f, FN=%.3f, FP=%.3f\n',qualStruct.snr,qualStruct.isoScore,qualStruct.fnScore,qualStruct.fpScore);

            spikes.qualStruct = qualStruct;

            save(sprintf('%s/%s/Channel%d/Unit%d/Spikes.mat',myDir,file,ic,iu),'spikes');
            if exist('sessSpks','var'),
                sessSpks(length(sessSpks)+1) = spikes;
            else
                sessSpks = spikes;
            end
        end
    else
        fprintf('\n');
    end
end
        