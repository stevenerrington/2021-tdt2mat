function [header] = readHeader(obj)
    sevFile = obj.dataFiles{1};
    [~,filename,~] = fileparts(sevFile);
    fid = fopen(sevFile,'rb');
    header = [];
    header.fileSizeBytes   = fread(fid,1,'uint64');
    header.fileType        = char(fread(fid,3,'char')');
    header.fileVersion     = fread(fid,1,'char');
    % make some assumptions if we don't have a real header
    header.eventName        = getEventNameFromFile(filename);
    header.channelNum       = getChannelNumFromFile(filename);
    header.dForm = 'single';
    header.fs = 24414.0625;

    if header.fileVersion < 4
        if header.fileVersion == 3
            header.eventname = fread(fid, 4, 'char');
        else
            [~]              = fread(fid, 4, 'char');                    
        end
        header.channelNum        = fread(fid, 1, 'uint16');
        header.totalNumChannels  = fread(fid, 1, 'uint16');
        header.sampleWidthBytes  = fread(fid, 1, 'uint16');
        [~]                      = fread(fid, 1, 'uint16');
        % data format of stream in lower four bits
        header.dForm             = getDataFormat(fread(fid, 1, 'uint8'));

        header.decimate   = fread(fid, 1, 'uint8');
        header.rate       = fread(fid, 1, 'uint16');
        % compute actual sampling rate
        if header.fileVersion > 0
            header.fs = 2^(header.rate - 12) * 25000000 / header.decimate;
        else
        warning('%s has empty header; assuming ch %d format %s and fs = %.2f\nupgrade to OpenEx v2.18 or above\n', ...
            filename, header.channelNum, header.dForm, header.fs);
        end
        fclose(fid);
    else
        fclose(fid);
        error(['unknown version ' num2str(header.fileVersion)]);
    end    
end

function [eventName] = getEventNameFromFile(filename)
    s = regexp(filename, '_', 'split');
    if length(s) > 1
        eventName = s{end-1};
    else
        eventName = filename;
    end
end

function [channelNum] = getChannelNumFromFile(filename)
    matches = regexp(filename, '_[Cc]h[0-9]*', 'match');
    if ~isempty(matches)
        sss = matches{end};
        channelNum = str2double(sss(4:end));
    end
end

function [dataformat] = getDataFormat(code)
    % data formats
    ALLOWED_FORMATS = {'single','int32','int16','int8','double','int64'};
    % data format of stream in lower four bits
    dataformat = ALLOWED_FORMATS{bitand(code,7)+1};
end
