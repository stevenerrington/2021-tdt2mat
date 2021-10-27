//==========================================================================
// RFIX_CHK.PRO
//   Description: Process Check Refix
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
//   Date: 2019-04-01
//==========================================================================
//  Revision History:

declare PROC_REFIX_CHK();


process PROC_REFIX_CHK()
{
    // Target- Eye left target window during targ-hold onwards for Stop trial
    if (PROCESS_STATE)
    {
        // Keep independent of previous state times if any.
        PROCESS_STATE  = 0;
        STAT_STRT_T    = time();
        STAT_DLTA_T    = 0;
        STAT_ALLOWED_T = MAX_SACC_DURATION * TIME_DILATE_FACTOR;

        STAT_I_DURATION = TRL_USE_MIN_THT_DURATION * TIME_DILATE_FACTOR;
        // initialize durations
        TRL_IS_REFIX = 0;
    }

    if (TRL_TRIAL_TYPE == TRIAL_TYPE_STOP)
    {
        if (TRL_DECIDE_SEC_TIME <= 0)
        {
            if (STAT_DLTA_T <= STAT_ALLOWED_T)
            {
                if (I_FIX)
                {
                    STAT_DLTA_T         = 0;
                    TRL_DECIDE_SEC_TIME = time();
                    spawn SEND_EVT(EVT_DECIDE_SEC_);

                    if (DEBUG_CONSOLE)
                    {
                        printf("****STAT_REFIX_CHK[%d]: Sent Event: EVT_DECIDE_SEC_[%d][%d]\n", STAT_REFIX_CHK, EVT_DECIDE_SEC_);

                        printf("****STAT_REFIX_CHK[%d]: Secondary saccade in [%d]/[%d](MAX_SACC_DURATION)\n",
                               STAT_REFIX_CHK, STAT_DLTA_T, STAT_ALLOWED_T);
                    }

                    TRL_REFIX_HOLD_DURATION = 0;
                }
            }
            else
            {
                printf("****STAT_REFIX_CHK[%d]: ERR (*Secondary Saccade-Eye elsewhere* in) [%d](MAX_SACC_DURATION)\n", STAT_REFIX_CHK, STAT_ALLOWED_T);

                PROCESS_STATE = 1;
                CURR_STAT     = STAT_OUTCOME;
            }
        }
        else if (TRL_DECIDE_SEC_TIME > 0)
        {
            // reset STAT_DLTA_T to 0 when TRL_DECIDE_SEC_TIME (> 0)/EVT_DECIDE_SEC_ (is sent)
            if (STAT_DLTA_T <= STAT_I_DURATION)
            {
                if (I_FIX)
                {
                    TRL_REFIX_HOLD_DURATION = TRL_REFIX_HOLD_DURATION + 1;
                    if (TRL_REFIX_HOLD_DURATION >= STAT_I_DURATION)
                    {
                        TRL_IS_REFIX = 1;

                        TRL_REFIX_TIME = time();
                        spawn SEND_EVT(EVT_REFIX_);

                        printf("****STAT_REFIX_CHK[%d]: Sent Event: EVT_REFIX_[%d][%d]\n", STAT_REFIX_CHK, EVT_REFIX_);

                        PROCESS_STATE = 1;
                        CURR_STAT     = STAT_OUTCOME;
                    }
                }
            }
            else
            {
                printf("****STAT_REFIX_CHK[%d]: ERR (*Refix Fixation break*) [%d]/[%d](TRL_USE_MIN_THT_DURATION)\n",
                       STAT_REFIX_CHK, STAT_DLTA_T, STAT_I_DURATION);

                PROCESS_STATE = 1;
                CURR_STAT     = STAT_OUTCOME;
            }
        }
    }
    else
    {
        if (DEBUG_CONSOLE)
        {
            printf("****STAT_REFIX_CHK[%d]: GO Trial; Not checking REFIX\n", STAT_REFIX_CHK);
        }
        PROCESS_STATE = 1;
        CURR_STAT     = STAT_OUTCOME;
    }
} /* PROC_REFIX_CHK */
