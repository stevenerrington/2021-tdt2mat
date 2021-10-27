//==========================================================================
// RITE_EYE.PRO
//   Description: Write eye data to file at some specified interval
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-03-22
//==========================================================================
//  Revision History:

declare PROC_WRITE_RAW_I_DATA();


process PROC_WRITE_RAW_I_DATA()
{
    declare int tickInterval  = 2;
    declare int writeEye2File = 0;
    declare int currTime;
    declare int pupil;
    declare int relTimeMs;

    currTime = time();
    //writef("rawIVals.csv relTimeMs,xADC,yADC,iInvalid,iInvalidDuration,iPupil\n");
    while (1)
    {
        if (writeEye2File)
        {
            //rawIVals.csv relTimeMs,xADC,yADC\n"
            pupil     = atable(EYE_PUPIL_CHANNEL);
            relTimeMs = time() - currTime;
            writef("rawIVals.csv %d,%d,%d,%d,%d,%d\n", relTimeMs, EYE_X_VOLTS, EYE_Y_VOLTS, pupil, I_INVALID, I_INVALID_DURATION);
        }
        nexttick tickInterval;
    }
}
