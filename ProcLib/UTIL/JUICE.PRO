//==========================================================================
// JUICE.PRO
//   Description: Deliver juice. Open solenoid for specified duration.
//
//   Inputs:
//           channel: Rig specific TTL channel connected to solenoid
//           duration: Length of time solenoid needs to remain open
//
//   Author: david.c.godlove@vanderbilt.edu
//   Date: 2011
//==========================================================================
//  Revision History:
//  001: 2019/02/08 chenchal subraveti
//       Changed event sending

declare JUICE(int channel, int duration);
declare JUICE_EXTRA();


process JUICE(int channel, int duration)
{
    declare int channelOpen  = 1;
    declare int channelClose = 0;

    spawn SEND_EVT(EVT_JUICE_START_);

    mio_dig_set(channel, channelOpen);
    wait(duration);
    mio_dig_set(channel, channelClose);
    spawn SEND_EVT(EVT_JUICE_END_);
}


process JUICE_EXTRA()
{
  declare int channelOpen  = 1;
  declare int channelClose = 0;
  declare int duration = 50;

  spawn SEND_EVT(EVT_EXTRA_JUICE_START_);
  mio_dig_set(JUICE_CHANNEL, channelOpen);
  wait(duration);
  mio_dig_set(JUICE_CHANNEL, channelClose);
  spawn SEND_EVT(EVT_EXTRA_JUICE_END_);

}
