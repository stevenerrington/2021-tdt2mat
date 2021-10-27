//==========================================================================
// CMD_STAT.PRO
//   Description: Task states for Countermanding. All states are based
//                on EYE POSITION and current TASK PHASE (avoiding saying STATE here)
//                A STATE should ideally know about
//                1. CURR_STAT : State in currently
//                2. STAT_DLTA_T : Length of time in this state (in ticks/ms)
//                3. STAT_ALLOWED_T : Max time for staying in this state
//                4. STAT_I_DURATION : If saccade occurs, it must complete in this time
//
//   NOTE:
//
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-01-25
//==========================================================================
//  Revision History:
//  001: 2019/01/31 chenchal subraveti
//       Have to redifine the outcomes descriptions
//       Added STAT_TEST, STAT_TARG_ON, STAT_TARG_ACQ
//       Updated STAT vars for processing saccade


//Current State variables in the absence of structs
declare int CURR_STAT;
declare int STAT_STRT_T;
declare int STAT_DLTA_T;
declare int STAT_ALLOWED_T;
// for gating the eye pos by time
declare int STAT_I_DURATION;
declare int STAT_I_DURATION2;

//
declare constant int STAT_TEST = 99;
// Eyes are anywhere on the screen
declare constant int STAT_IDLE = 0;

// Fixspot is NOT ON: Waiting for subj to be ready
// Check: Gaze hanging around the FIX_WIN_LARGE.
//        Gaze has not *crossed* FIX_WIN_LARGE within REDY_T
declare constant int STAT_GET_READY = 1;

// Fixspot is ON: Waiting for subject to reach the fix window and Fixate
// Check: Gaze within FIX_WIN, before ALLOWED_FIX_TIME
declare constant int STAT_FIX_ON = 2;

// Fixspot is ON: Waiting for subject to stay on fixspot
// Check: Gaze within FIX_WIN until TRL_USE_FIX_HOLD_DURATIONexpires
declare constant int STAT_FIX_HOLD = 3;

// Fixspot is OFF Target is ON:
// Check: Gaze in FIX window until MIN_SACCADE_TIME expires, else it is early saccade
//        Gaze left FIX_WIN before MAX_SACCADE_TIME, then correct saccade, else no saccade
declare constant int STAT_TARG_ON = 4;

// Fixspot is OFF Target is ON:
// Check: Gaze in TARG_WIN before MAX_SACC_DURATION
declare constant int STAT_TARG_ACQ = 5;

declare constant int STAT_TARG_HOLD = 6;


// Fixspot is OFF Target is ON:
// Check:
//   case 0: TRL_USE_XTRA_HOLD_DURATION <= TONE_DELAY
//         if gaze out of TARG_WIN before TRL_USE_XTRA_HOLD_DURATION expires: compute (ERROR) TONE, compute TIMEOUT_TIME, goto STAT_OUTCOME
//         if gaze in TARG_WIN until TRL_USE_XTRA_HOLD_DURATION expires: Play (SUCCESS) TONE at TONE_DELAY time
//   case 1: TRL_USE_XTRA_HOLD_DURATION <= TONE_DELAY + TONE_DURATION
//         if gaze in TARG_WIN until TONE_DURATION --> (SUCCESS-tone alredey delivered), goto STAT_RWRD_CHK
//         if gaze not in TARG_WIN during TONE_DURATION --> (SUCCESS-tone alredey delivered), compute TIMEOUT_TIME --> goto STAT_OUTCOME
//   case 2: TRL_USE_XTRA_HOLD_DURATION > TONE_DELAY + TONE_DURATION
//         Goto next state (reward already delivered), goto STAT_RWRD_CHK
declare constant int STAT_TONE_CHK = 7;

// Gaze Check:
// Fixspot is OFF Target is ON:
// Check:
//   case 0: TRL_USE_XTRA_HOLD_DURATION <= RWRD_DELAY
//         if gaze out of TARG_WIN before TRL_USE_XTRA_HOLD_DURATION expires: No Reward --> goto STAT_OUTCOME
//         if gaze in TARG_WIN until TRL_USE_XTRA_HOLD_DURATION expires: Deliver reward at RWRD_DELAY time
//   case 1: TRL_USE_XTRA_HOLD_DURATION <= RWRD_DELAY + RWRD_DURATION
//                if gaze in TARG_WIN until RWRD_DURATION --> (reward alredey delivered) --> goto STAT_OUTCOME
//                if gaze not in TARG_WIN during RWRD_DURATION --> (reward already delivered) --> goto STAT_TIM_OUT
//   case 2: TRL_USE_XTRA_HOLD_DURATION > RWRD_DELAY + RWRD_DURATION
//         if gaze in TARG_WIN until TRL_USE_XTRA_HOLD_DURATION expires: (reward already delivered) --> goto STAT_OUTCOME
//         if gaze out of TARG_WIN before TRL_USE_XTRA_HOLD_DURATION expires: (reward already delivered) --> goto STAT_TIM_OUT
declare constant int STAT_RWRD_CHK = 8;

