//==========================================================================
// JITTER.PRO
//   Description: Create an instance of a different distributions.
//                The computed value is written to a global variable JITTER_INT.
//
//   Inputs:
//          GAUSS_JITTER(int meanT, int spreadT):
//          UNIFORM_JITTER(int meanT, int spreadT);:
//          EXPONENT_JITTER(int meanT, int spreadT);:
//   Output:
//         Global variable: JITTER_INT (int)
//
//   Usage:
//                spawnwait GAUSS_JITTER(600,15);
//                valueNeeded = JITTER_INT;
//
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-03-05
//==========================================================================

declare GAUSS_JITTER(int meanT, int spreadT);
declare UNIFORM_JITTER(int meanT, int spreadT);
declare EXPONENT_JITTER(int meanT, int spreadT);

declare constant int JITTER_NONE             = 0;
declare constant int JITTER_GAUSS_FLAG       = 1;
declare constant int JITTER_UNIFORM_FLAG     = 2;
declare constant int JITTER_EXPONENTIAL_FLAG = 3;

declare int          JITTER_INT;


process JITTER(int meanT, int spreadT, int jitterFlag)
{
    if (meanT <= 0)
    {
        JITTER_INT = 0;
    }
    else if (meanT > 0 && spreadT <= 0)
    {
        JITTER_INT = meanT;
    }
    else if (jitterFlag == JITTER_NONE)
    {
        JITTER_INT = meanT;
    }
    else if (jitterFlag == JITTER_GAUSS_FLAG)
    {
        spawnwait GAUSS_JITTER(meanT, spreadT);
    }
    else if (jitterFlag == JITTER_UNIFORM_FLAG)
    {
        spawnwait UNIFORM_JITTER(meanT, spreadT);
    }
    else if (jitterFlag == JITTER_EXPONENTIAL_FLAG)
    {
        spawnwait EXPONENT_JITTER(meanT, spreadT);
    }
}


// Gaussian distribution
process GAUSS_JITTER(int meanT, int spreadT)
{
    // Box-Muller transform
    //Using: https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform
    declare float u1, u2, z1, tol;
    declare float twoPi = 2.0 * 22/7;

    // uniform random number (0 < u1 < 1)
    u1 = (random(65535) + 1.0)/65536.0;
    u2 = (random(65535) + 1.0)/65536.0;

    z1 = sqrt(-2.0 * ln(u1)) * cosrad(u2 * twoPi);
    //z1 = sqrt(-2.0 * ln(u1)) * sinrad(u2 * twoPi);

    JITTER_INT = round(z1 * spreadT) + meanT;
}


// Random uniform distribution
process UNIFORM_JITTER(int meanT, int spreadT)
{
    JITTER_INT = (meanT - spreadT) + random(2*spreadT);
}


// Exponential distribution
process EXPONENT_JITTER(int meanT, int spreadT)
{
    declare float jitter;

    jitter     = (random(1001))/1000.0;
    jitter     = exp(-1.0 * jitter/0.25);
    JITTER_INT = round(jitter * spreadT + meanT);
}
