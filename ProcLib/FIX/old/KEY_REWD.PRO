//------------------------------------------------------------------------
// process KEY_REWD()
// Give reward and play a tone when the button is pressed.  Had to be written
// b/c can't spawn processes with input at command prompt (stupid).
//
// written by david.c.godlove@vanderbilt.edu    January, 2011

declare KEY_REWD();


process KEY_REWD()
{
    declare hide int juice_duration, tone_freq, tone_durr;

    if (Base_Reward_time == 0)                                  //Don't know if these user defined globals have values yet
    {
        juice_duration = 80;
    }
    else
    {
        juice_duration = Base_Reward_time;
    }

    if (Success_Tone_medR == 0)                                 //Don't know if these user defined globals have values yet
    {
        tone_freq = 600;
    }
    else
    {
        tone_freq = Success_Tone_medR;
    }

    if (Tone_Duration == 0)                                     //Don't know if these user defined globals have values yet
    {
        tone_durr = 30;
    }
    else
    {
        tone_durr = Tone_Duration;
    }

    Event_fifo[Set_event] = ExtraReward_;
    Set_event             = (Set_event + 1) % Event_fifo_N;

    spawn JUICE(juice_channel, juice_duration);
    spawn TONE(tone_freq, tone_durr);
}