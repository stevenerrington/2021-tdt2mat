//==========================================================================
// ROOM29.PRO
//   Description: Set global variable for room 29
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2018-09-06
//==========================================================================
//  Revision History:
//

// Global variables for Room 29
//==========================================================================
// Screen width and height in pixels
declare int constant   SCRN_PIX_X = 640;
declare int constant   SCRN_PIX_Y = 400;
// Screen width and height in mm
declare float constant SCRN_MM_X = 375.0;
declare float constant SCRN_MM_Y = 275.0;
// Distance from center of Subject'seyeball to screen
declare float constant SUBJ_DIST_MM = 570.0;

declare float constant REFRESH_RATE = 1000.0/60;

// ISOLUMINANT colors
//==========================================================================
declare int RED_VAL   = 30;
declare int GREEN_VAL = 19;
declare int BLUE_VAL  = 64;
declare int YR_OFF    = 13;
declare int MR_OFF    = 9;
declare int MB_OFF    = 27;
declare int CG_OFF    = 1;
declare int CB_OFF    = 44;
declare int WR_OFF    = 13;
declare int WG_OFF    = 6;
declare int WB_OFF    = 50;

// DATA ACQUISITION PARAMS
//==========================================================================
// what are your eye variables?
// In 023, calibration target is 12.8cm horizontal, 12.8 cm vertical. Atan(12.8/58) = 9.74 deg, Atan(12.8/58) = 11.23 deg
// x scaling factor to convert eye trace voltage to degrees (must be calculated from calibration)
declare float constant EYE_X_GAIN = 3.622; //5.1;//9.74; //50; //3.492;
// y scaling factor to convert eye trace voltage to degrees (must be calculated from calibration)
declare float constant EYE_Y_GAIN = 3.837; //5.1;//11.23; //50; //3.729;

// what kind of hardware configuration are you using?
declare int constant JUICE_CHANNEL = 9;
//declare int constant STIM_CHANNEL  = 1;
declare int constant EYE_X_CHANNEL       = 1;
declare int constant EYE_Y_CHANNEL       = 2;
declare int constant PHOTOCELL_L_CHANNEL = 4;
declare int constant PHOTOCELL_R_CHANNEL = 3;
declare int constant MAX_VOLTAGE         = 10;    //look at das_gain and das_polarity in kped (setup tn)
declare int constant ANALOG_UNITS        = 65536; // use this for a 16 bit AD board
//AnalogUnits   = 4096;// use this for a 12 bit AD board
