//==========================================================================
// OUTCOME.PRO
//  Description: Determine trial outcome and appropriate EXTRA_TIMEOUT_DURATION in ms
//
// See CmdOutcomes.xls file in DOC folder - not updated
//        All Global variables and the following state variables are available to monitor state progress
//        1. PROCESS_STATE : Setup state processing, will be done once per call
//        1. CURR_STAT :
//        4. STAT_DLTA_T : Length of time in this state (in ticks/ms)
//        5. STAT_ALLOWED_T : Max time for staying in this state
//        5. STAT_I_DURATION : If saccade occurs, it must complete in this time
//
//  NOTE:
//
//  Author: chenchal.subraveti@vanderbilt.edu
//  Date: 2019-02-13
//==========================================================================
// Revision History:

declare PROC_TRL_OUTCOME();

declare PROC_GO_OUTCOMES();
declare PROC_NOGO_PRE_CANCEL_OUTCOMES();
declare PROC_NOGO_POST_CANCEL_OUTCOMES();

declare PROC_FIX_BREAK();
declare PROC_GO_ERR();
declare PROC_CANCELLED_BRK();
declare PROC_NON_CANCELLED_BRK();
declare PROC_NOGO_ERR();


process PROC_TRL_OUTCOME()
{
    declare int doOnce;

    // Target acquired, but not fixated yet or eye still in FixWin
    if (PROCESS_STATE)
    {
        // Keep independent of previous state times if any.
        PROCESS_STATE  = 0;
        STAT_STRT_T    = time();
        STAT_DLTA_T    = 0;
        STAT_ALLOWED_T = 5;
        dsendf("vp %d\n", PG_BLANK);

        INCEMENT_TARG_DURATION_FLAG = 0;
        TIMEOUT_DURATION            = 0;
        // set this as default and change to
        // TRL_IS_TIMEOUT = 0; when not error
        TRL_IS_TIMEOUT = 1;
        doOnce         = 1;
    }
    // it is big conditional depending on the current trial type and tyep of error

    if (STAT_DLTA_T <= STAT_ALLOWED_T)
    {
        if (doOnce)
        {
            doOnce = 0;
            if (TRL_TRIAL_TYPE == TRIAL_TYPE_GO)
            {
                spawn PROC_GO_OUTCOMES();
            }
            else if (TRL_TRIAL_TYPE == TRIAL_TYPE_STOP)
            {
                if (TRL_CANCEL_TIME > 0)
                {
                    spawn PROC_NOGO_POST_CANCEL_OUTCOMES();
                }
                else
                {
                    spawn PROC_NOGO_PRE_CANCEL_OUTCOMES();
                }
            }
        }
    }
    else
    {
        if (TRL_IS_TIMEOUT > 0)
        {
            if (TRL_TRIAL_TYPE == TRIAL_TYPE_GO)
            {
                TIMEOUT_TONE = GO_ERROR_TONE_HZ;
            }
            else if (TRL_TRIAL_TYPE == TRIAL_TYPE_STOP)
            {
                TIMEOUT_TONE = NOGO_ERROR_TONE_HZ;
            }
        }
        TIMEOUT_DURATION = TIMEOUT_DURATION * TRL_USE_TRIAL_DURATION * TIME_DILATE_FACTOR;
        printf("****STAT_OUTCOME[%d]: TRL_TRIAL_NUMBER[%d] TIMEOUT_DURATION [%d] \n", STAT_OUTCOME, TRL_TRIAL_NUMBER, TIMEOUT_DURATION);

        // Add REFIX timeout if trial is a REFIX
        if (TRL_IS_REFIX == 1)
        {
            TIMEOUT_DURATION = TIMEOUT_DURATION + (TIMEOUT_REFIX_EXTRA * TRL_USE_TRIAL_DURATION * TIME_DILATE_FACTOR);
        }

        PROCESS_STATE = 1;
        CURR_STAT     = STAT_ITI_CHK;
    }
} /* PROC_OUTCOME */


