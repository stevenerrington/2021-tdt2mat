function outEv = tdt2EvShft(event)

noHead = event - ((2^16)/2);
outEv = noHead./2;