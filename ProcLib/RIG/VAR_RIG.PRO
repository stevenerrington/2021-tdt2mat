//==========================================================================
// VAR_RIG.PRO
// Description:Set global variable for all RIGS.
// Screen settings, isoluminant colors, data acquisition channels
// These should be defined in RIG_xxx() processes in RIGS/ subdir
// Author: chenchal.subraveti@vanderbilt.edu
// Date: 2019-01-16
//==========================================================================
// Revision History:
// 001: 2019/01/16 chenchal subraveti
//

declare int RIG_ID;

// Ports on DIO board
declare constant PORTA = 0x1;
declare constant PORTB = 0x2;
declare constant PORTC = 0x4;

//==========================================================================
// Screen width and height in pixels
declare int   VDO_SYNC_MODE;
declare int   SCRN_PIX_X;
declare int   SCRN_PIX_Y;
// Screen width and height in mm
declare float SCRN_MM_X;
declare float SCRN_MM_Y;
declare float REFRESH_RATE; // Distance from center of Subject's eyeball to screen
declare float SUBJ_DIST_MM; // ISOLUMINANT colors
// Screen mm to degrees
declare float SCRN_DEG_X;
declare float SCRN_DEG_Y;
// Screen degrees to pixel conversion factor
declare float DEG_2_PIX_X;
declare float DEG_2_PIX_Y;

//==========================================================================
declare int RED_VAL;
declare int GREEN_VAL;
declare int BLUE_VAL;
declare int YR_OFF;
declare int MR_OFF;
declare int MB_OFF;
declare int CG_OFF;
declare int CB_OFF;
declare int WR_OFF;
declare int WG_OFF;
declare int WB_OFF;   // DATA ACQUISITION PARAMS
//==========================================================================
// Eye x scaling factor to convert eye trace voltage to degrees declare float EYE_X_GAIN;//5.1;//9.74; //50; //3.492;
// Eye y scaling factor to convert eye trace voltage to degrees
declare float EYE_X_GAIN;
declare float EYE_Y_GAIN;
// For seroing Eye x,y location to center of screen
declare float EYE_X_OFFSET;
declare float EYE_Y_OFFSET;
// Current Eyex and Eyey
declare float EYE_X_VOLTS;
declare float EYE_Y_VOLTS;
declare float CURR_EYE_X_DEG;
declare float CURR_EYE_Y_DEG;
declare float CURR_EYE_ANGLE;
declare float CURR_EYE_ECC;

// Eye location flags
declare int I_FIX_ACQ;
declare int I_FIX;
declare int I_FIX_WIDE;
declare int I_TARG;
declare int I_TARG_ANTI;
declare int I_TARG_WIDE;
declare int I_TARG_ANTI_WIDE;
declare int I_INVALID;


// For dynamically centering the Eye position
// Add these to .pcf file
//         KEY ALTE = Eye_on_VDOSync = 1
//         KEY ALTX = Eye_on_VDOSync = 0
//         KEY ALTC = CenterEyeNow = 1
declare EYE_ON_VDOSYNC = 0;
declare CENTER_EYE_NOW = 0;

// Hardware setup
declare int JUICE_CHANNEL;
declare int STIM_CHANNEL;
declare int EYE_X_CHANNEL;
declare int EYE_Y_CHANNEL;
declare int EYE_PUPIL_CHANNEL;
declare int PHOTOCELL_L_CHANNEL;
declare int PHOTOCELL_R_CHANNEL;
//Check das_gain and das_polarity in kped (setup tn)
declare int MAX_VOLTAGE;
// Base the number on n-bits of AD board
declare int ANALOG_UNITS;
