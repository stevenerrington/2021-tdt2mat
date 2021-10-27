//==========================================================================
// RWRD_CHK.PRO
//   Description: Process Reward state after Tone is delivered
//                Gaze is in TARG_WIN only if TRL_USE_XTRA_HOLD_DURATION >
//                TONE_DELAY + TONE_DURATION.
// Gaze Check:
// Fixspot is OFF Target is ON:
// Check:
//   case 0: TRL_USE_XTRA_HOLD_DURATION <= TRL_USE_RWRD_DELAY
//         if gaze out of TARG_WIN before TRL_USE_XTRA_HOLD_DURATION expires: No Reward --> goto STAT_OUTCOME
//         if gaze in TARG_WIN until TRL_USE_XTRA_HOLD_DURATION expires: Deliver reward at TRL_USE_RWRD_DELAY time
//   case 1: TRL_USE_XTRA_HOLD_DURATION <= TRL_USE_RWRD_DELAY + RWRD_DURATION
//                if gaze in TARG_WIN until RWRD_DURATION --> (reward alredey delivered) --> goto STAT_OUTCOME
//                if gaze not in TARG_WIN during RWRD_DURATION --> (reward already delivered) --> goto STAT_TIM_OUT
//   case 2: TRL_USE_XTRA_HOLD_DURATION > TRL_USE_RWRD_DELAY + RWRD_DURATION
//         if gaze in TARG_WIN until TRL_USE_XTRA_HOLD_DURATION expires: (reward already delivered) --> goto STAT_OUTCOME
//         if gaze out of TARG_WIN before TRL_USE_XTRA_HOLD_DURATION expires: (reward already delivered) --> goto STAT_TIM_OUT
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

declare PROC_RWRD_CHK();

declare int TEMP_RWRD_DURATION;