process PROC_GO_OUTCOMES()
{
    if (TRL_IS_MIN_THT > 0 && TRL_IS_XTRA_HOLD_DONE > 0)
    {
        TRL_IS_GO_CORRECT = 1;
        TIMEOUT_DURATION  = 0;
        TRL_IS_TIMEOUT    = 0;
        spawn SEND_EVT(EVT_OUTCOME_GO_CORRECT_);

        TRL_LAST_GO_OUTCOME_EVNTCODE = EVT_OUTCOME_GO_CORRECT_;
        printf("****STAT_OUTCOME[%d]: TRL_TRIAL_NUMBER[%d] outcome: GO-CORRECT\n", STAT_OUTCOME, TRL_TRIAL_NUMBER);
        if (DEBUG_CONSOLE)
        {
            printf("****STAT_OUTCOME[%d]: TRL_TRIAL_NUMBER[%d] outcome: EVT_OUTCOME_GO_CORRECT_ [%d]; Go Trial; (TRL_XTRA_HOLD_END_TIME - OK) \n",
                   STAT_OUTCOME, TRL_TRIAL_NUMBER, EVT_OUTCOME_GO_CORRECT_);
        }
        SESS_N_GO_CORRECT_TRLS = SESS_N_GO_CORRECT_TRLS + 1;
        TRL_BLOCK_N_CORRECT_TRLS   = TRL_BLOCK_N_CORRECT_TRLS + 1;
    }
    else if (TRL_FIX_BREAK_TIME > 0)
    {
        TIMEOUT_DURATION = TIMEOUT_FIX_BRK[GO_IDX];
        spawnwait PROC_FIX_BREAK();
    }
    else if (TRL_ERLY_SACCADE_TIME > 0)
    {
        TIMEOUT_DURATION = TIMEOUT_ERLY_SACC[GO_IDX];
        spawnwait PROC_GO_ERR();
    }
    else if (TRL_NO_SACCADE_TIME > 0)
    {
        TIMEOUT_DURATION = TIMEOUT_LATE_NO_SACC[GO_IDX];
        spawnwait PROC_GO_ERR();
    }
    else if (TRL_ACQUIRE_TARGET_ERROR_TIME > 0)
    {
        TIMEOUT_DURATION = TIMEOUT_TARG_ACQ_ERROR[GO_IDX];
        spawnwait PROC_GO_ERR();
    }
    else if (TRL_BRK_PRE_TONE_TIME > 0)
    {
        TIMEOUT_DURATION = TIMEOUT_BRK_PRE_TONE[GO_IDX];
        spawnwait PROC_GO_ERR();
    }
    else if (TRL_BRK_TONE_TIME > 0)
    {
        TIMEOUT_DURATION = TIMEOUT_BRK_TONE[GO_IDX];
        spawnwait PROC_GO_ERR();
    }
    else if (TRL_BRK_PRE_RWRD_TIME > 0)
    {
        TIMEOUT_DURATION = TIMEOUT_BRK_PRE_RWRD[GO_IDX];
        spawnwait PROC_GO_ERR();
    }
    else if (TRL_BRK_RWRD_TIME > 0)
    {
        TIMEOUT_DURATION = TIMEOUT_BRK_PRE_RWRD[GO_IDX];
        spawnwait PROC_GO_ERR();
    }
    else if (TRL_IS_MIN_THT <= 0)
    {
        TIMEOUT_DURATION = TIMEOUT_BRK_MIN_THT[GO_IDX];
        spawnwait PROC_GO_ERR();
    }
    else if (TRL_IS_XTRA_HOLD_DONE <= 0)
    {
        TIMEOUT_DURATION = TIMEOUT_BRK_XTRA_HOLD[GO_IDX];
        spawnwait PROC_GO_ERR();
    }
} /* PROC_GO_OUTCOMES */


