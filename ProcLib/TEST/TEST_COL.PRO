//==========================================================================
// TEST_COL.PRO
//   Description: Function to setup all colors/palettes for CMD task
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2018-12-07
//==========================================================================
//  Revision History:
//  001: 2018/09/09 chenchal subraveti
//       Global color indices and palettes for colors
//
//
declare TEST_SET_DEFAULT_COLORS(int colorIndex, int color_r, int color_g, int color_b);

// Global color Variables
// Default palettes
declare int constant PAL_DEFAULT = 0;
// There are 255 color indices in a palatte
// 0 is reserved for BLACK
// Use indices 1 to N for Target colorIndex etc
// Fill Indices from 255 backwards for other colors
int CLR_IDX_FIX         = 255;
int CLR_IDX_STOP_SIGNAL = 254;
int CLR_IDX_IGNORE      = 253;
int CLR_IDX_PTOTODIODE  = 247;


process TEST_SET_DEFAULT_COLORS()
{
    declare int RGB_R_IDX, RGB_G_IDX, RGB_B_IDX;
    declare     targetIndex;
    declare     nTargets;
    declare int fixation_color[3];
    declare int stop_sig_color[3];
    declare int ignore_sig_color[3];

    RGB_R_IDX = 0;
    RGB_G_IDX = 1;
    RGB_B_IDX = 2;

    printf("CMD_CLRS: Setting indexed colors for default palette\n");

    // Default to gray
    fixation_color[RGB_R_IDX] = RED_VAL - WR_OFF;
    fixation_color[RGB_G_IDX] = GREEN_VAL - WG_OFF;
    fixation_color[RGB_B_IDX] = BLUE_VAL - WB_OFF;
    spawn SET_CLR(CLR_IDX_FIX, fixation_color[RGB_R_IDX], fixation_color[RGB_G_IDX], fixation_color[RGB_B_IDX]);

    stop_sig_color[RGB_R_IDX] = 40;
    stop_sig_color[RGB_G_IDX] = 40;
    stop_sig_color[RGB_B_IDX] = 0;
    spawn SET_CLR(CLR_IDX_STOP_SIGNAL, stop_sig_color[RGB_R_IDX], stop_sig_color[RGB_G_IDX], stop_sig_color[RGB_B_IDX]);

    ignore_sig_color[RGB_R_IDX] = 0;
    ignore_sig_color[RGB_G_IDX] = 36;
    ignore_sig_color[RGB_B_IDX] = 0;
    spawn SET_CLR(CLR_IDX_STOP_SIGNAL, ignore_sig_color[RGB_R_IDX], ignore_sig_color[RGB_G_IDX], ignore_sig_color[RGB_B_IDX]);

    spawn SET_CLR(CLR_IDX_PTOTODIODE, 255, 255, 255);


    // All target position colors are same see original DEFAULT.PRO
    targetIndex = 1;
    nTargets    = 8;
    while (targetIndex <= nTargets)
    {
        spawn SET_CLR(targetIndex, 35, 33, 27);

        targetIndex = targetIndex + 1;
        nexttick;
    }

    spawn SET_CLR(1, 255, 0, 0);
    spawn SET_CLR(2, 0, 0, 255);
} /* TEST_SET_DEFAULT_COLORS */


process SET_CLR(int colorIndex, int color_r, int color_g, int color_b)
{
    // Set current hardware palette color index to defined user choice
    dsendf("cm %d %d %d %d;\n", colorIndex, color_r, color_g, color_b);
}