process PROC_RWRD_CHK()
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
        TEMP_DELY_PLUS_DURATION = STAT_ALLOWED_T + STAT_I_DURATION;

        spawn SEND_EVT(EVT_REWARD_DELAY_START_);

        if (DEBUG_CONSOLE)
        {
            printf("****STAT_RWRD_CHK[%d]: OK sent Event: EVT_REWARD_DELAY_START_[%d]\n", STAT_RWRD_CHK, EVT_REWARD_DELAY_START_);
        }
    }
    spawnwait CHECK_TARG_VERT_RFRSH();

    if (I_TARG && TRL_IS_XTRA_HOLD_DONE <= 0)
    {
        TRL_XTRA_HOLD_DURATION = TRL_XTRA_HOLD_DURATION + 1;
    }
    // reward delay
    if (STAT_DLTA_T <= STAT_ALLOWED_T)
    {
        if (!I_TARG && TRL_IS_XTRA_HOLD_DONE <= 0)
        {
            if (TEMP_XTRA_HOLD_TIME <= STAT_ALLOWED_T)
            {
                TRL_BRK_XTRA_HOLD_TIME = time();
                spawn SEND_EVT(EVT_XTRA_HOLD_BREAK_);
                spawn SEND_EVT(EVT_SACCADE_SEC_);

                if (DEBUG_CONSOLE)
                {
                    printf("****STAT_RWRD_CHK[%d]: ERR sent Event: EVT_XTRA_HOLD_BREAK_[%d], EVT_SACCADE_SEC_[%d]\n", STAT_RWRD_CHK, EVT_XTRA_HOLD_BREAK_, EVT_SACCADE_SEC_);
                    printf("****STAT_RWRD_CHK[%d]: ERR (*XTRA_HOLD*Broke Target Fixation--PRE--*)[%d]/[%d](TEMP_XTRA_HOLD_TIME)\n",
                           STAT_RWRD_CHK, TRL_XTRA_HOLD_DURATION, TEMP_XTRA_HOLD_TIME);
                }
                PROCESS_STATE = 1;
                CURR_STAT     = STAT_REFIX_CHK;
            }
            else if (TEMP_XTRA_HOLD_TIME > STAT_ALLOWED_T)
            {
                TRL_BRK_PRE_RWRD_TIME = time();
                spawn SEND_EVT(EVT_PRE_RWRD_BREAK_);
                spawn SEND_EVT(EVT_SACCADE_SEC_);

                if (DEBUG_CONSOLE)
                {
                    printf("****STAT_RWRD_CHK[%d]: ERR sent Event: EVT_PRE_RWRD_BREAK_[%d], EVT_SACCADE_SEC_[%d]\n", STAT_RWRD_CHK, EVT_PRE_RWRD_BREAK_, EVT_SACCADE_SEC_);
                    printf("****STAT_RWRD_CHK[%d]: ERR (*Pre-Reward*Broke Target Fixation*)[%d]/[%d](TEMP_XTRA_HOLD_TIME)\n",
                           STAT_RWRD_CHK, TRL_XTRA_HOLD_DURATION, TEMP_XTRA_HOLD_TIME);
                }
                PROCESS_STATE = 1;
                CURR_STAT     = STAT_REFIX_CHK;
            }
        }
    }
    // Reward duration
    else if (STAT_DLTA_T > STAT_ALLOWED_T && STAT_DLTA_T <= TEMP_DELY_PLUS_DURATION)
    {
        // DO not give juice for NOGO trial
        if (TRL_REWARD_DELAY_START_TIME <= 0 && TRL_TRIAL_TYPE == TRIAL_TYPE_GO)
        {
            TRL_REWARD_DELAY_START_TIME = time();
            spawn JUICE(JUICE_CHANNEL, TEMP_RWRD_DURATION);
            printf("****STAT_RWRD_CHK[%d]: OK JUICE given\n", STAT_RWRD_CHK);
        }

        if (!I_TARG && TRL_IS_XTRA_HOLD_DONE <= 0)
        {
            if (TEMP_XTRA_HOLD_TIME > STAT_ALLOWED_T && TEMP_XTRA_HOLD_TIME <= TEMP_DELY_PLUS_DURATION)
            {
                TRL_BRK_XTRA_HOLD_TIME = time();
                spawn SEND_EVT(EVT_XTRA_HOLD_BREAK_);
                spawn SEND_EVT(EVT_SACCADE_SEC_);

                if (DEBUG_CONSOLE)
                {
                    printf("****STAT_RWRD_CHK[%d]: ERR sent Event: EVT_XTRA_HOLD_BREAK_[%d], EVT_SACCADE_SEC_[%d]\n", STAT_RWRD_CHK, EVT_XTRA_HOLD_BREAK_, EVT_SACCADE_SEC_);
                    printf("****STAT_RWRD_CHK[%d]: ERR (*XTRA_HOLD*Broke Target Fixation*--DURING--*)[%d]/[%d](TEMP_XTRA_HOLD_TIME)\n",
                           STAT_RWRD_CHK, TRL_XTRA_HOLD_DURATION, TEMP_XTRA_HOLD_TIME);
                }
                PROCESS_STATE = 1;
                CURR_STAT     = STAT_REFIX_CHK;
            }
            else if (TEMP_XTRA_HOLD_TIME > TEMP_DELY_PLUS_DURATION)
            {
                TRL_BRK_RWRD_TIME = time();
                spawn SEND_EVT(EVT_RWRD_BREAK_);
                spawn SEND_EVT(EVT_SACCADE_SEC_);

                if (DEBUG_CONSOLE)
                {
                    printf("****STAT_RWRD_CHK[%d]: ERR sent Event: EVT_RWRD_BREAK_[%d][%d], EVT_SACCADE_SEC_[%d]\n", STAT_RWRD_CHK, EVT_RWRD_BREAK_, EVT_SACCADE_SEC_);
                    printf("****STAT_RWRD_CHK[%d]: ERR (*During-Reward*Broke Target Fixation*)[%d]/[%d](TEMP_XTRA_HOLD_TIME)\n",
                           STAT_RWRD_CHK, TRL_XTRA_HOLD_DURATION, TEMP_XTRA_HOLD_TIME);
                }
                PROCESS_STATE = 1;
                CURR_STAT     = STAT_REFIX_CHK;
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
                printf("****STAT_RWRD_CHK[%d]: OK sent Event: EVT_REWARD_DELAY_END_[%d]\n", STAT_RWRD_CHK, EVT_REWARD_DELAY_END_);
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
                printf("****STAT_RWRD_CHK[%d]: OK sent Event: EVT_XTRA_HOLD_END_[%d]\n", STAT_RWRD_CHK, EVT_XTRA_HOLD_END_);
            }
        }
        if (DEBUG_CONSOLE)
        {
            printf("****STAT_RWRD_CHK[%d]: OK (*XTRA_HOLD*Target Fixated*)[%d]/[%d](TEMP_XTRA_HOLD_TIME)\n",
                   STAT_RWRD_CHK, TRL_XTRA_HOLD_DURATION, TEMP_XTRA_HOLD_TIME);
        }
        PROCESS_STATE = 1;
        CURR_STAT     = STAT_OUTCOME;
    }
} /* PROC_RWRD_CHK */
