//==========================================================================
// CMD_TSK.PRO
//   Description: Loads all PRO files for CMD task
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-01-14
//==========================================================================
//  Revision History:
//
//==========================================================================
// Use variables on the fly - no declaration
#pragma declare = 1

#include C:/TEMPO/ProcLib/UTIL/WAIT_VDO.PRO
#include C:/TEMPO/ProcLib/CMD/SET_CMD.PRO
#include C:/TEMPO/ProcLib/CMD/EVENTDEF.PRO
#include C:/TEMPO/ProcLib/UTIL/TONE.PRO
#include C:/TEMPO/ProcLib/UTIL/JUICE.PRO
#include C:/TEMPO/ProcLib/CLEAR_VDO.PRO
#include C:/TEMPO/ProcLib/CALIBR8.PRO

// State flow
#include C:/TEMPO/ProcLib/CMD/STATES/GET_REDY.PRO
#include C:/TEMPO/ProcLib/CMD/STATES/FIX_ON.PRO
#include C:/TEMPO/ProcLib/CMD/STATES/FIX_HOLD.PRO
#include C:/TEMPO/ProcLib/CMD/STATES/TARG_VR.PRO
#include C:/TEMPO/ProcLib/CMD/STATES/TARG_ON.PRO
#include C:/TEMPO/ProcLib/CMD/STATES/TARG_SSD.PRO
#include C:/TEMPO/ProcLib/CMD/STATES/TARG_ACQ.PRO
#include C:/TEMPO/ProcLib/CMD/STATES/TARG_HLD.PRO
#include C:/TEMPO/ProcLib/CMD/STATES/TONE_CHK.PRO
#include C:/TEMPO/ProcLib/CMD/STATES/TONE_SSD.PRO
#include C:/TEMPO/ProcLib/CMD/STATES/RWRD_CHK.PRO
#include C:/TEMPO/ProcLib/CMD/STATES/RWRD_SSD.PRO
#include C:/TEMPO/ProcLib/CMD/STATES/OUTCOME.PRO
#include C:/TEMPO/ProcLib/CMD/STATES/ITI_CHK.PRO
#include C:/TEMPO/ProcLib/CMD/STATES/TIME_OUT.PRO
#include C:/TEMPO/ProcLib/CMD/STATES/RFIX_CHK.PRO
#include C:/TEMPO/ProcLib/CMD/INFOS.PRO

#include C:/TEMPO/ProcLib/WATCH/RITE_EYE.PRO
declare int WRITE_RAW_EYE_DATA = 0;

//==========================================================================
declare IDLE();
declare UPD8_MSG();
declare WRITE_TO_FILE();
declare USER_SUMMARY();

declare int WRITE_TO_FILE_FLAG = 0;
declare int WROTE_HEADER       = 0;
declare int TEST               = 100;
declare int RUN_TASK           = 0;
declare int SHOW_PAGES         = 0;
declare int CALIBRATE_EYE      = 0;
declare int RIG_IS_SET         = 0;
declare int MONK_IS_SET        = 0;