// if Eye left fix win Before Cancel time
process PROC_NOGO_PRE_CANCEL_OUTCOMES()
{
    declare int nogoIdx;

    if (TRL_IS_STOP_SIGNAL_ON)
    {
        nogoIdx = NOGO_POST_SSD_IDX;
        if (DEBUG_CONSOLE)
        {
            printf("****STAT_OUTCOME[%d]: TRL_TRIAL_NUMBER[%d] outcome: STOP Trial; POST-SSD, PRE_CANCEL\n", STAT_OUTCOME, TRL_TRIAL_NUMBER);
        }
    }
    else
    {
        nogoIdx = NOGO_PRE_SSD_IDX;
        if (DEBUG_CONSOLE)
        {
            printf("****STAT_OUTCOME[%d]: TRL_TRIAL_NUMBER[%d] outcome: STOP Trial; PRE-SSD, PRE_CANCEL\n", STAT_OUTCOME, TRL_TRIAL_NUMBER);
        }
    }

    if (TRL_IS_MIN_THT > 0 && TRL_IS_XTRA_HOLD_DONE > 0)
    {
        TRL_IS_NON_CANCELLED_NO_BRK = 1;
        TIMEOUT_DURATION            = 0;
        TRL_IS_TIMEOUT              = 0;
        spawn SEND_EVT(EVT_OUTCOME_NOGO_NON_CANCEL_NO_BRK_);

        TRL_LAST_STOP_OUTCOME_EVNTCODE = EVT_OUTCOME_NOGO_NON_CANCEL_NO_BRK_;
        printf("****STAT_OUTCOME[%d]: TRL_TRIAL_NUMBER[%d] outcome: NON-CANCELLED\n", STAT_OUTCOME, TRL_TRIAL_NUMBER);
        if (DEBUG_CONSOLE)
        {
            printf("****STAT_OUTCOME[%d]: TRL_TRIAL_NUMBER[%d] outcome: **EVT_OUTCOME_NOGO_NON_CANCEL_NO_BRK_** [%d]; TRL_IS_STAIRCASE_SSD [%d]; STOP Trial; (TRL_XTRA_HOLD_END_TIME - OK) \n",
                   STAT_OUTCOME, TRL_TRIAL_NUMBER, EVT_OUTCOME_NOGO_NON_CANCEL_NO_BRK_, TRL_IS_STAIRCASE_SSD);
        }
        SESS_N_NON_CANCEL_NO_BRK_TRLS = SESS_N_NON_CANCEL_NO_BRK_TRLS + 1;
    }
    else if (TRL_FIX_BREAK_TIME > 0)
    {
        TIMEOUT_DURATION = TIMEOUT_FIX_BRK[nogoIdx];
        spawnwait PROC_FIX_BREAK();
    }
    else if (TRL_NOGO_EARLY_SACCADE_TIME > 0)
    {
        TIMEOUT_DURATION = TIMEOUT_ERLY_SACC[nogoIdx];
        spawnwait PROC_NOGO_ERR();
    }
    else if (TRL_ACQUIRE_TARGET_ERROR_TIME > 0)
    {
        TIMEOUT_DURATION = TIMEOUT_TARG_ACQ_ERROR[nogoIdx];
        spawnwait PROC_NOGO_ERR();
    }
    else if (TRL_NOGO_LATE_SACCADE_TIME > 0)
    {
        TIMEOUT_DURATION = TIMEOUT_LATE_NO_SACC[nogoIdx];
        spawnwait PROC_NOGO_ERR();
    }
    else if (TRL_BRK_PRE_TONE_TIME > 0)
    {
        TIMEOUT_DURATION = TIMEOUT_BRK_PRE_TONE[nogoIdx];
        spawnwait PROC_NON_CANCELLED_BRK();
    }
    else if (TRL_BRK_TONE_TIME > 0)
    {
        TIMEOUT_DURATION = TIMEOUT_BRK_TONE[nogoIdx];
        spawnwait PROC_NON_CANCELLED_BRK();
    }
    else if (TRL_BRK_PRE_RWRD_TIME > 0)
    {
        TIMEOUT_DURATION = TIMEOUT_BRK_PRE_RWRD[nogoIdx];
        spawnwait PROC_NON_CANCELLED_BRK();
    }
    else if (TRL_BRK_RWRD_TIME > 0)
    {
        TIMEOUT_DURATION = TIMEOUT_BRK_RWRD[nogoIdx];
        spawnwait PROC_NON_CANCELLED_BRK();
    }
    else if (TRL_IS_MIN_THT <= 0)
    {
        TIMEOUT_DURATION = TIMEOUT_BRK_MIN_THT[nogoIdx];
        spawnwait PROC_NOGO_ERR();
    }
    else if (TRL_IS_XTRA_HOLD_DONE <= 0)
    {
        TIMEOUT_DURATION = TIMEOUT_BRK_XTRA_HOLD[nogoIdx];
        spawnwait PROC_NOGO_ERR();
    }
} /* PROC_NOGO_PRE_CANCEL_OUTCOMES */


