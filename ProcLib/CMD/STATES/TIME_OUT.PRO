//==========================================================================
// TIME_OUT.PRO
//   Description: Process TIMEOUT state
//
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

declare PROC_TIMEOUT_CHK();

declare int RND_PG;


process PROC_TIMEOUT_CHK()
{
    if (PROCESS_STATE)
    {
        // Keep independent of previous state times if any.
        PROCESS_STATE = 0;

        STAT_DLTA_T = 0;
        // Already adjusted for TIME_DILATE_FACTOR
        STAT_ALLOWED_T = TIMEOUT_DURATION;
        printf("****STAT_TIM_OUT[%d]: TIMEOUT_DURATION[%d]\n", STAT_TIM_OUT, TIMEOUT_DURATION);
        // spent 1 tick in ITI_CHK.PRO
        TRL_USE_TIMEOUT_DURATION = 1;
        TRL_USE_TONE_DURATION    = TIMEOUT_DURATION;
        TRL_USE_TONE_FREQ        = TIMEOUT_TONE;
        if (INCEMENT_TARG_DURATION_FLAG)
        {
            dsendf("vp %d\n", PG_BLANK);
            spawn GRAF_HIDE_FIX_TARG();

            INCEMENT_TARG_DURATION_FLAG = 0;
        }
    }
    // show random dot page(s)
    if (TIMEOUT_SHOW_RANDM_PG_FLAG == 1)
    {
        if ((STAT_DLTA_T % 64) == 0)
        {
            dsendf("vp %d\n", PG_RAND_ARRAY[random(2)]);
        }
    }

    if (STAT_DLTA_T <= STAT_ALLOWED_T)
    {
        TRL_USE_TIMEOUT_DURATION = TRL_USE_TIMEOUT_DURATION + 1;
        if (TRL_TIMEOUT_START_TIME <= 0)
        {
            TRL_TIMEOUT_START_TIME = time();
            spawn SEND_EVT(EVT_TIMEOUT_START_);

            if (DEBUG_CONSOLE)
            {
                printf("****STAT_ITI_CHK[%d]: OK sent Event: EVT_TIMEOUT_START_[%d]\n", STAT_ITI_CHK, EVT_TIMEOUT_START_);
            }
            if (TIMEOUT_PLAY_TONE_FLAG == 1)
            {
                spawn TONE(TRL_USE_TONE_FREQ, TRL_USE_TONE_DURATION);
            }
        }
    }
    else
    {
        dsendf("vp %d\n", PG_BLANK);
        spawn GRAF_HIDE_FIX_TARG();

        TRL_TIMEOUT_END_TIME = time();
        spawn SEND_EVT(EVT_TIMEOUT_END_);

        if (DEBUG_CONSOLE)
        {
            printf("****STAT_TIM_OUT[%d]: ERR sent Event: EVT_TIMEOUT_END_[%d]\n", STAT_TIM_OUT, EVT_TIMEOUT_END_);
            printf("****STAT_TIM_OUT[%d]: ERR  TRL_USE_TIMEOUT_DURATION[%d]/TRL_USE_TONE_DURATION [%d] \n", STAT_TIM_OUT, TRL_USE_TIMEOUT_DURATION, TRL_USE_TONE_DURATION);
        }
        PROCESS_STATE  = 1;
        CURR_STAT      = STAT_IDLE;
        TRL_IS_RUNNING = 1;
    }
}/*PROC_TIMEOUT_CHK*/
