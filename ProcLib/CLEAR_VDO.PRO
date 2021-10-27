
declare CLEAR_VDO();


process CLEAR_VDO()
{
    printf("Clearing Screen and flusing buffers\n");
    dioSetMode(0, PORTA | PORTB | PORTC);
    mio_dig_set(JUICE_CHANNEL, 0);
    mio_fout(0);
    dsend("vi 256;");
    dsend("ca");
}

