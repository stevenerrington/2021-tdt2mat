//==========================================================================
// SET_RIG.PRO
//   Description: Setup All RIG ids for tempo.
//                Each rig [NAME]_ID must have an accompanying
//                RIG/[NAME].PRO that [re]defines vars in given task for
//                example VAR_RIG.PRO.  Try not to add extra *global* declares,
//                instead add them to appropriate VAR_[RIG].PRO.
//
//   NOTE:
//       Create RIG/[name].PRO with process RIG_[name]() file for each rig used.  Define
//       parameters as needed for that rig
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-01-21
//==========================================================================
//  Revision History:

// Screen setip
#include C:/TEMPO/ProcLib/UTIL/SET_SCRN.PRO

// Rig 029
#include C:/TEMPO/ProcLib/RIG/RIG_029.PRO

declare int RIG_029_ID = 29;

declare SET_RIG(int id);
declare INIT_PORTS_AND_VDOSYNC();


process SET_RIG(int id)
{
    // clear tone buffer if any
    mio_fout(0);
    RIG_ID = id;
    if (RIG_ID == RIG_029_ID)
    {
        spawnwait RIG_029();
    }
    spawnwait INIT_PORTS_AND_VDOSYNC();
    spawnwait SET_SCRN();
}


process INIT_PORTS_AND_VDOSYNC()
{
    if (DEBUG_CONSOLE)
    {
        printf("Initializing VDOSYNC to mode to [%d] \n", VDO_SYNC_MODE);
    }
    dsendf("vi %d;", VDO_SYNC_MODE);
    dsend("ca");

    if (DEBUG_CONSOLE)
    {
        printf("Setting PORTS...\n");
    }
    dioSetMode(0, PORTA | PORTB | PORTC);

    if (DEBUG_CONSOLE)
    {
        printf("Resetting juice channel...\n");
    }
    mio_dig_set(JUICE_CHANNEL, 0);

    if (DEBUG_CONSOLE)
    {
        printf("Resetting audio...\n");
    }
    mio_fout(0);
    // for clearing videomode
    //nexttick 8000;
    spawnwait WaitForVideoSYNC();
}
