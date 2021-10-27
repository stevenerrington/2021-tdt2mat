//--------------------------------------------------------------------------------------------
// Run a fixation trial based on the variables calculated by SETF_TRL.pro and those
// given by the user.
//
// written by david.c.godlove@vanderbilt.edu    January, 2011


declare FIXTRIAL(allowed_fix_time,              // see ALL_VARS.pro and DEFAULT.pro
                 max_saccade_time,              // see ALL_VARS.pro and DEFAULT.pro
                 targ_hold_time,                // see ALL_VARS.pro and DEFAULT.pro
                 object_targ);                  // animated graph object


process FIXTRIAL(allowed_fix_time,              // see ALL_VARS.pro and DEFAULT.pro
                 max_saccade_time,              // see ALL_VARS.pro and DEFAULT.pro
                 targ_hold_time,                // see ALL_VARS.pro and DEFAULT.pro
                 object_targ)                   // animated graph object
{
    // Number the trial stages to make them easier to read below
    declare hide int need_targ = 1;
    declare hide int fixating  = 2;


    // Number the stimuli pages to make reading easier
    declare hide int blank  = 0;
    declare hide int target = 1;


    // Timing variables which will be used to time task
    declare hide float targ_time;
    declare hide float aquire_targ_time;

    // These variables make the while loop work
    declare hide int trl_running;
    declare hide int stage;


    // Have to be reset on every iteration since
    // variable declaration only occurs at load time
    trl_running = 1;
    stage       = need_targ;




    // HERE IS WHERE THE FUN BEGINS
    dsendf("vp %d\n", target);                                                                                  // flip the pg to the target stim
    targ_time = time();                                                                                         // record the time
    oSetAttribute(object_targ, aVISIBLE);                                                                       // turn on the target in animated graph

    while (trl_running)                                                                                         // trials ending will set trl_running = 0
    {
        //--------------------------------------------------------------------------------------------
        // STAGE need_targ (the target is on, but the subject hasn't looked at it)
        if (stage == need_targ)
        {
            if (In_TargWin)                                                                             // If the eyes have entered the fixation window (before time, see below)...
            {
                aquire_targ_time = time();                                                              // ...function call to time to note current time and...
                stage            = fixating;                                                            // ...advance to the next stage.
            }
            else if (time() > targ_time + max_saccade_time)                                             // But if time runs out...
            {
                dsendf("vp %d\n", blank);                                                               // Flip the pg to the blank screen,...
                oSetAttribute(object_targ, aINVISIBLE);                                                 // ...remove target from animated graph...
                trl_running = 0;                                                                        // ...and terminate the trial.
            }
        }



        //--------------------------------------------------------------------------------------------
        // STAGE fixating (the subject is looking at the target waiting for reward)
        else if (stage == fixating)
        {
            if (!In_TargWin)                                                                                    // If the eyes stray out of the target window...
            {
                dsendf("vp %d\n", blank);                                                                       // Flip the pg to the blank screen...
                oSetAttribute(object_targ, aINVISIBLE);                                                         // ...remove target from animated graph...
                print("broke");
                trl_running = 0;                                                                                // ...and terminate the trial.
            }
            else if (In_TargWin && time() >
                     aquire_targ_time + targ_hold_time)                                                 // But if the eyes are still in the window at end of holdtime...
            {
                dsendf("vp %d\n", blank);                                                               // Flip the pg to the blank screen...
                oSetAttribute(object_targ, aINVISIBLE);                                                 // ...remove target from animated graph...
                spawn TONE(success_Tone_medR, tone_duration);                                           // give the secondary reinforcer tone
                spawn JUICE(juice_channel, Base_Reward_time);                                           // YEAH BABY!  THAT'S WHAT IT'S ALL ABOUT!

                trl_running = 0;                                                                        // ...and terminate the trial.
            }
        }



        nexttick;
    }
} /* FIXTRIAL */