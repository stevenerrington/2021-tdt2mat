//==========================================================================
// SEND_EVT.PRO
//   Description: Set event code for event buffer and increment counter
//   Author: steven.p.errington@vanderbilt.edu
//   Date: 2018-09-03
//==========================================================================
//  Revision History:
//  002: 2019/01/21 chenchal subraveti
//       Send event code to TEMPO DIO
//       Added QUE_TTL as process QUE_EVT (see older QUE_TTL.PRO)
//       Added SEND_TTL as process SEND_TTL (no bit shift)
//

#include C:/TEMPO/ProcLib/UTIL/WAIT_MU.PRO

// Definitions for use with TEMPO's DIO module
// Copyright 1994-2002 Reflective Computing.  All rights reserved.
//
// OR these in dioSetMode() function(s) to set output TTL ports.

// Events: Length of strobed event buffer
declare int          CURR_EVENT_FIFO_IDX = 0;
declare int constant N_EVENT_FIFO        = 1000;
declare int          EVENT_FIFO[N_EVENT_FIFO];

// Max number of events to send during 1 process cycle
declare int events_per_cycle = 4;
// current event index to send. When event_idx == CURR_EVENT_FIFO_IDX,
// then there are no more events  to send in EVENT_FIFO buffer
declare int event_idx;
// Number of events which have been sent during *one* process cycle
declare int n_events_sent;


declare SEND_EVT(int eventCode);
declare SEND_TTL(int value);
declare QUE_TTL();


process SEND_EVT(int eventCode)
{
    EVENT_FIFO[CURR_EVENT_FIFO_IDX] = eventCode;
    CURR_EVENT_FIFO_IDX             = (CURR_EVENT_FIFO_IDX + 1) % N_EVENT_FIFO;
}

//==== Comments form QUE_TTL.PRO=============================
//-------------------------------------------------------------------------
// Process QUE_TTL() runs in the background and sends up to 5 event codes
// per process cycle to the remote system, drawing them from the Event_fifo[] buffer.
// This process should be the last process in your protocol so that any
// preceeding process that adds an event code to the Event_fifo[] will do so
// before QUE_TTL() runs.
// NOTE: Two problems may arise when sending TTLs.  First, TTLs may be sent
// too quickly for plexon to keep up and plexon may drop them.  This won't
// result in any errors you can see.  Second, too much time may be allotted
// to individual TTLs causing more time to be allotted to TTLs than is possible
// on a process cycle.  This will result in buffer overflow messages in TEMPO.
// The balance between too little time and too much time is struck by 1) the
// number of micro seconds allotted to each TTL, 2) the number of TTLs sent
// per process cycle, and 3) the amount of other stuff you allow to happen while
// TTLs are being sent.  In rig 028 I have found that 100 microseconds between TTLs
// and 5 TTLs per process cycle results in zero drops and zero overflows AS LONG AS
// I HAVE APPROPRIATELY PLACED nextticks IN AREAS OF HEAVY TTL VOLUME.  That way
// other processes (e.g. rdx communication) don't use up all of the buffer while I am
// trying to strobe.  All of this may depend on plexon settings that I am
// currently unaware of, and tests should be performed in each rig to find
// appropriate parameters.
//
// written by david.c.godlove@vanderbilt.edu  January, 2011


process QUE_TTL()
{
    while (1)
    {
        if (n_events_sent >= events_per_cycle)
        {
            n_events_sent = 0;
        }
        while (  n_events_sent < events_per_cycle
              && event_idx != CURR_EVENT_FIFO_IDX)
        {
            spawnwait SEND_TTL(EVENT_FIFO[event_idx]);

            event_idx     = (event_idx + 1) % N_EVENT_FIFO;
            n_events_sent = n_events_sent + 1;
        }
        // wait one process cycle
        nexttick;
        // Note that we may wait on process cycle because we are..
        // ...just waiting on data to be added to the Event_fifo, or...
        // ...we may wait because we have too many events for a...
        // ...single cycle.
    }
}


process SEND_TTL(int value)
{
    declare int output = 1;

    // set ports A, B, and C to send strobes (output)
    dioSetMode(output, PORTA | PORTB | PORTC);
    // Clear ports before sending
    //dioSetA(output, ~0xFF);
    //dioSetB(output, ~0xFF);

    //spawnwait WAIT_MU(50);
    // load the low 8 bits on port A
    dioSetA(output, value & 0xFF);
    // load the high 8 bits on port B
    dioSetB(output, (value >> 8) & 0xFF);
    //wait 200 micro seconds to avoid losing events
    spawnwait WAIT_MU(200);

    // Clear ports after sending
    dioSetA(output, ~0xFF);
    dioSetB(output, ~0xFF);
    spawnwait WAIT_MU(50);
}