process IDLE() enabled
{
    declare int tempCount;
    declare int infosStartT;
    declare int infosDuration;
    declare int doOnce;

    seed1(timeus());
    // activate seed by drawing a number from some distribution
    normal(1);

    // ========== Call once =============
    //RIG_ID = 29;
    //MONK_ID = JOULE_ID;

    printf("Setting SET_RIG\n");
    spawnwait SET_RIG(RIG_ID);

    printf("Setting SET_DEFAULT_COLORS\n");
    spawnwait SET_DEFAULT_COLORS();

    printf("Setting SET_DEFAULT_STIM_VARS\n");
    spawnwait SET_DEFAULT_STIM_VARS();

    printf("Setting monkID\n");
    spawnwait SET_MONK(MONK_ID);

    // Setup WATCHES
    printf("Setting GRAPHS\n");
    spawn GRAPHS();

    printf("Setting QUE_TTL\n");
    spawn QUE_TTL();

    printf("Setting WTCH_EYE\n");
    spawn WTCH_EYE();

    printf("Setting WTCH_SCHMITT\n");
    spawn WTCH_SCHMITT();

    if (WRITE_RAW_EYE_DATA)
    {
        printf("*******************WRITING RAW EYE DATA TO FILE*****************\n");
        spawn PROC_WRITE_RAW_I_DATA();
    }
    doOnce = 0;

    while (1)
    {
        //===============For each Trial=====================
        if (SHOW_PAGES)
        {
            TRL_IS_RUNNING = 0;
            spawnwait CMD_PGS(1.0, random(2) *180.0, 12.0, 1);

            printf("Showing Virtual Pages for COUNTERMANDING TASK\n");
            tempCount = 7;
            while(1)
            {
            while (tempCount < PG_MAX_PAGE_IDX + 1)
            {
                //printf("Showing page %d\n",tempCount);
                dsendf("vp %d\n", tempCount);
                nexttick 100;
                tempCount = tempCount + 1;
                //nexttick 1000;
                //dsendf("vp %d\n", PG_BLANK);
               // nexttick 500;
            }
            tempCount = 7;
            nexttick;
            }
            dsendf("vp %d\n", 0);
            printf("****Done showing Virtual Pages for COUNTERMANDING TASK\n\n");
        }
        else if (CALIBRATE_EYE)
        {
            spawnwait PROC_CALIBRATE();
        }
        else if (RUN_TASK)
        {
            printf("=============Setting TRIAL variables\n==================");
            spawnwait SET_CMD_TRL();

            printf("Done Setting TRIAL variables\n");

            if (doOnce == 0)
            {
                printf("Sending EVT_IDENTIFY_ROOM_\n");
                spawn SEND_EVT(EVT_IDENTIFY_ROOM_);

                printf("Sending RIG_ID\n");
                spawn SEND_EVT(RIG_ID);

                doOnce = 1;
            }
            PROCESS_STATE  = 1;
            TRL_IS_RUNNING = 1;
            printf("Trial running....\n");
            TRL_TASK_START_TIME = time();
            spawn SEND_EVT(EVT_TASK_START_);
            spawn SEND_EVT(EVT_CMAN_HEADER_);

            CURR_STAT   = STAT_GET_READY;
            STAT_DLTA_T = 0;
        }
        //CURR_STAT=STAT_TEST;
        while (TRL_IS_RUNNING)
        {
            while (CURR_STAT == STAT_TEST)
            {
                CURR_STAT = STAT_TEST;
                dsendf("vp %d\n", PG_FIXATION_PD);
                TRL_IS_RUNNING = 0;
                nexttick 100000;
            }

            //================= State = STAT_GET_READY===============
            if (CURR_STAT == STAT_GET_READY)
            {
                spawnwait PROC_GET_REDY();
            }
            //================= State = STAT_FIX_ON===============
            if (CURR_STAT == STAT_FIX_ON)
            {
                spawnwait PROC_FIX_ON();
            }
            //================= State = STAT_FIX_HOLD===============
            if (CURR_STAT == STAT_FIX_HOLD)
            {
                spawnwait PROC_FIX_HOLD();
            }
            //================= State = STAT_TARG_ON===============
            if (CURR_STAT == STAT_TARG_ON)
            {
                if (TRL_TRIAL_TYPE == TRIAL_TYPE_STOP)
                {
                    CURR_STAT = STAT_TARG_SSD;
                    spawnwait PROC_TARG_SSD();
                }
                else
                {
                    spawnwait PROC_TARG_ON();
                }
            }
            if (CURR_STAT == STAT_TARG_SSD)
            {
                spawnwait PROC_TARG_SSD();
            }
            //================= State = STAT_TARG_ACQ===============
            if (CURR_STAT == STAT_TARG_ACQ)
            {
                spawnwait PROC_TARG_ACQ();
            }
            //================= State = STAT_TARG_HOLD===============
            if (CURR_STAT == STAT_TARG_HOLD)
            {
                spawnwait PROC_TARG_HOLD();
            }
            //================= State = STAT_TONE_CHK===============
            if (CURR_STAT == STAT_TONE_CHK)
            {
                spawnwait PROC_TONE_CHK();
            }
            //================= State = STAT_RWRD_CHK===============
            if (CURR_STAT == STAT_RWRD_CHK)
            {
                spawnwait PROC_RWRD_CHK();
            }
            //================= State = STAT_TONE_SSD===============
            if (CURR_STAT == STAT_TONE_SSD)
            {
                spawnwait PROC_TONE_SSD();
            }
            //================= State = STAT_RWRD_SSD===============
            if (CURR_STAT == STAT_RWRD_SSD)
            {
                spawnwait PROC_RWRD_SSD();
            }
            //================= State = STAT_REFIX_CHK===============
            if (CURR_STAT == STAT_REFIX_CHK)
            {
                spawnwait PROC_REFIX_CHK();
            }
            //================= State = STAT_OUTCOME===============
            if (CURR_STAT == STAT_OUTCOME)
            {
                spawnwait PROC_TRL_OUTCOME();
            }
            //================= State = STAT_ITI_CHK===============
            if (CURR_STAT == STAT_ITI_CHK)
            {
                spawnwait PROC_ITI_CHK();
            }
            //================= State = STAT_TIM_OUT===============
            if (CURR_STAT == STAT_TIM_OUT)
            {
                spawnwait PROC_TIMEOUT_CHK();
            }
            if (CURR_STAT == STAT_IDLE)
            {
                printf("Sending BLANK page\n");
                dsendf("vp %d\n", PG_BLANK);

                TRL_START_INFOS_TIME = time();
                spawn SEND_EVT(EVT_INFOS_START_);

                printf("****CMD_TSK: Sending Infos: SEND_INFOS()\n");
                spawn SEND_INFOS();

                waitforprocess SEND_INFOS;

                TRL_END_INFOS_TIME = time();
                spawn SEND_EVT(EVT_INFOS_END_);

                TRL_TASK_END_TIME = time();
                spawn SEND_EVT(EVT_TASK_END_);
                
                
                if(DEBUG_CONSOLE)
                {
                    printf("****CMD_TSK: OK (Ending Task) sent Event: EVT_TASK_END_[%d]\n", EVT_TASK_END_);
                }
                printf("****CMD_TSK: OK (Ending Task) TRL_TRIAL_NUMBER [%d], TRL_CUM_DURATION[%d]\n", TRL_TRIAL_NUMBER, TRL_CUM_DURATION);
                TRL_IS_RUNNING = 0;
                PROCESS_STATE  = 0;
            }
            //================= State = xxxxxx===============
            if (INCEMENT_TARG_DURATION_FLAG == 1)
            {
                TRL_TARG_ON_DURATION = TRL_TARG_ON_DURATION + 1;
            }
            STAT_DLTA_T = STAT_DLTA_T + 1;
            if (TRL_TRIAL_START_TIME > 0)
            {
                TRL_CUM_DURATION = TRL_CUM_DURATION + 1;
            }
            nexttick;
        }         /*while(TRL_IS_RUNNING)*/
        if (RUN_TASK > 0)
        {
            spawnwait WRITE_TO_FILE();
            spawnwait USER_SUMMARY();

            printf("============================NEXT TRIAL========================\n");
        }
        nexttick;
    }         /*while(1)*/
} /*IDLE()*/


