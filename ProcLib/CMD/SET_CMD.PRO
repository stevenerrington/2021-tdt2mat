//==========================================================================
// SET_CMD.PRO
//   Description: Setup All variables, procs for Countermanding task.
//
//   NOTE:
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-01-24
//==========================================================================
//  Revision History:
//  002: 2019-03-15 chenchal subraveti
//       Changed variable names ot be more consistient between *_TIME, *_DURATION, *IS_*
//       Using TRL_USE_* prefix for user set/system scomputed variables for every trial
//       Using jitter(Mean, spread,jitterType) for all durations with upper and lower bounds:
//       FIX_HOLD, TARG_HOLD, TONE_DELY, RWRD_DELY, HI and LO RWRD_DURATION
//

// Load all constants and related gobal vars
#include C:/TEMPO/ProcLib/CONSTNTS.PRO
// Jitter utils
#include C:/TEMPO/ProcLib/UTIL/JITTER.PRO
// CMD Vars only...?
#include C:/TEMPO/ProcLib/CMD/VAR_CMD.PRO
// State defs
#include C:/TEMPO/ProcLib/CMD/STATES/CMD_STAT.PRO
// Rig specific vars for colors, mainly
#include C:/TEMPO/ProcLib/RIG/VAR_RIG.PRO
// Stimulus Variables: fixation, target, photodiode
#include C:/TEMPO/ProcLib/CMD/VAR_STIM.PRO
// Set palatte colors and color indices
#include C:/TEMPO/ProcLib/CMD/SET_CLRS.PRO
// Setup GRAPHS - referenced by _PGS
#include C:/TEMPO/ProcLib/GRAFS/GRAPHS.PRO
// set pages to load CMD_PGS.PRO?
#include C:/TEMPO/ProcLib/CMD/CMD_PGS.PRO
// Setup event defs so events can be sent
#include C:/TEMPO/ProcLib/CMD/EVENTDEF.PRO
// for using staircase method for SSD
#include C:/TEMPO/ProcLib/CMD/STAIR.PRO
//=====Now do monk specific========
// Load all constants and related gobal vars
#include C:/TEMPO/ProcLib/RIG/SET_RIG.PRO
// Set monk
#include C:/TEMPO/ProcLib/MONK/SET_MONK.PRO

//========other utils=============
// Send event processes
#include C:/TEMPO/ProcLib/UTIL/SEND_EVT.PRO
// Set up watches
#include C:/TEMPO/ProcLib/WATCH/WTCH_EYE.PRO
// Set up watches
#include C:/TEMPO/ProcLib/WATCH/WTCH_PD.PRO

declare SET_CMD_TRL();
declare INIT_TRL_VARS();
declare INIT_VARS_REPEAT_TRL();
declare SET_BLOCK_NUM();
declare PICK_TRIAL_TYPE();
declare COMPUTE_FIX_HOLD();
declare SET_TARGET();
declare SET_WINS();
declare PICK_TRL_SSD();
declare SET_TONE();
declare SET_RWRD_FOR_TRIAL();
declare SET_RWRD_RATIOS_FOR_BLOCK();
declare SET_RWRD();

// min stop signal hold time
declare COMPUTE_XTRA_HOLD_TIME();

// set TRL_USE_SSD_CANCEL_DURATION from SSD_CANCEL_DURATION
declare SET_MIN_MAX_SSD();
declare SET_CANCEL_TIME();

// min target hold time
declare COMPUTE_MIN_THT();

// Compute the max. trial duration
declare COMPUTE_TRIAL_DURATION();

// Compute TRL_USE_CORRECT_TRIALS_PER_BLOCK
declare SET_CORRECT_TRLS_PER_BLOCK();

// process new state
declare int PROCESS_STATE;
// current trial number
declare int TRL_TRIAL_NUMBER;
// current block number
declare int TRL_BLOCK_NUM;
// current trial type (GO or STOP)
declare int TRL_TRIAL_TYPE;

//====== TRIAL FLAGS ======================================
// is trial currently running
declare int TRL_IS_RUNNING;
// did eye leave the *fixation* window
declare int TRL_IS_I_IN_FLIGHT;
// if the fixspot on
declare int TRL_IS_FIX_ON;
// did eye *just-land* in fixation window
declare int TRL_IS_FIX_ACQUIRED;
// was the target shown in the screen (detected by PD signal)
declare int TRL_IS_TARGET_ON;
// did eye *just-land* in target window
declare int TRL_IS_TARG_ACQUIRED;
// was the stop-signal page shown (detected by PD signal)
declare int TRL_IS_STOP_SIGNAL_ON;
// did gaze fulfill extra hold-time (GO trial/STOP trial - time from when tone-delay starts)
declare int TRL_IS_XTRA_HOLD_DONE;
// did gaze fulfill min-target-hold-time duration (GO trial)
declare int TRL_IS_MIN_THT;
// did gaze fulfill cancel duration (STOP trial)
declare int TRL_IS_CANCEL;
// did current trial lead to a timeout situation
declare int TRL_IS_TIMEOUT;
// is correct GO trial
declare int TRL_IS_GO_CORRECT;
// is error GO trial
declare int TRL_IS_GO_ERR;
// is the current STOP trail cancelled (GO trial value = -1)
declare int TRL_IS_CANCELLED_NO_BRK;
// is the current STOP trail broke gaze after cancel and xtra-hold-time (GO trial value = -1)
declare int TRL_IS_CANCELLED_BRK;
// is the current STOP trail non-cancelled, maintainf target gaze till reward/xtra-hold-time (GO trial value = -1)
declare int TRL_IS_NON_CANCELLED_NO_BRK;
// is the current STOP trail non-cancelled target min-tht, then broke target(GO trial value = -1)
declare int TRL_IS_NON_CANCELLED_BRK;
// is the current STOP trail is an error - gaze out fo fix, but not on target or bad saccade (GO trial value = -1)
declare int TRL_IS_NOGO_ERR;
// is the trial a LO reward trial (for the current block)
declare int TRL_IS_LO_RWRD;
// is the trial a HI reward trial (for the current block)
declare int TRL_IS_HI_RWRD;
// is the trial a med reward trial (for the current block)
declare int TRL_IS_MED_RWRD;
// should the fix spot turn on for STOP trial as saccade occured within specified limits
declare int TRL_IS_FIX_REIGNITE;
// use to compute next STOP trial SSD (Cancel or non-cancelled and good saccade landed on target)
declare int TRL_IS_STAIRCASE_SSD;
// is the fix spot re-acquied in a second saccde for a Stop trial
declare int TRL_IS_REFIX;

