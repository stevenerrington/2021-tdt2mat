
//==========================================================================
// BITSWEEP.PRO
//   Description: Sweep through each bit to make sure that TDT can read all bits for event codes
//   Author: kaleb lowe
//   Date: ---
//==========================================================================
//  Revision History:
//  002: 2019/01/21 chenchal subraveti
//       Adapted from BITSWEEP.PRO
// Sweep through each bit to make sure that TDT can read all bits for event codes

#include C:/TEMPO/ProcLib/UTIL/SEND_EVT.PRO

declare BITSWEEP();

// Ports on DIO board, defined in VAR_RIG
declare constant PORTA = 0x1;
declare constant PORTB = 0x2;
declare constant PORTC = 0x4;


process BITSWEEP() enabled
{
    declare int maxBits  = 16;
    declare int thisBit  = 0;
    declare int waitTime = 1000;
    declare int sentTime;
    declare int bitValue;
    declare int temp = 0;

    spawn QUE_TTL();

    thisBit = 0;
    while (1)
    {
        thisBit = 0;
        while (thisBit < maxBits)
        {
            if (thisBit == 0)
            {
                bitValue = 1;
            }
            else
            {
                bitValue = bitValue * 2;
            }
            if (thisBit == maxBits - 1)
            {
                bitValue = bitValue - 1;
            }

            temp = 0;
            while (temp < 5)
            {
                printf("Sending bit [%d] value(2^%d) = [%d]\n", thisBit, thisBit, bitValue);
                spawnwait SEND_EVT(bitValue);

                wait 200;
                printf("Sending negative bit [%d] value(2^%d) = [%d]\n", thisBit, thisBit, -bitValue);
                spawnwait SEND_EVT(-bitValue);

                wait 200;
                printf("Sending (2^%d) + abs(negative value [%d])  = [%d]\n", 15, -bitValue, (32768 + bitValue));
                spawnwait SEND_EVT((32768 + bitValue));

                wait 200;
                wait 5000;
                temp = temp + 1;
            }
            sentTime = time();
            while (time() < (sentTime + waitTime))
            {
                nexttick;
            }
            thisBit = thisBit + 1;
        }
        nexttick 500;
        printf("Doing next cycle...\n");
    }
} /* BITSWEEP */
