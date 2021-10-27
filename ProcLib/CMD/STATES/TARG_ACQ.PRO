//==========================================================================
// TARG_ACQ.PRO
//   Description: Process Acquire Target State
//                Eye has to has to Acquire target before MAX_SACCADE_DURATION.
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
//   Date: 2019-02-08
//==========================================================================
//  Revision History:

declare PROC_TARG_ACQ();


process PROC_TARG_ACQ()
{
    // Target acquired, but not fixated yet or eye still in FixWin
    if (PROCESS_STATE)
    {
        // Keep independent of previous state times if any.
        PROCESS_STATE  = 0;
        STAT_STRT_T    = time();
        STAT_DLTA_T    = 0;
        STAT_ALLOWED_T = MAX_SACC_DURATION * TIME_DILATE_FACTOR;
        // initialize durations
        TRL_SACC_DURATION      = 0;
        TRL_TARG_HOLD_DURATION = 0;
    }
    spawnwait CHECK_TARG_VERT_RFRSH();

    //TRL_IS_I_IN_FLIGHT  should be true
    // Acquire target
    if (STAT_DLTA_T <= STAT_ALLOWED_T)
    {
        TRL_SACC_DURATION = TRL_SACC_DURATION + 1;
        if (I_TARG)
        {
            TRL_IS_TARG_ACQUIRED     = 1;
            TRL_TARGET_ACQUIRED_TIME = time();
            TRL_DECIDE_TIME          = time();
            spawn SEND_EVT(EVT_TARGET_ACQUIRED_);
            spawn SEND_EVT(EVT_DECIDE_);

            if (DEBUG_CONSOLE)
            {
                printf("****STAT_TARG_ACQ[%d]: OK sent Event: EVT_TARGET_ACQUIRED_[%d], EVT_DECIDE_[%d]\n", STAT_TARG_ACQ, EVT_TARGET_ACQUIRED_, EVT_DECIDE_);
            }
            printf("****STAT_TARG_ACQ[%d]: OK TARGET_ACQUIRED in [%d]/[%d](MAX_SACC_DURATION)\n", STAT_TARG_ACQ, TRL_SACC_DURATION, STAT_ALLOWED_T);

            PROCESS_STATE = 1;
            // process speparately for STOP/GO trials
            if (TRL_TRIAL_TYPE == TRIAL_TYPE_STOP && TRL_NOGO_LATE_SACCADE_TIME > 0)
            {
                CURR_STAT = STAT_OUTCOME;
            }
            else
            {
                if (TRL_TRIAL_TYPE == TRIAL_TYPE_STOP && TRL_IS_FIX_REIGNITE > 0)
                {
                    // change the display to PG_SIGNAL_PD to turn the signal back on
                    dsendf("vp %d\n", PG_SIGNAL_PD);
                    printf("****STAT_TARG_ACQ[%d]: OK (*Stop-Trial Saccade happened; Turn-on-Signal*) REIGNITE_FLAG ON\n", STAT_TARG_ACQ);
                }
                CURR_STAT = STAT_TARG_HOLD;
            }
        }
    }
    else
    {
        if (!I_TARG)
        {
            TRL_IS_TARG_ACQUIRED          = 0;
            TRL_IS_STAIRCASE_SSD          = 0;
            TRL_ACQUIRE_TARGET_ERROR_TIME = time();
            spawn SEND_EVT(EVT_ACQUIRE_TARGET_ERROR_);

            // Error saccade?
            if (DEBUG_CONSOLE)
            {
                printf("****STAT_TARG_ACQ[%d]: ERR sent Event: EVT_ACQUIRE_TARGET_ERROR_[%d]\n", STAT_TARG_ACQ, EVT_ACQUIRE_TARGET_ERROR_);
            }
            printf("****STAT_TARG_ACQ[%d]: ERR (*Eye elsewhere* in)[%d]/[%d](MAX_SACC_DURATION)\n", STAT_TARG_ACQ, TRL_SACC_DURATION, STAT_ALLOWED_T);

            PROCESS_STATE = 1;
            CURR_STAT     = STAT_OUTCOME;
        }
    }
} /* PROC_TARG_ACQ */