//======= TRIAL TIMES = time when event occurred ========
// when did task start - first code followed by task-header for every trial
declare int TRL_TASK_START_TIME;
// when trial started - starts from fixation acquired
declare int TRL_TRIAL_START_TIME;
// when did trial end - After ITI (good trials) period or start of TIMEOUT (error trials) period
declare int TRL_EOT_TIME;
// when was gaze monitoring outside Fix window started
declare int TRL_GET_READY_TIME;
// when was gaze outside Fix window wide acheved - time to show fixspot
declare int TRL_READY_TIME;
// when was trail aborted (did not acquire fixation)
declare int TRL_ABORT_TIME;
// when did fixspot come on detected by PD signal
declare int TRL_FIX_ON_TIME;
// when was gaze on fixspot or in fix window
declare int TRL_ACQUIRE_FIX_TIME;
// when was it decied that gaze on fixspot not achieved
declare int TRL_ACQUIRE_FIX_ERROR_TIME;
// when was gaze held on fixspot for fix hold duration achieved
declare int TRL_FIXATE_TIME;
// when was gaze broken during fixation but before target was on
declare int TRL_FIX_BREAK_TIME;
// when show target page command sent to vdosync
declare int TRL_TARGET_PRE_TIME;
// when was target shown as detected by PD signal
declare int TRL_TARGET_TIME;
// when did min target hold time start
declare int TRL_TARGET_HOLD_TIME;
// when did min target hold time break gaze
declare int TRL_TARGET_BREAK_TIME;
// when was fix-spot turned off (as soon as target was on - by default)
declare int TRL_FIX_SPOT_OFF_TIME;
// when was gaze on target or in target window
declare int TRL_TARGET_ACQUIRED_TIME;
// when did saccade enter target window (same as target acquied time)
declare int TRL_DECIDE_TIME;
// when did second saccade enter fix window (for refix)
declare int TRL_DECIDE_SEC_TIME;
// when did saccade enter fix window (after target was acquired)
declare int TRL_REFIX_TIME;
// when did gaze leave Fix window between min and max saccade time
declare int TRL_SACCADE_TIME;
// when did gaze leave Fix window *before* min saccade time
declare int TRL_ERLY_SACCADE_TIME;
// when did gaze leave Fix window *after* max saccade time
declare int TRL_LATE_SACC_TIME;
// when was it decided that gaze did not leave the fix window (Go trials)
declare int TRL_NO_SACCADE_TIME;
// when was it decided that gaze was elsewhere and did not land in target window
declare int TRL_ACQUIRE_TARGET_ERROR_TIME;
// when did min target-hold-time start
declare int TRL_MIN_THT_START_TIME;
// when did min target-hold-time end
declare int TRL_MIN_THT_END_TIME;
// when did min stop-signal-hold-time start (Cancel time start)
declare int TRL_CANCEL_START_TIME;
// when did min stop-signal-hold-time end (Cancel time start)
declare int TRL_CANCEL_END_TIME;
// when did gaze hold on target start after min target hold time/duration achieved
declare int TRL_XTRA_HOLD_START_TIME;
// when did gaze hold on target end after min target hold time/duration achieved
declare int TRL_XTRA_HOLD_END_TIME;
// when was gaze broken during xtra hold time (tone-reward period))
declare int TRL_BRK_XTRA_HOLD_TIME;
// when did gaze break during tone delay (after xtra-hold-eye-ms if any)
declare int TRL_BRK_PRE_TONE_TIME;
// when did gaze break during tone duration (after xtra-hold-eye-ms if any)
declare int TRL_BRK_TONE_TIME;
// when did gaze break during reward delay (after xtra-hold-eye-ms if any)
declare int TRL_BRK_PRE_RWRD_TIME;
// when did gaze break during reward duration (after xtra-hold-eye-ms if any)
declare int TRL_BRK_RWRD_TIME;
// when did tone duration start
declare int TRL_TONE_DELAY_START_TIME;
// when did tone duration end
declare int TRL_TONE_DELAY_END_TIME;
// when did juice solenoid open
declare int TRL_REWARD_DELAY_START_TIME;
// when did juice solenoid close
declare int TRL_REWARD_DELAY_END_TIME;
// when did inter-trial-interval start
declare int TRL_ITI_START_TIME;
// when did inter-trial-interval end
declare int TRL_ITI_END_TIME;
// when did infos sending start
declare int TRL_START_INFOS_TIME;
// when did infos sending start
declare int TRL_END_INFOS_TIME;
// when did timeout period start
declare int TRL_TIMEOUT_START_TIME;
// when did timeout period end
declare int TRL_TIMEOUT_END_TIME;
// when was stop signal page PD signal detected
declare int TRL_STOP_SIGNAL_TIME;
// when was hold fixation till SSD_CANCEL_DURATION achieved (STOP trial)
declare int TRL_CANCEL_TIME;
// when did fixation break during SSD_CANCEL_DURATION (STOP trial)
declare int TRL_BRK_CANCEL_TIME;
// when did gaze leave Fix window between min, max saccade time pre-ssd (STOP trial)
declare int TRL_NOGO_SACCADE_PRE_SSD_TIME;
// when did gaze leave Fix window between min, max saccade time post-ssd (STOP trial)
declare int TRL_NOGO_SACCADE_POST_SSD_TIME;
// when did gaze leave Fix window before min saccade time (STOP trial)
declare int TRL_NOGO_EARLY_SACCADE_TIME;
// when did gaze leave Fix window after max saccade time (STOP trial)
declare int TRL_NOGO_LATE_SACCADE_TIME;
// when did solenoid open for extra reward (or manual reward)
declare int TRL_XTRA_RWRD_ON_TIME;
// when did solenoid close for extra reward (or manual reward)
declare int TRL_XTRA_RWRD_OFF_TIME;
// when did task end - last code for every trial,followed by task-start for next trial, unless manual juice
declare int TRL_TASK_END_TIME;

//========== TRIAL DURATION - Observed through counting nextticks===========
// how long *from* trial-start-time, used to compute ITI if trial length is fixed
declare int TRL_CUM_DURATION;
// how long to get ready (how long gaze was outside FIX_WIN_LARGE)
declare int TRL_GET_READY_DURATION;
// how long gaze was in fix window
declare int TRL_FIX_HOLD_DURATION;
// how long gaze was in fix window when REFIX was achieved
declare int TRL_REFIX_HOLD_DURATION;
// how long was gaze in fix window *after* stop-signal was on (STOP trial = SSD Cancel duration)
declare int TRL_CANCEL_DURATION;
// how long was gaze in target window *after* target was acquired
declare int TRL_MIN_THT_DURATION;
// how long target was on
declare int TRL_TARG_ON_DURATION;
// how long more was gaze held (GO: on target or STOP: on Fix/signal) during the reinforcement time
declare int TRL_XTRA_HOLD_DURATION;
// how long did it take for saccade from start to finish
declare int TRL_SACC_DURATION;
// how long eye was on target (GO trial : till outcome is correct, STOP trial: for non-cancelled)
declare int TRL_TARG_HOLD_DURATION;
// how long did it take from PD detected first for target-page till PD deceted for stop-signal-page
declare int TRL_STOP_SIGNAL_DURATION;
// how long was ITI duration
declare int TRL_ITI_DURATION;
// how long was timeout duration
declare int TRL_TIMEOUT_DURATION;
//=========== TRIAL COUTNS - counting of PD signal (keep track of screen refreshe)=======
// number of vertical refreshs TARGET with PD was on
declare int TRL_TARG_VR_COUNT;
// number of vertical refreshs TARGET with PD was on *before* stop-signal page was shown
declare int TRL_SSD_VR_COUNT;

