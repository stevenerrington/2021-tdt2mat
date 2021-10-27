// From PROWIN/RDXTTL.PRO

declare WaitForVideoSYNC();

process WaitForVideoSYNC()
{
    declare int newBits;                    // =0,1,2,3
    
   declare int currTimeMs;
   
   currTimeMs = time();
    
    // WAIT FOR ALL PREVIOUS COMMAND TO GET SENT
    // This insures that we are in sync up to this point.
    
    while (dsend())
    {        
        nexttick;
    }
    // Now read the current TTL setting and advance by 1.
    // We are using both of RDX's TTL bits from VideoSYNC
    // to us.  But this is not necessary.  We could just
    // use one of the bits, leaving the other free for
    // other uses.

    newBits = (rdxGetTTLIN() + 1) % 4;  // Advance one MOD 4
    
    // Tell VideoSYNC to increment the sequence count
    // .. by setting its local OOB bits on the RDX link
    // We assume we are the only process sending the SO command.
    // If SO is sent by any other process, it will mess us up
    // and cause us to wait, possibly indefinitely, for our bits.
    
    dsendf("SO%d\n", newBits);

    // WAIT FOR VIDEOSYNC TO ACTUALLY EXECUTE THE SO COMMAND ABOVE.
    // When it does, it will set its "local" bits to newBits.
    // We will see that change here when we get the "remote" bits.

    while (rdxGetTTLIN() != newBits)    // Wait for the bits we expect
    {
        nexttick;
    }
    
    printf("****WAIT_VDO/WaitForVideoSYNC : completed in [%d] ms\n",
          time() - currTimeMs);
}