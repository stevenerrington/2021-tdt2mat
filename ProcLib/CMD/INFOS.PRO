//==========================================================================
// EVENTDEF.PRO
//   Description: Send all infos (call during ITI_CHK or TIME_OUT state processing).
//                ALL TRL_* variables are sent.
//                This file will be used for translating the session/infos variables
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-03-07
//==========================================================================
declare SEND_INFOS();
declare SEND_INFO_EVT(int evtVal);
declare SEND_INFO_REL_TIME(int evtVal, int offsetVal);

declare constant int INFOS_ZERO = 3000;
declare int          N_INFOS;


process SEND_INFOS()
{
    declare int TRL_RAND_NEG_NUMBER_TEST;

    N_INFOS = 0;
    printf("****INFOS.PRO: Sending infos....\n");
    TRL_RAND_NEG_NUMBER_TEST = -((random(5000) + 1) * 2);
    spawn SEND_INFO_EVT(TRL_RAND_NEG_NUMBER_TEST);
    spawn SEND_INFO_EVT(TRL_TRIAL_NUMBER);
    spawn SEND_INFO_EVT(TRL_BLOCK_NUM);
    spawn SEND_INFO_EVT(TRL_TRIAL_TYPE);
    spawn SEND_INFO_EVT(TRL_IS_FIX_ON);
    spawn SEND_INFO_EVT(TRL_IS_FIX_ACQUIRED);
    spawn SEND_INFO_EVT(TRL_IS_TARGET_ON);
    spawn SEND_INFO_EVT(TRL_IS_TARG_ACQUIRED);
    spawn SEND_INFO_EVT(TRL_IS_STOP_SIGNAL_ON);
    spawn SEND_INFO_EVT(TRL_IS_XTRA_HOLD_DONE);
    spawn SEND_INFO_EVT(TRL_IS_MIN_THT);
    spawn SEND_INFO_EVT(TRL_IS_CANCEL);
    spawn SEND_INFO_EVT(TRL_IS_TIMEOUT);
    spawn SEND_INFO_EVT(TRL_IS_GO_CORRECT);
    spawn SEND_INFO_EVT(TRL_IS_GO_ERR);
    spawn SEND_INFO_EVT(TRL_IS_CANCELLED_NO_BRK);
    spawn SEND_INFO_EVT(TRL_IS_CANCELLED_BRK);
    spawn SEND_INFO_EVT(TRL_IS_NON_CANCELLED_NO_BRK);
    spawn SEND_INFO_EVT(TRL_IS_NON_CANCELLED_BRK);
    spawn SEND_INFO_EVT(TRL_IS_NOGO_ERR);
    spawn SEND_INFO_EVT(TRL_IS_LO_RWRD);
    spawn SEND_INFO_EVT(TRL_IS_MED_RWRD);
    spawn SEND_INFO_EVT(TRL_IS_HI_RWRD);
    spawn SEND_INFO_EVT(TRL_IS_FIX_REIGNITE);
    spawn SEND_INFO_EVT(TRL_IS_STAIRCASE_SSD);
    spawn SEND_INFO_EVT(TRL_IS_REFIX);
    spawn SEND_INFO_EVT(TRL_CUM_DURATION);
    spawn SEND_INFO_EVT(TRL_GET_READY_DURATION);
    spawn SEND_INFO_EVT(TRL_FIX_HOLD_DURATION);
    spawn SEND_INFO_EVT(TRL_REFIX_HOLD_DURATION);
    spawn SEND_INFO_EVT(TRL_CANCEL_DURATION);
    spawn SEND_INFO_EVT(TRL_MIN_THT_DURATION);
    spawn SEND_INFO_EVT(TRL_TARG_ON_DURATION);
    spawn SEND_INFO_EVT(TRL_XTRA_HOLD_DURATION);
    spawn SEND_INFO_EVT(TRL_SACC_DURATION);
    spawn SEND_INFO_EVT(TRL_TARG_HOLD_DURATION);
    spawn SEND_INFO_EVT(TRL_STOP_SIGNAL_DURATION);
    spawn SEND_INFO_EVT(TRL_ITI_DURATION);
    spawn SEND_INFO_EVT(TRL_TIMEOUT_DURATION);
    spawn SEND_INFO_EVT(TRL_TARG_VR_COUNT);
    spawn SEND_INFO_EVT(TRL_SSD_VR_COUNT);
    spawn SEND_INFO_EVT(TRL_USE_TRIAL_DURATION);
    spawn SEND_INFO_EVT(TRL_USE_SSD_IDX);
    spawn SEND_INFO_EVT(TRL_USE_STAIRCASE);
    spawn SEND_INFO_EVT(TRL_USE_SSD_STEP_UP);
    spawn SEND_INFO_EVT(TRL_USE_SSD_STEP_DOWN);
    spawn SEND_INFO_EVT(TRL_USE_USE_PROVIDED_TRL_LENGTH);
    spawn SEND_INFO_EVT(TRL_USE_SSD_VR_COUNT);
    spawn SEND_INFO_EVT(TRL_USE_FIX_HOLD_DURATION);
    spawn SEND_INFO_EVT(TRL_USE_FIX_HOLD_ADJUST);
    spawn SEND_INFO_EVT(TRL_USE_MIN_THT_DURATION);
    spawn SEND_INFO_EVT(TRL_USE_SSD_CANCEL_DURATION);
    spawn SEND_INFO_EVT(TRL_USE_PRE_SSD_FIX_ON_DELAY);
    spawn SEND_INFO_EVT(TRL_USE_POST_SSD_FIX_ON_DELAY);
    spawn SEND_INFO_EVT(TRL_USE_TONE_DELAY);
    spawn SEND_INFO_EVT(TRL_USE_TONE_FREQ);
    spawn SEND_INFO_EVT(TRL_USE_TONE_DURATION);
    spawn SEND_INFO_EVT(TRL_USE_RWRD_DELAY);
    spawn SEND_INFO_EVT(TRL_USE_RWRD_DURATION);
    spawn SEND_INFO_EVT(TRL_USE_ITI_DURATION);
    spawn SEND_INFO_EVT(TRL_USE_TIMEOUT_DURATION);
    spawn SEND_INFO_EVT(TRL_USE_CORRECT_TRIALS_PER_BLOCK);
    spawn SEND_INFO_EVT(TRL_USE_REPEAT_LO_RWRD_ERROR_TRL);
    spawn SEND_INFO_EVT(TRL_USE_REPEAT_MAX);
    spawn SEND_INFO_EVT(TRL_USE_XTRA_HOLD_DURATION);
    spawn SEND_INFO_EVT(TRL_USE_XTRA_HOLD_TONE_RWRD_FLAG);
    spawn SEND_INFO_EVT(TRL_CURR_TARG_IDX);
    spawn SEND_INFO_EVT(int(TRL_CURR_TARG_SIZE * 100));
    spawn SEND_INFO_EVT(int(TRL_CURR_TARG_ANGLE * 100));
    spawn SEND_INFO_EVT(int(TRL_CURR_TARG_ECCENTRICITY * 100));
    spawn SEND_INFO_EVT(TRL_CURR_TARG_COLOR_IDX);
    spawn SEND_INFO_EVT(TRL_LO_RWRD_TARG_IDX);
    spawn SEND_INFO_EVT(TRL_REPEAT_COUNT);
    spawn SEND_INFO_EVT(TRL_LAST_STOP_OUTCOME_EVNTCODE);
    spawn SEND_INFO_EVT(TRL_LAST_GO_OUTCOME_EVNTCODE);
    spawn SEND_INFO_EVT(TRL_BLOCK_N_CORRECT_TRLS);
    spawn SEND_INFO_EVT(TRL_LAST_SSD_IDX);

    // Last info code
    spawn SEND_INFO_EVT(N_INFOS);

    nexttick;
} /* SEND_INFOS */


process SEND_INFO_EVT(int evtVal)
{
    N_INFOS = N_INFOS + 1;
    if (evtVal <= 0)
    {
        evtVal = 32768 - INFOS_ZERO - evtVal;
    }
    spawn SEND_EVT(INFOS_ZERO + evtVal);

    nexttick;
}


process SEND_INFO_REL_TIME(int evtVal, int offsetVal)
{
    declare int temp;

    N_INFOS = N_INFOS + 1;
    if (evtVal == 0)
    {
        temp = 0;
    }
    else if (evtVal == -1)
    {
        temp = -1;
    }
    else
    {
        temp = evtVal - offsetVal;
    }
    if (temp <= 0)
    {
        temp = 32768 - INFOS_ZERO - temp;
    }
    spawn SEND_EVT(INFOS_ZERO + temp);

    nexttick;
}