//========= TRIAL Variables to Use that are set by User or system ================
// user/system set - trial duration for determining iti when trial length is fixed
declare int TRL_USE_TRIAL_DURATION;
// system/staricasing set - index into SSD_ARRY to use for getting value of SSD in vertical refreshe count
declare int TRL_USE_SSD_IDX;
// user/system set - use staircase method to determing next SSD index
declare int TRL_USE_STAIRCASE;
// user/system set - when using staircase method, if increase SSD then: curr-ssd-idx + random(step-up) + 1
declare int TRL_USE_SSD_STEP_UP;
// user/system set - when using staircase method, if decrease SSD then: curr-ssd-idx - (random(step-up) + 1)
declare int TRL_USE_SSD_STEP_DOWN;
// user/system set - should fixed trial length be used to compute inter-trial-interval
declare int TRL_USE_USE_PROVIDED_TRL_LENGTH;
// how many vertical refreshes should the target-page be ON before stop-signal-page will be shown
declare int TRL_USE_SSD_VR_COUNT;
// system set - fix hold time for this trial (computed from min, max fix hold time)
declare int TRL_USE_FIX_HOLD_DURATION;
// system set - fix hold time for this trial *adjusted* so that target-on page can be queued for next refresh
declare int TRL_USE_FIX_HOLD_ADJUST;
// system set - min targ hold time for this trial
declare int TRL_USE_MIN_THT_DURATION;
// system/user set - how long to hold fixation *after* stop signal is shown for trial to be considered Cancel
declare int TRL_USE_SSD_CANCEL_DURATION;
// user/system set - delay *before* SSD for saccade to happen (before MAX_SACC_TIME) to turn FIX Back ON
declare int TRL_USE_PRE_SSD_FIX_ON_DELAY;
// user/system set - delay *after* SSD for saccade to happen (before MAX_SACC_TIME) to turn FIX Back ON
declare int TRL_USE_POST_SSD_FIX_ON_DELAY;
// user/system set - delay *after* target-hold/ssd-cancel for tone to start
declare int TRL_USE_TONE_DELAY;
// user/system set - frequency of tone to be used
declare int TRL_USE_TONE_FREQ;
// user/system set - how long will the tone be ON
declare int TRL_USE_TONE_DURATION;
// user/system set - delay *after* tone for juice solenoid to open
declare int TRL_USE_RWRD_DELAY;
// user/system set - how long will the juice solenoid be in open state
declare int TRL_USE_RWRD_DURATION;
// user/system set - how long is inter-trial-interval for Go-correct/ NoGoCancelled/NoGoNonCancelled
declare int TRL_USE_ITI_DURATION;
// user/system set - how long is timeout for Go-error/NoGoError trials (this includes any ITI)
declare int TRL_USE_TIMEOUT_DURATION;
// user/system set - asymmetric reward - number of trials (Go correct + STOP cancelled) for incrementing block number
declare int TRL_USE_CORRECT_TRIALS_PER_BLOCK;
// user/system set - value to determing if low rewarded error trial must be repeated
declare int TRL_USE_REPEAT_LO_RWRD_ERROR_TRL;
// user/system set - determins how many times to prepeat a previous error trial
declare int TRL_USE_REPEAT_MAX;
// user/system set - Extra hold time (GO - on target, STOP - on fixspot) from tone start, in order to get reward
declare int TRL_USE_XTRA_HOLD_DURATION;
// user/system set - flag =1, then hold eye (GO - on target, STOP - on fixspot) till reward is given
declare int TRL_USE_XTRA_HOLD_TONE_RWRD_FLAG;

//========= TRIAL Current trial target attributes ================
// index into TARG_* array for current trial: 0 based
declare int   TRL_CURR_TARG_IDX;
// current trial target size in degrees
declare float TRL_CURR_TARG_SIZE;
// current trial target angle in degrees
declare float TRL_CURR_TARG_ANGLE;
// current trial target eccentricity in degrees
declare float TRL_CURR_TARG_ECCENTRICITY;
// current target color index: *1* based - 0 is black
declare int   TRL_CURR_TARG_COLOR_IDX;

//========= TRIAL Asymmetric reward variables =====================
// current trial reward - asymmetic reward - low reward target index
declare int TRL_LO_RWRD_TARG_IDX;
// repeat count for lo-reward trials that resulted in GO error or STOP error
declare int TRL_REPEAT_COUNT;
// number of GO correct and STOP cancelled trial in current block
declare int TRL_BLOCK_N_CORRECT_TRLS;
// reward-ratio-index (for target location) to use for current block
declare int BLOCK_RWRD_BY_TARG_IDX[2];
declare int BLOCK_NEXT_RWRD_RATIO_IDXS[2];
// temporary variable for toggling target index for low reward for next block
declare int TOGGLE_RWRD_ASSOCIATION;
// Other variables for trial to use for staircasing in next session
declare int TRL_LAST_STOP_OUTCOME_EVNTCODE;
declare int TRL_LAST_GO_OUTCOME_EVNTCODE;
declare int TRL_LAST_SSD_IDX;

declare int INCEMENT_TARG_DURATION_FLAG;
//========= Operational variables not externalalized ===============
// number of GO trials in session - cumulative count
declare int SESS_N_GO_TRLS;
// number of GO correct trials in session - cumulative count
declare int SESS_N_GO_CORRECT_TRLS;
// number of GO error trials in session - cumulative count
declare int SESS_N_GO_ERROR_TRLS;
// number of STOP trials in session - cumulative count
declare int SESS_N_STOP_TRLS;
// number of STOP cancelled trials in session - cumulative count
declare int SESS_N_CANCEL_NO_BRK_TRLS;
// number of STOP gaze broke fix after cancel + xtra-hold-time - cumulative count
declare int SESS_N_CANCEL_BRK_TRLS;
// number of STOP non-cancelled trials in session - cumulative count
declare int SESS_N_NON_CANCEL_NO_BRK_TRLS;
// number of STOP non-cancelled trials, target fixated min-tht in session - cumulative count
declare int SESS_N_NON_CANCEL_BRK_TRLS;
// number of STOP error trials in session - cumulative count
declare int SESS_N_NOGO_ERROR_TRLS;


process SET_CMD_TRL()
{
    declare int tempCount;

    //============================================================================
    // values set by user for session - trasnsfer variable values
    TRL_USE_REPEAT_LO_RWRD_ERROR_TRL = REPEAT_LO_RWRD_ERROR_TRL;
    TRL_USE_REPEAT_MAX               = REPEAT_MAX;
    TRL_USE_STAIRCASE                = STAIRCASE_SSD;
    TRL_USE_SSD_STEP_UP              = SSD_STEP_UP;
    TRL_USE_SSD_STEP_DOWN            = SSD_STEP_DOWN;
    TRL_USE_USE_PROVIDED_TRL_LENGTH  = USE_PROVIDED_TRL_LENGTH;
    TRL_USE_XTRA_HOLD_TONE_RWRD_FLAG = XTRA_HOLD_TONE_RWRD_FLAG;
    //============================================================================
    if (DEBUG_CONSOLE)
    {
        printf("****SET_CMD/SET_CMD_TRL: Setting Trial/Task Variables for trial****\n");
    }

    if (  TRL_USE_REPEAT_LO_RWRD_ERROR_TRL && TRL_IS_TIMEOUT > 0 && TRL_IS_LO_RWRD > 0
       && (TRL_USE_REPEAT_MAX == -1 || (TRL_REPEAT_COUNT < TRL_USE_REPEAT_MAX && TRL_USE_REPEAT_MAX > 0)))
    {
        printf("****************REPEAT LOW-REWARD ERROR TRIAL***********************\n");
        // Repeat the complete trial. Do not initialize *all* variables, but only those needed for Repeat
        spawnwait INIT_VARS_REPEAT_TRL();

        TRL_USE_TONE_DURATION = TONE_DURATION;
    }
    else
    {
        // Initialize all trial variables
        spawnwait INIT_TRL_VARS();
        spawnwait PICK_TRIAL_TYPE();
        spawnwait SET_BLOCK_NUM();
        spawnwait COMPUTE_FIX_HOLD();
        spawnwait SET_TARGET();
        spawnwait SET_TONE();
        spawnwait SET_RWRD();
        spawnwait COMPUTE_XTRA_HOLD_TIME();

        if (TRL_TRIAL_TYPE == TRIAL_TYPE_STOP)
        {
            SESS_N_STOP_TRLS = SESS_N_STOP_TRLS + 1;
            spawnwait SET_CANCEL_TIME();
            spawnwait PICK_TRL_SSD();
        }
        else
        {
            SESS_N_GO_TRLS       = SESS_N_GO_TRLS + 1;
            TRL_USE_SSD_VR_COUNT = -1;
        }
        // Compute this for both STOP and GO trials
        spawnwait COMPUTE_MIN_THT();

        // Setup CMD PAGES
        if (DEBUG_CONSOLE)
        {
            printf("****SET_CMD/SET_CMD_TRL: Setting CMD_PGS****\n");
        }
        spawnwait CMD_PGS(TRL_CURR_TARG_SIZE, TRL_CURR_TARG_ANGLE, TRL_CURR_TARG_ECCENTRICITY, TRL_CURR_TARG_COLOR_IDX);

        // compute trial duration (mainly for fixed trial length)
        spawnwait COMPUTE_TRIAL_DURATION();
    } // if previous trial is not an error

    // Update graph object for Target
    // Show the windows - without the fixspot or target to cue user
    spawnwait GRAF_UPD8_FIX();
    spawnwait GRAF_UPD8_TARG(TRL_CURR_TARG_SIZE, TRL_CURR_TARG_ANGLE, TRL_CURR_TARG_ECCENTRICITY);

    // increment trial number
    TRL_TRIAL_NUMBER = TRL_TRIAL_NUMBER + 1;

    printf("Block [%d], Trl [%d], targIdx [%d], rewardDuration [%d]\n",
           TRL_BLOCK_NUM, TRL_TRIAL_NUMBER, TRL_CURR_TARG_IDX, TRL_USE_RWRD_DURATION);
} /* SET_CMD_TRL */


