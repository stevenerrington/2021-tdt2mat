function klMergeSEV(subject,sessDate,varargin)

% Directories
rootDir = [tebaMount,'/data/',subject,'/proNoElongationColor_Sprobe'];

% SEV Type
sevType = 'Wav1';

% Decode varargin
varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'-t','type'}
            sevType = varargin{varStrInd(iv)+1};
    end
end


% Get the sessions
sess = dir([rootDir,filesep,subject,'*',sessDate,'*']);
sess(cellfun(@(x) contains(x,'Merged'),{sess.name})) = [];
for is = 1:length(sess)
    sessName = sess(is).name;
    dashes = strfind(sessName,'-');
    sessStartStr = sessName(dashes(2)+(1:6));
    sessStartSec(is) = str2double(sessStartStr(1:2))*3600+str2double(sessStartStr(3:4))*60+str2double(sessStartStr(5:6));
end
sessOffsets = sessStartSec-min(sessStartSec);
switch sevType
    case 'Wav1'
        sr = 24414;
    case 'Lfp1'
        load('slowSamplingRate.mat');
        sr = sampRate;
    otherwise
        load('slowSamplingRate.mat');
        sr = sampRate;
end
sessOffsetsSamples = sessOffsets.*sr;
        
% Get number of channels from the first session
nChans = length(dir([sess(1).folder,filesep,sess(1).name,'/*',sevType,'*.sev']));

mkdir(sprintf('%s/%s-%s-Merged',rootDir,subject,sessDate));

% Start channel loop
printStr = [];
for ic = 1:nChans
    fprintf(repmat('\b',1,length(printStr)));
    printStr = sprintf('Working on channel %d (of %d)...',ic,nChans);
    fprintf(printStr);
    mergedData = [];% zeros(10,1);
    saveName = [];
    nSamps = 0;
    % Start session loop
    for is = 1:length(sess)
        % Load SEV
        sev = dir([sess(is).folder,filesep,sess(is).name,'/*',sevType,'*Ch',num2str(ic),'.sev']);
        chanID = fopen(fullfile(sev.folder,sev.name),'r');
        chanDataWithHeader = fread(chanID,'single');
        fclose(chanID);
        if is ==1
            saveName = sev.name;
            chanData = chanDataWithHeader;
            mergedData = chanData;
            nSamps = nSamps+length(chanDataWithHeader);
        else
            chanData = chanDataWithHeader(11:end);
            nSamps = nSamps+length([zeros(round(sessOffsetsSamples(is)-(length(mergedData)-10)),1);chanData]);
            mergedData = [mergedData;zeros(round(sessOffsetsSamples(is)-(length(mergedData)-10)),1);chanData];
        end
    end
%     mergedData(1) = typecast(nSamps*4,'uint64');
    mergedData(1) = nSamps*4;
    % Write output file
    f=fopen(sprintf('%s/%s-%s-Merged/%s',rootDir,subject,sessDate,saveName),'w+');
    fwrite(f,mergedData,'single');
    fclose(f);
end
fprintf(repmat('\b',1,length(printStr)));
fprintf('Done!\n');    
    