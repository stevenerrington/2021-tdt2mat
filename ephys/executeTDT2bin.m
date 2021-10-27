function executeTDT2bin(ops, forceFlag)

if forceFlag == 1
        fprintf('Converting Wav1_*.sev files for session [%s] to binary file [%s]...',ops.sessionName,ops.fbinary);
        convertTdt2Bin(ops);
        fprintf('done!\n');
else
    if exist(ops.fbinary, 'file')
        fprintf('Converted binary file exists\n');
        d = dir(ops.fbinary);
        s = evalc('[disp(d)]');
        fprintf('%s\n',s)
        % Otherwise, convert files (~ 2 mins)
    else
        fprintf('Converting Wav1_*.sev files for session [%s] to binary file [%s]...',ops.sessionName,ops.fbinary);
        convertTdt2Bin(ops);
        fprintf('done!\n');
    end
end

end
