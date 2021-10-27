//==========================================================================
// JITR_TST.PRO
//   Description: Test different distributions
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-03-05
//==========================================================================
//  Revision History:
//  002: 2019-03-06 chenchal subraveti

#include C:/TEMPO/ProcLib/UTIL/JITTER.PRO

declare JITTER_TEST();


process JITTER_TEST() enabled
{
    declare int nPoints = 2000;

    declare int meanT     = 15;
    declare int varianceT = 3;

    declare int exponentJitter, uniformJitter, gaussJitter;

    declare int temp = 0;

    writef("jitters.csv exponentJitter, uniformJitter, gaussJitter\n");
    while (temp < nPoints)
    {
        spawnwait JITTER(meanT, varianceT, JITTER_EXPONENTIAL_FLAG);

        exponentJitter = JITTER_INT;

        spawnwait JITTER(meanT, varianceT, JITTER_UNIFORM_FLAG);

        uniformJitter = JITTER_INT;

        spawnwait JITTER(meanT, varianceT, JITTER_GAUSS_FLAG);

        gaussJitter = JITTER_INT;

        printf("%d,%d,%d\n", exponentJitter, uniformJitter, gaussJitter);
        writef("jitters.csv %d,%d,%d\n", exponentJitter, uniformJitter, gaussJitter);
        temp = temp + 1;
        nexttick 2;
    }
    printf("\n****Writing file : jitters.csv---will complete--ONLY when you exit the TEMPO Client****\n");
}/* JITTER_TEST */
