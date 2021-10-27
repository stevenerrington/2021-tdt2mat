//==========================================================================
// RWRD_SSD.PRO
//   Description: Process Rewarde state after Tone is delivered for STOP trial
//                Gaze is in FIX_WIN only if TRL_USE_XTRA_HOLD_DURATION >
//                TONE_DELAY + TONE_DURATION.
// Gaze Check:
// Signal is ON Target is ON:
// Check:
//   case 0: TRL_USE_XTRA_HOLD_DURATION <= RWRD_DELAY
//         if gaze out of FIX_WIN before TRL_USE_XTRA_HOLD_DURATION expires: No Reward --> goto STAT_OUTCOME
//         if gaze in FIX_WIN until TRL_USE_XTRA_HOLD_DURATION expires: Deliver reward at RWRD_DELAY time
//   case 1: TRL_USE_XTRA_HOLD_DURATION <= RWRD_DELAY + RWRD_DURATION
//                if gaze in FIX_WIN until RWRD_DURATION --> (reward alredey delivered)--> goto STAT_OUTCOME
//                if gaze not in FIX_WIN during RWRD_DURATION --> (reward already delivered) --> goto STAT_TIM_OUT
//   case 2: TRL_USE_XTRA_HOLD_DURATION > RWRD_DELAY + RWRD_DURATION
//         if gaze in FIX_WIN until TRL_USE_XTRA_HOLD_DURATION expires: (reward already delivered) --> goto STAT_OUTCOME
//         if gaze out of FIX_WIN before TRL_USE_XTRA_HOLD_DURATION expires: (reward already delivered) --> goto STAT_TIM_OUT
//
//   All Global variables and the following state variables are available to monitor state progress
//                1. PROCESS_STATE : Setup state processing, will be done once per call
//                1. CURR_STAT :


//                4. STAT_DLTA_T : Length of time in this state (in ticks/ms)
//                5. STAT_ALLOWED_T : Max time for staying in this state
//                5. STAT_I_DURATION : If saccade occurs, it must complete in this time
//
//   NOTE:
//
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-02-09
//==========================================================================
//  Revision History:

declare PROC_RWRD_SSD();

declare int TEMP_RWRD_DURATION;


