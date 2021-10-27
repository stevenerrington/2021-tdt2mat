//==========================================================================
// VAR_STIM.PRO
//   Description: Global declares for Stimulus variables
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-01-14
//==========================================================================
//  Revision History:
//

// Fix vars
//=========== Window sizes (degrees) ==================
declare float        FIX_SIZE_DEG = 1.0;
declare float        FIX_WIN_SIZE = 5;
declare float        FIX_WIN_ACQ[4];
declare float        FIX_WIN[4];
declare float        FIX_WIN_ACQ_SIZE = 1.0;
declare float        FIX_WIN_SIZE_LARGE = FIX_WIN_SIZE * 1.2;
declare float        FIX_WIN_LARGE[4];
// Stimulus - target attributes
declare constant int MAX_TARG_POS = 12;
declare int          N_TARG_POS;
declare float        TARG_SIZE_ARRY[MAX_TARG_POS];
declare float        TARG_ANGLE_ARRY[MAX_TARG_POS];
declare float        TARG_ECCENTRICITY_ARRY[MAX_TARG_POS];
declare float        TARG_WIN_SIZE = 7;
declare float        TARG_WIN[4];
declare float        TARG_WIN_ANTI[4];
declare float        TARG_WIN_SIZE_LARGE = TARG_WIN_SIZE * 1.5;
declare float        TARG_WIN_LARGE[4];
declare float        TARG_WIN_ANTI_LARGE[4];

// Photocell marker TRL_CURR_TARG_SIZE
declare float PD_WIDTH_DEG = 4.0;

declare SET_DEFAULT_STIM_VARS();


process SET_DEFAULT_STIM_VARS()
{
    declare int   tempCounter;
    declare float targEccX, targEccY;

    N_TARG_POS  = MAX_TARG_POS;
    tempCounter = 0;

    // Default Target angle
    while (tempCounter < N_TARG_POS)
    {
        // Default all target sizes to same
        TARG_SIZE_ARRY[tempCounter] = 1.0;
        // Default all eccentricities to be same
        TARG_ECCENTRICITY_ARRY[tempCounter] = 12.0;
        // clockwise: 45, 90, 135, ...
        TARG_ANGLE_ARRY[tempCounter] = tempCounter * (360.0/N_TARG_POS);
        tempCounter                  = tempCounter + 1;
        nexttick;
    }
} /* SET_DEFAULT_STIM_VARS */
