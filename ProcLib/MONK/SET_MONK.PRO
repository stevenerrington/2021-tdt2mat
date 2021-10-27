//==========================================================================
// SET_MONK.PRO
//   Description: Setup All subject ids for tempo.
//                Each subject [NAME]_ID must have an accompanying
//                MONK/[NAME].PRO that [re]defines vars in given task for
//                example VAR_CMD.PRO.  Try not to add extra *global* declares,
//                instead add them to appropriate VAR_[task].PRO.
//
//   NOTE:
//       Create MONK/[name].PRO with process MONK_[name]() file for each monk used.  Define
//       parameters as needed for that subject
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-01-20
//==========================================================================
//  Revision History:
//

#include C:/TEMPO/ProcLib/MONK/AUTO.PRO
#include C:/TEMPO/ProcLib/MONK/JOULE.PRO

declare int MONK_ID;
declare int AUTO_ID  = 0;
declare int JOULE_ID = 1;

declare SET_MONK(int monkId);


process SET_MONK(int monkId)
{
    MONK_ID = monkId;
    if (MONK_ID == AUTO_ID)
    {
        spawnwait AUTO();
    }
    else if (MONK_ID == JOULE_ID)
    {
        spawnwait JOULE();
    }
    spawnwait SET_CLR_PALETTE();
}