process PROC_RWRD_SSD()
{
    // Target acquired, but not fixated yet or gaze still in FixWin
    if (PROCESS_STATE)
    {
        // Keep independent of previous state times if any.
        PROCESS_STATE = 0;

        STAT_DLTA_T = 0;
        // Give reward after this time, unless Abort
        STAT_ALLOWED_T = TRL_USE_RWRD_DELAY * TIME_DILATE_FACTOR;
        // Reward already given, during reward duration check gaze
        TEMP_RWRD_DURATION = TRL_USE_RWRD_DURATION * TIME_DILATE_FACTOR;
        // This is incremented in the CMD_TSK.PRO --> state flow controller
        TEMP_XTRA_HOLD_TIME     = TRL_USE_XTRA_HOLD_DURATION * TIME_DILATE_FACTOR;
        TEMP_DELY_PLUS_DURATION = STAT_ALLOWED_T + TEMP_RWRD_DURATION;

        spawn SEND_EVT(EVT_REWARD_DELAY_START_);

        if (DEBUG_CONSOLE)
        {
            printf("****STAT_RWRD_SSD[%d]: OK sent Event: EVT_REWARD_DELAY_START_[%d]\n", STAT_RWRD_SSD, EVT_REWARD_DELAY_START_);
        }
    }
    spawnwait CHECK_TARG_VERT_RFRSH();

    if (I_FIX && TRL_IS_XTRA_HOLD_DONE <= 0)
    {
        TRL_XTRA_HOLD_DURATION = TRL_XTRA_HOLD_DURATION + 1;
    }

    // Reward delay
    if (STAT_DLTA_T <= STAT_ALLOWED_T)
    {
        if (!I_FIX && TRL_IS_XTRA_HOLD_DONE <= 0)
        {
            if (TEMP_XTRA_HOLD_TIME <= STAT_ALLOWED_T)
            {
                TRL_BRK_XTRA_HOLD_TIME = time();
                spawn SEND_EVT(EVT_XTRA_HOLD_BREAK_);

                if (DEBUG_CONSOLE)
                {
                    printf("****STAT_RWRD_SSD[%d]: ERR sent Event: EVT_XTRA_HOLD_BREAK_[%d]\n", STAT_RWRD_SSD, EVT_XTRA_HOLD_BREAK_);
                    printf("****STAT_RWRD_SSD[%d]: ERR (*XTRA_HOLD*Broke Fixation--PRE--*)[%d]/[%d](TEMP_XTRA_HOLD_TIME)\n",
                           STAT_RWRD_SSD, TRL_XTRA_HOLD_DURATION, TEMP_XTRA_HOLD_TIME);
                }
                PROCESS_STATE = 1;
                CURR_STAT     = STAT_OUTCOME;
            }
            else if (TEMP_XTRA_HOLD_TIME > STAT_ALLOWED_T)
            {
                TRL_BRK_PRE_RWRD_TIME = time();
                spawn SEND_EVT(EVT_PRE_RWRD_BREAK_);

                if (DEBUG_CONSOLE)
                {
                    printf("****STAT_RWRD_SSD[%d]: ERR sent Event: EVT_PRE_RWRD_BREAK_[%d]\n", STAT_RWRD_SSD, EVT_PRE_RWRD_BREAK_);
                    printf("****STAT_RWRD_SSD[%d]: ERR (*Pre-Reward*Broke Fixation*)[%d]/[%d](TEMP_XTRA_HOLD_TIME)\n",
                           STAT_RWRD_SSD, TRL_XTRA_HOLD_DURATION, TEMP_XTRA_HOLD_TIME);
                }
                PROCESS_STATE = 1;
                CURR_STAT     = STAT_OUTCOME;
            }
        }
    }
    // Reward duration
    else if (STAT_DLTA_T > STAT_ALLOWED_T && STAT_DLTA_T <= TEMP_DELY_PLUS_DURATION)
    {
        if (TRL_REWARD_DELAY_START_TIME <= 0)
        {
            TRL_REWARD_DELAY_START_TIME = time();
            spawn JUICE(JUICE_CHANNEL, TEMP_RWRD_DURATION);

            printf("****STAT_RWRD_SSD[%d]: OK JUICE given\n", STAT_RWRD_SSD);
        }
        if (!I_FIX && TRL_IS_XTRA_HOLD_DONE <= 0)
        {
            if (TEMP_XTRA_HOLD_TIME > STAT_ALLOWED_T && TEMP_XTRA_HOLD_TIME <= TEMP_DELY_PLUS_DURATION)
            {
                TRL_BRK_XTRA_HOLD_TIME = time();
                spawn SEND_EVT(EVT_XTRA_HOLD_BREAK_);

                if (DEBUG_CONSOLE)
                {
                    printf("****STAT_RWRD_SSD[%d]: ERR sent Event: EVT_XTRA_HOLD_BREAK_[%d]\n", STAT_RWRD_SSD, EVT_XTRA_HOLD_BREAK_);
                    printf("****STAT_RWRD_SSD[%d]: ERR (*XTRA_HOLD*Broke Fixation*--DURING--*)[%d]/[%d](TEMP_XTRA_HOLD_TIME)\n",
                           STAT_RWRD_SSD, TRL_XTRA_HOLD_DURATION, TEMP_XTRA_HOLD_TIME);
                }
                PROCESS_STATE = 1;
                CURR_STAT     = STAT_OUTCOME;
            }
            else if (TEMP_XTRA_HOLD_TIME > TEMP_DELY_PLUS_DURATION)
            {
                TRL_BRK_RWRD_TIME = time();
                spawn SEND_EVT(EVT_RWRD_BREAK_);

                if (DEBUG_CONSOLE)
                {
                    printf("****STAT_RWRD_SSD[%d]: ERR sent Event: EVT_RWRD_BREAK_[%d][%d]\n", STAT_RWRD_SSD, EVT_RWRD_BREAK_);
                    printf("****STAT_RWRD_SSD[%d]: ERR (*During-Reward*Broke Fixation*)[%d]/[%d](TEMP_XTRA_HOLD_TIME)\n",
                           STAT_RWRD_SSD, TRL_XTRA_HOLD_DURATION, TEMP_XTRA_HOLD_TIME);
                }
                PROCESS_STATE = 1;
                CURR_STAT     = STAT_OUTCOME;
            }
        }
    }
    else if (STAT_DLTA_T > TEMP_DELY_PLUS_DURATION)   // after reward
    {
        if (TRL_REWARD_DELAY_END_TIME <= 0)
        {
            TRL_REWARD_DELAY_END_TIME = time();
            spawn SEND_EVT(EVT_REWARD_DELAY_END_);

            if (DEBUG_CONSOLE)
            {
                printf("****STAT_RWRD_SSD[%d]: OK sent Event: EVT_REWARD_DELAY_END_[%d]\n", STAT_RWRD_SSD, EVT_REWARD_DELAY_END_);
            }
        }

        // if you reached here xtra-hold is done
        TRL_IS_XTRA_HOLD_DONE = 1;
        if (TRL_XTRA_HOLD_END_TIME <= 0)
        {
            TRL_XTRA_HOLD_END_TIME = time();
            spawn SEND_EVT(EVT_XTRA_HOLD_END_);

            if (DEBUG_CONSOLE)
            {
                printf("****STAT_RWRD_SSD[%d]: OK sent Event: EVT_XTRA_HOLD_END_[%d]\n", STAT_RWRD_SSD, EVT_XTRA_HOLD_END_);
            }
        }
        if (DEBUG_CONSOLE)
        {
            printf("****STAT_RWRD_SSD[%d]: OK (*XTRA_HOLD* Fixated*)[%d]/[%d](TEMP_XTRA_HOLD_TIME)\n",
                   STAT_RWRD_SSD, TRL_XTRA_HOLD_DURATION, TEMP_XTRA_HOLD_TIME);
        }
        PROCESS_STATE = 1;
        CURR_STAT     = STAT_OUTCOME;
    }
} /* PROC_RWRD_SSD */