// See CmdOutcomes.xls file in DOC folder - not Updated
declare constant int STAT_OUTCOME = 9;

//
declare constant int STAT_ITI_CHK = 10;

//
declare constant int STAT_TIM_OUT = 11;

//
declare constant int STAT_REFIX_CHK = 12;

/// Gaze Check:
// Fixspot is OFF Target is ON:
// Check: Gaze in FIX window until MIN_SACCADE_TIME expires, else it is early saccade
//        Gaze left FIX_WIN before MAX_SACCADE_TIME, then correct saccade, else no saccade
// Check:
//   case 0: TRL_USE_SSD_VR_COUNT has not expired
//                   if gaze out of FIX-WIN before MIN_SACC_TIME --> EVT_NOGO_EARLY_SACCADE_, goto STAT_OUTCOME
//                   if gaze out of FIX-WIN after MIN_SACC_TIME and before MAX_SACC_TIME --> NoGoEVT_SACCADE_, goto STAT_TARG_ACQ
//                   if gaze out of FIX-WIN after MAX_SACC_TIME --> EVT_NOGO_LATE_SACCADE_, goto STAT_OUTCOME
//   case 1: TRL_USE_SSD_VR_COUNT has expired and TRL_USE_SSD_CANCEL_DURATION has not expired
//   [Stop Signal ON] show PG_SIGNAL_PD (PD on RIGHT) for 1 screen refresh and switch to PG_SIGNAL(PD on LEFT)
//                   if gaze out of FIX-WIN before MIN_SACC_TIME --> EVT_NOGO_EARLY_SACCADE_, goto STAT_OUTCOME
//                   if gaze out of FIX-WIN after MIN_SACC_TIME and before MAX_SACC_TIME --> NoGoEVT_SACCADE_, goto STAT_TARG_ACQ
//   [Stop Signal OFF] switch page from PG_SIGNAL to PG_TARGET_PD (do nto show stop signal)
//                   if gaze out of FIX-WIN after MAX_SACC_TIME --> EVT_NOGO_LATE_SACCADE_, goto STAT_OUTCOME
declare constant int STAT_TARG_SSD = 40;

// Signal is ON Target is ON:
// Check:
//   case 0: TRL_USE_XTRA_HOLD_DURATION <= TONE_DELAY
//         if gaze out of FIX_WIN before TRL_USE_XTRA_HOLD_DURATION expires: compute (ERROR) TONE, compute TIMEOUT_TIME, goto STAT_OUTCOME
//         if gaze in FIX_WIN until TRL_USE_XTRA_HOLD_DURATION expires: Play (SUCCESS) TONE at TONE_DELAY time
//   case 1: TRL_USE_XTRA_HOLD_DURATION <= TONE_DELAY + TONE_DURATION
//         if gaze in FIX_WIN until TONE_DURATION --> (SUCCESS-tone alredey delivered), goto STAT_RWRD_SSD
//         if gaze not in FIX_WIN during TONE_DURATION --> (SUCCESS-tone alredey delivered), compute TIMEOUT_TIME --> goto STAT_OUTCOME
//   case 2: TRL_USE_XTRA_HOLD_DURATION > TONE_DELAY + TONE_DURATION
//         Goto next state (reward already delivered), goto STAT_RWRD_SSD
declare constant int STAT_TONE_SSD = 41;

// Gaze Check:
// Signal is ON Target is ON:
// Check:
//   case 0: TRL_USE_XTRA_HOLD_DURATION <= RWRD_DELAY
//         if gaze out of FIX_WIN before TRL_USE_XTRA_HOLD_DURATION expires: No Reward --> goto STAT_OUTCOME
//         if gaze in FIX_WIN until TRL_USE_XTRA_HOLD_DURATION expires: Deliver reward at RWRD_DELAY time
//   case 1: TRL_USE_XTRA_HOLD_DURATION <= RWRD_DELAY + RWRD_DURATION
//                if gaze in FIX_WIN until RWRD_DURATION --> (reward alredey delivered)--> goto STAT_OUTCOME
//                if gaze not in FIX_WIN during RWRD_DURATION --> (reward already delivered) --> goto STAT_TIM_OUT
//   case 2: TRL_USE_XTRA_HOLD_DURATION > RWRD_DELAY + RWRD_DURATION
//         if gaze in FIX_WIN until TRL_USE_XTRA_HOLD_DURATION expires: (reward already delivered) --> goto STAT_OUTCOME
//         if gaze out of FIX_WIN before TRL_USE_XTRA_HOLD_DURATION expires: (reward already delivered) --> goto STAT_TIM_OUT
declare constant int STAT_RWRD_SSD = 42;