// if Eye left fix win After Cancel time
process PROC_NOGO_POST_CANCEL_OUTCOMES()
{
    declare int nogoIdx;

    nogoIdx = NOGO_POST_SSD_IDX;
    if (DEBUG_CONSOLE)
    {
        printf("****STAT_OUTCOME[%d]: TRL_TRIAL_NUMBER[%d] outcome: STOP Trial; POST-SSD, POST-CANCEL\n", STAT_OUTCOME, TRL_TRIAL_NUMBER);
    }
    if (TRL_IS_CANCEL > 0 && TRL_IS_XTRA_HOLD_DONE > 0)
    {
        TRL_IS_CANCELLED_NO_BRK = 1;
        TIMEOUT_DURATION        = 0;
        TRL_IS_TIMEOUT          = 0;
        spawn SEND_EVT(EVT_OUTCOME_NOGO_CANCEL_NO_BRK_);

        TRL_LAST_STOP_OUTCOME_EVNTCODE = EVT_OUTCOME_NOGO_CANCEL_NO_BRK_;
        printf("****STAT_OUTCOME[%d]: TRL_TRIAL_NUMBER[%d] outcome: CANCELLED; SSD [%d, %dms]\n", STAT_OUTCOME, TRL_TRIAL_NUMBER, TRL_USE_SSD_VR_COUNT, TRL_STOP_SIGNAL_DURATION);
        if (DEBUG_CONSOLE)
        {
            printf("****STAT_OUTCOME[%d]: TRL_TRIAL_NUMBER[%d] outcome: EVT_OUTCOME_NOGO_CANCEL_NO_BRK_ [%d]; TRL_IS_STAIRCASE_SSD  [%d]; STOP Trial; (TRL_IS_TARG_IS_CANCEL - OK) \n",
                   STAT_OUTCOME, TRL_TRIAL_NUMBER, EVT_OUTCOME_NOGO_CANCEL_NO_BRK_, TRL_IS_STAIRCASE_SSD);
        }

        SESS_N_CANCEL_NO_BRK_TRLS = SESS_N_CANCEL_NO_BRK_TRLS + 1;
        TRL_BLOCK_N_CORRECT_TRLS      = TRL_BLOCK_N_CORRECT_TRLS + 1;
    }
    else if (TRL_BRK_PRE_TONE_TIME > 0)
    {
        TIMEOUT_DURATION = TIMEOUT_BRK_PRE_TONE[nogoIdx];
        spawnwait PROC_CANCELLED_BRK();
    }
    else if (TRL_BRK_TONE_TIME > 0)
    {
        TIMEOUT_DURATION = TIMEOUT_BRK_TONE[nogoIdx];
        spawnwait PROC_CANCELLED_BRK();
    }
    else if (TRL_BRK_PRE_RWRD_TIME > 0)
    {
        TIMEOUT_DURATION = TIMEOUT_BRK_PRE_RWRD[nogoIdx];
        spawnwait PROC_CANCELLED_BRK();
    }
    else if (TRL_BRK_RWRD_TIME > 0)
    {
        TIMEOUT_DURATION = TIMEOUT_BRK_RWRD[nogoIdx];
        spawnwait PROC_CANCELLED_BRK();
    }
    else if (TRL_IS_CANCEL <= 0)
    {
        TIMEOUT_DURATION = TIMEOUT_BRK_IS_CANCEL[nogoIdx];
        spawnwait PROC_NOGO_ERR();
    }
    else if (TRL_IS_XTRA_HOLD_DONE <= 0)
    {
        TIMEOUT_DURATION = TIMEOUT_BRK_XTRA_HOLD[nogoIdx];
        spawnwait PROC_NOGO_ERR();
    }
} /* PROC_NOGO_POST_CANCEL_OUTCOMES */


process PROC_FIX_BREAK()
{
    spawn SEND_EVT(EVT_OUTCOME_FIX_BREAK_);

    printf("****STAT_OUTCOME[%d]: TRL_TRIAL_NUMBER[%d] outcome: FIX_BREAK\n", STAT_OUTCOME, TRL_TRIAL_NUMBER);

    if (DEBUG_CONSOLE)
    {
        printf("****STAT_OUTCOME[%d]: TRL_TRIAL_NUMBER[%d] outcome: EVT_OUTCOME_FIX_BREAK_ [%d] \n",
               STAT_OUTCOME, TRL_TRIAL_NUMBER, EVT_OUTCOME_FIX_BREAK_);
    }
}


