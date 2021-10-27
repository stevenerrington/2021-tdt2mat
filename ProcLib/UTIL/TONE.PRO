//==========================================================================
// TONE.PRO
//   Description: Play a tone of specified frequency and duration over the speaker.
//                See section 6-60-6-64 of the TEMPO reference manual.
//                mio_fout- Pulse Generator on Analog Board:
//                If the pcie-das1602l16 counter is used as an POUT, it is initialized
//                to 0 Hz (off) when the KERNEL is loaded (i.e., mio_fout(O)). The default
//                internal clock rate is 1 MHz (see Jumper P2 on board). If you set jumper P2 to 10 MHz,
//                that will be used as the internal clock for the counter.
//   Example from TEMPO manual:
//           int hzMioFout = 1000000; // P2 Jumper is set, 10MHz
//           int hzFreq = 220; // middle C
//           mio_fout(hzMioFout/hzFreq); // Set FOUT to gener ate pulses at h zFreq
//           mio_fout (0); // Disable FOUT pulses
//
//   Inputs:
//           frequency: Tone frequency
//           duration: Length of time tome needs to be played
//
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-02-08
//==========================================================================
//  Revision History:
//  001: 2019/02/08 chenchal subraveti


declare TONE(int frequency, int duration);
declare PLAY_WHITE_NOISE(int duration);


process TONE(int frequency, int duration)
{
    // P2 Jumper is set so, 10 MHz
    declare int internalClock = 10000000;

    spawn SEND_EVT(EVT_AUDIO_START_);

    mio_fout(internalClock/frequency);
    nexttick duration;
    spawn SEND_EVT(EVT_AUDIO_END_);

    mio_fout(0);
}


process PLAY_WHITE_NOISE(int duration)
{
    // Play random 50-20050 Hz each for varying duration
    declare int runDuration;
    declare int delta;
    declare int freq;

    while (runDuration <= duration)
    {
        delta = random(5) + 1;
        freq  = random(20000) + 50;
        if ((runDuration + delta) > duration)
        {
            delta = runDuration + delta - duration;
        }
        spawn TONE(freq, delta);

        runDuration = runDuration + delta;
        nexttick delta;
    }
}