process COMPUTE_TRIAL_DURATION()
{
    declare int maxTrialDuration;
    declare int tempCancelTime;

    declare int tonePlusReward;

    tonePlusReward = TONE_DELAY_MEAN + TONE_DELAY_SPREAD + TONE_DURATION;
    tonePlusReward = tonePlusReward + RWRD_DELAY_MEAN + RWRD_DELAY_SPREAD + HI_RWRD_DUR;

    if (DEBUG_CONSOLE)
    {
        printf("****SET_CMD/COMPUTE_TRIAL_DURATION: Computing MAX TRL_USE_TRIAL_DURATION and Checking user setting for FIXED TRL LENGTH\n");
    }
    // Add max ssd delay as this will be the longest TRL duration
    spawnwait SET_MIN_MAX_SSD();

    // Add Cancel duration,
    if (TRL_USE_SSD_CANCEL_DURATION <= 0)
    {
        spawnwait SET_CANCEL_TIME();

        tempCancelTime = TRL_USE_SSD_CANCEL_DURATION;
        //reset since the trial may be a GO trial
        TRL_USE_SSD_CANCEL_DURATION = -1;
    }

    // maxTrialDuration is computed *after* Fixation is acquired, using all max times
    // same for GO/STOP
    maxTrialDuration = FIX_HOLD_MEAN + FIX_HOLD_SPREAD + BASE_ITI_FOR_AUTO_TRL_DURATION;
    // Since TRL_USE_SSD_CANCEL_DURATION must be => MAX_SACC_TIME + MAXS_SACC_DURATION
    maxTrialDuration = maxTrialDuration + tempCancelTime;
    // add max SSD time
    maxTrialDuration = maxTrialDuration + ceil(MAX_SSD * REFRESH_RATE);
    // add min-target hold time
    maxTrialDuration = maxTrialDuration + TARG_HOLD_MEAN + TARG_HOLD_SPREAD;
    // check for extra hold time based on user set flag
    if (TRL_USE_XTRA_HOLD_TONE_RWRD_FLAG == 1)
    {
        maxTrialDuration = maxTrialDuration + tonePlusReward;
    }
    else
    {
        maxTrialDuration = maxTrialDuration + TRL_USE_XTRA_HOLD_DURATION;
    }
    // maxTrialDuration to the nearest higher 100ms
    maxTrialDuration = ceil(maxTrialDuration/100.0) * 100;

    // now check for the longest time of the following
    if (USE_PROVIDED_TRL_LENGTH && maxTrialDuration > PROVIDED_TRL_LENGTH)
    {
        TRL_USE_TRIAL_DURATION = maxTrialDuration;
        // error alert user that for fixed trial length duration,
        // the computed trial duration > than user specified PROVIDED_TRL_LENGTH
        // and adjust the trial duration to computed trial duration
        if (DEBUG_CONSOLE)
        {
            printf("**********PROVIDED_TRL_LENGTH CHANGE ALERT********************\n");
            printf("****SET_CMD/COMPUTE_TRIAL_DURATION: USE_PROVIDED_TRL_LENGTH [%d]****\n", USE_PROVIDED_TRL_LENGTH);
            printf("****SET_CMD/COMPUTE_TRIAL_DURATION: Computed trial length time[%d] exceeds PROVIDED_TRL_LENGTH [%d]****\n", TRL_USE_TRIAL_DURATION, PROVIDED_TRL_LENGTH);
            printf("****SET_CMD/COMPUTE_TRIAL_DURATION: Using TRL_USE_TRIAL_DURATION of [%d] ms (as USE_PROVIDED_TRL_LENGTH = [%d], and maxTrialDuration [%d] > PROVIDED_TRL_LENGTH [%d])\n",
                   TRL_USE_TRIAL_DURATION, USE_PROVIDED_TRL_LENGTH, maxTrialDuration, PROVIDED_TRL_LENGTH);
        }
    }
    else if (USE_PROVIDED_TRL_LENGTH && maxTrialDuration <= PROVIDED_TRL_LENGTH)
    {
        TRL_USE_TRIAL_DURATION = PROVIDED_TRL_LENGTH;
        if (DEBUG_CONSOLE)
        {
            printf("****SET_CMD/COMPUTE_TRIAL_DURATION: Using TRL_USE_TRIAL_DURATION of [%d] ms (as USE_PROVIDED_TRL_LENGTH = [%d], and maxTrialDuration [%d] <= PROVIDED_TRL_LENGTH [%d])****\n",
                   TRL_USE_TRIAL_DURATION, USE_PROVIDED_TRL_LENGTH, maxTrialDuration, PROVIDED_TRL_LENGTH);
        }
    }
    else // USE_PROVIDED_TRL_LENGTH = 0
    {
        TRL_USE_TRIAL_DURATION = maxTrialDuration;
        if (DEBUG_CONSOLE)
        {
            printf("****SET_CMD/COMPUTE_TRIAL_DURATION: Using TRL_USE_TRIAL_DURATION of [%d] ms (as USE_PROVIDED_TRL_LENGTH = [%d] and maxTrialDuration [%d])****\n",
                   TRL_USE_TRIAL_DURATION, USE_PROVIDED_TRL_LENGTH, maxTrialDuration);
        }
    }
} /* COMPUTE_TRIAL_DURATION */


process SET_CANCEL_TIME()
{
    declare int tempVar;

    if (DEBUG_CONSOLE)
    {
        printf("****SET_CMD/SET_CANCEL_TIME: Compute CANCEL_TIME\n");
    }
    spawnwait SET_MIN_MAX_SSD();

    // short SSD cancel time relative to Target on
    // must be greater than MAX_SACC_TIME
    if (DEBUG_CONSOLE)
    {
        printf("****SET_CMD/SET_CANCEL_TIME: Checking min CANCEL time > MAX_SACC_TIME****\n");
        printf("****SET_CMD/SET_CANCEL_TIME: min CANCEL time = ceil(MIN_SSD * REFRESH_RATE) + SSD_CANCEL_DURATION****\n");
    }
    tempVar = ceil(MIN_SSD * REFRESH_RATE) + SSD_CANCEL_DURATION;
    if (tempVar < MAX_SACC_TIME + MAX_SACC_DURATION)
    {
        TRL_USE_SSD_CANCEL_DURATION = (MAX_SACC_TIME + MAX_SACC_DURATION) - ceil(MIN_SSD * REFRESH_RATE);
        if (DEBUG_CONSOLE)
        {
            printf("**********CANCEL_TIME CHANGE ALERT********************\n");
            printf("****SET_CMD/SET_CANCEL_TIME: min CANCEL time [%d] is less than MAX_SACC_TIME + MAX_SACC_DURATION [%d]****\n", tempVar, MAX_SACC_TIME + MAX_SACC_DURATION);
            printf("****SET_CMD/SET_CANCEL_TIME: Using CANCEL time [%d] instead of SSD_CANCEL_DURATION[%d]****\n", TRL_USE_SSD_CANCEL_DURATION, SSD_CANCEL_DURATION);
        }
    }
    else
    {
        TRL_USE_SSD_CANCEL_DURATION = SSD_CANCEL_DURATION;
        if (DEBUG_CONSOLE)
        {
            printf("****SET_CMD/SET_CANCEL_TIME: Using CANCEL time as SSD_CANCEL_DURATION[%d]****\n", SSD_CANCEL_DURATION);
        }
    }
}


