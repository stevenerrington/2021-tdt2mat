//--------------------------------------------------------------------------------------------------------------
// Wait a user defined number if micro-seconds.  (Just like wait() but
// with micro instead of milli senoncds and obviously needing a spawnwait
// statement before it.
//
// ripped off by david.c.godlove@vanderbilt.edu   January, 2011

declare WAIT_MU(int u_sec);


process WAIT_MU(int u_sec)                      // uSec between 1 and 1000
{
    int start, duration, clock_cycles;

    // Convert uSec to 1192000 Hz hardware clock cycles (this is approximate).
    // The PC clock does not count in true uSec.  It counts at a rate around
    // 1192000 Hz (give or take based on many variables).  Yours may differ
    // from this estimate.  To find out use...
    // time1 = timeus();
    // nexttick;
    // time2 = timeus();
    // cycles_per_ms = ((time2 - time1)/asets)/1000.0;
    // NOTE: This answer will be variable, so try it several times before...
    // ...settling on an answer for good.
    // see pg 6-94.
    clock_cycles = u_sec * 1.192;
    start        = timeus();
    duration     = 0;
    while (duration < clock_cycles)
    {
        duration = (timeus() - start) & 0xFFFF;
    }
}
