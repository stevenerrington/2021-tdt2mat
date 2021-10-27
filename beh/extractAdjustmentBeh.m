function [valueBeh] = extractAdjustmentBeh(Infos,ttx)

    RTdata = Infos.Decide_ - Infos.Target_;

    % No-stop (hi & lo)
    valueBeh.dist.nostop.hi = RTdata(ttx.nostop.all.hi);
    valueBeh.dist.nostop.lo = RTdata(ttx.nostop.all.lo);

    % Non-canceled (hi & lo)
    valueBeh.dist.noncanceled.hi = RTdata(ttx.noncanceled.all.hi);
    valueBeh.dist.noncanceled.lo = RTdata(ttx.noncanceled.all.lo);

    % All (hi & lo)
    valueBeh.dist.all.hi = RTdata([ttx.nostop.all.hi;ttx.noncanceled.all.hi]);
    valueBeh.dist.all.lo = RTdata([ttx.nostop.all.lo;ttx.noncanceled.all.lo]);

    % Summary values
    valueBeh.summaryData = table();
    valueBeh.summaryData.nostop_hi = mean(valueBeh.dist.nostop.hi);
    valueBeh.summaryData.nostop_lo = mean(valueBeh.dist.nostop.lo);
    valueBeh.summaryData.noncanc_hi = mean(valueBeh.dist.noncanceled.hi);
    valueBeh.summaryData.noncanc_lo = mean(valueBeh.dist.noncanceled.lo);
    valueBeh.summaryData.all_hi = mean(valueBeh.dist.all.hi);
    valueBeh.summaryData.all_lo = mean(valueBeh.dist.all.lo);
    
    valueBeh.statisticFlags = table();
    valueBeh.statisticFlags.all = ttest2(valueBeh.dist.all.hi,valueBeh.dist.all.lo);
    valueBeh.statisticFlags.noncanc = ttest2(valueBeh.dist.noncanceled.hi,valueBeh.dist.noncanceled.lo);    
    valueBeh.statisticFlags.nostop = ttest2(valueBeh.dist.nostop.hi,valueBeh.dist.nostop.lo);    
    
    valueBeh.cdf.nostop_hi = cumulDist(valueBeh.dist.nostop.hi);
    valueBeh.cdf.nostop_lo = cumulDist(valueBeh.dist.nostop.lo);
    valueBeh.cdf.noncanc_hi = cumulDist(valueBeh.dist.noncanceled.hi);
    valueBeh.cdf.noncanc_lo = cumulDist(valueBeh.dist.noncanceled.lo);
    valueBeh.cdf.all_hi = cumulDist(valueBeh.dist.all.hi);
    valueBeh.cdf.all_lo = cumulDist(valueBeh.dist.all.lo);
    


end
