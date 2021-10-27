//==========================================================================
// MAIN_MNU.PRO
//   Description: Loads all PRO files for CMD task
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-01-23
//==========================================================================
//  Revision History:
//
//==========================================================================
// Use variables on the fly - no declaration
#pragma declare = 1

//#include C:/TEMPO/ProcLib/CMD_TSK.PRO
//#include C:/TEMPO/ProcLib/TEST/TEST_SSD.PRO

declare int TASK;
declare int TASK_TEST_SSD = 0;
declare int TASK_CMD      = 1;


declare MAIN_MNU();


process MAIN_MNU() enabled
{
    if (TASK == TASK_TEST_SSD)
    {
        pload C:/TEMPO/ProcLib/TEST/TEST_SSD.PRO;
    }
    else
    {
        pload C:/TEMPO/ProcLib/CMD_TSK.PRO;
    }
}
