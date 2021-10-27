//==========================================================================
// GRAPHS.PRO
//   Description: Setup graph objects for updating.
//                Adapted form GRAPHS.PRO from previous builds
//                BY david c godlove Jan 2011
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-01-23
//==========================================================================
//  Revision History:
//

#include C:/TEMPO/ProcLib/GRAFS/OBJECT.PRO

// graph objects for LEFT window
declare OBJ_EYE;
declare OBJ_FIX;
declare OBJ_FIX_WIN_ACQ;
declare OBJ_FIX_WIN;
declare OBJ_FIX_WIN_L;
declare OBJ_TARG;
declare OBJ_TARG_WIN;
declare OBJ_TARG_WIN_L;
declare OBJ_TARG_WIN_ANTI;
declare OBJ_TARG_WIN_ANTI_L;

//
declare int GRAF_SHOW = 1;
declare int GRAF_HIDE = 0;


declare GRAPHS();
declare GRAF_UPD8_EYE(float currEyeX, float currEyeY);
declare GRAF_UPD8_FIX();
declare GRAF_UPD8_TARG(float targSize, float targAngle, float targEccentricity);

// only fis/target windows
declare GRAF_SHOW_FIX_WIN();
declare GRAF_SHOW_TARG_WIN();

// fixsopt/target and related windows
declare GRAF_HIDE_FIX_TARG();
declare GRAF_SHOW_FIX_TARG();

// only fixspot or target
declare GRAF_SHOW_FIX(int showHide);
declare GRAF_SHOW_TARG(int showHide);


process GRAPHS()
{
    oSetGraph(gLEFT, aCLEAR);
    // set LEFT graph to virtual coordinates
    oSetGraph(gLEFT, aRANGE, -SCRN_PIX_X/2, SCRN_PIX_X/2, -SCRN_PIX_Y/2, SCRN_PIX_Y/2);
    oSetGraph(gLEFT, aTITLE, "TASK PROGRESS");
    //=======EYE OBJECT============
    // Create eye as a visible + type graph
    OBJ_EYE = oCreate(tCross, gLEFT, DEG_2_PIX_X, DEG_2_PIX_Y);
    oSetAttribute(OBJ_eye, aVISIBLE);
    //=======FIX/FIX_WINDOW OBJECTS============
    // Create invisible filled box type graph for fix spot
    OBJ_FIX = oCreate(tBOX, gLEFT, 0, 0);
    oSetAttribute(OBJ_FIX, aFILLED);
    oSetAttribute(OBJ_FIX, aINVISIBLE);
    // Create invisible unfilled box type graph for fix window
    OBJ_FIX_WIN = oCreate(tBOX, gLEFT, 0, 0);
    oSetAttribute(OBJ_FIX_WIN, aUNFILLED);
    oSetAttribute(OBJ_FIX_WIN, aINVISIBLE);
    OBJ_FIX_WIN_ACQ = oCreate(tBOX, gLEFT, 0, 0);
    oSetAttribute(OBJ_FIX_WIN_ACQ, aUNFILLED);
    oSetAttribute(OBJ_FIX_WIN_ACQ, aINVISIBLE);
    OBJ_FIX_WIN_L = oCreate(tBOX, gLEFT, 0, 0);
    oSetAttribute(OBJ_FIX_WIN_L, aUNFILLED);
    oSetAttribute(OBJ_FIX_WIN_L, aINVISIBLE);
    //=======TARGET/TARGET_WINDOW OBJECTS============
    // Create invisible filled box type graph for target
    OBJ_TARG = oCreate(tBOX, gLEFT, 0, 0);
    oSetAttribute(OBJ_TARG, aFILLED);
    oSetAttribute(OBJ_TARG, aINVISIBLE);
    // Create invisible unfilled box type graph for target window
    OBJ_TARG_WIN = oCreate(tBOX, gLEFT, 0, 0);
    oSetAttribute(OBJ_TARG_WIN, aUNFILLED);
    oSetAttribute(OBJ_TARG_WIN, aINVISIBLE);
    OBJ_TARG_WIN_L = oCreate(tBOX, gLEFT, 0, 0);
    oSetAttribute(OBJ_TARG_WIN_L, aUNFILLED);
    oSetAttribute(OBJ_TARG_WIN_L, aINVISIBLE);
    // Create invisible unfilled box type graph for target window ANTI
    OBJ_TARG_WIN_ANTI = oCreate(tBOX, gLEFT, 0, 0);
    oSetAttribute(OBJ_TARG_WIN, aUNFILLED);
    oSetAttribute(OBJ_TARG_WIN, aINVISIBLE);
    OBJ_TARG_WIN_ANTI_L = oCreate(tBOX, gLEFT, 0, 0);
    oSetAttribute(OBJ_TARG_WIN_L, aUNFILLED);
    oSetAttribute(OBJ_TARG_WIN_L, aINVISIBLE);
} /* GRAPHS */


