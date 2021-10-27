//==========================================================================
// TARG_SSD.PRO
//   Description: Process Target On State for STOP Trial
//                Eye has to HOLD fixation till TRL_USE_SSD_VR_COUNT + TRL_USE_SSD_CANCEL_DURATION.
//                After TRL_USE_SSD_VR_COUNT, PG_SIGNAL_PD is shown (TRL_IS_STOP_SIGNAL_ON =1)
//                Gaze has to be in FIX_WIN for the whole duration for the successful Cancel trial.
//                If Gaze out of Fix win before time expires, then subject made a NoGo type Saccade
//                based on MIN_SACC_TIME and MAX_SACC_TIME
// Gaze Check:
// Fixspot is OFF Target is ON:
// Check: Gaze in FIX window until MIN_SACCADE_TIME expires, else it is early saccade
//        Gaze left FIX_WIN before MAX_SACCADE_TIME, then correct saccade, else no saccade
// Check:
//   case 0: TRL_USE_SSD_VR_COUNT has not expired
//                   if gaze out of FIX-WIN before MIN_SACC_TIME --> EVT_NOGO_EARLY_SACCADE_, goto STAT_OUTCOME
//                   if gaze out of FIX-WIN after MIN_SACC_TIME and before MAX_SACC_TIME --> NoGoEVT_SACCADE_, goto STAT_TARG_ACQ
//                   if gaze out of FIX-WIN after MAX_SACC_TIME --> EVT_NOGO_LATE_SACCADE_, goto STAT_OUTCOME
//   case 1: TRL_USE_SSD_VR_COUNT has expired and TRL_USE_SSD_CANCEL_DURATION has not expired
//   [Stop Signal ON] show PG_SIGNAL_PD (PD on RIGHT) for 1 screen refresh and switch to PG_SIGNAL(PD on LEFT)
//                   if gaze out of FIX-WIN before MIN_SACC_TIME --> EVT_NOGO_EARLY_SACCADE_, goto STAT_OUTCOME
//                   if gaze out of FIX-WIN after MIN_SACC_TIME and before MAX_SACC_TIME --> NoGoEVT_SACCADE_, goto STAT_TARG_ACQ
//   [Stop Signal OFF] switch page from PG_SIGNAL to PG_TARGET_PD (do nto show stop signal)
//                   if gaze out of FIX-WIN after MAX_SACC_TIME --> EVT_NOGO_LATE_SACCADE_, goto STAT_OUTCOME
//
//                All Global variables and the following state variables are available to monitor state progress
//                1. PROCESS_STATE : Setup state processing, will be done once per call
//                1. CURR_STAT :


//                4. STAT_DLTA_T : Length of time in this state (in ticks/ms)
//                5. STAT_ALLOWED_T : Max time for staying in this state
//                5. STAT_I_DURATION : If saccade occurs, it must complete in this time
//
//   NOTE:
//
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-01-25
//==========================================================================
//  Revision History:

declare PROC_TARG_SSD();
declare PRINT_MSG();
declare SSD_CHECK_SACC();


