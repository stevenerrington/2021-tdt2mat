//==========================================================================
// TARG_HLD.PRO
//   Description: Process Hold target State
//                Eye has to HOLD target for minimum target hold time.
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
//   Date: 2019-03-18
//==========================================================================
//  Revision History:

declare PROC_TARG_HOLD();


process PROC_TARG_HOLD()
{
    if (PROCESS_STATE)
    {
        // actually TRL_ACQUIRE_FIX_TIME, however the below is practically
        //same and it keeps this state independent of previous state
        PROCESS_STATE = 0;

        STAT_DLTA_T = 0;

        STAT_ALLOWED_T = TRL_USE_MIN_THT_DURATION * TIME_DILATE_FACTOR;

        // always send even if TRL_USE_XTRA_HOLD_DURATION = 0
        TRL_MIN_THT_START_TIME = time();
        spawn SEND_EVT(EVT_MIN_THT_START_);

        if (DEBUG_CONSOLE)
        {
            printf("****STAT_TARG_HOLD[%d]: OK sent Event: EVT_MIN_THT_START_[%d]\n", STAT_TARG_HOLD, EVT_MIN_THT_START_);
        }

        // initialize durations
        TRL_TARG_HOLD_DURATION = 0;
        TRL_MIN_THT_DURATION   = 0;
        TRL_IS_MIN_THT         = 0;
    }
    if (I_TARG)
    {
        TRL_TARG_HOLD_DURATION = TRL_TARG_HOLD_DURATION + 1;
        TRL_MIN_THT_DURATION   = TRL_MIN_THT_DURATION + 1;
    }

    if (TRL_MIN_THT_DURATION >= STAT_ALLOWED_T)
    {
        TRL_IS_MIN_THT = 1;
        if (TRL_MIN_THT_END_TIME <= 0)
        {
            TRL_MIN_THT_END_TIME = time();
            spawn SEND_EVT(EVT_MIN_THT_END_);

            if (DEBUG_CONSOLE)
            {
                printf("****STAT_TARG_HOLD[%d]: OK sent Event: EVT_MIN_THT_END_[%d]\n", STAT_TARG_HOLD, EVT_MIN_THT_END_);
            }
        }
    }

    if (STAT_DLTA_T < STAT_ALLOWED_T)
    {
        if (!I_TARG)
        {
            TRL_TARGET_BREAK_TIME = time();
            spawn SEND_EVT(EVT_TARGET_BREAK_);
            spawn SEND_EVT(EVT_SACCADE_SEC_);

            if (DEBUG_CONSOLE)
            {
                printf("****STAT_TARG_HOLD[%d]: ERR sent Event: EVT_TARGET_BREAK_[%d], EVT_SACCADE_SEC_[%d] \n", STAT_TARG_HOLD, EVT_TARGET_BREAK_, EVT_SACCADE_SEC_);
            }
            printf("****STAT_TARG_HOLD[%d]:ERR (Broke target fixation)[%d]/[%d] (TRL_USE_MIN_THT_DURATION)\n", STAT_TARG_HOLD, TRL_MIN_THT_DURATION, STAT_ALLOWED_T);
            PROCESS_STATE = 1;
            CURR_STAT     = STAT_REFIX_CHK;
        }
    }
    else
    {
        if (I_TARG)
        {
            TRL_TARGET_HOLD_TIME = time();
            spawn SEND_EVT(EVT_TARGET_HOLD_);

            if (DEBUG_CONSOLE)
            {
                printf("****STAT_TARG_HOLD[%d]: OK sent Event: EVT_TARGET_HOLD_[%d], Abort_[%d]\n", STAT_TARG_HOLD, EVT_TARGET_HOLD_);
            }
            printf("****STAT_TARG_HOLD[%d]: OK (Target held for min THT)[%d]/[%d] (TRL_MIN_THT_DURATION)\n", STAT_TARG_HOLD, TRL_MIN_THT_DURATION, STAT_ALLOWED_T);
            PROCESS_STATE = 1;
            CURR_STAT     = STAT_TONE_CHK;
        }
    }
} /* PROC_TARG_HOLD */