process GRAF_UPD8_EYE(float currEyeX, float currEyeY)
{
    oMove(OBJ_EYE, currEyeX * DEG_2_PIX_X, currEyeY * DEG_2_PIX_Y);
}


process GRAF_UPD8_FIX()
{
    oSetAttribute(OBJ_FIX, aSIZE, ceil(FIX_SIZE_DEG * DEG_2_PIX_X), ceil(FIX_SIZE_DEG * DEG_2_PIX_Y));
    oSetAttribute(OBJ_FIX, aINVISIBLE);
    oSetAttribute(OBJ_FIX_WIN, aSIZE, FIX_WIN_SIZE * DEG_2_PIX_X, FIX_WIN_SIZE * DEG_2_PIX_Y);
    oSetAttribute(OBJ_FIX, aVISIBLE);
    oSetAttribute(OBJ_FIX_WIN_ACQ, aSIZE, FIX_WIN_ACQ_SIZE * DEG_2_PIX_X, FIX_WIN_ACQ_SIZE * DEG_2_PIX_Y);
    oSetAttribute(OBJ_FIX, aVISIBLE);
    oSetAttribute(OBJ_FIX_WIN_L, aSIZE, FIX_WIN_SIZE_LARGE * DEG_2_PIX_X, FIX_WIN_SIZE_LARGE * DEG_2_PIX_Y);
    oSetAttribute(OBJ_FIX, aVISIBLE);
}


process GRAF_UPD8_TARG(float targSize, float targAngle, float targEccentricity)
{
    declare float eccX;
    declare float eccY;

    // find the center of the box in x and y space based on the targAngle and targEccentricity...
    eccX = cos(targAngle) * targEccentricity;
    eccY = -sin(targAngle) * targEccentricity;
    // Update animated graph object
    oSetAttribute(OBJ_TARG, aSIZE, targSize * DEG_2_PIX_X, targSize * DEG_2_PIX_Y);
    oMove(OBJ_TARG, eccX * DEG_2_PIX_X, eccY * DEG_2_PIX_Y);
    oSetAttribute(OBJ_TARG, aINVISIBLE);

    oSetAttribute(OBJ_TARG_WIN, aSIZE, TARG_WIN_SIZE * DEG_2_PIX_X, TARG_WIN_SIZE * DEG_2_PIX_Y);
    oMove(OBJ_TARG_WIN, eccX * DEG_2_PIX_X, eccY * DEG_2_PIX_Y);
    oSetAttribute(OBJ_TARG_WIN, aVISIBLE);

    oSetAttribute(OBJ_TARG_WIN_L, aSIZE, TARG_WIN_SIZE_LARGE * DEG_2_PIX_X, TARG_WIN_SIZE_LARGE * DEG_2_PIX_Y);
    oMove(OBJ_TARG_WIN_L, eccX * DEG_2_PIX_X, eccY * DEG_2_PIX_Y);
    oSetAttribute(OBJ_TARG_WIN_L, aVISIBLE);

    // ANTI- find the center of the box in x and y space based on the targAngle and targEccentricity...
    eccX = cos(targAngle + 180) * targEccentricity;
    eccY = -sin(targAngle + 180) * targEccentricity;
    // Update animated graph object
    oMove(OBJ_TARG_WIN_ANTI, eccX * DEG_2_PIX_X, eccY * DEG_2_PIX_Y);
    oSetAttribute(OBJ_TARG_WIN_ANTI, aSIZE, TARG_WIN_SIZE * DEG_2_PIX_X, TARG_WIN_SIZE * DEG_2_PIX_Y);
    oSetAttribute(OBJ_TARG_WIN_ANTI, aINVISIBLE);

    oMove(OBJ_TARG_WIN_ANTI_L, eccX * DEG_2_PIX_X, eccY * DEG_2_PIX_Y);
    oSetAttribute(OBJ_TARG_WIN_ANTI_L, aSIZE, TARG_WIN_SIZE_LARGE * DEG_2_PIX_X, TARG_WIN_SIZE_LARGE * DEG_2_PIX_Y);
    oSetAttribute(OBJ_TARG_WIN_ANTI_L, aINVISIBLE);
}


