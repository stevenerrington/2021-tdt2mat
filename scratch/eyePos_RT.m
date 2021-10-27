figure;
trials_nostop = ttx.nostop.all.all;
trials_noncanc = ttx.noncanceled.all.all;
RTdata = trialEventTimes.saccade - trialEventTimes.target;

plotWin = [-1000:2000];

subplot(2,1,1)
histogram(RTdata(trials_nostop),-1000:50:2000); hold on
histogram(RTdata(trials_noncanc),-1000:50:2000)
xlim([-100 1000])

subplot(2,1,2)

for ii = 1:length(trials_nostop)
tempLine = plot(plotWin, tdtEyes.X.target(trials_nostop(ii),:));
tempLine.Color=[0,0,0,0.05];
xlim([-100 1000]); ylim([-5 5])
hold on;
end

for ii = 1:length(trials_noncanc)
tempLine = plot(plotWin, tdtEyes.X.target(trials_noncanc(ii),:));
tempLine.Color=[0.8,0,0,0.25];
xlim([-100 1000]); ylim([-5 5])
hold on;
end


vline(0,'k')
vline(0+min(RTdata(trials_nostop)),'r')

plotWin = [-999:2000];

figure
plot(plotWin,nanmean(tdtEyes.Pupil.target(trials_noncanc,plotWin+1000)));
hold on
plot(plotWin,nanmean(tdtEyes.Pupil.target(trials_nostop,plotWin+1000)));
vline(0,'k'); xlim([-250 500])



figure

for ii = 1:length(trials_noncanc)
tempLine = plot(alignedEyeX_event(trials_noncanc(ii),plotWin+1000));
tempLine.Color=[0.8,0,0,0.25];

hold on;
end