process PROC_GO_ERR()
{
    TRL_IS_GO_ERR = 1;
    spawn SEND_EVT(EVT_OUTCOME_GO_ERR_);

    TRL_LAST_STOP_OUTCOME_EVNTCODE = EVT_OUTCOME_GO_ERR_;
    printf("****STAT_OUTCOME[%d]: TRL_TRIAL_NUMBER[%d] outcome: GO-ERR\n", STAT_OUTCOME, TRL_TRIAL_NUMBER);
    if (DEBUG_CONSOLE)
    {
        printf("****STAT_OUTCOME[%d]: TRL_TRIAL_NUMBER[%d] outcome: EVT_OUTCOME_GO_ERR_ [%d]; Go Trial\n",
               STAT_OUTCOME, TRL_TRIAL_NUMBER, EVT_OUTCOME_GO_ERR_);
    }
    SESS_N_GO_ERROR_TRLS = SESS_N_GO_ERROR_TRLS + 1;
}


process PROC_CANCELLED_BRK()
{
    TRL_IS_CANCELLED_BRK = 1;
    spawn SEND_EVT(EVT_OUTCOME_NOGO_CANCEL_BRK_);

    TRL_LAST_STOP_OUTCOME_EVNTCODE = EVT_OUTCOME_NOGO_CANCEL_BRK_;
    printf("****STAT_OUTCOME[%d]: TRL_TRIAL_NUMBER[%d] outcome: CANCELLED-ERR\n", STAT_OUTCOME, TRL_TRIAL_NUMBER);
    if (DEBUG_CONSOLE)
    {
        printf("****STAT_OUTCOME[%d]: TRL_TRIAL_NUMBER[%d] outcome: **EVT_OUTCOME_NOGO_CANCEL_BRK_** [%d];STOP Trial\n",
               STAT_OUTCOME, TRL_TRIAL_NUMBER, EVT_OUTCOME_NOGO_CANCEL_BRK_);
    }
    SESS_N_CANCEL_BRK_TRLS = SESS_N_CANCEL_BRK_TRLS + 1;
}


process PROC_NON_CANCELLED_BRK()
{
    TRL_IS_NON_CANCELLED_BRK = 1;
    spawn SEND_EVT(EVT_OUTCOME_NOGO_NON_CANCEL_BRK_);

    TRL_LAST_STOP_OUTCOME_EVNTCODE = EVT_OUTCOME_NOGO_NON_CANCEL_BRK_;
    printf("-****STAT_OUTCOME[%d]: TRL_TRIAL_NUMBER[%d] outcome: NON-CANCELLED-ERR\n", STAT_OUTCOME, TRL_TRIAL_NUMBER);
    if (DEBUG_CONSOLE)
    {
        printf("****STAT_OUTCOME[%d]: TRL_TRIAL_NUMBER[%d] outcome: **EVT_OUTCOME_NOGO_NON_CANCEL_BRK_** [%d];STOP Trial\n",
               STAT_OUTCOME, TRL_TRIAL_NUMBER, EVT_OUTCOME_NOGO_NON_CANCEL_BRK_);
    }
    SESS_N_NON_CANCEL_BRK_TRLS = SESS_N_NON_CANCEL_BRK_TRLS + 1;
}


process PROC_NOGO_ERR()
{
    TRL_IS_NOGO_ERR = 1;
    spawn SEND_EVT(EVT_OUTCOME_NOGO_ERR_);

    TRL_LAST_STOP_OUTCOME_EVNTCODE = EVT_OUTCOME_NOGO_ERR_;
    printf("-****STAT_OUTCOME[%d]: TRL_TRIAL_NUMBER[%d] outcome: NOGO-ERR\n", STAT_OUTCOME, TRL_TRIAL_NUMBER);
    if (DEBUG_CONSOLE)
    {
        printf("****STAT_OUTCOME[%d]: TRL_TRIAL_NUMBER[%d] outcome: EVT_OUTCOME_NOGO_ERR_ [%d]; STOP Trial\n",
               STAT_OUTCOME, TRL_TRIAL_NUMBER, EVT_OUTCOME_NOGO_ERR_);
    }
    SESS_N_NOGO_ERROR_TRLS = SESS_N_NOGO_ERROR_TRLS + 1;
}
