//==========================================================================
// SET_SCRN.PRO
//   Description: Set Virtual screen coordinates.(0,0 is center)
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2018-09-06
//==========================================================================
//  Revision History:
//  001: 2018/09/06 chenchal subraveti
//      Establish Virtual coordinate system.
//  Screen dimensions in pixels, mm, and subject distance are defined in CONFIG/ROOM0DD.PRO
//  For 1280 by 768
//
//            (+384)
//               |
//               |
//  (-640)-----(0,0)-----(+640)
//               |
//               |
//            (-384)
//
declare SET_SCRN();

//==========Derived measurements from global variables=============
// Screen mm to pixel conversion factor
declare float constant MM_2_PIX_X = SCRN_PIX_X/SCRN_MM_X;
declare float constant MM_2_PIX_Y = SCRN_PIX_Y/SCRN_MM_Y;
// Screen in degrees of visual angle
// Visual angle is angle subtended by gaze shift from center of screen to either
// Left/right or top/bottom of the screen. Therefore,
// distance from eye to screen is adjacent, while
// distance from center of screen to left/right of screen is opposite in X-coordinate
// distance from center of screen to top/bottom of screen is opposite in Y-coordinate
//(eye)X---------|
//       X-------|
//         X-----|
//           X---|
//             X-|
//               X
// Screen mm to degrees
declare float SCRN_DEG_X;
declare float SCRN_DEG_Y;
// Screen degrees to pixel conversion factor
declare float DEG_2_PIX_X;
declare float DEG_2_PIX_Y;


process SET_SCRN()
{
    SCRN_DEG_X = rad2deg(atan((SCRN_MM_X/2)/SUBJ_DIST_MM));
    SCRN_DEG_Y = rad2deg(atan((SCRN_MM_Y/2)/SUBJ_DIST_MM));

    DEG_2_PIX_X = (SCRN_PIX_X/2)/SCRN_DEG_X;
    DEG_2_PIX_Y = (SCRN_PIX_Y/2)/SCRN_DEG_Y;

    printf("SET_SCRN: Deg2Pix_X(DEG_2_PIX_X) %0.4d, Deg2Pix_Y(DEG_2_PIX_Y) %0.4d\n", DEG_2_PIX_X, DEG_2_PIX_Y);
    printf("SET_SCRN: Unit2Pix_X(MM_2_PIX_X) %0.4d, Unit2Pix_Y(MM_2_PIX_Y) %0.4d\n", MM_2_PIX_X, MM_2_PIX_Y);
    printf("SET_SCRN: Setting virtual cordinate system for drawing pages to screen buffer\n");

    // Set screen virtual coordinate systm for screen
    dsendf("vc %d, %d, %d, %d\n", SCRN_PIX_X/(-2), SCRN_PIX_X/2, SCRN_PIX_Y/2, SCRN_PIX_Y/(-2));
}
