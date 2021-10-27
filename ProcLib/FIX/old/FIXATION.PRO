//--------------------------------------------------------------------------------------------------
// This is the main fixation protocol.  It works like this.
// 1) Define all varialbes
// 2) Setup stimuli
// 3) Run a trial
// 4) repeat
//
// written by david.c.godlove@vanderbilt.edu    January, 2011

#include C:/TEMPO/ProcLib/FIXTRIAL.pro

declare FIXATION();


process FIXATION()
{
    declare hide int run_fix_sess = 2;
    declare hide int run_idle     = 0;



    if (Last_task != run_fix_sess)                                      // Only do this if we have gone into another task or if this is first run of day.
    {
        system("dialog Select_Monkey");
        spawnwait DEFAULT(State,                                                // Set all globals to their default values.
                          Monkey, Room);

        Last_task = run_fix_sess;
    }

    while (!OK)
    {
        nexttick;
        if (Set_monkey)
        {
            spawnwait DEFAULT(State,                                            // Set all globals to their default values based on the monkey.
                              Monkey, Room);

            Set_monkey = 0;
        }
    }

    if (fix_manual == 1)
    {
        Trl_number = 1;

        system("key currt = spawn KEY_T_UP");                   // define right key macro
        system("key curlf = spawn KEY_T_DN");                   // define left key macro
        system("key curup = spawn KEY_REWD");                   // define up key macro
        system("key curdn = OK = 1");                           // define down to start task
        spawnwait GOODVARS(State);

        spawnwait SET_DEFAULT_COLORS(n_targ_pos);


        nexttick 10;                                                            // to prevent buffer overflows after task reentry.
        while (State == run_fix_sess)                                           // while the user has not yet terminated the countermanding task
        {
            spawnwait WINDOWS(fixation_target,                                  // GLOBAL set by F_DFAULT and KEY_TARG (key macros KEY_T_UP and KEY_T_DN)
                              fix_win_size,                                     // see DEFAULT.pro and ALL_VARS.pro
                              targ_win_size,                                    // see DEFAULT.pro and ALL_VARS.pro
                              object_fixwin,                                    // animated graph object
                              object_targwin,                                   // animated graph object
                              deg2pix_X,                                        // see SET_COOR.pro
                              deg2pix_Y);                                       // see SET_COOR.pro

            oSetAttribute(object_fixwin, aINVISIBLE);

            spawnwait FIX_PGS(fixation_target,                                  // GLOBAL set by F_DFAULT and KEY_TARG (key macros KEY_T_UP and KEY_T_DN)
                              deg2pix_X,                                        // see SET_COOR.pro
                              deg2pix_Y,                                        // see SET_COOR.pro
                              object_targ);                                     // see GRAPHS.pro


            spawnwait FIXTRIAL(allowed_fix_time,                        // see ALL_VARS.pro and DEFAULT.pro
                               max_saccade_time,                        // see ALL_VARS.pro and DEFAULT.pro
                               targ_hold_time,                          // see ALL_VARS.pro and DEFAULT.pro
                               object_targ);                            // animated graph object


            Trl_number = Trl_number + 1;
            nexttick;                                                                           // wait at least one cycle and do it all again
            wait Inter_trl_int;                                                                 // wait for the intertrial interval
        }

        // the State global variables allow a control structure...
        // ...to impliment the task.
        State = run_idle;                                                                       // If we are out of the while loop the user wanted...
        // ...to stop cmanding.

        oDestroy(object_fixwin);                                                        // destroy all graph objects
        oDestroy(object_targwin);
        oDestroy(object_fix);
        oDestroy(object_targ);
        oDestroy(object_eye);

        oSetGraph(gleft, aCLEAR);                                                       // clear the left graph

        system("key currt = ");                                                         // clear right key macro
        system("key curlf = ");                                                         // clear left key macro
        system("key curup = ");                                                         // clear up key macro
        system("key curdn = ");                                                         // clear down key macro

        spawn IDLE;                                                                     // return control to IDLE.pro
    }
    else if (fix_manual == 0)
    {
        Trl_number    = 1;
        Inter_trl_int = 1500;

        spawnwait GOODVARS(State);

        spawnwait SET_DEFAULT_COLORS(n_targ_pos);


        nexttick 10;                                                            // to prevent buffer overflows after task reentry.
        while (State == run_fix_sess)                                           // while the user has not yet terminated the countermanding task
        {
            fixation_target = random(9);

            spawnwait WINDOWS(fixation_target,                                  // GLOBAL set by F_DFAULT and KEY_TARG (key macros KEY_T_UP and KEY_T_DN)
                              fix_win_size,                                     // see DEFAULT.pro and ALL_VARS.pro
                              targ_win_size,                                    // see DEFAULT.pro and ALL_VARS.pro
                              object_fixwin,                                    // animated graph object
                              object_targwin,                                   // animated graph object
                              deg2pix_X,                                        // see SET_COOR.pro
                              deg2pix_Y);                                       // see SET_COOR.pro

            oSetAttribute(object_fixwin, aINVISIBLE);

            spawnwait FIX_PGS(fixation_target,                                  // GLOBAL set by F_DFAULT and KEY_TARG (key macros KEY_T_UP and KEY_T_DN)
                              deg2pix_X,                                        // see SET_COOR.pro
                              deg2pix_Y,                                        // see SET_COOR.pro
                              object_targ);                                     // see GRAPHS.pro


            spawnwait FIXTRIAL(allowed_fix_time,                        // see ALL_VARS.pro and DEFAULT.pro
                               max_saccade_time,                        // see ALL_VARS.pro and DEFAULT.pro
                               targ_hold_time,                          // see ALL_VARS.pro and DEFAULT.pro
                               object_targ);                            // animated graph object


            Trl_number = Trl_number + 1;
            nexttick;                                                                           // wait at least one cycle and do it all again
            wait Inter_trl_int;                                                                 // wait for the intertrial interval
        }

        // the State global variables allow a control structure...
        // ...to impliment the task.
        State = run_idle;                                                                       // If we are out of the while loop the user wanted...
        // ...to stop cmanding.

        oDestroy(object_fixwin);                                                        // destroy all graph objects
        oDestroy(object_targwin);
        oDestroy(object_fix);
        oDestroy(object_targ);
        oDestroy(object_eye);

        oSetGraph(gleft, aCLEAR);                                                       //

        spawn IDLE;
    }
} /* FIXATION */