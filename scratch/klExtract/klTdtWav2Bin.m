function klTdtWav2Bin(sessName,chans)

if nargin < 2
    chans = 1:32;
end

subj = sessName(1:(find(ismember(sessName,'-'),1)-1));

% sessDir = [tebaMount,'/data/Kaleb/antiSessions'];
sessDir = [tebaMount,'/data/',subj,'/proNoElongationColor_physio'];
% outDir = '/mnt/teba/Users/Kaleb/testTdtBins/';
outDir = [tebaMount,'/data/',subj,'/proNoElongationColor_physio_bins/'];

if ~exist([outDir,sessName]), mkdir([outDir,sessName]); end
%     f=fopen([outDir,sessName,'/AllChans.bin'],'w+');
    for i = chans
        try
            fprintf('Reading Channel %d...',i);
            % y=TDTbin2mat(fullfile(sessDir,sessName),'TYPE',{'streams'},'STORE','Wav1','CHANNEL',i);
            % y=TDTbin2mat(fullfile(sessDir,sessName),'STORE','Wav1','CHANNEL',i);
            y=SEV2mat(fullfile(sessDir,sessName),'CHANNEL',i);
            f=fopen([outDir,sessName,'/Chan',num2str(i),'.bin'],'w+');
            fprintf('Writing Channel %d...',i);
            % dat = y.streams.Wav1.data;
            dat = y.Wav1.data;
%             fseek(f,(i-1),'bof');
            fwrite(f,dat.*(2^16),'int16');
            fprintf('Done!\n');
            fclose(f);
        end
    end
%     fclose(f);
end