//==========================================================================
// VAR_CMD.PRO
//   Description: Global declares for COUNTERMANDING trials and Default defines
//
//   TODO:
//        Separate out VAR_COMN, common for all tasks
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-01-14
//==========================================================================
//  Revision History:
//  002: 2019-02-08 chenchal subraveti
//       Compute TRL_USE_XTRA_HOLD_DURATION using USE_TONE_AND_REWRD_FOR_MIN_THT
//       if 0: then TRL_USE_XTRA_HOLD_DURATION =
//       if 1: then TRL_USE_XTRA_HOLD_DURATION = TONE_DELAY+TONE_DURATION+RWRD_DURATION+RWRD_DELAY+
//       TRL_USE_XTRA_HOLD_DURATION:
//       if break gaze on target  ==> Punish, Always do TIMEOUT_TIME regardless of TONE/JUICE given
//       if gaze ob target ==> NO TIMEOUT_TIME
//
// 003: 2019-03-13 chenchal subraveti
//       TRL_USE_XTRA_HOLD_DURATION = determined by the vars below
//       TARG_HOLD_MEAN, TARG_HOLD_SPREAD, TARG_HOLD_JITTER_FLAG
//

//===========Trial types and distributions======================
declare constant int TRIAL_TYPE_GO   = 0;
declare constant int TRIAL_TYPE_STOP = 1;

// Percentage of trial types (must sum to 100)
declare float GO_WEIGHT     = 67.0;
declare float STOP_WEIGHT   = 33.0;
declare float IGNORE_WEIGHT = 0.0;
// Repeat low reward error Trials
declare int   REPEAT_LO_RWRD_ERROR_TRL = 0;
// Values: -1 : repeat till monk got it right
//          0 : No repeat
//          N : Any positive number
declare int REPEAT_MAX = 0;
//==========Jitter flags and definitions=========================
// See UTIL/JITTER.PRO
// declare constant int JITTER_NONE             = 0;
// declare constant int JITTER_GAUSS_FLAG       = 1;
// declare constant int JITTER_UNIFORM_FLAG     = 2;
// declare constant int JITTER_EXPONENTIAL_FLAG = 3;
// temporary globals to be used in state processing
declare int TEMP_XTRA_HOLD_TIME;
declare int TEMP_DELY_PLUS_DURATION;

//============= Timing variables    ===================
// Time dialation factor to multiply all times for manual operation
// 1 = default to be used when running expreriment;
declare int TIME_DILATE_FACTOR = 1;
// subject has this long to hang around fix-spot outside FIX_WIN_SIZE_LARGE
declare int READY_TIME = 500;
// subject has this long to acquire fixation before a new trial is initiated
declare int ALLOWED_FIX_TIME = 3000;
// subject did not acquire fixation, show blank screen and wait before next trial
declare int FIX_NOT_ACQ_WAIT_TIME = 500;
// defines if exponential holdtime is used or if holdtime is sampled from rectanglular dist.
declare int FIX_JITTER_FLAG = JITTER_UNIFORM_FLAG;
// fix hold mean time
declare int FIX_HOLD_MEAN = 800;
// fix hold spread mean +/- spread
declare int FIX_HOLD_SPREAD      = 200;
declare int FIX_HOLD_JITTER_FLAG = JITTER_UNIFORM_FLAG;
// min-max saccade time is same for Go and STOP trials
declare int MIN_SACC_TIME = 100;
declare int MAX_SACC_TIME = 700;
// subject has this long to saccade to the target
//declare int MAX_SACCADE_TIME = 700;
// once the eyes leave fixation they must be in the target before this time is up
declare int MAX_SACC_DURATION = 150;

//========== GO TRIAL TARG HOLD TIME ======================
// after saccade subject must hold gaze on target for this long
declare int TARG_HOLD_MEAN        = 200;
declare int TARG_HOLD_SPREAD      = 0;
declare int TARG_HOLD_JITTER_FLAG = JITTER_NONE;

//========== STOP TASK SPECIFIC =============================
// maximum number of stop signal delays
declare int   N_SSD_MAX = 30;
// needs to be in refresh rate units
declare float SSD_ARRY[N_SSD_MAX];
// number of *non-zero* stop signal delays
declare int   N_SSD;
// min max ssd
declare int   MIN_SSD;
declare int   MAX_SSD;
// do we select the next SSD based on a staircasing algorithm
// No coding for setting of '0' :-)
declare int STAIRCASE_SSD = 1;
// Step up max index for increasing SSD. current idx + (random(3) +1)
declare int SSD_STEP_UP = 3;
// Step down max index for decreasin SSD. current idx - (random(3) +1)
declare int SSD_STEP_DOWN = 3;
// Minimum time *after* stop signal that subject has to fixate
// in order for trial to be considered as Cancel trial
// Relative to TRL_USE_SSD_VR_COUNT (equivalent to TRL_USE_XTRA_HOLD_DURATION for GO trials)
declare int SSD_CANCEL_DURATION = 1200;
// after TRL_USE_SSD_VR_COUNT, subject must hold gaze on FIXSPOT for this long
// if not, then TIMEOUT is imposed regardless of TONE or REWARD
// evt: FixHoldMinSSHT_
// Turn fix spot back on for stop trial when:
// FIX_REIGNITE_FLAG == 1 *AND*
// saccade is made to target within PRE_SSD_FIX_ON_DELAY or
// saccade is made to target within POST_SSD_FIX_ON_DELAY
declare int FIX_REIGNITE_FLAG     = 0;
declare int PRE_SSD_FIX_ON_DELAY  = 0;
declare int POST_SSD_FIX_ON_DELAY = 5000;