// set TRL_USE_SSD_CANCEL_DURATION from SSD_CANCEL_DURATION
process SET_MIN_MAX_SSD()
{
    declare int tempCount;

    tempCount = 0;
    MIN_SSD   = SSD_ARRY[tempCount];
    MAX_SSD   = SSD_ARRY[tempCount];
    tempCount = 1;
    N_SSD     = 1;
    while (tempCount < N_SSD_MAX)
    {
        if (SSD_ARRY[tempCount] > 0)
        {
            N_SSD = N_SSD + 1;
            if (SSD_ARRY[tempCount] > MAX_SSD)
            {
                MAX_SSD = SSD_ARRY[tempCount];
            }
            if (SSD_ARRY[tempCount] < MIN_SSD)
            {
                MIN_SSD = SSD_ARRY[tempCount];
            }
        }
        tempCount = tempCount + 1;
    }
    if (DEBUG_CONSOLE)
    {
        printf("****SET_CMD/SET_MIN_MAX_SSD: MIN_SSD, MAX_SSD[in vert refresh] = [%d, %d]****\n", MIN_SSD, MAX_SSD);
    }
}


process COMPUTE_XTRA_HOLD_TIME()
{
    declare int tonePlusReward;

    // Assume TRL_USE_XTRA_HOLD_TONE_RWRD_FLAG = 1
    TRL_USE_XTRA_HOLD_DURATION = TONE_DELAY_MEAN + TONE_DELAY_SPREAD + TONE_DURATION;
    TRL_USE_XTRA_HOLD_DURATION = TRL_USE_XTRA_HOLD_DURATION + RWRD_DELAY_MEAN + RWRD_DELAY_SPREAD + HI_RWRD_DUR;

    if (TRL_USE_XTRA_HOLD_TONE_RWRD_FLAG == 0)
    {
        spawnwait JITTER(XTRA_HOLD_MEAN, XTRA_HOLD_SPREAD, XTRA_HOLD_JITTER_FLAG);

        // extra hold time cannot be more than tone + reward
        if (JITTER_INT < TRL_USE_XTRA_HOLD_DURATION)
        {
            TRL_USE_XTRA_HOLD_DURATION = JITTER_INT;
        }
    }
    // atleast 1 tick for running the process check
    if (TRL_USE_XTRA_HOLD_DURATION <= 0)
    {
        TRL_USE_XTRA_HOLD_DURATION = 1;
    }

    if (DEBUG_CONSOLE)
    {
        printf("****SET_CMD/COMPUTE_XTRA_HOLD_TIME: TRL_USE_XTRA_HOLD_DURATION = [%d]****\n", TRL_USE_XTRA_HOLD_DURATION);
    }
}/* COMPUTE_XTRA_HOLD_TIME */


process COMPUTE_MIN_THT()
{
    spawnwait JITTER(TARG_HOLD_MEAN, TARG_HOLD_SPREAD, TARG_HOLD_JITTER_FLAG);

    TRL_USE_MIN_THT_DURATION = JITTER_INT;
    if (DEBUG_CONSOLE)
    {
        printf("****SET_CMD/COMPUTE_MIN_THT: TRL_USE_MIN_THT_DURATION = [%d]****\n", TRL_USE_MIN_THT_DURATION);
    }
}/* COMPUTE_MIN_THT */


process SET_TONE()
{
    spawnwait JITTER(TONE_DELAY_MEAN, TONE_DELAY_SPREAD, TONE_JITTER_FLAG);

    TRL_USE_TONE_DELAY    = JITTER_INT;
    TRL_USE_TONE_DURATION = TONE_DURATION;
    if (DEBUG_CONSOLE)
    {
        printf("****SET_CMD/SET_TONE: TONE_DELAY, TONE_DURATION = [%d, %d]****\n", TRL_USE_TONE_DELAY, TRL_USE_TONE_DURATION);
    }
}  /* SET_TONE */


process SET_RWRD()
{
    spawnwait JITTER(RWRD_DELAY_MEAN, RWRD_DELAY_SPREAD, RWRD_JITTER_FLAG);

    TRL_USE_RWRD_DELAY = JITTER_INT;
    //spawnwait SET_ASYMMETRIC_RWRD();
    spawnwait SET_RWRD_FOR_TRIAL();

    if (DEBUG_CONSOLE)
    {
        printf("****SET_CMD/SET_RWRD: RWRD_DELAY, RWRD_DURATION = [%d, %d]****\n", TRL_USE_RWRD_DELAY, TRL_USE_RWRD_DURATION);
    }
}/* SET_RWRD */


process PICK_TRL_SSD()
{
    declare int tempCount;

    tempCount = 0;
    spawnwait SET_MIN_MAX_SSD();

    nexttick;
    // must get from SSD_ARRY; use staircasing....
    TRL_IS_STAIRCASE_SSD = STAIRCASE_SSD;
    spawnwait STAIRCASE_NEXT_SSD(TRL_LAST_STOP_OUTCOME_EVNTCODE, TRL_LAST_SSD_IDX, SSD_STEP_UP, SSD_STEP_DOWN, N_SSD, TRL_IS_STAIRCASE_SSD);

    TRL_USE_SSD_IDX      = STAIRCASE_NEXT_SSD_IDX;
    TRL_USE_SSD_VR_COUNT = SSD_ARRY[TRL_USE_SSD_IDX];
    TRL_LAST_SSD_IDX     = TRL_USE_SSD_IDX;
    if (DEBUG_CONSOLE)
    {
        printf("****SET_CMD/PICK_TRL_SSD: TRL_USE_SSD_VR_COUNT[in vert refresh] = [%d]****\n", TRL_USE_SSD_VR_COUNT);
    }
} /* PICK_TRL_SSD */


process COMPUTE_FIX_HOLD()
{
    // Set up any timing jitters etc
    spawnwait JITTER(FIX_HOLD_MEAN, FIX_HOLD_SPREAD, FIX_HOLD_JITTER_FLAG);

    TRL_USE_FIX_HOLD_DURATION = JITTER_INT;
    if (DEBUG_CONSOLE)
    {
        printf("****SET_CMD/COMPUTE_FIX_HOLD: TRL_USE_FIX_HOLD_DURATION = [%d]****\n", TRL_USE_FIX_HOLD_DURATION);
    }
} /* COMPUTE_FIX_HOLD */

process SET_CORRECT_TRLS_PER_BLOCK()
{
    // set no of correct trials per block to use
    spawnwait JITTER(CORRECT_TRLS_BLK_MEAN, CORRECT_TRLS_BLK_SPREAD, CORRECT_TRLS_BLK_JITTER_FLAG);  
    TRL_USE_CORRECT_TRIALS_PER_BLOCK = JITTER_INT;
// ****REMOVE LINE BELOW AFTER TESTING************//
    printf("****SET_CMD/SET_TRL_CORRECT_TRIALS_PER_BLOCK: TRL_USE_CORRECT_TRIALS_PER_BLOCK = [%d]****\n", TRL_USE_CORRECT_TRIALS_PER_BLOCK);
    if (DEBUG_CONSOLE)
    {
        printf("****SET_CMD/SET_CORRECT_TRIALS_PER_BLOCK: TRL_USE_CORRECT_TRIALS_PER_BLOCK = [%d]****\n", TRL_USE_CORRECT_TRIALS_PER_BLOCK);
    }    
    
}