process PROC_TARG_SSD()
{
    declare int queuedStopSignalPage;

    if (PROCESS_STATE)
    {
        TRL_TARGET_PRE_TIME = time();
        spawn SEND_EVT(EVT_TARGET_PRE_);

        dsendf("vp %d\n", PG_TARGET_PD);
        spawn GRAF_SHOW_FIX(GRAF_HIDE);
        spawn GRAF_SHOW_TARG(GRAF_SHOW);

        PROCESS_STATE    = 0;
        STAT_DLTA_T      = 0;
        STAT_STRT_T      = TRL_TARGET_PRE_TIME;
        STAT_I_DURATION  = MIN_SACC_TIME * TIME_DILATE_FACTOR;
        STAT_I_DURATION2 = MAX_SACC_TIME * TIME_DILATE_FACTOR;
        //STAT_ALLOWED_T          = ceil(TRL_USE_SSD_VR_COUNT * REFRESH_RATE * TIME_DILATE_FACTOR);
        // in refresh counts
        STAT_ALLOWED_T = TRL_USE_SSD_VR_COUNT * TIME_DILATE_FACTOR;

        // TEMP_DELY_PLUS_DURATION = STAT_ALLOWED_T + (TRL_USE_SSD_CANCEL_DURATION * TIME_DILATE_FACTOR);
        TEMP_DELY_PLUS_DURATION = ceil(TRL_USE_SSD_VR_COUNT * REFRESH_RATE * TIME_DILATE_FACTOR) + (TRL_USE_SSD_CANCEL_DURATION * TIME_DILATE_FACTOR);

        // initialize durations
        TRL_CANCEL_DURATION      = 0;
        TRL_STOP_SIGNAL_DURATION = 0;

        TRL_TARG_VR_COUNT     = 0;
        queuedStopSignalPage  = 0;
        TRL_IS_STOP_SIGNAL_ON = 0;
        TRL_IS_CANCEL         = 0;
        TRL_IS_TARGET_ON      = 0;
    }

    spawnwait CHECK_TARG_VERT_RFRSH();

    // keep track of stop signal duration in ms and in vertical refresh count
    if (TRL_IS_STOP_SIGNAL_ON <= 0 && TRL_TARG_VR_COUNT > 0)
    {
        TRL_SSD_VR_COUNT         = TRL_TARG_VR_COUNT;
        TRL_STOP_SIGNAL_DURATION = TRL_STOP_SIGNAL_DURATION + 1;
    }

    // keep track of target vertical refresh count
    if (TRL_TARG_VR_COUNT == 1 && TRL_TARGET_TIME <= 0)
    {
        TRL_IS_TARGET_ON = 1;
        TRL_TARGET_TIME  = time();
        spawn SEND_EVT(EVT_TARGET_);

        TRL_FIX_SPOT_OFF_TIME = time();
        spawn SEND_EVT(EVT_FIX_SPOT_OFF_);

        if
        (DEBUG_CONSOLE)
        {
            printf("****STAT_TARG_SSD[%d]: Sent Event EVT_TARGET_[%d], Time [%d]\n", STAT_TARG_SSD, EVT_TARGET_, TRL_TARGET_TIME);
            printf("****STAT_TARG_SSD[%d]: Sent Event EVT_FIX_SPOT_OFF_[%d], Time [%d]\n", STAT_TARG_SSD, EVT_FIX_SPOT_OFF_, TRL_TARGET_TIME);
        }
    }
    if (TRL_IS_STOP_SIGNAL_ON)
    {
        if (TRL_STOP_SIGNAL_TIME <= 0)
        {
            TRL_STOP_SIGNAL_TIME = time();
            spawn SEND_EVT(EVT_STOP_SIGNAL_);
            spawn GRAF_SHOW_FIX(GRAF_SHOW);

            if (DEBUG_CONSOLE)
            {
                printf("****STAT_TARG_SSD[%d]: OK sent Event: EVT_STOP_SIGNAL_[%d], Time [%d]\n", STAT_TARG_SSD, EVT_STOP_SIGNAL_, TRL_STOP_SIGNAL_TIME);
            }
        }
        TRL_CANCEL_DURATION = TRL_CANCEL_DURATION + 1;
        if (TRL_CANCEL_START_TIME <= 0)
        {
            TRL_CANCEL_START_TIME = time();
            spawn SEND_EVT(EVT_CANCEL_START_);

            if (DEBUG_CONSOLE)
            {
                printf("****STAT_TARG_SSD[%d]: OK sent Event: EVT_CANCEL_START_[%d],Time [%d]\n", STAT_TARG_SSD, EVT_CANCEL_START_, TRL_CANCEL_START_TIME);
            }
        }
    }

    if (TRL_TARG_VR_COUNT < STAT_ALLOWED_T)    // || TRL_TARG_VR_COUNT < TRL_USE_SSD_VR_COUNT)
    {
        // till it is time to show stop signal
        if (!I_FIX)
        {
            spawnwait SSD_CHECK_SACC();
        }
    }
    else if (STAT_DLTA_T < TEMP_DELY_PLUS_DURATION)
    {
        // from SSD till it is time to expire Cancel time for trial to be considered successful cancel
        if (!queuedStopSignalPage)
        {
            queuedStopSignalPage = 1;
            dsendf("vp %d\n", PG_SIGNAL_PD);
            if (DEBUG_CONSOLE)
            {
                printf("****STAT_TARG_SSD[%d]: OK (*Stop signal page sent*)[%d]/[%d] (TRL_STOP_SIGNAL_DURATION)\n", STAT_TARG_SSD, STAT_DLTA_T, TRL_STOP_SIGNAL_DURATION);
            }
        }

        // till Cancel time is expired and the stop signal is shown
        if (!I_FIX)
        {
            spawnwait SSD_CHECK_SACC();
        }
    }
    else if (STAT_DLTA_T >= TEMP_DELY_PLUS_DURATION)
    {
        // if reached here then it is a successful cancel  trial
        if (I_FIX)
        {
            TRL_CANCEL_TIME = time();
            TRL_IS_CANCEL   = 1;

            spawn SEND_EVT(EVT_CANCEL_);

            TRL_CANCEL_END_TIME = time();
            spawn SEND_EVT(EVT_CANCEL_END_);

            if (DEBUG_CONSOLE)
            {
                printf("****STAT_TARG_SSD[%d]: OK sent Event: EVT_CANCEL_[%d],Time [%d]\n", STAT_TARG_SSD, EVT_CANCEL_, TRL_CANCEL_TIME);
                printf("****STAT_TARG_SSD[%d]: OK sent Event: EVT_CANCEL_END_[%d],Time [%d]\n", STAT_TARG_SSD, EVT_CANCEL_, TRL_CANCEL_END_TIME);
            }
            printf("****STAT_TARG_SSD[%d]: OK (EVT_CANCEL_ in)[%d]/[%d](TRL_USE_SSD_VR_COUNT + TRL_USE_SSD_CANCEL_DURATION)\n", STAT_TARG_SSD, STAT_DLTA_T, TEMP_DELY_PLUS_DURATION);

            spawn PRINT_MSG();

            PROCESS_STATE = 1;
            CURR_STAT     = STAT_TONE_SSD;
        }
        else
        {
            spawnwait SSD_CHECK_SACC();
        }
    }
} /* PROC_TARG_SSD */


