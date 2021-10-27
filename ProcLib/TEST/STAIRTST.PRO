//==========================================================================
// DISTTEST.PRO
//   Description: Test process in CMD/STAIR.PRO/STAIRCASE_SSD()
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-03-06
//==========================================================================

// Global variables accessed by STAIRCASR_SSD()
#include C:/TEMPO/ProcLib/CMD/VAR_CMD.PRO
#include C:/TEMPO/ProcLib/CMD/SET_CMD.PRO
#include C:/TEMPO/ProcLib/CMD/STAIR.PRO

declare STAIRCASE_SSD_TEST();


process STAIRCASE_SSD_TEST() enabled
{
    declare int nTrials = 2000;
    declare int trlNo;
    declare int nogoErrorRunCount = 4;
    declare int stopOutcomes[3]   = { EVT_OUTCOME_NOGO_CANCEL_NO_BRK_, EVT_OUTCOME_NOGO_NON_CANCEL_NO_BRK_, EVT_OUTCOME_NOGO_ERR_ };
    declare int goOutcomes[2]     = { EVT_OUTCOME_GO_CORRECT_, EVT_OUTCOME_GO_ERR_ };

    SSD_STEP_UP   = 3;
    SSD_STEP_DOWN = 3;
    N_SSD         = 10;

    writef("stairSsd.csv trlNo, trialType, trlLastGoOutcome, trlLastStopOutcome, trlLastSsdIdx, trlSsdIdx\n");
    while (trlNo < nTrials)
    {
        trlNo          = trlNo + 1;
        TRL_TRIAL_TYPE = TRIAL_TYPE_GO;
        if (random(2) > 0)
        {
            TRL_TRIAL_TYPE = TRIAL_TYPE_STOP;
        }
        if (trlNo > 1) // dont know outcomes for trial 1
        {
            if (TRL_TRIAL_TYPE == TRIAL_TYPE_GO)
            {
                TRL_LAST_GO_OUTCOME_EVNTCODE = goOutcomes[random(2)];
            }
            else
            {
                TRL_LAST_STOP_OUTCOME_EVNTCODE = stopOutcomes[random(3)];
            }
        }
        // set the trl SSD
        if (TRL_TRIAL_TYPE == TRIAL_TYPE_STOP)
        {
            spawnwait STAIRCASE_SSD(TRL_LAST_STOP_OUTCOME_EVNTCODE, TRL_LAST_SSD_IDX, SSD_STEP_UP, SSD_STEP_DOWN, N_SSD, 1);

            TRL_USE_SSD_IDX = TRL_IS_STAIRCASE_SSD;
            printf("%d,%d,%d,%d,%d,%d\n", trlNo, TRL_TRIAL_TYPE, TRL_LAST_GO_OUTCOME_EVNTCODE, TRL_LAST_STOP_OUTCOME_EVNTCODE, TRL_LAST_SSD_IDX, TRL_USE_SSD_IDX);
            writef("stairSsd.csv %d,%d,%d,%d,%d,%d\n", trlNo, TRL_TRIAL_TYPE, TRL_LAST_GO_OUTCOME_EVNTCODE, TRL_LAST_STOP_OUTCOME_EVNTCODE, TRL_LAST_SSD_IDX, TRL_USE_SSD_IDX);

            TRL_LAST_SSD_IDX = TRL_USE_SSD_IDX;
        }
        else
        {
            // should we put a -1?
            TRL_USE_SSD_IDX = 0;
            printf("%d,%d,%d,%d,%d,%d\n", trlNo, TRL_TRIAL_TYPE, TRL_LAST_GO_OUTCOME_EVNTCODE, TRL_LAST_STOP_OUTCOME_EVNTCODE, TRL_LAST_SSD_IDX, TRL_USE_SSD_IDX);
            writef("stairSsd.csv %d,%d,%d,%d,%d,%d\n", trlNo, TRL_TRIAL_TYPE, TRL_LAST_GO_OUTCOME_EVNTCODE, TRL_LAST_STOP_OUTCOME_EVNTCODE, TRL_LAST_SSD_IDX, TRL_USE_SSD_IDX);
        }

        nexttick 2;
    }
    printf("\n****Writing file : stairSsd.csv---will complete--ONLY when you exit the TEMPO Client****\n");
}/* STAIRCASE_SSD_TEST */
