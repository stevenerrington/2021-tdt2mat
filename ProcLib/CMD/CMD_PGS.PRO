//==========================================================================
// CMD_PGS.PRO
//   Description: Function to setup all PAGES for CMD task
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2018-12-07
//==========================================================================
//  Revision History:
//  001: 2018/12/10 chenchal subraveti
//       Global targColorIdx indices and palettes for colorIdxs
//

// Room variables
#include C:/TEMPO/ProcLib/UTIL/DRW_RECT.PRO

declare DRW_RANDOM_DOT_PAGE(int pgIndex, int dotSize);

// Virtual Page indices
declare int PG_BLANK           = 0;
declare int PG_FIXATION_PD     = 1;
declare int PG_FIXATION        = 2;
declare int PG_TARGET_PD       = 3;
declare int PG_TARGET          = 4;
declare int PG_SIGNAL_PD       = 5;
declare int PG_SIGNAL          = 6;
declare int N_RANDOM_DOT_PAGES = 2;
declare int PG_RAND_ARRAY[2]   = { 7, 8 };
declare int PG_MAX_PAGE_IDX    = 8;

declare int RANDOM_DOT_SIZE   = 10;
declare int RANDOM_PAGES_DONE = 0;

declare CMD_PGS(float targSize, float targAngle, float targEccentricity, int targColorIdx);


process CMD_PGS(float targSize, float targAngle, float targEccentricity, int targColorIdx)
{
    declare float pdEccentricity;
    declare float pdAngleR;
    declare float pdAngleL;
    declare float opposite;
    declare float adjacent;

    //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    // For Photodiode marker
    adjacent = rad2deg(atan((SCRN_MM_X/2)/SUBJ_DIST_MM));
    opposite = rad2deg(atan((SCRN_MM_Y/2)/SUBJ_DIST_MM));

    pdEccentricity = sqrt((opposite * opposite) + (adjacent * adjacent)) - 0.5;
    pdAngleR       = rad2deg(atan(opposite/adjacent));
    pdAngleL       = 180 - rad2deg(atan(opposite/adjacent));

    //--------------------------------------------------------------------------------------------------------------------
    // Draw pg 1 FIXATION_PD - PD is drawn on LEFT-TOP of screen only
    if (DEBUG_CONSOLE)
    {
        printf("CMD_PGS: Drawing PG_FIXATION_PD page %d FIX_SIZE %2.2d, PD_WIDTH_DEG %3.4d, pdAngleL %3.2d\n", PG_FIXATION_PD, FIX_SIZE_DEG, PD_WIDTH_DEG, pdAngleL);
    }
    dsendf("rw %d,%d;\n", PG_FIXATION_PD, PG_FIXATION_PD);
    dsendf("cl:\n");
    spawnwait DRW_RECT(FIX_SIZE_DEG, FIX_SIZE_DEG, 0.0, 0.0, CLR_IDX_FIX, FILL);
    spawnwait DRW_RECT(PD_WIDTH_DEG, PD_WIDTH_DEG/4, pdAngleL, pdEccentricity, CLR_IDX_PTOTODIODE, FILL);

    nexttick;
    //--------------------------------------------------------------------------------------------------------------------
    // Draw pg 2 FIXATION - No PD
    if (DEBUG_CONSOLE)
    {
        printf("CMD_PGS: Drawing PG_FIXATION page %d FIX_SIZE %d\n", PG_FIXATION, FIX_SIZE_DEG);
    }
    dsendf("rw %d,%d;\n", PG_FIXATION, PG_FIXATION);
    dsendf("cl:\n");
    spawnwait DRW_RECT(FIX_SIZE_DEG, FIX_SIZE_DEG, 0.0, 0.0, CLR_IDX_FIX, FILL);

    nexttick;
    //--------------------------------------------------------------------------------------------------------------------
    // Draw pg 3 TARGET with PD - PD is drawn on LEFT-TOP of screen only
    if (DEBUG_CONSOLE)
    {
        printf("CMD_PGS: Drawing PG_TARGET_PD page %d targetSize %2.2d, PD_WIDTH_DEG %3.4d, pdAngleL %3.2d\n", PG_TARGET_PD, targSize, PD_WIDTH_DEG, pdAngleL);
    }
    dsendf("rw %d,%d;\n", PG_TARGET_PD, PG_TARGET_PD);
    dsendf("cl:\n");
    // draw PG_TARGET
    spawnwait DRW_RECT(targSize, targSize, targAngle, targEccentricity, targColorIdx, FILL);

    // draw OPEN PG_FIXATION point
    spawnwait DRW_RECT(FIX_SIZE_DEG, FIX_SIZE_DEG, 0.0, 0.0, CLR_IDX_FIX, OPEN);

    // Draw left PD marker
    spawnwait DRW_RECT(PD_WIDTH_DEG, PD_WIDTH_DEG/4, pdAngleL, pdEccentricity, CLR_IDX_PTOTODIODE, FILL);

    nexttick;
    //--------------------------------------------------------------------------------------------------------------------
    // Draw pg 4 TARGET no PD
    if (DEBUG_CONSOLE)
    {
        printf("CMD_PGS: Drawing PG_TARGET page %d targetSize %2.2d\n", PG_TARGET, targSize);
    }
    dsendf("rw %d,%d;\n", PG_TARGET, PG_TARGET);
    dsendf("cl:\n");
    spawnwait DRW_RECT(targSize, targSize, targAngle, targEccentricity, targColorIdx, FILL);

    // draw OPEN PG_FIXATION point
    spawnwait DRW_RECT(FIX_SIZE_DEG, FIX_SIZE_DEG, 0.0, 0.0, CLR_IDX_FIX, OPEN);

    nexttick;

    //--------------------------------------------------------------------------------------------------------------------
    // Draw pg 5 SIGNAL PD - PD is drawn on the right only
    if (DEBUG_CONSOLE)
    {
        printf("CMD_PGS: Drawing PG_SIGNAL_PD page %d targetSize %2.2d, PD_WIDTH_DEG %3.4d, pdAngleR %3.2d\n", PG_SIGNAL_PD, targSize, PD_WIDTH_DEG, pdAngleR);
    }
    dsendf("rw %d,%d;\n", PG_SIGNAL_PD, PG_SIGNAL_PD);
    dsendf("cl:\n");
    spawnwait DRW_RECT(targSize, targSize, targAngle, targEccentricity, targColorIdx, FILL);

    // draw PG_TARGET
    spawnwait DRW_RECT(FIX_SIZE_DEG, FIX_SIZE_DEG, 0.0, 0.0, CLR_IDX_STOP_SIGNAL, FILL);

    // draw PG_FIXATION point
    spawnwait DRW_RECT(FIX_SIZE_DEG, FIX_SIZE_DEG, 0.0, 0.0, CLR_IDX_FIX, OPEN);

    // Draw right PD marker
    spawnwait DRW_RECT(PD_WIDTH_DEG, PD_WIDTH_DEG/4, pdAngleR, pdEccentricity, CLR_IDX_PTOTODIODE, FILL);

    nexttick;
    //--------------------------------------------------------------------------------------------------------------------
    // Draw pg 6 SIGNAL no PD
    if (DEBUG_CONSOLE)
    {
        printf("CMD_PGS: Drawing PG_SIGNAL page %d targetSize %2.2d\n", PG_SIGNAL, targSize);
    }
    dsendf("rw %d,%d;\n", PG_SIGNAL, PG_SIGNAL);
    dsendf("cl:\n");

    // draw PG_TARGET
    spawnwait DRW_RECT(FIX_SIZE_DEG, FIX_SIZE_DEG, 0.0, 0.0, CLR_IDX_STOP_SIGNAL, FILL);

    // draw PG_FIXATION point
    spawnwait DRW_RECT(FIX_SIZE_DEG, FIX_SIZE_DEG, 0.0, 0.0, CLR_IDX_FIX, OPEN);

    // Draw **left** PD marker
    spawnwait DRW_RECT(PD_WIDTH_DEG, PD_WIDTH_DEG/4, pdAngleL, pdEccentricity, CLR_IDX_PTOTODIODE, FILL);

    nexttick;
    //--------------------------------------------------------------------------------------------------------------------
    // Draw RANDOM DOT PAGES
    if (DEBUG_CONSOLE)
    {
        printf("CMD_PGS: Drawing RANDOM_DOT pages [%d,%d] \n", PG_RAND_ARRAY[0], PG_RAND_ARRAY[1]);
    }
    if (!RANDOM_PAGES_DONE)
    {
        spawnwait DRW_RANDOM_DOT_PAGE(PG_RAND_ARRAY[0], RANDOM_DOT_SIZE);
        spawnwait DRW_RANDOM_DOT_PAGE(PG_RAND_ARRAY[1], RANDOM_DOT_SIZE);

        RANDOM_PAGES_DONE = 1;
    }
    //--------------------------------------------------------------------------------------------------------------------
    // Draw pg 0 BLANK (draw last so it is displayed as default))
    if (DEBUG_CONSOLE)
    {
        printf("CMD_PGS: Drawing PG_BLANK page %d\n", PG_BLANK);
    }
    // draw the PG_BLANK screen last so that it shows up first
    dsendf("rw %d,%d;\n", PG_BLANK, PG_BLANK);
    dsendf("cl\n");
    nexttick;

    spawnwait WaitForVideoSYNC();
} /* CMD_PGS */


