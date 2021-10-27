

logIdx = find(not(cellfun('isempty',strfind(ephysLog.Session,outFilename))));

topCortexChannel = str2double(ephysLog.CtxTopChannel{logIdx});

EEGchannel = 1;% topCortexChannel - 3;


EEGdata = tdtLFP.aligned.(['LFP_' int2str(EEGchannel)]).saccade;

window = [-100:600];
trialsNC = ttx.noncanceled.all.all;
trialsGO = ttx.nostop.all.all;

figure;
plot(window,nanmean(EEGdata(trialsNC,window+1000)));
hold on
plot(window,nanmean(EEGdata(trialsGO,window+1000)));
legend({'NC','GO'})
set(gca,'YDir','Reverse')