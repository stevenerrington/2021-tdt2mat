//==========================================================================
// CMD_PGS.PRO
//   Description: Function to setup all PAGES for CMD task
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2018-12-07
//==========================================================================
//  Revision History:
//  001: 2018/12/10 chenchal subraveti
//       Global color indices and palettes for colors
//

// Room variables
#include C:/TEMPO/ProcLib/TEST/DRW_RECT.PRO

// number the pgs that need to be drawn
declare int PAGE_BLANK          = 0;
declare int PAGE_FIX_PD         = 1;
declare int PAGE_STOP_SIGNAL_PD = 2;
declare int PAGE_TEST_PD        = 3;

declare CMD_PGS();


process CMD_PGS()
{
    declare float pd_eccentricity;
    declare float pdAngleR;
    declare float pdAngleL;
    declare float opposite;
    declare float adjacent;
    declare int   open   = 0;
    declare int   fill   = 1;
    declare float pdSize = 4;

    printf("CMD_PGS: Drawing pages\n");
    adjacent        = SCRN_DEG_X;
    opposite        = SCRN_DEG_Y;
    pd_eccentricity = sqrt((opposite * opposite) + (adjacent * adjacent)) - 0.5;

    pdAngleL = rad2deg(atan(opposite/adjacent)) + 180;
    pdAngleR = -rad2deg(atan(opposite/adjacent));


    printf("CMD_PGS: pdSize %d, pdAngleL %0.4d, pdAngleR %0.4d, fix_size %0.2d\n", pdSize, pdAngleL, pdAngleR, FIX_SIZE);
    //--------------------------------------------------------------------------------------------------------------------
    // Draw pg 0
    printf("-----------------\n");
    printf("CMD_PGS: Drawing page %d\n", PAGE_BLANK);
    dsendf("rw %d,%d;\n", PAGE_BLANK, PAGE_BLANK);
    dsendf("cl:\n");
    printf("-----------------\n");
    nexttick 10;
    //--------------------------------------------------------------------------------------------------------------------
    // Draw pg 1 FIXATION_PD - PD is drawn on LEFT-TOP of screen only
    printf("CMD_PGS: Drawing page %d FIX_SIZE %d, pdSize %3.4d, pdAngleL %3.2d\n", PAGE_FIX_PD, FIX_SIZE, pdSize, pdAngleL);
    dsendf("rw %d,%d;\n", PAGE_FIX_PD, PAGE_FIX_PD);
    dsendf("cl:\n");
    spawnwait DRW_RECT(FIX_SIZE, FIX_SIZE, 0.0, 0.0, CLR_IDX_FIX, fill);
    spawnwait DRW_RECT(pdSize, pdSize/4, pdAngleL, pd_eccentricity, CLR_IDX_PTOTODIODE, fill);

    printf("-----------------\n");
    nexttick 10;
    //--------------------------------------------------------------------------------------------------------------------
    // Draw pg 2 STOP_SIGNAL_PD - PD is drawn on RIGHT-TOP of screen only
    printf("CMD_PGS: Drawing page %d FIX_SIZE %d, pdSize %3.4d, pdAngleR %3.2d\n", PAGE_STOP_SIGNAL_PD, FIX_SIZE, pdSize, pdAngleR);
    dsendf("rw %d,%d;\n", PAGE_STOP_SIGNAL_PD, PAGE_STOP_SIGNAL_PD);
    dsendf("cl:\n");
    spawnwait DRW_RECT(FIX_SIZE, FIX_SIZE, 0.0, 0.0, CLR_IDX_STOP_SIGNAL, fill);
    spawnwait DRW_RECT(pdSize, pdSize/4, pdAngleR, pd_eccentricity, CLR_IDX_PTOTODIODE, fill);

    printf("-----------------\n");
    nexttick 10;
    //--------------------------------------------------------------------------------------------------------------------
    // Draw pg 100 PAGE_TEST_PD - PD is drawn on LEFT-TOP and RIGHT-TOP of screen
    printf("CMD_PGS: Drawing page %d FIX_SIZE %d, pdSize %3.4d, pdAngleL %3.2d, pdAngleR %3.2d\n", PAGE_TEST_PD, FIX_SIZE, pdSize, pdAngleR, pdAngleR);
    dsendf("rw %d,%d;\n", PAGE_TEST_PD, PAGE_TEST_PD);
    dsendf("cl:\n");
    spawnwait DRW_RECT(FIX_SIZE, FIX_SIZE, 0.0, 0.0, CLR_IDX_STOP_SIGNAL, fill);
    spawnwait DRW_RECT(pdSize, pdSize/4, pdAngleL, pd_eccentricity, CLR_IDX_PTOTODIODE, fill);
    spawnwait DRW_RECT(pdSize, pdSize/4, pdAngleR, pd_eccentricity, CLR_IDX_PTOTODIODE, fill);

    printf("-----------------\n");
    nexttick 10;

    //--------------------------------------------------------------------------------------------------------------------
    dsendf("vw %d\n", PAGE_BLANK);
} /* CMD_PGS */
