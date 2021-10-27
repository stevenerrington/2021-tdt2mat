//==========================================================================
// RIG_029.PRO
//   Description: Set global variable for room 29.
//               Screen settings, isoluminant colors, data acquisition channels
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2018-09-06
//==========================================================================
//  Revision History:
//  002: 2019/01/14 chenchal subraveti
//       Changed file name to VAR_029 as this file contains variables only
//  003: 2019/01/16 chenchal subraveti
//       Changed file name to RIG_029 to DEFINE the golbal vars declared in VAR_RIG.PRO
//       Converted to process so that different rigs may be used

// For Room 29: DEFINE Global variables declared in VAR_RIG.PRO
declare RIG_029();


process RIG_029()
{
    RIG_ID = 29;
    // Screen Params
    //==========================================================================
    // VideoSYNC mode and Screen width and height in pixels are related
    // See TEMPO manual
    // 256 = pixels:640 x 400; colors:256; pages:16; bitsPerPixel:8
    VDO_SYNC_MODE = 256;
    SCRN_PIX_X    = 640;
    SCRN_PIX_Y    = 400;
    // Screen width and height in mm
    SCRN_MM_X = 375.0;
    SCRN_MM_Y = 275.0;
    // Distance from center of Subject'seyeball to screen
    SUBJ_DIST_MM = 570.0;

    REFRESH_RATE = 1000.0/60;

    // ISOLUMINANT colors
    //==========================================================================
    RED_VAL   = 30;
    GREEN_VAL = 19;
    BLUE_VAL  = 64;
    YR_OFF    = 13;
    MR_OFF    = 9;
    MB_OFF    = 27;
    CG_OFF    = 1;
    CB_OFF    = 44;
    WR_OFF    = 13;
    WG_OFF    = 6;
    WB_OFF    = 50;

    // DATA ACQUISITION PARAMS
    //==========================================================================
    // what are your eye variables?
    // In 023, calibration target is 12.8cm horizontal, 12.8 cm vertical. Atan(12.8/58) = 9.74 deg, Atan(12.8/58) = 11.23 deg
    // x scaling factor to convert eye trace voltage to degrees (must be calculated from calibration)
    EYE_X_GAIN = 3.622;    //5.1;//9.74; //50; //3.492;
    // y scaling factor to convert eye trace voltage to degrees (must be calculated from calibration)
    EYE_Y_GAIN = 3.837;    //5.1;//11.23; //50; //3.729;

    // what kind of hardware configuration are you using?
    JUICE_CHANNEL = 9;
    //  STIM_CHANNEL  = 1;
    EYE_X_CHANNEL       = 1;
    EYE_Y_CHANNEL       = 2;
    EYE_PUPIL_CHANNEL   = 5;
    PHOTOCELL_L_CHANNEL = 4;
    PHOTOCELL_R_CHANNEL = 3;
    MAX_VOLTAGE         = 10;     //look at das_gain and das_polarity in kped (setup tn)
    ANALOG_UNITS        = 65536;  // use this for a 16 bit AD board
    //AnalogUnits   = 4096;// use this for a 12 bit AD board
} /* RIG_029 */
