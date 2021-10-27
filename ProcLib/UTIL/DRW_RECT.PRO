//==========================================================================
// DRW_RECT.PRO
//   Description: Draw a rectangle on the video sync screen
//   Author: steven.p.errington@vanderbilt.edu
//   Date: 2018-09-03
//==========================================================================
//  Revision History:
//  002: 2018/09/07 chenchal subraveti
//       Changed to DRW_RECT.PRO
//       Compute upper-left and lower-right pixel cordinates from following rectangle dimensions
// 003: 2019/01/08 chenchal subraveti
//       Updated comments and moved the function to main ProcLib directory.
//       All sizes and angles are in degrees (no mm or pixels)
//

declare DRW_RECT(float sizeX, float sizeY, float targAngle, float targEcc, int colorIndex, int fillFlag);


//
// INPUT
//	 sizeX: Width of the rectangle in visual degrees
//	 sizeY: Height of the rectangle in visual degrees
//	 targAngle: Visual targAngle the center of the stimulus subtends at the eye
//   targEcc: How far from center in degrees of visual targAngle
//   colorIndex: Color index of the palette
//
process DRW_RECT(float sizeX, float sizeY, float targAngle, float targEcc, int colorIndex, int fillFlag)
{
    declare float stim_ecc_x;
    declare float stim_ecc_y;
    declare int   ulx;
    declare int   uly;
    declare int   lrx;
    declare int   lry;

    // find the center of the box in x and y space based on the targAngle and targEcc
    stim_ecc_x = cos(targAngle) * targEcc;
    stim_ecc_y = sin(targAngle) * targEcc;

    // find locations of upper left and lower right corners based on location of center and TRL_CURR_TARG_SIZE
    ulx = round((stim_ecc_x - sizeX/2) * DEG_2_PIX_X);
    uly = round((stim_ecc_y + sizeY/2) * DEG_2_PIX_Y);
    lrx = round((stim_ecc_x + sizeX/2) * DEG_2_PIX_X);
    lry = round((stim_ecc_y - sizeY/2) * DEG_2_PIX_Y);

    //printf("DRW_RECT: COLOR_INDEX %d\n", colorIndex);
    //printf("DRW_RECT: sizeX %0.2d, sizeY %0.2d, targAngle %0.2d, targEcc %0.2d, colorIndex %d, fillFlag %d\n",sizeX, sizeY, targAngle, targEcc, colorIndex, fillFlag);
    dsendf("co %d;\n", colorIndex);
    if (fillFlag == 0)
    {
        dsendf("ru %d,%d,%d,%d;\n", ulx, uly, lrx, lry);
    }
    else
    {
        dsendf("rf %d,%d,%d,%d;\n", ulx, uly, lrx, lry);
    }
}
