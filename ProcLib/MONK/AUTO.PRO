//==========================================================================
// AUTO.PRO
//   Description: Setsup default parameters Auto subject.
//                AUTO monk makes pre-decided outcomes on each trial.
//                Once integrated, This helps to test all outcomes
//   NOTE:
//       Create one monk_name.PRO file for each monk used.  Define
//       parameters as needed for that subject
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-01-15
//==========================================================================
//  Revision History:
//

#include C:/TEMPO/ProcLib/WATCH/AUTO_EYE.PRO
declare AUTO();


process AUTO()
{
    declare int tempVar = 0;

    EYE_X_GAIN   = 1.0;
    EYE_Y_GAIN   = 1.0;
    EYE_X_OFFSET = 0.0;
    EYE_Y_OFFSET = 0.0;
    spawn AUTO_EYE();

    //SSD list is not set
    while (tempVar < N_SSD_MAX)
    {
        SSD_ARRY[tempVar] = tempVar * 2 + 2;
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
            TARG_SIZE_ARRY[tempVar]         = 2.0;
            TARG_ANGLE_ARRY[tempVar]        = tempVar * (360.0/N_TARG_POS);
            TARG_ECCENTRICITY_ARRY[tempVar] = 10.0;
        }

        tempVar = tempVar + 1;
    }
} /* AUTO */