process SSD_CHECK_SACC()
{
    // Flip page to PG_TARG_PD and continue as a GO trial
    if (DEBUG_CONSOLE)
    {
        printf("****STAT_TARG_SSD[%d]: NoGo correct saccade, continue as Go trial. Flipping page to PG_TARGET_PD\n", STAT_TARG_SSD);
    }
    dsendf("vp %d\n", PG_TARGET_PD);
    //dsendf("vw 1\n");
    spawn GRAF_SHOW_FIX(GRAF_HIDE);
    spawn GRAF_SHOW_TARG(GRAF_SHOW);
    spawn PRINT_MSG();

    if (STAT_DLTA_T <= STAT_I_DURATION)
    {
        // Early saccade
        TRL_IS_I_IN_FLIGHT          = 1;
        TRL_NOGO_EARLY_SACCADE_TIME = time();
        spawn SEND_EVT(EVT_NOGO_EARLY_SACCADE_);

        if (DEBUG_CONSOLE)
        {
            printf("****STAT_TARG_SSD[%d]: ERR sent Event: EVT_NOGO_EARLY_SACCADE_[%d]\n", STAT_TARG_SSD, EVT_NOGO_EARLY_SACCADE_);
        }
        printf("****STAT_TARG_SSD[%d]: ERR (*NoGo Early Saccade*)[%d]/[%d] (MIN_SACC_TIME)\n", STAT_TARG_SSD, STAT_DLTA_T, STAT_I_DURATION);
        PROCESS_STATE = 1;
        CURR_STAT     = STAT_OUTCOME;
        spawn PRINT_MSG();
    }
    else if (STAT_DLTA_T > STAT_I_DURATION && STAT_DLTA_T <= STAT_I_DURATION2)
    {
        TRL_IS_I_IN_FLIGHT = 1;

        if (TRL_IS_STOP_SIGNAL_ON > 0)
        {
            TRL_NOGO_SACCADE_POST_SSD_TIME = time();
            spawn SEND_EVT(EVT_NOGO_SACCADE_POST_SSD_);

            if (DEBUG_CONSOLE)
            {
                printf("****STAT_TARG_SSD[%d]: ERR sent Event: EVT_NOGO_SACCADE_POST_SSD_[%d]\n", STAT_TARG_SSD, EVT_NOGO_SACCADE_POST_SSD_);
            }
            printf("****STAT_TARG_SSD[%d]: ERR: (*NoGo Saccade**After SSD*)[%d]/[%d, %d] (MIN_SACC_TIME, MAX_SACC_TIME)\n", STAT_TARG_SSD, STAT_DLTA_T, STAT_I_DURATION, STAT_I_DURATION2);

            TRL_USE_POST_SSD_FIX_ON_DELAY = STAT_DLTA_T - ceil((STAT_ALLOWED_T * REFRESH_RATE));
            // How long *after* SSD did saccade happen (before MAX_SACC_TIME), since we know when SSD happened, use actual stop signal time
            if (TRL_STOP_SIGNAL_TIME > 0)
            {
                TRL_USE_POST_SSD_FIX_ON_DELAY = TRL_NOGO_SACCADE_POST_SSD_TIME - TRL_STOP_SIGNAL_TIME;
            }
            // set the fix-spot turn back on to what user wants; will start out as 0
            if (TRL_USE_POST_SSD_FIX_ON_DELAY * TIME_DILATE_FACTOR < POST_SSD_FIX_ON_DELAY)
            {
                TRL_IS_FIX_REIGNITE = FIX_REIGNITE_FLAG;
            }
        }
        else
        {
            TRL_NOGO_SACCADE_PRE_SSD_TIME = time();
            spawn SEND_EVT(EVT_NOGO_SACCADE_PRE_SSD_);

            if (DEBUG_CONSOLE)
            {
                printf("****STAT_TARG_SSD[%d]: ERR sent Event: EVT_NOGO_SACCADE_PRE_SSD_[%d]\n", STAT_TARG_SSD, EVT_NOGO_SACCADE_PRE_SSD_);
            }
            printf("****STAT_TARG_SSD[%d]: ERR: (*NoGo Saccade**Before SSD*)[%d]/[%d, %d] (MIN_SACC_TIME, MAX_SACC_TIME)\n", STAT_TARG_SSD, STAT_DLTA_T, STAT_I_DURATION, STAT_I_DURATION2);

            // How long *before* SSD did saccade happen (before MAX_SACC_TIME), since we do not have stop signal use possible stop signal time
            TRL_USE_PRE_SSD_FIX_ON_DELAY = ceil((STAT_ALLOWED_T * REFRESH_RATE * TIME_DILATE_FACTOR) - STAT_DLTA_T);
            // set the fix-spot turn back on to what user wants; will start out as 0
            if (TRL_USE_PRE_SSD_FIX_ON_DELAY * TIME_DILATE_FACTOR < PRE_SSD_FIX_ON_DELAY)
            {
                TRL_IS_FIX_REIGNITE = FIX_REIGNITE_FLAG;
            }
        }
        PROCESS_STATE = 1;
        CURR_STAT     = STAT_TARG_ACQ;
        spawn PRINT_MSG();
    }
    else if (STAT_DLTA_T > STAT_I_DURATION2)
    {
        // Late saccade
        TRL_IS_I_IN_FLIGHT         = 1;
        TRL_NOGO_LATE_SACCADE_TIME = time();
        spawn SEND_EVT(EVT_NOGO_LATE_SACCADE_);

        if (DEBUG_CONSOLE)
        {
            printf("****STAT_TARG_SSD[%d]: ERR sent Event: EVT_NOGO_LATE_SACCADE_[%d]\n", STAT_TARG_SSD, EVT_NOGO_LATE_SACCADE_);
        }
        printf("****STAT_TARG_SSD[%d]: ERR (*NoGo Late Saccade*)[%d]/[%d] (MAX_SACC_TIME)\n", STAT_TARG_SSD, STAT_DLTA_T, STAT_I_DURATION2);
        PROCESS_STATE = 1;
        CURR_STAT     = STAT_TARG_ACQ;
        spawn PRINT_MSG();
    }
}/* SSD_CHECK_SACC */