process SET_WINS()
{
    declare float eccX, eccY;

    if (DEBUG_CONSOLE)
    {
        printf("****SET_CMD/SET_WINS: Setting Window sizes for FIX and TARG****\n");
    }
    // Compute fix win size
    FIX_WIN_ACQ[LEFT]  = -FIX_WIN_ACQ_SIZE/2;
    FIX_WIN_ACQ[RIGHT] = FIX_WIN_ACQ_SIZE/2;
    FIX_WIN_ACQ[UP]    = -FIX_WIN_ACQ_SIZE/2;
    FIX_WIN_ACQ[DOWN]  = FIX_WIN_ACQ_SIZE/2;
    // Fix spot center is at 0,0, so we do not need to compute
    FIX_WIN[LEFT]  = -FIX_WIN_SIZE/2;
    FIX_WIN[RIGHT] = FIX_WIN_SIZE/2;
    FIX_WIN[UP]    = -FIX_WIN_SIZE/2;
    FIX_WIN[DOWN]  = FIX_WIN_SIZE/2;
    // Larger fix win - For inaccurate eye position
    FIX_WIN_LARGE[LEFT]  = -FIX_WIN_SIZE_LARGE/2;
    FIX_WIN_LARGE[RIGHT] = FIX_WIN_SIZE_LARGE/2;
    FIX_WIN_LARGE[UP]    = -FIX_WIN_SIZE_LARGE/2;
    FIX_WIN_LARGE[DOWN]  = FIX_WIN_SIZE_LARGE/2;
    // Compute TARG_WIN and TARG_WIN_LARGE
    eccX            = cos(TARG_ANGLE_ARRY[TRL_CURR_TARG_IDX]) * TARG_ECCENTRICITY_ARRY[TRL_CURR_TARG_IDX];
    eccY            = -sin(TARG_ANGLE_ARRY[TRL_CURR_TARG_IDX]) * TARG_ECCENTRICITY_ARRY[TRL_CURR_TARG_IDX];
    TARG_WIN[LEFT]  = eccX - TARG_WIN_SIZE/2;
    TARG_WIN[RIGHT] = eccX + TARG_WIN_SIZE/2;
    TARG_WIN[UP]    = eccY - TARG_WIN_SIZE/2;
    TARG_WIN[DOWN]  = eccY + TARG_WIN_SIZE/2;
    // Larger target window - For inaccurate eye position
    TARG_WIN_LARGE[LEFT]  = eccX - TARG_WIN_SIZE_LARGE/2;
    TARG_WIN_LARGE[RIGHT] = eccX + TARG_WIN_SIZE_LARGE/2;
    TARG_WIN_LARGE[UP]    = eccY - TARG_WIN_SIZE_LARGE/2;
    TARG_WIN_LARGE[DOWN]  = eccY + TARG_WIN_SIZE_LARGE/2;
    // Compute TARG_WIN_ANTI and TARG_WIN_LARGE_ANTI
    eccX                 = cos(TARG_ANGLE_ARRY[TRL_CURR_TARG_IDX] + 180) * TARG_ECCENTRICITY_ARRY[TRL_CURR_TARG_IDX];
    eccY                 = -sin(TARG_ANGLE_ARRY[TRL_CURR_TARG_IDX] + 180) * TARG_ECCENTRICITY_ARRY[TRL_CURR_TARG_IDX];
    TARG_WIN_ANTI[LEFT]  = eccX - TARG_WIN_SIZE/2;
    TARG_WIN_ANTI[RIGHT] = eccX + TARG_WIN_SIZE/2;
    TARG_WIN_ANTI[UP]    = eccY - TARG_WIN_SIZE/2;
    TARG_WIN_ANTI[DOWN]  = eccY + TARG_WIN_SIZE/2;
    // Larget ANTI target window - For inaccurate Eye position
    TARG_WIN_ANTI_LARGE[LEFT]  = eccX - TARG_WIN_SIZE_LARGE/2;
    TARG_WIN_ANTI_LARGE[RIGHT] = eccX + TARG_WIN_SIZE_LARGE/2;
    TARG_WIN_ANTI_LARGE[UP]    = eccY - TARG_WIN_SIZE_LARGE/2;
    TARG_WIN_ANTI_LARGE[DOWN]  = eccY + TARG_WIN_SIZE_LARGE/2;
} /* SET_WINS */


process SET_RWRD_FOR_TRIAL()
{
    if (DEBUG_CONSOLE)
    {
        printf("****SET_CMD/SET_RWRD_FOR_TRIAL: Setting asymmetric reward****\n");
    }
    TRL_USE_RWRD_DURATION = BLOCK_RWRD_BY_TARG_IDX[TRL_CURR_TARG_IDX];
    if (TRL_USE_RWRD_DURATION == LO_RWRD_DUR)
    {
        TRL_IS_LO_RWRD  = 1;
        TRL_IS_HI_RWRD  = 0;
        TRL_IS_MED_RWRD = 0;
    }
    else if (TRL_USE_RWRD_DURATION == HI_RWRD_DUR)
    {
        TRL_IS_LO_RWRD  = 0;
        TRL_IS_HI_RWRD  = 1;
        TRL_IS_MED_RWRD = 0;
    }
    else if (TRL_USE_RWRD_DURATION == MED_RWRD_DUR)
    {
        TRL_IS_LO_RWRD  = 0;
        TRL_IS_HI_RWRD  = 0;
        TRL_IS_MED_RWRD = 1;
    }
}

process SET_TARGET()
{
    // pick random current target location
    TRL_CURR_TARG_IDX          = random(N_TARG_POS);
    TRL_CURR_TARG_SIZE         = TARG_SIZE_ARRY[TRL_CURR_TARG_IDX];
    TRL_CURR_TARG_ANGLE        = TARG_ANGLE_ARRY[TRL_CURR_TARG_IDX];
    TRL_CURR_TARG_ECCENTRICITY = TARG_ECCENTRICITY_ARRY[TRL_CURR_TARG_IDX];
    // target colors are defined in monk.pro (JOULE.PRO/AUTO.PRO)
    TRL_CURR_TARG_COLOR_IDX = CLR_IDX_TARG_ARRAY[TRL_CURR_TARG_IDX];
    if (DEBUG_CONSOLE)
    {
        printf("****SET_CMD/SET_TARGET: CURR_TARG IDX, SIZE, ANGLE, ECC = [%d, %5.2d, %6.2d, %4.2d]****\n",
               TRL_CURR_TARG_IDX, TRL_CURR_TARG_SIZE, TRL_CURR_TARG_ANGLE, TRL_CURR_TARG_ECCENTRICITY);
    }

    spawnwait SET_WINS();
} /* SET_TARGET */

process PICK_TRIAL_TYPE()
{
    declare float trlType;

    trlType = (1.0 + random(9999))/100.0;
    if (trlType <= GO_WEIGHT)
    {
        TRL_TRIAL_TYPE = TRIAL_TYPE_GO;
    }
    else
    {
        TRL_TRIAL_TYPE = TRIAL_TYPE_STOP;
    }
    if (DEBUG_CONSOLE)
    {
        printf("****SET_CMD/PICK_TRIAL_TYPE: TRIAL_TYPE [%d],****\n", TRL_TRIAL_TYPE);
    }
}/* PICK_TRIAL_TYPE */


process SET_BLOCK_NUM()
{
    if (TRL_BLOCK_NUM == 0)
    {
        TRL_BLOCK_NUM        = 1;
        TRL_BLOCK_N_CORRECT_TRLS = 0;
        spawnwait SET_RWRD_RATIOS_FOR_BLOCK();
        spawnwait SET_CORRECT_TRLS_PER_BLOCK();
    }
    else if (TRL_BLOCK_N_CORRECT_TRLS == TRL_USE_CORRECT_TRIALS_PER_BLOCK)
    {
        TOGGLE_RWRD_ASSOCIATION = 1;
        TRL_BLOCK_NUM           = TRL_BLOCK_NUM + 1;
        TRL_BLOCK_N_CORRECT_TRLS    = 0;
        spawnwait SET_RWRD_RATIOS_FOR_BLOCK();
        spawnwait SET_CORRECT_TRLS_PER_BLOCK();
    }
    if (DEBUG_CONSOLE)
    {
        printf("****SET_CMD/SET_BLOCK_NUM: BLOCK_NUM [%d],****\n", TRL_BLOCK_NUM);
    }
}/* SET_BLOCK_NUM */


