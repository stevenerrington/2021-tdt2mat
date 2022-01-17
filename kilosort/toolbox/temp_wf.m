function [averageWF, waveforms, channel] = temp_wf(nCh,st,clu,rootZ)

addpath(genpath(rootZ)) % path to Kilosort Data folder

tic
mmf = memmapfile([rootZ '\temp_wh.dat'], 'Format', 'int16'); % map raw binary data in file
fs = 24414.14;
templates = readNPY('templates.npy');
spike_templates = readNPY('spike_templates.npy');
nclu = max(clu); % number of clusters
waveforms = cell(1,nclu+1);
averageWF1 = cell(1,nclu+1);
fid = tdfread([rootZ '\cluster_group.tsv'],'tab');
cluster_groups = cellstr(fid.KSLabel);
good = {'good'};
ichannel = 0;

%% only find waveforms for clusters marked as "good" in phy
for unit = 1:nclu
    
    
    fprintf('cluster %d/%d\n',unit-1,nclu)
    toc
    
    theseST = st(clu==(unit-1)); % spike times for cluster
    
    cluspktemp = spike_templates(clu==(unit-1)); % original templates for clusters created in phy
    extractST = (double(theseST(1:length(theseST))))/fs; %extract all spikes, convert to double and seconds
    nWFsToLoad = length(extractST);
    wfWin = [-0.00075 0.0018]; % samples around the spike times to load (sec/sampling rate)(-30/fs 72/fs).
    nsamples = uint32(((abs(wfWin(1)) + wfWin(end))*fs)+1); % number of samples for each waveform
    theseWF = zeros(nsamples,nWFsToLoad);
    wfData = mmf.Data;
    
    %% identify which channel each cluster came from
    maxch = 0;
    maxts = 0;
    for ch = 1:nCh
        if unit < numel(templates(:,1,1))
            tempch = max(templates(unit,:,ch));
            if tempch > maxts
                maxts = tempch;
                maxch = ch;
            end
        else
            origtemplate = mode(cluspktemp) + 1;
            tempch = max(templates(origtemplate,:,ch));
            if tempch > maxts
                maxts = tempch;
                maxch = ch;
            end
        end
    end
    if maxch ~= 0
        ichannel = ichannel + 1;
        channel(ichannel) = maxch;
    end
    %% extract samples for each waveform
    for i=1:nWFsToLoad
        if extractST(i)> abs(wfWin(1))
            x1 = extractST(i)+wfWin(1)+1;                                   % time that first sample is taken from (sec)
            int1 = floor(x1);                                               % which second (row) in wfData to take first sample from
            dec1 = (x1 - int1);                                             % which sample within second to take (in seconds)
            dec1samp = uint64((dec1 *fs+1));                             % which sample within second to take (in samples)
            x2 = extractST(i)+wfWin(end)+1;                                 % time that last sample is taken from (sec)
            int2 = floor(x2);                                               % which second (row) in wfData to take last sample from
            dec2 = (x2 - int2);                                             % which sample within second to take (in seconds)
            dec2samp = uint64((dec2 *fs+1));                             % which sample within second to take (in samples)
            
            if int1 == int2 && (0<int1) && (int2<=length(wfData))           % if first and last sample are to be taken from the same second
                sampleSec = wfData(int1).x;
                if dec1samp > 0
                    tempWF = sampleSec(maxch,dec1samp:dec2samp);
                else
                    continue
                end
            elseif int1 ~= int2 && (0<int1) && (int2<=length(wfData))       % if first and last sample are to be taken from different seconds
                sampleSec1 = wfData(int1).x;
                if dec1samp >0
                    tempWF1 = sampleSec1(maxch,dec1samp:fs);
                    sampleSec2 = wfData(int2).x;
                    tempWF2 = sampleSec2(maxch,1:dec2samp);
                    tempWF = horzcat(tempWF1,tempWF2);                      % concatenate samples from different seconds together
                else
                    continue
                end
            else
                continue
            end
            
            tempWF = tempWF';
            theseWF(:,i) = tempWF; % waveform samples
        else
            continue % move on to next index
        end
    end
    
    waveforms{unit} = theseWF;                                          % creates cell structure with waveforms for each channel in each cell
    averageWF1{unit} = mean(waveforms{unit},2);                         % finds average waveform for each sample of each channel in cell structure
    waveforms = waveforms(~cellfun('isempty', waveforms));              % deletes empty cells
    averageWF = averageWF1(~cellfun('isempty',averageWF1));             % deletes empty (noise or MUA) clusters
    
end

fclose(fid);
toc