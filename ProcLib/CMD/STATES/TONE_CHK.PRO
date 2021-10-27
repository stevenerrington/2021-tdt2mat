//==========================================================================
// TONE_CHK.PRO
//   Description: Process Tone state after Target is acquired. Eye is already in Target window
//                Gaze is in TARG_WIN. Check gaze until TRL_USE_TONE_DELAY+ TRL_USE_TONE_DURATION expires,
//                play TONE depending on gaze and TRL_USE_XTRA_HOLD_DURATION
// Gaze check:
// Fixspot is OFF Target is ON:
// Check:
//   case 0: TRL_USE_XTRA_HOLD_DURATION <= TRL_USE_TONE_DELAY
//         if gaze out of TARG_WIN before TRL_USE_XTRA_HOLD_DURATION expires: compute (ERROR) TONE, compute TIMEOUT_TIME, goto STAT_OUTCOME
//         if gaze in TARG_WIN until TRL_USE_XTRA_HOLD_DURATION expires: Play (SUCCESS) TONE at TRL_USE_TONE_DELAY time
//   case 1: TRL_USE_XTRA_HOLD_DURATION <= TRL_USE_TONE_DELAY+ TRL_USE_TONE_DURATION
//         if gaze in TARG_WIN until TRL_USE_TONE_DURATION --> (SUCCESS-tone alredey delivered), goto STAT_RWRD_CHK
//         if gaze not in TARG_WIN during TRL_USE_TONE_DURATION --> (SUCCESS-tone alredey delivered), compute TIMEOUT_TIME --> goto STAT_OUTCOME
//   case 2: TRL_USE_XTRA_HOLD_DURATION > TRL_USE_TONE_DELAY+ TRL_USE_TONE_DURATION
//         Goto next state (reward already delivered), goto STAT_RWRD_CHK
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
//   Date: 2019-02-08
//==========================================================================
//  Revision History:

declare PROC_TONE_CHK();

declare int TEMP_TONE_DURATION;


