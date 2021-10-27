//==========================================================================
// CALIBR8.PRO
//   Description: Calibrate Eye position for screen size and offsets
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-03-11
//==========================================================================
//  Revision History:



declare constant int N_CALIB_POS = 9;
// calibration dot position on screen: [center, N, S, W, E, NW, NE, SW, SE]
declare constant int N_CALIB_ANGLES[9]  = { 0, 90, 270, 180, 0, 135, 45, 225, 315 };
declare float        CALIB_ECCENTRICITY = 12.0;
declare int          CALIBRATING;


declare PROC_CALIBRATE();

//declare PROC_CALIB_PGS();


process PROC_CALIBRATE()
{
    // Define KEY macros
    //system("key currt = spawn KEY_T_UP");
    //system("key curlf = spawn KEY_T_DN");
    //system("key curup = spawn KEY_REWD");
    //system("key curdn = OK = 1");

    printf("***CALIBR8.PRO/PROC_CALIBRATE(): Eye Clibration in progress...\n");

    while (CALIBRATING)
    {
        printf("***CALIBR8.PRO/PROC_CALIBRATE(): In calibrate...***NOT**YET***\n");
        // cycle thorugh pages to show calibration dots on screen
        nexttick 500;
    }

    printf("***CALIBR8.PRO/PROC_CALIBRATE(): Eye calibration ended...\n");
}
