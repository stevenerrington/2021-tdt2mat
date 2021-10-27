//==========================================================================
// JOULE.PRO
//   Description: Setsup default parameters subject JOULE_ID.
//
//   NOTE:
//       Create one monk_name.PRO file for each monk used.  Define
//       parameters as needed for that subject
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-01-15
//==========================================================================
//  Revision History:
//

declare JOULE();


process JOULE()
{
    declare int tempVar = 0;

    //SSD list is not set
    // See VAR_CMD.PRO
    SSD_ARRY[0] = 4;
    SSD_ARRY[1] = 11;
    SSD_ARRY[2] = 16;
    SSD_ARRY[3] = 19;
    SSD_ARRY[4] = 22;
    SSD_ARRY[5] = 25;
    SSD_ARRY[6] = 30;
    SSD_ARRY[7] = 37;
    //SSD_ARRY[8] = 36;
    //SSD_ARRY[9] = 40;

    tempVar = 8;
    while (tempVar < N_SSD_MAX)
    {
        SSD_ARRY[tempVar] = 0;
        tempVar           = tempVar + 1;
    }
    // See CMD_VARS and add those that you want to change.
    // Check VAR_STIM.PRO --> SET_DEFAULT_STIM_VARS()
    FIX_COLOR[R_IDX] = RED_VAL - WR_OFF;
    FIX_COLOR[G_IDX] = GREEN_VAL - WG_OFF;
    FIX_COLOR[B_IDX] = BLUE_VAL - WB_OFF;

    STOP_SIGNAL_COLOR[R_IDX] = 17;
    STOP_SIGNAL_COLOR[G_IDX] = 13;
    STOP_SIGNAL_COLOR[B_IDX] = 14;

    IGNORE_SIGNAL_COLOR[R_IDX] = 41;
    IGNORE_SIGNAL_COLOR[G_IDX] = 42;
    IGNORE_SIGNAL_COLOR[B_IDX] = 43;

    // Check VAR_STIM.PRO --> SET_DEFAULT_STIM_VARS()
    N_TARG_POS = 2;
    tempVar    = 0;
    while (tempVar < MAX_TARG_POS)
    {
        // All target colors are same
        TARG_COLOR_ARRAY[tempVar, R_IDX] = 35;
        TARG_COLOR_ARRAY[tempVar, G_IDX] = 33;
        TARG_COLOR_ARRAY[tempVar, B_IDX] = 27;

        if (tempVar >= N_TARG_POS)
        {
            TARG_SIZE_ARRY[tempVar]         = 0.0;
            TARG_ANGLE_ARRY[tempVar]        = 0.0;
            TARG_ECCENTRICITY_ARRY[tempVar] = 0;
        }
        else
        {
            TARG_SIZE_ARRY[tempVar]         = 1.0;
            TARG_ANGLE_ARRY[tempVar]        = tempVar * (360.0/N_TARG_POS);
            TARG_ECCENTRICITY_ARRY[tempVar] = 12.0;
        }
        tempVar = tempVar + 1;
    }

    FIX_SIZE_DEG       = 1.0;
    FIX_WIN_ACQ_SIZE   = FIX_SIZE_DEG * 3;
    FIX_WIN_SIZE       = 5;
    FIX_WIN_SIZE_LARGE = FIX_WIN_SIZE * 1.5;

    TARG_WIN_SIZE       = 7;
    TARG_WIN_SIZE_LARGE = TARG_WIN_SIZE * 1.5;
} /* JOULE */