process PRINT_MSG()
{
    declare int dummy;

    dummy = 0;
    if (DEBUG_CONSOLE)
    {
        printf("****STAT_TARG_SSD[%d]: STOP TRIAL; TRL_USE_SSD_VR_COUNT = (TRL_USE_SSD_VR_COUNT * REFRESH_RATE)\n", STAT_TARG_SSD);
        printf("****STAT_TARG_SSD[%d]: Expected SSD = TRL_USE_SSD_VR_COUNT[%d, %dms]\n", STAT_TARG_SSD, TRL_USE_SSD_VR_COUNT * TIME_DILATE_FACTOR, STAT_ALLOWED_T);
        printf("****STAT_TARG_SSD[%d]: SSD (using nexttick count)  = TRL_STOP_SIGNAL_DURATION[%d, %dms],  \n", STAT_TARG_SSD, TRL_TARG_VR_COUNT,
               TRL_STOP_SIGNAL_DURATION);
        printf("****STAT_TARG_SSD[%d]: SSD (using SSD Vertical Refresh count) TRL_SSD_VR_COUNT[%d, %dms] \n", STAT_TARG_SSD, TRL_SSD_VR_COUNT,
               ceil(TRL_SSD_VR_COUNT * REFRESH_RATE));
        printf("****STAT_TARG_SSD[%d]: SSD + CANCEL TIME [%d + %d] = [%dms] \n", STAT_TARG_SSD,
               ceil(TRL_USE_SSD_VR_COUNT * REFRESH_RATE * TIME_DILATE_FACTOR), (TRL_USE_SSD_CANCEL_DURATION * TIME_DILATE_FACTOR), TEMP_DELY_PLUS_DURATION);
        printf("****STAT_TARG_SSD[%d]: Target ON duration   = TRL_TARG_ON_DURATION [%dms],  \n", STAT_TARG_SSD, TRL_TARG_ON_DURATION);
        printf("****STAT_TARG_SSD[%d]: Target ON duration (using Vertical Refresh count) TRL_TARG_VR_COUNT[%d, %dms] \n", STAT_TARG_SSD,
               TRL_TARG_VR_COUNT, ceil(TRL_TARG_VR_COUNT * REFRESH_RATE));
    }
}/* PRINT_MSG */
