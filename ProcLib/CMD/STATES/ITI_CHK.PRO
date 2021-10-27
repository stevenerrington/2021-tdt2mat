//==========================================================================
// ITI_CHK.PRO
//   Description: Process ITI state. Compute the TRL_USE_ITI_DURATION based on USE_PROVIDED_TRL_LENGTH
//                if USE_PROVIDED_TRL_LENGTH = 1 : Use TRL_USE_TRIAL_DURATION and TRL_CUM_DURATION
//                if USE_PROVIDED_TRL_LENGTH = 0 : Use BASE_ITI_FOR_AUTO_TRL_DURATION
//
//                if TRL_IS_TIMEOUT = 0 : Continue processing until TRL_USE_ITI_DURATION expires
//                If TRL_IS_TIMEOUT = 1 : Add TRL_USE_ITI_DURATION to TIMEOUT_DURATION (from OUTCOME.PRO)
//                                        and goto STAT_TIM_OUT for further processing
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
//   Date: 2019-02-13
//==========================================================================
//  Revision History:

declare PROC_ITI_CHK();


process PROC_ITI_CHK()
{
    if (PROCESS_STATE)
    {
        // Keep independent of previous state times if any.
        PROCESS_STATE = 0;

        STAT_DLTA_T = 0;
        dsendf("vp %d\n", PG_BLANK);
        spawn GRAF_HIDE_FIX_TARG();

        INCEMENT_TARG_DURATION_FLAG = 0;
        if (DEBUG_CONSOLE)
        {
            printf("****STAT_ITI_CHK[%d]: OK TRL_CUM_DURATION[%d]\n", STAT_ITI_CHK, TRL_CUM_DURATION);
            printf("****STAT_ITI_CHK[%d]: OK; TRL_USE_ITI_DURATION = (TRL_USE_TRIAL_DURATION * TIME_DILATE_FACTOR)  - TRL_CUM_DURATION\n");
        }
        TRL_USE_ITI_DURATION = (TRL_USE_TRIAL_DURATION * TIME_DILATE_FACTOR) - TRL_CUM_DURATION;
        if (DEBUG_CONSOLE)
        {
            printf("****STAT_ITI_CHK[%d]: OK; TRL_USE_ITI_DURATION [%d] = (%d * %d) - %d\n", STAT_ITI_CHK, TRL_USE_ITI_DURATION, TRL_USE_TRIAL_DURATION, TIME_DILATE_FACTOR, TRL_CUM_DURATION);
        }
        STAT_ALLOWED_T   = TRL_USE_ITI_DURATION;
        TRL_ITI_DURATION = 0;
    }

    if (TRL_ITI_START_TIME > 0)
    {
        TRL_ITI_DURATION = TRL_ITI_DURATION + 1;
    }

    if (STAT_DLTA_T <= STAT_ALLOWED_T)
    {
        if (TRL_IS_TIMEOUT)
        {
            // initialize durations
            TRL_TIMEOUT_DURATION = 0;

            TIMEOUT_DURATION = TIMEOUT_DURATION + TRL_USE_ITI_DURATION;
            PROCESS_STATE    = 1;
            TRL_IS_RUNNING   = 1;
            CURR_STAT        = STAT_TIM_OUT;
            TRL_EOT_TIME     = time();
            spawn SEND_EVT(EVT_EOT_);

            printf("****STAT_ITI_CHK[%d]: **Going to TIME_OUT State** sent Event: EVT_EOT_[%d]\n", STAT_ITI_CHK, EVT_EOT_);
        }
        else if (TRL_ITI_START_TIME <= 0)
        {
            TRL_ITI_START_TIME = time();
            spawn SEND_EVT(EVT_ITI_START_);

            // initialize durations
            TRL_ITI_DURATION = 0;
            if (DEBUG_CONSOLE)
            {
                printf("****STAT_ITI_CHK[%d]: OK sent Event: EVT_ITI_START_[%d]\n", STAT_ITI_CHK, EVT_ITI_START_);
            }
        }
    }
    else
    {
        TRL_ITI_END_TIME = time();
        spawn SEND_EVT(EVT_ITI_END_);

        if (DEBUG_CONSOLE)
        {
            printf("****STAT_ITI_CHK[%d]: OK sent Event: EVT_ITI_END_[%d]\n", STAT_ITI_CHK, EVT_ITI_END_);
        }
        PROCESS_STATE  = 1;
        TRL_IS_RUNNING = 1;
        CURR_STAT      = STAT_IDLE;
        TRL_EOT_TIME   = time();
        spawn SEND_EVT(EVT_EOT_);

        printf("****STAT_ITI_CHK[%d]: **Going to IDLE State** sent Event: EVT_EOT_[%d]\n", STAT_ITI_CHK, EVT_EOT_);
    }
} /* PROC_ITI_CHK */