process SET_RWRD_RATIOS_FOR_BLOCK()
{
    declare int tempRand, tempCount, idx;

    if (DEBUG_CONSOLE)
    {
        printf("****SET_CMD/SET_RWRD_RATIOS_FOR_BLOCK: Setting asymmetric reward****\n");
    }
    // Pick BLOCK_RWRD_BY_TARG_IDX for block 1 or if TOGGLE_RWRD_ASSOCIATION (change for each block)
    //declare int BLOCK_RWRD_BY_TARG_IDX[2];
    //declare int BLOCK_NEXT_RWRD_RATIO_IDXS[2];
    if (TRL_BLOCK_NUM == 1)
    {
        tempRand = random(NUM_RWRD_RATIOS);
        // setup current bloch reward ratios by target location
        idx = 0;
        while (idx < NUM_RWRD_TARG_LOCS)
        {
            BLOCK_RWRD_BY_TARG_IDX[idx] = RWRD_RATIOS[tempRand, idx];
            idx                         = idx + 1;
        }
    }
    else if (TOGGLE_RWRD_ASSOCIATION == 1)
    {
        TOGGLE_RWRD_ASSOCIATION = 0;
        tempRand                = BLOCK_NEXT_RWRD_RATIO_IDXS[random(NUM_RWRD_RATIOS - 1)];
        // setup current bloch reward ratios by target location
        idx = 0;
        while (idx < NUM_RWRD_TARG_LOCS)
        {
            BLOCK_RWRD_BY_TARG_IDX[idx] = RWRD_RATIOS[tempRand, idx];
            idx                         = idx + 1;
        }
        // setup Reward ratio pair indices for next block
        tempCount = 0;
        idx       = 0;
        while (tempCount < NUM_RWRD_RATIOS)
        {
            if (tempCount != tempRand)
            {
                BLOCK_NEXT_RWRD_RATIO_IDXS[idx] = tempCount;
                idx                             = idx + 1;
            }
            tempCount = tempCount + 1;
        }
    }
}/* SET_RWRD_RATIOS_FOR_BLOCK */


process INIT_VARS_REPEAT_TRL()
{
    PROCESS_STATE                  = 0;
    TRL_IS_RUNNING                 = 0;
    TRL_IS_I_IN_FLIGHT             = -1;
    TRL_IS_FIX_ON                  = -1;
    TRL_IS_FIX_ACQUIRED            = -1;
    TRL_IS_TARGET_ON               = -1;
    TRL_IS_TARG_ACQUIRED           = -1;
    TRL_IS_STOP_SIGNAL_ON          = -1;
    TRL_IS_XTRA_HOLD_DONE          = -1;
    TRL_IS_CANCEL                  = -1;
    TRL_IS_TIMEOUT                 = -1;
    TRL_IS_GO_CORRECT              = -1;
    TRL_IS_GO_ERR                  = -1;
    TRL_IS_CANCELLED_NO_BRK        = -1;
    TRL_IS_CANCELLED_BRK           = -1;
    TRL_IS_NON_CANCELLED_NO_BRK    = -1;
    TRL_IS_NON_CANCELLED_BRK       = -1;
    TRL_IS_NOGO_ERR                = -1;
    TRL_IS_FIX_REIGNITE            = -1;
    TRL_IS_REFIX                   = -1;
    TRL_TASK_START_TIME            = -1;
    TRL_TRIAL_START_TIME           = -1;
    TRL_EOT_TIME                   = -1;
    TRL_GET_READY_TIME             = -1;
    TRL_READY_TIME                 = -1;
    TRL_ABORT_TIME                 = -1;
    TRL_FIX_ON_TIME                = -1;
    TRL_ACQUIRE_FIX_TIME           = -1;
    TRL_ACQUIRE_FIX_ERROR_TIME     = -1;
    TRL_MIN_THT_START_TIME         = -1;
    TRL_MIN_THT_END_TIME           = -1;
    TRL_CANCEL_START_TIME          = -1;
    TRL_CANCEL_END_TIME            = -1;
    TRL_FIXATE_TIME                = -1;
    TRL_FIX_BREAK_TIME             = -1;
    TRL_TARGET_PRE_TIME            = -1;
    TRL_TARGET_TIME                = -1;
    TRL_TARGET_HOLD_TIME           = -1;
    TRL_TARGET_BREAK_TIME          = -1;
    TRL_FIX_SPOT_OFF_TIME          = -1;
    TRL_TARGET_ACQUIRED_TIME       = -1;
    TRL_DECIDE_TIME                = -1;
    TRL_DECIDE_SEC_TIME            = -1;
    TRL_REFIX_TIME                 = -1;
    TRL_SACCADE_TIME               = -1;
    TRL_ERLY_SACCADE_TIME          = -1;
    TRL_LATE_SACC_TIME             = -1;
    TRL_NO_SACCADE_TIME            = -1;
    TRL_ACQUIRE_TARGET_ERROR_TIME  = -1;
    TRL_XTRA_HOLD_START_TIME       = -1;
    TRL_XTRA_HOLD_END_TIME         = -1;
    TRL_BRK_XTRA_HOLD_TIME         = -1;
    TRL_BRK_PRE_TONE_TIME          = -1;
    TRL_BRK_TONE_TIME              = -1;
    TRL_BRK_PRE_RWRD_TIME          = -1;
    TRL_BRK_RWRD_TIME              = -1;
    TRL_TONE_DELAY_START_TIME      = -1;
    TRL_TONE_DELAY_END_TIME        = -1;
    TRL_REWARD_DELAY_START_TIME    = -1;
    TRL_REWARD_DELAY_END_TIME      = -1;
    TRL_ITI_START_TIME             = -1;
    TRL_ITI_END_TIME               = -1;
    TRL_START_INFOS_TIME           = -1;
    TRL_END_INFOS_TIME             = -1;
    TRL_TIMEOUT_START_TIME         = -1;
    TRL_TIMEOUT_END_TIME           = -1;
    TRL_STOP_SIGNAL_TIME           = -1;
    TRL_CANCEL_TIME                = -1;
    TRL_BRK_CANCEL_TIME            = -1;
    TRL_NOGO_SACCADE_PRE_SSD_TIME  = -1;
    TRL_NOGO_SACCADE_POST_SSD_TIME = -1;
    TRL_NOGO_EARLY_SACCADE_TIME    = -1;
    TRL_NOGO_LATE_SACCADE_TIME     = -1;
    TRL_XTRA_RWRD_ON_TIME          = -1;
    TRL_XTRA_RWRD_OFF_TIME         = -1;
    TRL_TASK_END_TIME              = -1;
    TRL_CUM_DURATION               = -1;
    TRL_GET_READY_DURATION         = -1;
    TRL_FIX_HOLD_DURATION          = -1;
    TRL_REFIX_HOLD_DURATION        = -1;
    TRL_CANCEL_DURATION            = -1;
    TRL_MIN_THT_DURATION           = -1;
    TRL_TARG_ON_DURATION           = -1;
    TRL_XTRA_HOLD_DURATION         = -1;
    TRL_SACC_DURATION              = -1;
    TRL_TARG_HOLD_DURATION         = -1;
    TRL_STOP_SIGNAL_DURATION       = -1;
    TRL_ITI_DURATION               = -1;
    TRL_TIMEOUT_DURATION           = -1;
    TRL_TARG_VR_COUNT              = 0;
    TRL_SSD_VR_COUNT               = 0;
    TRL_REPEAT_COUNT               = TRL_REPEAT_COUNT + 1;
    if (DEBUG_CONSOLE)
    {
        printf("****SET_CMD/INIT_VARS_REPEAT_TRL: REPEAT_COUNT [%d],****\n", TRL_REPEAT_COUNT);
    }
} /* INIT_REPEAT_TRL_VARS */