process PROC_TONE_CHK()
{
    // Target acquired, but not fixated yet or gaze still in FixWin
    if (PROCESS_STATE)
    {
        // Keep independent of previous state times if any.
        PROCESS_STATE = 0;

        STAT_DLTA_T = 0;
        // Give tone after this time, unless Abort
        STAT_ALLOWED_T = TRL_USE_TONE_DELAY * TIME_DILATE_FACTOR;
        // Tone already given, during tone check gaze
        TEMP_TONE_DURATION = TRL_USE_TONE_DURATION * TIME_DILATE_FACTOR;

        TEMP_XTRA_HOLD_TIME     = TRL_USE_XTRA_HOLD_DURATION * TIME_DILATE_FACTOR;
        TEMP_DELY_PLUS_DURATION = STAT_ALLOWED_T + TEMP_TONE_DURATION;

        if (TRL_TRIAL_TYPE == TRIAL_TYPE_STOP)
        {
            // is a non-cancelled trial so far...
            TRL_USE_TONE_FREQ = NON_CANCELLED_NO_BRK_NO_BRK_TONE_HZ;
            if (DEBUG_CONSOLE)
            {
                printf("****STAT_TONE_CHK[%d]: Processing Tone times; STOP Trial: %d Hz\n", STAT_TONE_CHK, TRL_USE_TONE_FREQ);
            }
        }
        else if (TRL_TRIAL_TYPE == TRIAL_TYPE_GO)
        {
            TRL_USE_TONE_FREQ = GO_CORRECT_TONE_HZ;
            if (DEBUG_CONSOLE)
            {
                printf("****STAT_TONE_CHK[%d]: Processing Tone times; GO Trial: %d Hz\n", STAT_TONE_CHK, TRL_USE_TONE_FREQ);
            }
        }
        spawn SEND_EVT(EVT_TONE_DELAY_START_);

        if (DEBUG_CONSOLE)
        {
            printf("****STAT_TONE_CHK[%d]: OK sent Event: EVT_TONE_DELAY_START_[%d]\n", STAT_TONE_CHK, EVT_TONE_DELAY_START_);
        }
        // always send even if TRL_USE_XTRA_HOLD_DURATION = 0
        TRL_XTRA_HOLD_START_TIME = time();
        spawn SEND_EVT(EVT_XTRA_HOLD_START_);

        TRL_XTRA_HOLD_DURATION = 0;
        TRL_IS_XTRA_HOLD_DONE  = 0;
        if (DEBUG_CONSOLE)
        {
            printf("****STAT_TONE_CHK[%d]: OK sent Event: EVT_XTRA_HOLD_START_[%d]\n", STAT_TONE_CHK, EVT_XTRA_HOLD_START_);
            printf("******* TEMP_XTRA_HOLD_TIME [%d], STAT_ALLOWED_T [%d] ***********\n", TEMP_XTRA_HOLD_TIME, STAT_ALLOWED_T);
        }
    }
    spawnwait CHECK_TARG_VERT_RFRSH();

    if (I_TARG && TRL_IS_XTRA_HOLD_DONE <= 0)
    {
        TRL_XTRA_HOLD_DURATION = TRL_XTRA_HOLD_DURATION + 1;
    }

    if (TRL_XTRA_HOLD_DURATION >= TEMP_XTRA_HOLD_TIME)
    {
        TRL_IS_XTRA_HOLD_DONE = 1;
        if (TRL_XTRA_HOLD_END_TIME <= 0)
        {
            TRL_XTRA_HOLD_END_TIME = time();
            spawn SEND_EVT(EVT_XTRA_HOLD_END_);

            if (DEBUG_CONSOLE)
            {
                printf("****STAT_TONE_CHK[%d]: OK sent Event: EVT_XTRA_HOLD_END_[%d]\n", STAT_TONE_CHK, EVT_XTRA_HOLD_END_);
            }
        }
    }

    // Tone delay
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
                    printf("****STAT_TONE_CHK[%d]: ERR sent Event: EVT_XTRA_HOLD_BREAK_[%d], EVT_SACCADE_SEC_[%d]\n", STAT_TONE_CHK, EVT_XTRA_HOLD_BREAK_, EVT_SACCADE_SEC_);
                }
                printf("****STAT_TONE_CHK[%d]: ERR (*XTRA_HOLD*Broke Target Fixation--PRE--*)[%d]/[%d](TEMP_XTRA_HOLD_TIME)\n",
                       STAT_TONE_CHK, TRL_XTRA_HOLD_DURATION, TEMP_XTRA_HOLD_TIME);
                PROCESS_STATE = 1;
                CURR_STAT     = STAT_REFIX_CHK;
            }
            else if (TEMP_XTRA_HOLD_TIME > STAT_ALLOWED_T)
            {
                TRL_BRK_PRE_TONE_TIME = time();
                spawn SEND_EVT(EVT_PRE_TONE_BREAK_);
                spawn SEND_EVT(EVT_SACCADE_SEC_);

                if (DEBUG_CONSOLE)
                {
                    printf("****STAT_TONE_CHK[%d]: ERR sent Event: EVT_PRE_TONE_BREAK_[%d], EVT_SACCADE_SEC_[d]\n", STAT_TONE_CHK, EVT_PRE_TONE_BREAK_, EVT_SACCADE_SEC_);
                }
                printf("****STAT_TONE_CHK[%d]: ERR (*Pre-Tone*Broke Target Fixation*)[%d]/[%d](TEMP_XTRA_HOLD_TIME)\n",
                       STAT_TONE_CHK, TRL_XTRA_HOLD_DURATION, TEMP_XTRA_HOLD_TIME);
                PROCESS_STATE = 1;
                CURR_STAT     = STAT_REFIX_CHK;
            }
        }
    }
    // Tone duration
    else if (STAT_DLTA_T > STAT_ALLOWED_T && STAT_DLTA_T <= TEMP_DELY_PLUS_DURATION)
    {
        // Reach here give GOOD tone, if entered this condition
        if (TRL_TONE_DELAY_START_TIME <= 0)
        {
            TRL_TONE_DELAY_START_TIME = time();
            spawn TONE(TRL_USE_TONE_FREQ, TEMP_TONE_DURATION);
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
                    printf("****STAT_TONE_CHK[%d]: ERR sent Event: EVT_XTRA_HOLD_BREAK_[%d], EVT_SACCADE_SEC_[%d]\n", STAT_TONE_CHK, EVT_XTRA_HOLD_BREAK_, EVT_SACCADE_SEC_);
                }
                printf("****STAT_TONE_CHK[%d]: ERR (*XTRA_HOLD*Broke Target Fixation--DURING--*)[%d]/[%d](TEMP_XTRA_HOLD_TIME)\n",
                       STAT_TONE_CHK, TRL_XTRA_HOLD_DURATION, TEMP_XTRA_HOLD_TIME);
                PROCESS_STATE = 1;
                CURR_STAT     = STAT_REFIX_CHK;
            }
            else if (TEMP_XTRA_HOLD_TIME > TEMP_DELY_PLUS_DURATION)
            {
                TRL_BRK_TONE_TIME = time();
                spawn SEND_EVT(EVT_TONE_BREAK_);
                spawn SEND_EVT(EVT_SACCADE_SEC_);

                if (DEBUG_CONSOLE)
                {
                    printf("****STAT_TONE_CHK[%d]: ERR sent Event: EVT_TONE_BREAK_[%d], EVT_SACCADE_SEC_[%d]\n", STAT_TONE_CHK, EVT_TONE_BREAK_, EVT_SACCADE_SEC_);
                }
                printf("****STAT_TONE_CHK[%d]: ERR (*During-Tone*Broke Target Fixation*)[%d]/[%d](TEMP_XTRA_HOLD_TIME)\n",
                       STAT_TONE_CHK, TRL_XTRA_HOLD_DURATION, TEMP_XTRA_HOLD_TIME);
                PROCESS_STATE = 1;
                CURR_STAT     = STAT_REFIX_CHK;
            }
        }
    }
    else     // eye in Target win until TEMP_XTRA_HOLD_TIME, or TEMP_XTRA_HOLD_TIME is greater than TRL_USE_TONE_DELAY+TRL_USE_TONE_DURATION
    {
        TRL_TONE_DELAY_END_TIME = time();
        spawn SEND_EVT(EVT_TONE_DELAY_END_);

        if (DEBUG_CONSOLE)
        {
            printf("****STAT_TONE_CHK[%d]: OK sent Event: EVT_TONE_DELAY_END_[%d]\n", STAT_TONE_CHK, EVT_TONE_DELAY_END_);
        }
        printf("****STAT_TONE_CHK[%d]: OK (*Tone*Target Fixated*)[%d]/[%d](TEMP_XTRA_HOLD_TIME)\n",
               STAT_TONE_CHK, TRL_XTRA_HOLD_DURATION, TEMP_XTRA_HOLD_TIME);
        PROCESS_STATE = 1;
        CURR_STAT     = STAT_RWRD_CHK;
    }
} /* PROC_TONE_CHK */
