//==========================================================================
// TARG_VR.PRO
//   Description: Process to count target vertical refresh
//                EPD Marker set on the top-left of Target page
//
//   NOTE:
//
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-02-06
//==========================================================================
//  Revision History:


declare CHECK_TARG_VERT_RFRSH();

declare int PD_WIDTH_DURATION;


// For counting Target vertical refresh for both GO and STOP trials
process CHECK_TARG_VERT_RFRSH()
{
    declare int trigWidth = 3;

    if (PD_TRIG_R)
    {
        if (TRL_IS_STOP_SIGNAL_ON <= 0)
        {
            TRL_IS_STOP_SIGNAL_ON = 1;
            if (DEBUG_CONSOLE)
            {
                printf("****TARG_VR.PRO: TRL_IS_STOP_SIGNAL_ON = [%d]\n", TRL_IS_STOP_SIGNAL_ON);
            }
            TRL_TARG_VR_COUNT = TRL_TARG_VR_COUNT + 1;
        }
        if ((STAT_DLTA_T - PD_WIDTH_DURATION) > trigWidth)
        {
            TRL_TARG_VR_COUNT = TRL_TARG_VR_COUNT + 1;
        }
        PD_WIDTH_DURATION = STAT_DLTA_T;
    }

    if (PD_TRIG_L)
    {
        if (TRL_TARG_VR_COUNT <= 0)
        {
            INCEMENT_TARG_DURATION_FLAG = 1;
            TRL_TARG_VR_COUNT           = 1;
        }
        else if ((STAT_DLTA_T - PD_WIDTH_DURATION) > trigWidth)
        {
            TRL_TARG_VR_COUNT = TRL_TARG_VR_COUNT + 1;
        }
        PD_WIDTH_DURATION = STAT_DLTA_T;
    }
} /* CHECK_TARG_VERT_RFRSH */
