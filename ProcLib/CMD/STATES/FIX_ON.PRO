//==========================================================================
// FIX_ON.PRO
//   Description: Process Fixspot on State
//                Eye has to acquire fixation within ALLOWED_FIX_TIME.
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

declare PROC_FIX_ON();


process PROC_FIX_ON()
{
    if (PROCESS_STATE)
    {
        dsendf("vp %d\n", PG_FIXATION_PD);
        // show for only 1 screen refresh
        dsendf("vw 1\n");

        PROCESS_STATE  = 0;
        STAT_DLTA_T    = 0;
        STAT_ALLOWED_T = ALLOWED_FIX_TIME * TIME_DILATE_FACTOR;
    }

    if (PD_TRIG_L)
    {
        if (TRL_FIX_ON_TIME <= 0)
        {
            TRL_IS_FIX_ON   = 1;
            TRL_FIX_ON_TIME = time();
            spawn SEND_EVT(EVT_FIX_SPOT_ON_);
            spawn GRAF_SHOW_FIX(GRAF_SHOW);

            dsendf("vp %d\n", PG_FIXATION);
            if (DEBUG_CONSOLE)
            {
                printf("****STAT_FIX_ON[%d]: OK sent Event: EVT_FIX_SPOT_ON_[%d]\n", STAT_FIX_ON, EVT_FIX_SPOT_ON_);
            }
        }
    }

    // There is about 13 ms to complete drawing the screen, so eye can still be out
    if (STAT_DLTA_T > ceil(REFRESH_RATE) && STAT_DLTA_T <= STAT_ALLOWED_T)
    {
        if (I_FIX_ACQ)
        {
            TRL_IS_FIX_ACQUIRED  = 1;
            TRL_ACQUIRE_FIX_TIME = time();
            spawn SEND_EVT(EVT_ACQUIRE_FIX_);

            TRL_TRIAL_START_TIME = time();
            spawn SEND_EVT(EVT_TRIAL_START_);

            if (DEBUG_CONSOLE)
            {
                printf("****STAT_FIX_ON[%d]: OK sent Event: EVT_ACQUIRE_FIX_[%d], EVT_TRIAL_START_[%d]\n", STAT_FIX_ON, EVT_ACQUIRE_FIX_, EVT_TRIAL_START_);
            }
            printf("****STAT_FIX_ON[%d]: OK (Fixation acquired)[%d]/[%d] (ALLOWED_FIX_TIME)\n", STAT_FIX_ON, STAT_DLTA_T, STAT_ALLOWED_T);

            PROCESS_STATE = 1;
            CURR_STAT     = STAT_FIX_HOLD;
        }
    }
    else if (STAT_DLTA_T > STAT_ALLOWED_T)
    {
        if (TRL_IS_FIX_ACQUIRED != 1)
        {
            TRL_IS_FIX_ACQUIRED        = 0;
            TRL_ACQUIRE_FIX_ERROR_TIME = time();
            spawn SEND_EVT(EVT_ACQUIRE_FIX_ERROR_);

            if (DEBUG_CONSOLE)
            {
                printf("****STAT_FIX_ON[%d]: ERR sent Event: EVT_ACQUIRE_FIX_ERROR_[%d]\n", STAT_FIX_ON, EVT_ACQUIRE_FIX_ERROR_);
            }
            printf("****STAT_FIX_ON[%d]: ERR (Fixation not acquired)[%d]/[%d] (ALLOWED_FIX_TIME)\n", STAT_FIX_ON, STAT_DLTA_T, STAT_ALLOWED_T);

            // Show blank page for about No timeout or any tone
            dsendf("vp %d\n", PG_BLANK);
            spawn GRAF_HIDE_FIX_TARG();

            spawn SEND_EVT(EVT_OUTCOME_FIX_ERR_);

            if (DEBUG_CONSOLE)
            {
                printf("****STAT_FIX_ON[%d]: ERR sent Event: EVT_OUTCOME_FIX_ERR_[%d]\n", STAT_FIX_ON, EVT_OUTCOME_FIX_ERR_);
                printf("****STAT_FIX_ON[%d]: Waiting for FIX_NOT_ACQ_WAIT_TIME [%d] before going to STAT_IDLE\n", STAT_FIX_ON, FIX_NOT_ACQ_WAIT_TIME);
            }
            wait(FIX_NOT_ACQ_WAIT_TIME);
            PROCESS_STATE  = 1;
            CURR_STAT      = STAT_IDLE;
            TRL_IS_RUNNING = 0;
        }
    }
} /* PROC_FIX_ON */
