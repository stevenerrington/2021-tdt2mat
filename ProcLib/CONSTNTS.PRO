//==========================================================================
// CONSTNTS.PRO
//   Description: Define all constants fand related global vars
//                for the experiments
//   Author: chenchal.subraveti@vanderbilt.edu
//   Date: 2019-01-15
//==========================================================================
//  Revision History:

// For debugging and file writing of vars
declare int          DEBUG_CONSOLE = 0;
declare int          WRITE_FILE    = 0;
// Color indexes
declare constant int R_IDX = 0;
declare constant int G_IDX = 1;
declare constant int B_IDX = 2;

// Window corners
declare constant int LEFT  = 0;
declare constant int RIGHT = 1;
declare constant int UP    = 2;
declare constant int DOWN  = 3;

// Task definitions
declare int          TASK;
declare constant int TASK_TEST           = 99;
declare constant int TASK_COUNTERMANDING = 1;
declare constant int TASK_FIXATION       = 2;
declare constant int TASK_SEARCH         = 3;
declare constant int TASK_MEMORY_GUIDED  = 4;

// graphics
declare constant int OPEN = 0;
declare constant int FILL = 1;
