//==========================================================================
// TONETEST.PRO
//   Description: Test playing of different tones
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-02-08
//==========================================================================
//  Revision History:
//  002: 2019-02-08 chenchal subraveti
//       Adapted from BITSWEEP.PRO
//

#include C:/TEMPO/ProcLib/UTIL/SEND_EVT.PRO
#include C:/TEMPO/ProcLib/UTIL/TONE.PRO

declare TONETEST();
declare PLAY_HP();

declare int playHp         = 0;
declare int playWhiteNoise = 0;


process TONETEST() enabled
{
    declare int freq[10] = { 100, 200, 300, 500, 1000, 2000, 4000, 8000, 16000, 32000 };
    declare int duration = 50;
    declare int temp     = 0;

    // set tone to off
    mio_fout(0);

    temp = 0;
    while (temp < 10)
    {
        spawnwait TONE(freq[temp], duration);

        temp = temp + 1;
    }
    if (playHp)
    {
        spawnwait PLAY_HP();
    }
    if (playWhiteNoise)
    {
        spawnwait PLAY_WHITE_NOISE(2000);
    }
} /* TONETEST */


// Play Harry Potter Theme Song:-)
// Check the file: https://www.instructables.com/id/Arduino-Harry-Potter-Theme-Song/
// check: https://www.arduino.cc/en/Tutorial/ToneMelody?from=Tutorial.Tone
process PLAY_HP()
{
    declare int   A   = 550;
    declare int   As  = 582;
    declare int   B   = 617;
    declare int   C   = 654;
    declare int   Cs  = 693;
    declare int   D   = 734;
    declare int   Ds  = 777;
    declare int   E   = 824;
    declare int   F   = 873;
    declare int   Fs  = 925;
    declare int   G   = 980;
    declare int   Gs  = 1003;
    declare int   A2  = 1100;
    declare int   A2s = 1165;
    declare int   B2  = 1234;
    declare int   C3  = 1308;
    declare int   C3s = 1385;
    declare int   D3  = 1555;

    declare float half     = 0.5;
    declare float one      = 1.0;
    declare float one_half = 1.5;
    declare float two      = 2.0;
    declare float two_half = 2.5;
    declare int   tempo    = 400;


    spawnwait TONE(B, Int(tempo *one));
    spawnwait TONE(E, Int(tempo *one_half));
    spawnwait TONE(G, Int(tempo *half));
    spawnwait TONE(F, Int(tempo *one));
    spawnwait TONE(E, Int(tempo *two));
    spawnwait TONE(B2, Int(tempo *one));
    spawnwait TONE(A2, Int(tempo *two_half));
    spawnwait TONE(Fs, Int(tempo *two_half));

    spawnwait TONE(E, Int(tempo *one_half));
    spawnwait TONE(G, Int(tempo *half));
    spawnwait TONE(F, Int(tempo *one));
    spawnwait TONE(Ds, Int(tempo *two));
    spawnwait TONE(F, Int(tempo *one));
    spawnwait TONE(B, Int(tempo *two_half));
} /* PLAY_HP */
