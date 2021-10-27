//==========================================================================
// TEST_SSD.PRO
//   Description: Run a countermanding SSD test by showing sequence of related pages
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2018-09-06
//==========================================================================
//  Revision History:
//
//==========================================================================

// DECLARE PROCESS
//==========================================================================
// Use variables on the fly - no declaration
#pragma declare = 1
declare SETUP_SCRN_CLRS_PGS();
declare SETUP_DATA_ACQ_PARMS();
declare ESTMT_MS_PER_TICK();
declare WTCH_SCHMITT();
declare WTCH_EYE();

declare TEST_SSD();

declare int DEBUG_CONSOLE=1;
declare float MS_PER_TICK;
declare int   ASETS            = 1;
declare float FIX_SIZE         = 0.5;
declare int   VERT_RFRSH_COUNT = 0;
declare int   VERT_RFRSH_SSD   = 0;
declare int   TRL_NUM          = 0;
declare int   BREAK_FIX_FLAG   = 0;

declare constant int DEBUG_PD      = 0;
declare constant int WRITE_PD_FILE = 1;
declare int          PD_TRIG_L     = 0;
declare int          PD_TRIG_R     = 0;
declare int          PD_THRESHOLD  = 500;



// RIG variables
#include C:/TEMPO/ProcLib/RIG/VAR_RIG.PRO
// Room variables
#include C:/TEMPO/ProcLib/TEST/TEST_029.PRO
// Screen parameters including isoluminant colors,
#include C:/TEMPO/ProcLib/UTIL/SET_SCRN.PRO
// Set palatte colors for countermanding
#include C:/TEMPO/ProcLib/TEST/TEST_CLRS.PRO
// set pages to load CMD_PGS.PRO?
#include C:/TEMPO/ProcLib/TEST/TEST_PGS.PRO
// GLOBAL variables for color:
//==========================================================================


// Run as default
process TEST_SSD() enabled
{
    declare int   maxTrialCount     = 10000;
    declare int   minWaitTicks      = 200;
    declare int   maxSsdRefresh     = 40;
    declare int   startTime         = 0;
    declare int   stopTime          = 0;
    declare int   ssdTime           = 0;
    declare float ssdTimeExpected   = 0.0;
    declare int   currWaitTicks     = 0;
    declare int   currBreakFix      = 0;
    declare int   currWatchEyeTicks = 0;
    declare int   ticks             = 0;
    declare int   trlRunning        = 1;

    printf("Running TEST_SSD\n");
    spawnwait ESTMT_MS_PER_TICK();
    spawnwait SETUP_SCRN_CLRS_PGS();
    spawnwait SETUP_DATA_ACQ_PARMS();
    //spawn WTCH_PD_SCHMITT();
    spawn WTCH_SCHMITT();
    spawn WTCH_EYE();

    TRL_NUM = 0;
    while(1)
    {
        // show both right and left PD
        dsendf("vp %d\n", PAGE_TEST_PD);
        nexttick 10000;
    }
    //while(1)
    //{
    // dsendf("vp %d\n", PAGE_FIX_PD);
    // nexttick 80;
    // dsendf("vp %d\n", PAGE_STOP_SIGNAL_PD);
    //  nexttick 5;
    //}
    nexttick 1000;
    while (TRL_NUM < maxTrialCount + 1 && trlRunning == 1)
    {
        TRL_NUM = TRL_NUM + 1;
        dsendf("vp %d\n", PAGE_BLANK);
        ticks             = 0;
        VERT_RFRSH_COUNT  = 0;
        VERT_RFRSH_SSD    = (random(maxSsdRefresh) + 1) * 1;//2-60
        ssdTimeExpected   = VERT_RFRSH_SSD * REFRESH_RATE;
        currBreakFix      = BREAK_FIX_FLAG;
        currWatchEyeTicks = random(25) * 40 + 100;
        dsendf("vp %d\n", PAGE_FIX_PD);
        startTime = time();
        stopTime  = startTime;
        while (trlRunning && VERT_RFRSH_COUNT < VERT_RFRSH_SSD)
        {
            // queue command to VideoSYNC refresh screen
            //dsendf("VW %d\n", 1);
            // VERT_RFRSH_COUNT = VERT_RFRSH_COUNT + 1;
            // Lets us count left Trigs
            if (PD_TRIG_L)
            {
                VERT_RFRSH_COUNT = VERT_RFRSH_COUNT + 1;
                // do not count for 5 ticks
                // as the trig will be on for about 3 ms
                nexttick 2;
            }
            // expire some random no. ticks before deciding broke fix state
            if (ticks < currWatchEyeTicks)
            {
                ticks = ticks + 1;
                // nexttick;
            }
            // check eye state
            if (currBreakFix == 1 && ticks > currWatchEyeTicks - 1)
            {
                dsendf("vp %d\n", PAGE_BLANK);
                trlRunning = 0;
            }
            nexttick;
        }
        if (trlRunning)  // ie no Break fixation...
        {
            dsendf("vp %d\n", PAGE_STOP_SIGNAL_PD);
            while (!PD_TRIG_R)
            {
                nexttick;
            }
            dsendf("vp %d\n", PAGE_BLANK);
        }
        stopTime        = time();
        ssdTime         = stopTime - startTime;
        ssdTimeExpected = VERT_RFRSH_SSD * REFRESH_RATE;
        currWaitTicks   = random(20) * 30 + minWaitTicks;
        // complete ISI...?
        nexttick currWaitTicks;
        trlRunning = 1;
        // Update User
        if (currBreakFix == 1)
        {
            printf("===BROKE FIX====\n");
        }
        else
        {
            printf("===OK OK OK====\n");
        }
        printf("TRL %d, V_RFRSH_SSD [%d], V_RFRSH_COUNT [%d], ssdTime [%d], ssdExpec [%d], isiTicks [%d], eyeTicks [%d], breakFix [%d]\n", TRL_NUM,VERT_RFRSH_SSD,VERT_RFRSH_COUNT,ssdTime,ssdTimeExpected,currWaitTicks,currWatchEyeTicks,currBreakFix);
        writef("testSSDR.csv %d,%d,%d,%d,%d,%d,%d,%d\n", TRL_NUM, VERT_RFRSH_SSD, VERT_RFRSH_COUNT, ssdTime, ssdTimeExpected,currWaitTicks,currWatchEyeTicks,currBreakFix);
    }
} /* TEST_SSD */


