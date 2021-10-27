//==========================================================================
// STAIR.PRO
//   Description: Process to pick the STAIRCASE_NEXT_SSD_IDX for the stop trial.
//                It is assumed that the SSD_ARRY contains SSDs in *increasing* order.
//
//     Case0: If lastStopOutcomeEvntCode == EVT_OUTCOME_NOGO_CANCEL_NO_BRK_
//               Increase the SSD. STAIRCASE_NEXT_SSD_IDX =  lastSsdIdx + (random(stepUpMax) + 1)
//     Case1: If lastStopOutcomeEvntCode == EVT_OUTCOME_NOGO_NON_CANCEL_NO_BRK_
//               Decrease the SSD. STAIRCASE_NEXT_SSD_IDX =  lastSsdIdx - (random(stepDownMax) + 1)
//     Case2: If lastStopOutcomeEvntCode == EVT_OUTCOME_NOGO_ERR_
//               Repeat the SSD. STAIRCASE_NEXT_SSD_IDX =  lastSsdIdx
//
//   Author: steven.errington@vanderbilt.edu
//   Date: 2014-01
//==========================================================================

declare STAIRCASE_NEXT_SSD(int lastStopOutcomeEvntCode, int lastSsdIdx, int stepUpMax, int stepDownMax, int nSSD, int staircaseFlag);

declare int STAIRCASE_NEXT_SSD_IDX;
// pick a random SSD index for very first stop trial
declare int IS_FIRST_STOP_TRIAL;


process STAIRCASE_NEXT_SSD(int lastStopOutcomeEvntCode, int lastSsdIdx, int stepUpMax, int stepDownMax, int nSSD, int staircaseFlag)
{
    // nSSDs should have been set here : see SET_CMD.PRO/PICK_TRL_SSD
    declare int tempVar;

    if (DEBUG_CONSOLE)
    {
        printf("****STAIR.PRO/STAIRCASE_NEXT_SSD: lastStopOutcomeEvntCode [%d], lastSsdIdx [%d], stepUpMax [%d], stepDownMax [%d], nSSD [%d], staircaseFlag [%d]\n",
               lastStopOutcomeEvntCode, lastSsdIdx, stepUpMax, stepDownMax, nSSD, staircaseFlag);
    }
    if (staircaseFlag == 0)
    {
        STAIRCASE_NEXT_SSD_IDX = random(nSSD);
        if (DEBUG_CONSOLE)
        {
            printf("****STAIR.PRO/STAIRCASE_NEXT_SSD: ****staircaseFlag [%d]****\n", staircaseFlag);
            printf("****STAIR.PRO/STAIRCASE_NEXT_SSD: lastSssdIdx [%d], --> next: RANDOM ", lastSsdIdx);
        }
    }
    else if (lastStopOutcomeEvntCode == EVT_OUTCOME_NOGO_CANCEL_NO_BRK_ || lastStopOutcomeEvntCode == EVT_OUTCOME_NOGO_CANCEL_BRK_)
    {
        STAIRCASE_NEXT_SSD_IDX = lastSsdIdx + random(stepUpMax) + 1;
        if (DEBUG_CONSOLE)
        {
            printf("****STAIR.PRO/STAIRCASE_NEXT_SSD: ****STEP-UP****\n");
            printf("*********LastStopOutcome [%d] is (EVT_OUTCOME_NOGO_CANCEL_NO_BRK_ [%d] or EVT_OUTCOME_NOGO_CANCEL_BRK_ [%d]), lastSssdIdx [%d], --> ",
                   lastStopOutcomeEvntCode, EVT_OUTCOME_NOGO_CANCEL_NO_BRK_, EVT_OUTCOME_NOGO_CANCEL_BRK_, lastSsdIdx);
        }
    }
    else if (lastStopOutcomeEvntCode == EVT_OUTCOME_NOGO_NON_CANCEL_NO_BRK_ || lastStopOutcomeEvntCode == EVT_OUTCOME_NOGO_NON_CANCEL_BRK_)
    {
        STAIRCASE_NEXT_SSD_IDX = lastSsdIdx - (random(stepDownMax) + 1);
        if (DEBUG_CONSOLE)
        {
            printf("****STAIR.PRO/STAIRCASE_NEXT_SSD: ****STEP-DOWN****\n");
            printf("*********LastStopOutcome [%d] is (EVT_OUTCOME_NOGO_NON_CANCEL_NO_BRK_[%d] or EVT_OUTCOME_NOGO_NON_CANCEL_BRK_ [%d]), lastSssdIdx [%d], --> ",
                   lastStopOutcomeEvntCode, EVT_OUTCOME_NOGO_NON_CANCEL_NO_BRK_, EVT_OUTCOME_NOGO_NON_CANCEL_BRK_, lastSsdIdx);
        }
    }
    else if (lastStopOutcomeEvntCode == EVT_OUTCOME_NOGO_ERR_)
    {
        STAIRCASE_NEXT_SSD_IDX = lastSsdIdx;
        if (DEBUG_CONSOLE)
        {
            printf("****STAIR.PRO/STAIRCASE_NEXT_SSD: ****NO-CHANGE****\n");
            printf("*********LastStopOutcome [%d] is EVT_OUTCOME_NOGO_ERR_ []%d], lastSssdIdx [%d], -->  ",
                   lastStopOutcomeEvntCode, EVT_OUTCOME_NOGO_ERR_, lastSsdIdx);
        }
    }
    else
    {
        STAIRCASE_NEXT_SSD_IDX = random(nSSD);
        if (DEBUG_CONSOLE)
        {
            printf("****STAIR.PRO/STAIRCASE_NEXT_SSD: ****RANDOM****\n");
        }
        if (IS_FIRST_STOP_TRIAL <= 0)
        {
            IS_FIRST_STOP_TRIAL = 1;
            if (DEBUG_CONSOLE)
            {
                printf("*********LastStopOutcome *UNKNOWN* TRL_NUMBER = [%d], lastssdIdx [first-stop-trial], --> ");
            }
        }
        else
        {
            printf("++++++++++++++++++++ERROR IN STAIRCASING AFTER FIRST STOP TRIAL++++++++++++++++\n");
            printf("++++++++++++++++++++ERROR LastStopOutcome [%d] UNKNOWN, lastssdIdx [%d]++++++++++++++++ --> ",
                   lastStopOutcomeEvntCode, lastSsdIdx);
        }
    }
    // Check limits
    if (STAIRCASE_NEXT_SSD_IDX <= 0)
    {
        STAIRCASE_NEXT_SSD_IDX = 0;
    }
    else if (STAIRCASE_NEXT_SSD_IDX >= nSSD)
    {
        STAIRCASE_NEXT_SSD_IDX = nSSD - 1;
    }

    printf("****STAIR/STAIRCASE_NEXT_SSD STAIRCASE_NEXT_SSD_IDX = [%d]\n", STAIRCASE_NEXT_SSD_IDX);
}/* STAIRCASE_NEXT_SSD */
