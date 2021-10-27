//==========================================================================
// GET_REDY.PRO
//   Description: Process GET_REDY State
//                Eye has to wait outside the FIX_WIN_WIDE for the duration of TRL_GET_REDY_TIME.
//                If eye crosses the FIX_WIN_LARGE, the wait time counter resets.
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

declare PROC_GET_REDY();


process PROC_GET_REDY()
{
    if (PROCESS_STATE)
    {
        if (DEBUG_CONSOLE)
        {
            printf("****STAT_GET_READY[%d]: Waiting for Eye to be outside FIX_WIN_WIDE\n", STAT_GET_READY);
        }
        TRL_GET_READY_TIME     = time();
        TRL_GET_READY_DURATION = 0;
        spawn SEND_EVT(EVT_TRIAL_GET_READY_);
        spawn GRAF_SHOW_FIX(GRAF_HIDE);

        printf("****STAT_GET_READY[%d]: TRL_TRIAL_NUMBER[%d]\n", STAT_GET_READY, TRL_TRIAL_NUMBER);

        PROCESS_STATE  = 0;
        STAT_DLTA_T    = 0;
        STAT_ALLOWED_T = READY_TIME * TIME_DILATE_FACTOR;
        // initialize durations
        TRL_GET_READY_DURATION = 0;
    }

    TRL_GET_READY_DURATION = TRL_GET_READY_DURATION + 1;
    if (STAT_DLTA_T <= STAT_ALLOWED_T && TRL_TRIAL_NUMBER > 1)
    {
        if (I_FIX || I_FIX_WIDE)
        {
            //printf("****STAT_GET_READY[%d]: ERR (Not Ready)[%d]/[%d] (READY_TIME)\n", STAT_GET_READY, TRL_GET_READY_DURATION, STAT_ALLOWED_T);
            //printf("****STAT_GET_READY[%d]: ERR (*Resetting TRL_GET_READY_DURATION*)[%d]/[%d] (READY_TIME)\n", STAT_GET_READY, TRL_GET_READY_DURATION, STAT_ALLOWED_T);
            TRL_GET_READY_DURATION = 0;
            STAT_DLTA_T            = 0;
        }
    }
    else
    {
        TRL_READY_TIME = time();
        spawn SEND_EVT(EVT_TRIAL_READY_);

        if (DEBUG_CONSOLE)
        {
            printf("****STAT_GET_READY[%d]: OK sent Event: EVT_TRIAL_READY_[%d]\n", STAT_GET_READY, EVT_TRIAL_READY_);
        }
        printf("****STAT_GET_READY[%d]: OK (Ready)[%d]/[%d] (READY_TIME)\n", STAT_GET_READY, TRL_GET_READY_DURATION, STAT_ALLOWED_T);
        PROCESS_STATE = 1;
        CURR_STAT     = STAT_FIX_ON;
    }
} /* PROC_GET_REDY */