//============= Trial duration for computing ITI and Timeout =========================
// Max_trial_duration = compute max duration for longest STOP trial, including BASE_ITI_FOR_AUTO_TRL_DURATION
// the trial_duration_to_use for computing ITI and Timeout depends on USE_PROVIDED_TRL_LENGTH flag:
// Case 0 : trial_duration_to_use = Compute max trial duration (include the base ITI in computation)
// Case 1 : trial_duration_to_use = max(Max_trial_duration,PROVIDED_TRL_LENGTH)
declare int USE_PROVIDED_TRL_LENGTH = 0;
// Use this value if USE_PROVIDED_TRL_LENGTH == 1 && this value is greater than Max_trial_duration
declare int PROVIDED_TRL_LENGTH = 4000;
// Use this duration for computing Max_trial_duration
declare int BASE_ITI_FOR_AUTO_TRL_DURATION = 1000;

//================= Fix/Targ hold duration ===========================
// Stay in window (TARG for GO/ FIX for STOP) till reward is given
declare int XTRA_HOLD_TONE_RWRD_FLAG = 1;
// compute xtra hold time if XTRA_HOLD_TONE_RWRD_FLAG = 0;
declare int XTRA_HOLD_MEAN        = 500;
declare int XTRA_HOLD_SPREAD      = 0;
declare int XTRA_HOLD_JITTER_FLAG = JITTER_NONE;

//================= Tone variables =================================
// how long after IS_TARG_ACQUIRED before tone is played (primary reinforcement)
declare int TONE_DELAY_MEAN = 400;
// Variance to the delay: See UTIL/JITTER.PRO
// if TONE_JITTER_FLAG == JITTER_GAUSS_FLAG : then use GAUSS_JITTER(mean, sd)
// if TONE_JITTER_FLAG == JITTER_UNIFORM_FLAG : then use UNIFORM_JITTER(mean, spread)
// if TONE_JITTER_FLAG == JITTER_EXPONENTIAL_FLAG : then EXPONENT_JITTER(mean, spread)
declare int TONE_DELAY_SPREAD = 0;
declare int TONE_JITTER_FLAG  = JITTER_NONE;

// how long should the error and success tones be presented?
// this will be recomputed during trial
// Actual used will be TRL_USE_TONE_DURATION, TRL_USE_TONE_FREQ
declare int TONE_DURATION = 30;

//================= Reward variables =================================
// how long after tone before juice is given (needed to seperate primary and secondary reinforcement)
declare int RWRD_DELAY_MEAN = 400;
// Variance to the delay: See UTIL/JITTER.PRO
// if RWRD_JITTER_FLAG == JITTER_GAUSS_FLAG : then use GAUSS_JITTER(mean, sd)
// if RWRD_JITTER_FLAG == JITTER_UNIFORM_FLAG : then use UNIFORM_JITTER(mean, spread)
// if RWRD_JITTER_FLAG == JITTER_EXPONENTIAL_FLAG : then EXPONENT_JITTER(mean, spread)
declare int RWRD_DELAY_SPREAD = 0;
declare int RWRD_JITTER_FLAG  = JITTER_NONE;
// how long will the juice solenoid remain open (monkeys are very interested in this varaible)
// this will be recomputed during trial
// Actual used will be TRL_USE_RWRD_DURATION

//====================Asymmetric reward ========================
// Switch block after number of Correct trials = TRIALS_PER_BLOCK
// TRL_USE_CORRECT_TRIALS_PER_BLOCK is computed when block changes
declare int CORRECT_TRLS_BLK_MEAN = 20;
declare int CORRECT_TRLS_BLK_SPREAD = 8;
declare int CORRECT_TRLS_BLK_JITTER_FLAG  = JITTER_UNIFORM_FLAG;

