*-----------------------------------------------------------
* Title      : Random numbers
* Written by : Nishanth Sundharesan
* Date       : 9-October-2016
* Description: This files contains 2 subroutines. One is to seed the Random number.
*              The other one is to generate the random number.
*-----------------------------------------------------------

*This subroutine is used to set the seed of the Random number
SeedRandomNumber
        move.b  #TIMER_TRAP_CODE,d0
        TRAP    #15
        move.l  d1,RANDOM_VALUE
        
        rts

*This subroutine gets a Random number from 0-255
GetRandomByteIntoD0
        movem.l d1,-(sp)
        move.l  RANDOM_VALUE,d0
       	moveq	#$AF-$100,d1
       	moveq	#18,d2
Ninc0	
	    add.l	d0,d0
    	bcc	    Ninc1
	    eor.b	d1,d0
Ninc1
	    dbf	    d2,Ninc0
	
    	move.l	d0,RANDOM_VALUE
	
        movem.l (sp)+,d1
        rts

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
