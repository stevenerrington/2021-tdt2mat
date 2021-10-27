//==========================================================================
// FIX_HOLD.PRO
//   Description: Process Hold fixation State
//                Eye has to HOLD fixation for TRL_FIX_HOLD.
//
//                All Global variables and the following state variables are available to monitor state progress
//                1. PROCESS_STATE : Setup state processing, will be done once per call
//                1. CURR_STAT :


//                4. STAT_DLTA_T : Length of time in this state (in ticks/ms)
//                5. STAT_ALLOWED_T : Max time for staying in this state
//                5. STAT_I_DURATION : If saccade occurs, it must complete in this time
//
//   NOTE:
//
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-01-25
//==========================================================================
//  Revision History:

declare PROC_FIX_HOLD();


process PROC_FIX_HOLD()
{
  declare int   adjust = 1;
  declare float tempVRcount;
  //if fix break happens within 10 ms of fix acquire, disregard it,
  //as we (Amir/Chenchal) observed from data that most of this type of fix breaks
  //are as a result of intrinsic noise + eye natural jitter + may be a "slow" sacc?
  declare int allowFixBreakInitialTime = 10;

  // Give enough time for next refresh to occur
  // so that the queued vdosync commnad
  // can execute without wait
  declare int offsetForVdoSync = 8;

  if (PROCESS_STATE)
  {
    // actually TRL_ACQUIRE_FIX_TIME, however the below is practically
    //same and it keeps this state independent of previous state
    PROCESS_STATE = 0;
    STAT_DLTA_T   = 0;
    //STAT_ALLOWED_T = TRL_USE_FIX_HOLD_DURATION* TIME_DILATE_FACTOR;
    // Dynamically adjust TRL_USE_FIX_HOLD_DURATIONsuch that the duration from
    // TRL_FIX_ON_TIME till the end of TRL_USE_FIX_HOLD_DURATIONis a multiple of REFRESH_RATE
    // so that we sync all target presentation to vertical retrace (less offsetForVdoSync)
    // variable time when fix is acquired and the length of fix hold time

    tempVRCount             = (TRL_ACQUIRE_FIX_TIME - TRL_FIX_ON_TIME + TRL_USE_FIX_HOLD_DURATION) * 1.0/REFRESH_RATE;
    TRL_USE_FIX_HOLD_ADJUST = round(round(tempVRCount) * REFRESH_RATE) + TRL_FIX_ON_TIME - TRL_ACQUIRE_FIX_TIME - TRL_USE_FIX_HOLD_DURATION;
    TRL_USE_FIX_HOLD_ADJUST = TRL_USE_FIX_HOLD_ADJUST - offsetForVdoSync;
    if (adjust)
    {
      if (DEBUG_CONSOLE)
      {
        printf("*************tempVRCount [%8.4d], tempFixHoldAjust = [%d]\n", tempVRCount, TRL_USE_FIX_HOLD_ADJUST);
        printf("****STAT_FIX_HOLD[%d]: Adjusting TRL_USE_FIX_HOLD_DURATION[%d] by [%d] ms\n", STAT_FIX_HOLD, TRL_USE_FIX_HOLD_DURATION, TRL_USE_FIX_HOLD_ADJUST);
      }
      TRL_USE_FIX_HOLD_DURATION = TRL_USE_FIX_HOLD_DURATION + TRL_USE_FIX_HOLD_ADJUST;
    }

    STAT_ALLOWED_T = TRL_USE_FIX_HOLD_DURATION * TIME_DILATE_FACTOR;
    // initialize durations
    TRL_FIX_HOLD_DURATION = 0;
  }

  TRL_FIX_HOLD_DURATION = TRL_FIX_HOLD_DURATION + 1;
  //printf("    STAT_DLTA_T [%d], I_FIX [%d], I_FIX_ACQ [%d], xVolt[%10.4d], yVolt[%10.4d], fndLoc[%d], xDeg[%10.5d], yDeg[%10.5d]\n",
  //STAT_DLTA_T,I_FIX,I_FIX_ACQ,EYE_X_VOLTS,EYE_Y_VOLTS,foundLoc,eyeXdeg,eyeYdeg);
  if (STAT_DLTA_T < STAT_ALLOWED_T)
  {
    if (!I_FIX && STAT_DLTA_T > allowFixBreakInitialTime)
    {
      TRL_FIX_BREAK_TIME = time();
      spawn SEND_EVT(EVT_FIX_BREAK_);

      if (DEBUG_CONSOLE)
      {
        printf("****STAT_FIX_HOLD[%d]: ERR sent Event: EVT_FIX_BREAK_[%d]\n", STAT_FIX_HOLD, EVT_FIX_BREAK_);
        printf("****STAT_FIX_HOLD[%d]:ERR (Broke fixation)[%d]/[%d] (TRL_FIX_HOLD)\n", STAT_FIX_HOLD, TRL_FIX_HOLD_DURATION, STAT_ALLOWED_T);
      }
      // Show blank page for about No timeout or any tone
      dsendf("vp %d\n", PG_BLANK);
      spawn GRAF_HIDE_FIX_TARG();

      if (DEBUG_CONSOLE)
      {
        printf("****STAT_FIX_HOLD[%d]: Waiting for FIX_NOT_ACQ_WAIT_TIME [%d] before going to STAT_IDLE\n", STAT_FIX_HOLD, FIX_NOT_ACQ_WAIT_TIME);
      }
      wait(FIX_NOT_ACQ_WAIT_TIME);
      PROCESS_STATE  = 1;
      CURR_STAT      = STAT_IDLE;
      TRL_IS_RUNNING = 0;
    }
  }
  else
  {
    if (I_FIX)
    {
      TRL_FIXATE_TIME = time();
      spawn SEND_EVT(EVT_FIXATE_);

      if (DEBUG_CONSOLE)
      {
        printf("****STAT_FIX_HOLD[%d]: OK sent Event: EVT_FIXATE_[%d], Abort_[%d]\n", STAT_FIX_HOLD, EVT_FIXATE_);
      }
      printf("****STAT_FIX_HOLD[%d]: OK (Fixated)[%d]/[%d] (TRL_FIX_HOLD)\n", STAT_FIX_HOLD, TRL_FIX_HOLD_DURATION, STAT_ALLOWED_T);
      PROCESS_STATE = 1;
      CURR_STAT     = STAT_TARG_ON;
    }
  }
} /* PROC_FIX_HOLD */