process USER_SUMMARY()
{
    printf("**********************************\n");
    printf("Trial Number: [%d]\n", TRL_TRIAL_NUMBER);
    printf("GO/CANCELLED/NON-CANCELLED [%d]/[%d]/[%d] \n",
           SESS_N_GO_CORRECT_TRLS, SESS_N_CANCEL_NO_BRK_TRLS, SESS_N_NON_CANCEL_NO_BRK_TRLS);
    printf("CANCELLED_BRK/NON_CANCELLED_BRK [%d]/[%d] \n",
           SESS_N_CANCEL_BRK_TRLS, SESS_N_NON_CANCEL_BRK_TRLS);
    printf("GO ERROR/ NOGO_ERROR: [%d]/[%d] \n",
           SESS_N_GO_ERROR_TRLS, SESS_N_NOGO_ERROR_TRLS);
    printf("TRL_BLOCK_NUM [%d] : TRL_BLOCK_N_CORRECT_TRLS/ TRL_USE_CORRECT_TRIALS_PER_BLOCK: [%d]/[%d] \n",
           TRL_BLOCK_NUM, TRL_BLOCK_N_CORRECT_TRLS, TRL_USE_CORRECT_TRIALS_PER_BLOCK);
    nexttick;
}


process UPD8_MSG()
{
    declare int dummy = 0;

    dummy = 1;
    printf("TRL_NUM [%d], TRL_CUM_DURATION [%d], CURR_STAT [%d], STAT_DLTA_T [%d]\n", TRL_TRIAL_NUMBER, TRL_CUM_DURATION, CURR_STAT, STAT_DLTA_T);
}


process WRITE_TO_FILE()
{
    if (WRITE_TO_FILE_FLAG)
    {
        printf("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n", TRL_TRIAL_NUMBER, TRL_USE_SSD_VR_COUNT, TRL_SSD_VR_COUNT, TRL_TARGET_TIME,
               TRL_STOP_SIGNAL_TIME, TRL_STOP_SIGNAL_DURATION, TRL_FIX_ON_TIME, TRL_ACQUIRE_FIX_TIME, TRL_FIX_HOLD_DURATION, TRL_FIXATE_TIME);
        if (!WROTE_HEADER)
        {
            writef("stopSig.csv TRL_TRIAL_NUMBER,TRL_USE_SSD_VR_COUNT,TRL_SSD_VR_COUNT,TRL_TARGET_TIME,");
            writef("stopSig.csv TRL_STOP_SIGNAL_TIME,TRL_STOP_SIGNAL_DURATION,TRL_FIX_ON_TIME,TRL_ACQUIRE_FIX_TIME,TRL_FIX_HOLD,TRL_FIXATE_TIME\n");
            WROTE_HEADER = 1;
        }
        writef("stopSig.csv %d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n", TRL_TRIAL_NUMBER, TRL_USE_SSD_VR_COUNT, TRL_SSD_VR_COUNT, TRL_TARGET_TIME,
               TRL_STOP_SIGNAL_TIME, TRL_STOP_SIGNAL_DURATION, TRL_FIX_ON_TIME, TRL_ACQUIRE_FIX_TIME, TRL_FIX_HOLD_DURATION, TRL_FIXATE_TIME);
    }
}