// Reward amounts for Asymmetric REWARD COMBINATIONS
//  Lo / Med / Hi
declare int LO_RWRD_DUR  = 40;
declare int MED_RWRD_DUR = 120;
declare int HI_RWRD_DUR  = 400;
// Reward Ratios by Target Location - No Jitter
// For each block one of the rows from RWRD_RATIOS is chosen to
// associate Asymmetic rewards by location. For details:
// see SET_CMD.PRO/SET_RWRD_RATIOS_FOR_BLOCK and SET_CMD.PRO/SET_RWRD_FOR_TRIAL
// For the 3 variables below:
//    1. NUM_RWRD_RATIOS    = num_rows in the RWRD_RATIOS array below
//    2. NUM_RWRD_TARG_LOCS = num_cols in the RWRD_RATIOS array below
//             additionally, NUM_RWRD_TARG_LOCS *shall* = N_TARG_POS
//    3. RWRD_RATIOS  = Possible Asymmetic reward ratios for a block  
// ** For 2 ratios : {LO, HI} and (HI, LO} use this and comment out the other RWRD_RATIOS *below*
declare int NUM_RWRD_RATIOS    = 2;
declare int NUM_RWRD_TARG_LOCS = 2;
declare int RWRD_RATIOS[NUM_RWRD_RATIOS, NUM_RWRD_TARG_LOCS] =
{
    LO_RWRD_DUR,  HI_RWRD_DUR,
    HI_RWRD_DUR,  LO_RWRD_DUR
 };
// ** For 3 ratios : {LO, HI}, (HI, LO}, {MED, MED} use this and comment out the other RWRD_RATIOS *above*
// declare int NUM_RWRD_RATIOS    = 3;
// declare int NUM_RWRD_TARG_LOCS = 2;
// declare int RWRD_RATIOS[NUM_RWRD_RATIOS, NUM_RWRD_TARG_LOCS] =
//  {
//    LO_RWRD_DUR,  HI_RWRD_DUR,
//    HI_RWRD_DUR,  LO_RWRD_DUR,
//    MED_RWRD_DUR, MED_RWRD_DUR
//  };

//=========================== Timeout variables ======================
// timeout time for punishment computed
declare int TIMEOUT_DURATION;
declare int TIMEOUT_TONE;
declare int TIMEOUT_SHOW_RANDM_PG_FLAG = 0;
declare int TIMEOUT_PLAY_TONE_FLAG     = 1;

// See ProcLib/DOC/CmdOutcomes.xlsx
// Extra punish time for diferent outcomes in number of Trial lengths
// The value must be an integer
// TIMEOUT_TIME = TRL_USE_TRIAL_DURATION (see SET_CMD.PRO) * XTRA_TIMEOUT
// GoTrial = TIMEOUT_xxx[0]
// NoGoTrial_pre_SSD = TIMEOUT_xxx[1]
// NoGoTrial_post_SSD = TIMEOUT_xxx[2]
declare constant int GO_IDX            = 0;
declare constant int NOGO_PRE_SSD_IDX  = 1;
declare constant int NOGO_POST_SSD_IDX = 2;

//
// in number of trial durations
declare int TIMEOUT_REFIX_EXTRA       = 2;
declare int TIMEOUT_FIX_ACQ_ERROR[3]  = { 0, 0, 0 };
declare int TIMEOUT_FIX_BRK[3]        = { 0, 0, 0 };
declare int TIMEOUT_ERLY_SACC[3]      = { 0, 0, 0 };
declare int TIMEOUT_LATE_NO_SACC[3]   = { 0, 0, 0 };
declare int TIMEOUT_TARG_ACQ_ERROR[3] = { 0, 0, 0 };
declare int TIMEOUT_BRK_MIN_THT[3]    = { 1, 1, 1 };
declare int TIMEOUT_BRK_XTRA_HOLD[3]  = { 1, 1, 1 };
declare int TIMEOUT_BRK_PRE_TONE[3]   = { 1, 1, 1 };
declare int TIMEOUT_BRK_TONE[3]       = { 1, 1, 1 };
declare int TIMEOUT_BRK_PRE_RWRD[3]   = { 1, 1, 1 };
declare int TIMEOUT_BRK_RWRD[3]       = { 1, 1, 1 };
declare int TIMEOUT_BRK_POST_RWRD[3]  = { 1, 1, 1 };
// Only valid for NoGo Trial, the 0 index is not used for GoTrial
declare int TIMEOUT_BRK_IS_CANCEL[3] = { 0, 0, 0 };
// Tone frequencies for different outcomes
declare int NON_CANCELLED_NO_BRK_NO_BRK_TONE_HZ = 1000;
declare int CANCELLED_TONE_HZ                   = 400;
declare int GO_CORRECT_TONE_HZ                  = 400;
declare int GO_ERROR_TONE_HZ                    = 100;
declare int NOGO_ERROR_TONE_HZ                  = 100;

//==========================Additional Timeouts======================
// additive timeout imposed for each body movement
//declare int BODY_MOVE_TIMEOUT;
// Output lets us know how many times the body has moved.
//declare int BODY_MOVE_COUNT;
// Setting maximum move_ct so monkey doesn't self-punish to eternity
//declare int MAX_BODY_MOVE_COUNT;
// Indicates that we are using motion detector to train the monk to be still
//declare int TRAINING_STILL;
