/* DIOTEST.PRO - Test DIO functions
**
** (This is for users with the DIO module and card).
**
*/
#include C:/Tempo/ProcLib/UTIL/DIO.PRO                     // DIO definitions

declare DIO_IN();
declare DIO_OUT();

dio_chip = 1;                           // 8255 chip to use (DIO0_BASE must be set)
HEX dio_a, dio_b, dio_c;                // 8255 TTL inputs

// Input 8255's 3 ports into PCL variables.

process DIO_IN enabled
{
    suspend DIO_OUT;                    // Run one or the other but not both!
    print();
    print("DIO set to input");
    print("Type SPAWN DIO_OUT to switch DIO to output");
    dioSetMode(dio_chip, 0);            // Set all DIO ports to INPUT

    while (1)
    {
        dio_a = dioGetA(dio_chip);
        dio_b = dioGetB(dio_chip);
        dio_c = dioGetC(dio_chip);
        nexttick;
    }
}

// Output 8255's 3 ports from PCL variables.

process DIO_OUT                         // Write to 8255 dio ports
{
    suspend DIO_IN;                     // Run one or the other but not both!
    print();
    print("DIO set to output");
    print("Type SPAWN DIO_IN to switch DIO to input.");
    dioSetMode(dio_chip, PORTA | PORTB | PORTC);   // Set all DIO ports to OUTPUT

    dio_a = 0;
    dio_b = 0xFF;
    dio_c = 0x0F;

    while (1)
    {
        wait    1000;
        dio_a = ~dio_a & 0xFF;
        dio_b = ~dio_b & 0xFF;
        dio_c = ~dio_c & 0xFF;
        dioSetA(dio_chip, dio_a);
        dioSetB(dio_chip, dio_b);
        dioSetC(dio_chip, dio_c);
    }
}
