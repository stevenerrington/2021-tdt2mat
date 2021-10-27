
% For batch or single session conversion of Wav1 or Rsn1 SEV files
monk = 'Joule';
baseDir = 'data/Joule/cmanding/ephys/TESTDATA/In-Situ';
sessionDirs = dir(fullfile(baseDir,[monk '*']));

for sno = 1:size(sessionDirs,1)
    sessName = sessionDirs(sno).name;
    ops.dataDir = fullfile(sessionDirs(sno).folder,sessName);
    
    ops.fbinary = fullfile(ops.dataDir,[sessName '.bin']);
    if exist(ops.fbinary, 'file')
        fprintf('Converted binary file exists\n');
        d = dir(ops.fbinary);
        s = evalc('[disp(d)]');
        fprintf('%s\n',s)
    else
        fprintf('Converting Wav1_*.sev filesfor session [%s] to binary file [%s]...',sessName,ops.fbinary);
        convertWav2Bin(ops);
        fprintf('done!\n');
    end
end