process GRAF_HIDE_FIX_TARG()
{
    oSetAttribute(OBJ_FIX, aINVISIBLE);
    oSetAttribute(OBJ_FIX_WIN_ACQ, aINVISIBLE);
    oSetAttribute(OBJ_FIX_WIN, aINVISIBLE);
    oSetAttribute(OBJ_FIX_WIN_L, aINVISIBLE);

    oSetAttribute(OBJ_TARG, aINVISIBLE);
    oSetAttribute(OBJ_TARG_WIN, aINVISIBLE);
    oSetAttribute(OBJ_TARG_WIN_L, aINVISIBLE);
}


process GRAF_SHOW_FIX_TARG()
{
    oSetAttribute(OBJ_FIX, aVISIBLE);
    oSetAttribute(OBJ_FIX_WIN_ACQ, aVISIBLE);
    oSetAttribute(OBJ_FIX_WIN, aVISIBLE);
    oSetAttribute(OBJ_FIX_WIN_L, aVISIBLE);

    oSetAttribute(OBJ_TARG, aVISIBLE);
    oSetAttribute(OBJ_TARG_WIN, aVISIBLE);
    oSetAttribute(OBJ_TARG_WIN_L, aVISIBLE);
}


process GRAF_SHOW_FIX_WIN()
{
    oSetAttribute(OBJ_FIX_WIN_ACQ, aVISIBLE);
    oSetAttribute(OBJ_FIX_WIN, aVISIBLE);
    oSetAttribute(OBJ_FIX_WIN_L, aVISIBLE);
}


process GRAF_SHOW_TARG_WIN()
{
    oSetAttribute(OBJ_TARG_WIN, aVISIBLE);
    oSetAttribute(OBJ_TARG_WIN_L, aVISIBLE);
}


process GRAF_SHOW_FIX(int showHide)
{
    if (showHide == GRAF_SHOW)
    {
        oSetAttribute(OBJ_FIX, aVISIBLE);
        oSetAttribute(OBJ_FIX_WIN_ACQ, aVISIBLE);
        oSetAttribute(OBJ_FIX_WIN, aVISIBLE);
        oSetAttribute(OBJ_FIX_WIN_L, aVISIBLE);
    }
    else
    {
        oSetAttribute(OBJ_FIX, aINVISIBLE);
        //fix win still visible
        oSetAttribute(OBJ_FIX_WIN_ACQ, aVISIBLE);
        oSetAttribute(OBJ_FIX_WIN, aVISIBLE);
        oSetAttribute(OBJ_FIX_WIN_L, aVISIBLE);
    }
}


process GRAF_SHOW_TARG(int showHide)
{
    if (showHide == GRAF_SHOW)
    {
        oSetAttribute(OBJ_TARG, aVISIBLE);
        oSetAttribute(OBJ_TARG_WIN, aVISIBLE);
        oSetAttribute(OBJ_TARG_WIN_L, aVISIBLE);
    }
    else
    {
        oSetAttribute(OBJ_TARG, aINVISIBLE);
        // targ_win still visible
        oSetAttribute(OBJ_TARG_WIN, aVISIBLE);
        oSetAttribute(OBJ_TARG_WIN_L, aVISIBLE);
    }
}
