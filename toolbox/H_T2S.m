function s = H_T2S(t, fs, varargin)
 
u = 'ms';
 
varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'-u','unit'}
            u = varargin{varStrInd(iv)+1};
    end
end
 
switch u
    case 'ms'
        s = round(t * fs / 1000);
    case 's'
        s = round(t * fs);
end
 
end