process INIT_TRL_VARS()
{
    PROCESS_STATE                    = 0;
    TRL_IS_RUNNING                   = 0;
    TRL_TRIAL_TYPE                   = -1;
    TRL_IS_I_IN_FLIGHT               = -1;
    TRL_IS_FIX_ON                    = -1;
    TRL_IS_FIX_ACQUIRED              = -1;
    TRL_IS_TARGET_ON                 = -1;
    TRL_IS_TARG_ACQUIRED             = -1;
    TRL_IS_STOP_SIGNAL_ON            = -1;
    TRL_IS_XTRA_HOLD_DONE            = -1;
    TRL_IS_CANCEL                    = -1;
    TRL_IS_TIMEOUT                   = -1;
    TRL_IS_GO_CORRECT                = -1;
    TRL_IS_GO_ERR                    = -1;
    TRL_IS_CANCELLED_NO_BRK          = -1;
    TRL_IS_CANCELLED_BRK             = -1;
    TRL_IS_NON_CANCELLED_NO_BRK      = -1;
    TRL_IS_NON_CANCELLED_BRK         = -1;
    TRL_IS_NOGO_ERR                  = -1;
    TRL_IS_FIX_REIGNITE              = -1;
    TRL_IS_STAIRCASE_SSD             = -1;
    TRL_IS_REFIX                     = -1;
    TRL_IS_LO_RWRD                   = -1;
    TRL_IS_MED_RWRD                  = -1;
    TRL_IS_HI_RWRD                   = -1;
    TRL_TASK_START_TIME              = -1;
    TRL_TRIAL_START_TIME             = -1;
    TRL_EOT_TIME                     = -1;
    TRL_GET_READY_TIME               = -1;
    TRL_READY_TIME                   = -1;
    TRL_ABORT_TIME                   = -1;
    TRL_FIX_ON_TIME                  = -1;
    TRL_ACQUIRE_FIX_TIME             = -1;
    TRL_ACQUIRE_FIX_ERROR_TIME       = -1;
    TRL_MIN_THT_START_TIME           = -1;
    TRL_MIN_THT_END_TIME             = -1;
    TRL_CANCEL_START_TIME            = -1;
    TRL_CANCEL_END_TIME              = -1;
    TRL_FIXATE_TIME                  = -1;
    TRL_FIX_BREAK_TIME               = -1;
    TRL_TARGET_PRE_TIME              = -1;
    TRL_TARGET_TIME                  = -1;
    TRL_TARGET_HOLD_TIME             = -1;
    TRL_TARGET_BREAK_TIME            = -1;
    TRL_FIX_SPOT_OFF_TIME            = -1;
    TRL_TARGET_ACQUIRED_TIME         = -1;
    TRL_DECIDE_TIME                  = -1;
    TRL_DECIDE_SEC_TIME              = -1;
    TRL_REFIX_TIME                   = -1;
    TRL_SACCADE_TIME                 = -1;
    TRL_ERLY_SACCADE_TIME            = -1;
    TRL_LATE_SACC_TIME               = -1;
    TRL_NO_SACCADE_TIME              = -1;
    TRL_ACQUIRE_TARGET_ERROR_TIME    = -1;
    TRL_XTRA_HOLD_START_TIME         = -1;
    TRL_XTRA_HOLD_END_TIME           = -1;
    TRL_BRK_XTRA_HOLD_TIME           = -1;
    TRL_BRK_PRE_TONE_TIME            = -1;
    TRL_BRK_TONE_TIME                = -1;
    TRL_BRK_PRE_RWRD_TIME            = -1;
    TRL_BRK_RWRD_TIME                = -1;
    TRL_TONE_DELAY_START_TIME        = -1;
    TRL_TONE_DELAY_END_TIME          = -1;
    TRL_REWARD_DELAY_START_TIME      = -1;
    TRL_REWARD_DELAY_END_TIME        = -1;
    TRL_ITI_START_TIME               = -1;
    TRL_ITI_END_TIME                 = -1;
    TRL_START_INFOS_TIME             = -1;
    TRL_END_INFOS_TIME               = -1;
    TRL_TIMEOUT_START_TIME           = -1;
    TRL_TIMEOUT_END_TIME             = -1;
    TRL_STOP_SIGNAL_TIME             = -1;
    TRL_CANCEL_TIME                  = -1;
    TRL_BRK_CANCEL_TIME              = -1;
    TRL_NOGO_SACCADE_PRE_SSD_TIME    = -1;
    TRL_NOGO_SACCADE_POST_SSD_TIME   = -1;
    TRL_NOGO_EARLY_SACCADE_TIME      = -1;
    TRL_NOGO_LATE_SACCADE_TIME       = -1;
    TRL_XTRA_RWRD_ON_TIME            = -1;
    TRL_XTRA_RWRD_OFF_TIME           = -1;
    TRL_TASK_END_TIME                = -1;
    TRL_CUM_DURATION                 = -1;
    TRL_GET_READY_DURATION           = -1;
    TRL_FIX_HOLD_DURATION            = -1;
    TRL_REFIX_HOLD_DURATION          = -1;
    TRL_CANCEL_DURATION              = -1;
    TRL_MIN_THT_DURATION             = -1;
    TRL_TARG_ON_DURATION             = -1;
    TRL_XTRA_HOLD_DURATION           = -1;
    TRL_SACC_DURATION                = -1;
    TRL_TARG_HOLD_DURATION           = -1;
    TRL_STOP_SIGNAL_DURATION         = -1;
    TRL_ITI_DURATION                 = -1;
    TRL_TIMEOUT_DURATION             = -1;
    TRL_TARG_VR_COUNT                = -1;
    TRL_SSD_VR_COUNT                 = -1;
    TRL_USE_TRIAL_DURATION           = -1;
    TRL_USE_SSD_IDX                  = -1;
    TRL_USE_SSD_VR_COUNT             = -1;
    TRL_USE_FIX_HOLD_DURATION        = -1;
    TRL_USE_FIX_HOLD_ADJUST          = -1;
    TRL_USE_SSD_CANCEL_DURATION      = -1;
    TRL_USE_PRE_SSD_FIX_ON_DELAY     = -1;
    TRL_USE_POST_SSD_FIX_ON_DELAY    = -1;
    TRL_USE_TONE_DELAY               = -1;
    TRL_USE_TONE_FREQ                = -1;
    TRL_USE_TONE_DURATION            = -1;
    TRL_USE_RWRD_DELAY               = -1;
    TRL_USE_RWRD_DURATION            = -1;
    TRL_USE_ITI_DURATION             = -1;
    TRL_USE_TIMEOUT_DURATION         = -1;
    TRL_CURR_TARG_IDX                = -1;
    TRL_CURR_TARG_SIZE               = -1;
    TRL_CURR_TARG_ANGLE              = -1;
    TRL_CURR_TARG_ECCENTRICITY       = -1;
    TRL_CURR_TARG_COLOR_IDX          = -1;
    TRL_REPEAT_COUNT                 = 0;
    if (TRL_TRIAL_NUMBER == 0)
    {
        TRL_BLOCK_NUM                  = 0;
        TRL_LAST_STOP_OUTCOME_EVNTCODE = -1;
        TRL_LAST_GO_OUTCOME_EVNTCODE   = -1;
        TRL_LAST_SSD_IDX               = -1;
        TOGGLE_RWRD_ASSOCIATION        = 0;
    }
    if (DEBUG_CONSOLE)
    {
        printf("****SET_CMD/INIT_TRL_VARS****\n");
    }
}/* INIT_TRL_VARS */
