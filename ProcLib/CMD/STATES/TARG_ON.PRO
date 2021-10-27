//==========================================================================
// TARG_ON.PRO
//   Description: Process Target On State
//                Eye has to HOLD fixation till MIN_SACC_TIME before saccade.
//                If MAX_SACC_TOME expires, then no saccade
// Gaze Check:
// Fixspot is OFF Target is ON:
// Check: Gaze in FIX window until MIN_SACCADE_TIME expires, else it is early saccade
//        Gaze left FIX_WIN before MAX_SACCADE_TIME, then correct saccade, else no saccade
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

declare PROC_TARG_ON();


process PROC_TARG_ON()
{
    if (PROCESS_STATE)
    {
        TRL_TARGET_PRE_TIME = time();
        spawn SEND_EVT(EVT_TARGET_PRE_);

        dsendf("vp %d\n", PG_TARGET_PD);
        spawn GRAF_SHOW_FIX(GRAF_HIDE);
        spawn GRAF_SHOW_TARG(GRAF_SHOW);

        PROCESS_STATE   = 0;
        STAT_STRT_T     = TRL_TARGET_PRE_TIME;
        STAT_DLTA_T     = 0;
        STAT_I_DURATION = MIN_SACC_TIME * TIME_DILATE_FACTOR;
        STAT_ALLOWED_T  = MAX_SACC_TIME * TIME_DILATE_FACTOR;

        //
        TRL_IS_TARGET_ON = 0;
    }

    spawnwait CHECK_TARG_VERT_RFRSH();

    if (TRL_TARG_VR_COUNT == 1 && TRL_TARGET_TIME <= 0)
    {
        TRL_IS_TARGET_ON = 1;
        TRL_TARGET_TIME  = time();
        spawn SEND_EVT(EVT_TARGET_);

        TRL_FIX_SPOT_OFF_TIME = time();
        spawn SEND_EVT(EVT_FIX_SPOT_OFF_);

        if (DEBUG_CONSOLE)
        {
            printf("****STAT_TARG_ON[%d]: Sent Event EVT_TARGET_[%d]\n", STAT_TARG_ON, EVT_TARGET_);
            printf("****STAT_TARG_ON[%d]: Sent Event EVT_FIX_SPOT_OFF_[%d]\n", STAT_TARG_ON, EVT_FIX_SPOT_OFF_);
        }
    }
    // Before MIN_SACCADE_TIME
    if (STAT_DLTA_T <= STAT_I_DURATION)
    {
        if (!I_FIX)
        {
            TRL_IS_I_IN_FLIGHT    = 1;
            TRL_ERLY_SACCADE_TIME = time();
            spawn SEND_EVT(EVT_EARLY_SACCADE_);

            if (DEBUG_CONSOLE)
            {
                printf("****STAT_TARG_ON[%d]: ERR sent Event: EVT_EARLY_SACCADE_[%d]\n", STAT_TARG_ON, EVT_EARLY_SACCADE_);
            }
            printf("****STAT_TARG_ON[%d]: ERR (*Early Saccade*)[%d]/[%d] (MIN_SACC_TIME)\n", STAT_TARG_ON, STAT_DLTA_T, STAT_I_DURATION);
            PROCESS_STATE = 1;
            CURR_STAT     = STAT_OUTCOME;
        }
    }
    else if (STAT_DLTA_T <= STAT_ALLOWED_T)
    {
        if (!I_FIX)
        {
            TRL_IS_I_IN_FLIGHT = 1;
            TRL_SACCADE_TIME   = time();
            spawn SEND_EVT(EVT_SACCADE_);

            if (DEBUG_CONSOLE)
            {
                printf("****STAT_TARG_ON[%d]: OK sent Event: EVT_SACCADE_[%d]\n", STAT_TARG_ON, EVT_SACCADE_);
            }
            printf("****STAT_TARG_ON[%d]: OK (Correct Saccade)[%d]/([%d,%d]) (MIN, MAX SACC_TIME)\n", STAT_TARG_ON, STAT_DLTA_T, STAT_I_DURATION, STAT_ALLOWED_T);
            PROCESS_STATE = 1;
            CURR_STAT     = STAT_TARG_ACQ;
        }
    }
    else
    {
        if (I_FIX)
        {
            TRL_IS_I_IN_FLIGHT  = 0;
            TRL_NO_SACCADE_TIME = time();
            spawn SEND_EVT(EVT_NO_SACCADE_);

            if (DEBUG_CONSOLE)
            {
                printf("****STAT_TARG_ON[%d]: ERR sent Event: EVT_NO_SACCADE_[%d]\n", STAT_TARG_ON, EVT_NO_SACCADE_);
            }
            printf("****STAT_TARG_ON[%d]: ERR (No Saccade)[%d]/[%d] (MAX_SACCADE_TIME)\n", STAT_TARG_ON, STAT_DLTA_T, STAT_ALLOWED_T);
            PROCESS_STATE = 1;
            CURR_STAT     = STAT_OUTCOME;
        }
    }
} /* PROC_TARG_ON */
