//==========================================================================
// SET_DEFAULT_COLORS.PRO
//   Description: Function to setup all colors/palettes for CMD task
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2018-12-07
//==========================================================================
//  Revision History:
//  001: 2018/09/09 chenchal subraveti
//       Global color indices and palettes for colors
//
//
declare SET_DEFAULT_COLORS();
declare SET_CLR_PALETTE();
declare SET_CLR(int colorIndex, int color_r, int color_g, int color_b);

// Global color Variables
// Default palettes
declare int constant PAL_DEFAULT = 0;

// Stop/ignore trial Cue
declare int STOP_SIGNAL_COLOR[3];
declare int IGNORE_SIGNAL_COLOR[3];
declare int FIX_COLOR[3];
//
declare int TARG_COLOR_ARRAY[MAX_TARG_POS, 3];
declare int N_COLORS = 0;

// There are 255 color indices in a palatte
// 0 is reserved for BLACK
// Use indices 1 to N for Target colorIndex etc
// Fill Indices from 250 backwards for other colors
declare constant int CLR_IDX_FIX                      = 250;
declare constant int CLR_IDX_STOP_SIGNAL              = 249;
declare constant int CLR_IDX_IGNORE                   = 248;
declare constant int CLR_IDX_PTOTODIODE               = 247;
declare constant int CLR_IDX_TARG_ARRAY[MAX_TARG_POS] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 };
declare constant int CLR_IDX_TARG_1                   = 1;

process SET_DEFAULT_COLORS()
{
    declare int varTemp;

    FIX_COLOR[R_IDX] = RED_VAL - WR_OFF;
    FIX_COLOR[G_IDX] = GREEN_VAL - WG_OFF;
    FIX_COLOR[B_IDX] = BLUE_VAL - WB_OFF;

    STOP_SIGNAL_COLOR[R_IDX] = 35;
    STOP_SIGNAL_COLOR[G_IDX] = 33;
    STOP_SIGNAL_COLOR[B_IDX] = 27;

    IGNORE_SIGNAL_COLOR[R_IDX] = 41;
    IGNORE_SIGNAL_COLOR[G_IDX] = 42;
    IGNORE_SIGNAL_COLOR[B_IDX] = 43;

    // define Target colors
    // All target position colors are same see original DEFAULT.PRO
    //CLR_IDX_TARG_1: 35, 33, 27
    varTemp = 0;
    while (varTemp < MAX_TARG_POS)
    {
        TARG_COLOR_ARRAY[0, R_IDX] = 17;
        TARG_COLOR_ARRAY[0, G_IDX] = 16;
        TARG_COLOR_ARRAY[0, B_IDX] = 13;
        N_COLORS                   = N_COLORS + 1;
        varTemp                    = varTemp + 1;
    }
    
    spawnwait SET_CLR_PALETTE();
}


process SET_CLR_PALETTE()
{
    declare int varTemp;

    spawnwait SET_CLR(CLR_IDX_FIX, FIX_COLOR[R_IDX], FIX_COLOR[G_IDX], FIX_COLOR[B_IDX]);
    spawnwait SET_CLR(CLR_IDX_STOP_SIGNAL, STOP_SIGNAL_COLOR[R_IDX], STOP_SIGNAL_COLOR[G_IDX], STOP_SIGNAL_COLOR[B_IDX]);
    spawnwait SET_CLR(CLR_IDX_IGNORE, IGNORE_SIGNAL_COLOR[R_IDX], IGNORE_SIGNAL_COLOR[G_IDX], IGNORE_SIGNAL_COLOR[B_IDX]);
    spawnwait SET_CLR(CLR_IDX_PTOTODIODE, 255, 255, 255);

    varTemp = 0;
    while (varTemp < MAX_TARG_POS)
    {
        spawnwait SET_CLR(CLR_IDX_TARG_ARRAY[varTemp], TARG_COLOR_ARRAY[varTemp, R_IDX], TARG_COLOR_ARRAY[varTemp, G_IDX], TARG_COLOR_ARRAY[varTemp, B_IDX]);

        varTemp = varTemp + 1;
    }
}


process SET_CLR(int colorIndex, int color_r, int color_g, int color_b)
{
    // Set current hardware palette color index to defined user choice
    dsendf("cm %d %d %d %d;\n", colorIndex, color_r, color_g, color_b);
}