process DRW_RANDOM_DOT_PAGE(pgIndex, dotSize)
{
    declare int xSteps, ySteps;
    declare int ulx, uly, lrx, lry;
    declare int xs, ys;
    declare int cIdx, cIdxToUse;

    cIdxToUse = CLR_IDX_STOP_SIGNAL;
    dsendf("rw %d,%d;\n", pgIndex, pgIndex);
    dsendf("cl\n");
    xSteps = floor(SCRN_PIX_X/dotSize);
    ySteps = floor(SCRN_PIX_Y/dotSize);

    ulx = SCRN_PIX_X/(-2);
    xs  = 0;
    while (xs < xSteps - 1)
    {
        uly = SCRN_PIX_Y/2;
        ys  = 0;
        while (ys < ySteps - 1)
        {
            lrx = ulx + dotSize;
            if (lrx > SCRN_PIX_X/2)
            {
                lrx = (SCRN_PIX_X/2);
            }
            lry = uly - dotSize;
            if (lry > SCRN_PIX_Y/2)
            {
                lry = (SCRN_PIX_Y/2);
            }
            cIdx = random(2) * cIdxToUse;
            dsendf("co %d\n", cIdx);
            dsendf("rf %d,%d,%d,%d\n", ulx, uly, lrx, lry);
            uly = uly - dotSize;
            ys  = ys + 1;
            nexttick;
        }
        xs  = xs + 1;
        ulx = ulx + dotSize;
        nexttick;
    }
} /* DRW_RANDOM_DOT_PAGE */
