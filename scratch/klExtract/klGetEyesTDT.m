function Eyes = klGetEyesTDT(sessName,varargin)

% Set defaults
fresh = 1;
rawDir = '/mnt/teba/data/Kaleb/antiSessions/';
% rawDir = '/mnt/teba/Users/Kaleb/proAntiRaw';
procDir = '/mnt/teba/Users/Kaleb/proAntiProcessed/';
doSave = 0;
print = 1;
doInvert = 1;

% Decode varargin
varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'-p','print'}
            print = varargin{varStrInd(iv)+1};
        case {'-f','fresh'}
            fresh = varargin{varStrInd(iv)+1};
        case {'-r','rawDir','rawdir'}
            rawDir = varargin{varStrInd(iv)+1};
        case {'-proc'}
            procDir = varargin{varStrInd(iv)+1};
        case {'-s','save'}
            doSave = varargin{varStrInd(iv)+1};
        case {'-i','invert'}
            doInvert = varargin{varStrInd(iv)+1};
    end
end

% Set up directory stuff
if ~ismember(sessName(end),['/','\']), sessName(end+1) = filesep;  end
if ismember(rawDir(end),['/','\']), fileName = [rawDir,sessName]; else fileName = [rawDir,filesep,sessName]; end
if ismember(procDir(end),['/','\']), saveDir = [procDir,sessName]; else saveDir = [procDir,filesep,sessName]; end

% Determine which TDT function to use
% if ispc
%     getFun = @TDT2mat;
% elseif isunix
    getFun = @TDTbin2mat;
% end

% Get eye positions
skipEyes = 0;
if exist(sprintf('%sEyes.mat',saveDir),'file') && ~fresh
    load(sprintf('%sEyes.mat',saveDir));
    if isfield(Eyes,'Good') && Eyes.Good==1
        skipEyes = 1;
    end
end
if ~skipEyes
%     try

        if print
            if exist('printStr','var')
                for ib = 1:length(printStr)
                    fprintf('\b');
                end
            end
            printStr = 'Getting Eye X...';
            fprintf(printStr);
        end
        eyeXRaw = getFun(fileName,'TYPE',{'streams'},'STORE','EyeX','VERBOSE',0);
        if print
            for ib = 1:length(printStr)
                fprintf('\b');
            end
            printStr = 'Getting Eye Y...';
            fprintf(printStr);
        end
        eyeYRaw = getFun(fileName,'TYPE',{'streams'},'STORE','EyeY','VERBOSE',0);
        if doInvert
            eyeX = eyeYRaw.streams.EyeY.data;%.*(3);
            eyeY = -eyeXRaw.streams.EyeX.data;%.*(-3);
        else
            eyeX = eyeXRaw.streams.EyeX.data;%.*3;
            eyeY = -eyeYRaw.streams.EyeY.data;%.*(-3);
        end
        minLen = min([length(eyeX),length(eyeY)]);
        eyeX = eyeX(1:minLen);
        eyeY = eyeY(1:minLen);
%         eyeT = (0:(length(eyeX)-1)).*(1000/eyeXRaw.streams.EyeX.fs);
        eyeT = (1:length(eyeX)).*(1000/eyeXRaw.streams.EyeX.fs);
        eyeR = sqrt(eyeX.^2 + eyeY.^2);
        eyeThRaw = klRad2Deg(atan(abs(eyeY)./abs(eyeX)));
        eyeTh = nan(size(eyeThRaw));
        eyeTh(eyeX > 0 & eyeY > 0) = eyeThRaw(eyeX > 0 & eyeY > 0);
        eyeTh(eyeX < 0 & eyeY > 0) = 180-eyeThRaw(eyeX < 0 & eyeY > 0);
        eyeTh(eyeX < 0 & eyeY < 0) = 180+eyeThRaw(eyeX < 0 & eyeY < 0);
        eyeTh(eyeX > 0 & eyeY < 0) = 360-eyeThRaw(eyeX > 0 & eyeY < 0);
        Eyes.X = eyeX;
        Eyes.Y = eyeY;
        Eyes.R = eyeR;
        Eyes.Theta = eyeTh;
        Eyes.Times = eyeT;
        [Eyes.saccStarts, Eyes.saccEnds] = klSaccDetectNew(Eyes.X,Eyes.Y,Eyes.Times);
        Eyes.Good = 1;
        if print
            for ib = 1:length(printStr)
                fprintf('\b');
            end
            printStr = 'Saving Eyes...';
            fprintf(printStr);
        end
        if doSave
            save(sprintf('%sEyes.mat',saveDir),'Eyes');
        end
        clear eyeXRaw eyeYRaw eyeX eyeY eyeT eyeR eyeThRaw eyeTh
        
%     catch
%         Eyes.X = nan;
%         Eyes.Y = nan;
%         Eyes.R = nan;
%         Eyes.Theta = nan;
%         Eyes.Times = nan;
%         Eyes.Good = 0;
%     end
end
