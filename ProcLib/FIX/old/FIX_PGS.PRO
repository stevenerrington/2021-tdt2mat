//--------------------------------------------------------------------------------------------------
// Figure out stimulus that will be needed on the next fixation trial and
// place it into video memory.
//
// written by david.c.godlove@vanderbilt.edu    January, 2011



declare FIX_PGS(int   curr_target,                                                                                                                      // set SETC_TRL.pro
                float deg2pix_X,                                                                                                                        // see SET_COOR.pro
                float deg2pix_Y,                                                                                                                        // see SET_COOR.pro
                int   object_targ);                                                                                                                     // see GRAPHS.pro


process FIX_PGS(int   curr_target,                                                                                                                      // set SETC_TRL.pro
                float deg2pix_X,                                                                                                                        // see SET_COOR.pro
                float deg2pix_Y,                                                                                                                        // see SET_COOR.pro
                int   object_targ)                                                                                                                      // see GRAPHS.pro
{
    declare hide float size;                                                                                                                            // Global output will be sent as stobes...
    declare hide float angle;                                                                                                                           // ...by INFOS.pro at trial end.
    declare hide float eccentricity;
    declare hide int   color;

    declare hide float stim_ecc_x;
    declare hide float stim_ecc_y;
    declare hide int   open = 0;
    declare hide int   fill = 1;

    // number the pgs that need to be drawn
    declare hide int blank  = 0;
    declare hide int target = 1;


    //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    // Calculate screen coordinates for stimuli on this trial
    size         = Size_list[curr_target];                                                                                      // Figure out the attributes of the current target
    angle        = Angle_list[curr_target];                                                                                     // THESE USER DEFINED GLOBALS ARE ARRAYS SO
    eccentricity = Eccentricity_list[curr_target];                                                                              // THEY CANNOT BE PASSED INTO PROCESSES
    color        = curr_target + 1;                                                                                             // zero is reserved for black.  see SET_DEFAULT_COLORS.pro

    stim_ecc_x = cos(angle) * eccentricity;                                                                                     // find the center of the box in x and y space based on the angle and eccentricity...
    stim_ecc_y = sin(angle) * eccentricity * -1;
    oMove(object_targ, stim_ecc_x * deg2pix_X, stim_ecc_y * deg2pix_Y);                                                         // ...and move the animated graph object there.
    oSetAttribute(object_targ, aSIZE, size * deg2pix_X, size * deg2pix_Y);                                                      // while we are at it, resize fixation object on animated graph
    oSetAttribute(object_fix, aSIZE, 1 * deg2pix_X, 1 * deg2pix_Y);



    //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    // Draw pg 1
    // print("target");
    dsendf("rw %d,%d;\n", target, target);                                                              // draw first pg of video memory
    dsendf("cl:\n");                                                                                    // clear screen
    spawnwait DRW_SQR(size, angle, eccentricity, color, fill, deg2pix_X, deg2pix_Y);                    // draw target


    //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    // Draw pg 0 (last is displayed first)
    // print("blank");
    dsendf("rw %d,%d;\n", blank, blank);                                                            // draw the blank screen last so that it shows up first
    dsendf("cl:\n");                                                                                // clear screen (that's all)
} /* FIX_PGS */