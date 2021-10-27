//==========================================================================
// TST_GO.PRO
//   Description: Test Go trials
//   NOTE:
//         Only works if MONK_ID is set to AUTO_ID
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-01-25
//==========================================================================
//  Revision History:
//

declare TEST_GO_TRIALS();

// For different states
declare TEST_GET_READY();
declare TEST_FIX_ON();
declare TEST_FIXATE();
declare TEST_TARG_ON();
declare TEST_TARG_ACQ();
declare TEST_TARG_SSD();

// Utils for eye pos
// declare AUTO_EYE_POS_ACQ_TARG();
// declare AUTO_EYE_POS_MARCH();
// declare AUTO_EYE_POS_RAND();
// declare AUTO_EYE_POS_FIX();
// declare AUTO_EYE_POS_FIX_WIDE();
// declare AUTO_EYE_POS_TARG();


//======Flags for states======
//0= no saccade
declare int AUTO_NO_SACC = 0;
//1= normal saccade
declare int AUTO_NORM_SACC = 1;
//2= early saccade
declare int AUTO_EARLY_SACC = 2;

declare int AUTO_SACC = AUTO_NORM_SACC;

// 0=stay in FIX (for late saccade)
declare int AUTO_I_FIX = 0;
// 1=goto Target within SACC_DURATION
declare int AUTO_I_TARG = 1;
// 2=goto random loc out of FIX WIN_W
declare int AUTO_I_WAIT_FIX = 2;

declare int AUTO_I_LOC_ = 1;


process TEST_GO()
{
    while (1)
    {
        if (CURR_STAT == STAT_IDLE)
        {
            spawnwait AUTO_EYE_POS_RAND();
        }
        else if (CURR_STAT == STAT_GET_READY)
        {
            if (STAT_DLTA_T <= (STAT_ALLOWED_T)+10)
            {
                spawnwait AUTO_EYE_POS_FIX_WIDE();
            }
        }
        else if (CURR_STAT == STAT_FIX_ON)
        {
            if (STAT_DLTA_T <= round(STAT_ALLOWED_T * 0.8))
            {
                // hold position for half the allowed fix timetime
                TEST_X_DEG = TEST_X_DEG + random(10)/10.0;
                TEST_Y_DEG = TEST_Y_DEG + random(10)/10.0;
            }
            else       // fixate
            {
                spawnwait AUTO_EYE_POS_FIX();
            }
        }
        else if (CURR_STAT == STAT_FIX_HOLD)
        {
            if (STAT_DLTA_T <= round(STAT_ALLOWED_T * 1.1))
            {
                // hold fix
                TEST_X_DEG = random(5)/10.0;
                TEST_Y_DEG = random(5)/10.0;
            }
            else           // break fix
            {
                spawnwait AUTO_EYE_POS_FIX_WIDE();
            }
        }
        else if (CURR_STAT == STAT_TARG_ON)
        {
            spawnwait TEST_TARG_ON();
        }
        else if (CURR_STAT == STAT_TARG_ACQ)
        {
            spawnwait TEST_TARG_ACQ();
        }
        else if (CURR_STAT == STAT_TARG_SSD)
        {
            spawnwait TEST_TARG_SSD();
        }
        else
        {
            //freeze
            TEST_X_DEG = TEST_X_DEG;
            TEST_Y_DEG = TEST_Y_DEG;
        }
        nexttick;
    }
} /* AUTO_EYE */




// State FIXATE


// State TARG_SSD
process TEST_TARG_SSD()
{
    declare int out;

    // just fixate, no saccade
    spawnwait AUTO_EYE_POS_FIX();

    out = random(3);
    if (STAT_DLTA_T > (random(50) * random(10)) + 1)
    {
        if (out == 0)
        {
            spawnwait AUTO_EYE_POS_FIX();
        }
        else if (out == 1)
        {
            spawnwait AUTO_EYE_POS_RAND();
        }
        else if (out == 2)
        {
            spawnwait AUTO_EYE_POS_TARG();
        }
    }
}


// State TARG_ON
process TEST_TARG_ON()
{
    declare float fracTime;

    fracTime = 1.1;
    if (AUTO_SACC > 0)
    {
        // cant use random since it changes every nexttick
        fracTime = 0.8;
    }
    if (AUTO_SACC == AUTO_NO_SACC)
    {
        // hold fix
        spawnwait AUTO_EYE_POS_FIX();
    }
    else if (AUTO_SACC == AUTO_EARLY_SACC)     // early saccade
    {
        if (STAT_DLTA_T <= round(STAT_I_DURATION * fracTime))
        {
            // hold fix
            spawnwait AUTO_EYE_POS_FIX();
        }
        else
        {
            spawnwait AUTO_EYE_POS_FIX_WIDE();
        }
    }
    else     // normal saccade
    {
        if (STAT_DLTA_T <= round(STAT_ALLOWED_T * fracTime))
        {
            // hold fix
            spawnwait AUTO_EYE_POS_FIX();
        }
        else
        {
            spawnwait AUTO_EYE_POS_FIX_WIDE();
        }
    }
}


// State TARG_ACQ
process TEST_TARG_ACQ()
{
    declare float fracTime;

    // Eye should be in flight or not?
    if (AUTO_SACC == AUTO_NO_SACC)
    {
        spawnwait AUTO_EYE_POS_FIX();
    }
    else if (AUTO_I_LOC_ == AUTO_I_TARG)
    {
        fracTime = 0.5;
        if (STAT_DLTA_T < round(STAT_I_DURATION * fracTime))
        {
            spawnwait AUTO_EYE_POS_FIX();
        }
        else
        {
            spawnwait AUTO_EYE_POS_TARG();
        }
    }
    else if (AUTO_I_LOC_ == AUTO_I_WAIT_FIX)     // elsewhere
    {
        fracTime = 0.5;
        if (STAT_DLTA_T < round(STAT_I_DURATION * fracTime))
        {
            spawnwait AUTO_EYE_POS_FIX();
        }
        else
        {
            spawnwait AUTO_EYE_POS_FIX_WIDE();
        }
    }
}
