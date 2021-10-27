function fs = G_FS(inp)
 
if strcmp(inp, 'fast')
    fs = 24414.0625;
elseif strcmp(inp, 'slow')
    fs = 1017.2526;
end
 
end