//==========================================================================
// WTCH_PD.PRO
//   Description: Monitors the Left and right Photocell markers every clock cycle.
//                Each photo-cell signal is passed through a Schmitt trigger.
//                Schmitt output is HI when there is no marker
//                Schmitt output is LO when the photocell signal is above the high threshold
//                and HI when the photocell signal is below the low threshold of Schmitt
//   NOTE:
//       Trigger is ON when Schmitt output is BELOW threshold, and remains ON(1) till the output
//       goes ABOVE the threshold, when it goes OFF (0).
//       That is OFF (=0; above threshold) and ON (=1; below threshold)
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-01-20
//==========================================================================
//  Revision History:
//
declare constant int DEBUG_PD      = 0;
declare constant int WRITE_PD_FILE = 0;
declare int          PD_TRIG_L     = 0;
declare int          PD_TRIG_R     = 0;
declare int          PD_THRESHOLD  = 500;

declare WTCH_SCHMITT();


process WTCH_SCHMITT()
{
    declare float pdValL = 5000;
    declare float pdValR = 5000;

    while (1)
    {
        pdValL = atable(PHOTOCELL_L_CHANNEL);
        pdValR = atable(PHOTOCELL_R_CHANNEL);
        if (pdValL < PD_THRESHOLD && PD_TRIG_L == 0)
        {
            PD_TRIG_L = 1;
            spawn SEND_EVT(EVT_PD_TRIGGER_LEFT_);
        }
        else if (pdValL > PD_THRESHOLD && PD_TRIG_L == 1)
        {
            PD_TRIG_L = 0;
        }
        // PD Right
        if (pdValR < PD_THRESHOLD && PD_TRIG_R == 0)
        {
            PD_TRIG_R = 1;
            spawn SEND_EVT(EVT_PD_TRIGGER_RIGHT_);
        }
        else if (pdValR > PD_THRESHOLD && PD_TRIG_R == 1)
        {
            PD_TRIG_R = 0;
        }
        if (WRITE_PD_FILE)
        {
            writef("pdValsSc.csv %d,%d,%d,%d\n", pdValL, pdValR, PD_TRIG_L, PD_TRIG_R);
        }
        if (DEBUG_PD)
        {
            printf("%d,%d,%d,%d\n", pdValL, pdValR, PD_TRIG_L, PD_TRIG_R);
        }
        nexttick;
    }
}