process SETUP_SCRN_CLRS_PGS()
{
    // make sure vdosync is in correct config
    // Check in set_scrn.pro 1024 x 768
    //dsend("vi 261;");
    dsend("vi 256;");
    // flush all vdosync memory
    dsend("ca");
    // Set up pages
    spawnwait SET_SCRN();
    spawnwait TEST_SET_DEFAULT_COLORS();
    spawnwait TEST_PGS();

    nexttick 5000;
}


process SETUP_DATA_ACQ_PARMS()
{
    printf("SETUP_DATA_ACQ_PARMS...");
}

process WTCH_SCHMITT()
{
    declare float pdValL = 5000;
    declare float pdValR = 5000;

    while (1)
    {
        pdValL = atable(PHOTOCELL_L_CHANNEL);
        pdValR = atable(PHOTOCELL_R_CHANNEL);
        if (pdValL < PD_THRESHOLD && PD_TRIG_L == 0)
        {
            PD_TRIG_L = 1;
        }
        else if (pdValL > PD_THRESHOLD && PD_TRIG_L == 1)
        {
            PD_TRIG_L = 0;
        }
        // PD Right
        if (pdValR < PD_THRESHOLD && PD_TRIG_R == 0)
        {
            PD_TRIG_R = 1;
        }
        else if (pdValR > PD_THRESHOLD && PD_TRIG_R == 1)
        {
            PD_TRIG_R = 0;
        }
        if (WRITE_PD_FILE)
        {
            writef("pdValsSc.csv %d,%d,%d,%d\n", pdValL, pdValR, PD_TRIG_L, PD_TRIG_R);
        }
        if (DEBUG_PD)
        {
            printf("%d,%d,%d,%d\n", pdValL, pdValR, PD_TRIG_L, PD_TRIG_R);
        }
        nexttick;
    }
}


process WTCH_EYE()
{
    while (1)
    {
        BREAK_FIX_FLAG = random(2);
        nexttick;
    }
}


process ESTMT_MS_PER_TICK()
{
    declare float temp = 0.0;
    declare int   i = 1;
    declare int   n = 1000;
    declare float time1, time2;

    while (i < 100)
    {
        // Take a mean after several tries see: 6-94
        time1 = timeus();
        nexttick;
        time2 = timeus();
        temp  = temp + ((time2 - time1)/ASETS)/1000.0;
        i     = i + 1;
        //printf("temp %0.5d\n",temp);
        //nexttick random(20);
    }
    MS_PER_TICK = temp/n;
    printf("*****CYCLES_PER_MS %2.5d*****\n", MS_PER_TICK);
}
