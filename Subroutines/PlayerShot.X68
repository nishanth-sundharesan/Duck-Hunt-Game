*---------------------------------------------------------------------------------
* Title      : Handle shot explosion
* Written by : Nishanth Sundharesan
* Date       : 8-October-2016
* Description: This subroutine accepts the trigger explosion input and handles it.
*---------------------------------------------------------------------------------
HandleExplosionInput      
        move.l  #KEY_SPACEBAR,d1
        move.l  #KEY_INPUT_TRAP_CODE,d0
        TRAP    #15
        andi.l  #$FF,d1                                 ;Check for key press. $FF = Key pressed. $00 = Key not pressed
        beq     NOSPACEBARINPUT                         ;If spacebar is not pressed, then exit the subroutine
        
        
        *Implementing the debounce logic
        move.b  HAVE_HAD_NO_INPUT,d0
        beq     AROUNDNOINPUT
        move.b  #0,HAVE_HAD_NO_INPUT
        

        *Check and reduce the shots
        lea     SHOTS_LEFT,a6
        cmpi.l  #0,(a6)                                 ;Check if the shots are remaining
        beq     AROUNDNOINPUT                           ;If not then exit the subroutine
        
        subi.l  #1,(a6)                                 ;Subtract the shots by 1
                   
        *---------------------------------------------------------------------------------------------------------------------                        
        *Draw the Remaining shots
        movem.l REGISTERS_7SEGMENT_LED,-(sp)            ;Save the registers
        
        move.l  (a6),d6                                 ;Move the score to a data register
        move.l  #SHOTS_POSITION_X,Number_Position_X
        move.l  #SHOTS_POSITION_Y,Number_Position_Y
        jsr     Display7Segment
        
        movem.l (sp)+,REGISTERS_7SEGMENT_LED            ;Load back the registers
        *---------------------------------------------------------------------------------------------------------------------
        
        movem.l REGISTERS_EXPLOSION,-(sp)               ;Save the registers        

        *Setting the color for the explosion rectangle
        move.l  #WHITE_COLOR,d1                         ;Set the pen and fill color to white        
        move.l  #PEN_COLOR_TRAP_CODE,d0                 ;Set the pen color
        TRAP    #15        
        move.l  #FILL_COLOR_TRAP_CODE,d0                ;Set the fill color
        TRAP    #15
        
        move.l  d5,d1                                   ;X co-ordinate on the screen        
        move.l  d6,d2                                   ;Y co-ordinate on the screen
        
        lsr.l   #FRAC_BITS,d1                           ;Shift the X co-ordinate from 2e-8 land
        lsr.l   #FRAC_BITS,d2                           ;Shift the Y co-ordinate from 2e-8 land
        
        addi.w  #EXPLOSION_OFFSET,d1                    ;Upper left X co-ordinate
        addi.w  #EXPLOSION_OFFSET,d2                    ;Upper left Y co-ordinate

        move.l  d1,d3                                   ;Lower right X co-ordinate
        addi.w  #EXPLOSION_SIZE,d3
        
        move.l  d2,d4                                   ;Lower right Y co-ordinate
        addi.w  #EXPLOSION_SIZE,d4                            
        
            
        *Draw the explosion
        move.l  #DRAW_FILLED_RECTANGLE,d0               ;Draw filled rectangle
        TRAP    #15
        
        jsr     DisplayFromBuffer                       ;Display from buffer(display the explosion)

        movem.l (sp)+,REGISTERS_EXPLOSION               ;Reload the registers


        *--------------------------------------------------------------------------------------------------------------------------    
        *Play the Explosion Sound        
        move.l  a1,-(sp)                                ;Store duck movement data temporarily
        
        lea	    Explosion_Sound,a1
        move.l  #PLAY_SOUND_TRAP_CODE,d0
	    TRAP    #15
        
        move.l  (sp)+,a1                                ;Load back duck movement data
        *--------------------------------------------------------------------------------------------------------------------------    


        
        *--------------------------------------------------------------------------------------------------------------------------    
        *Draw Background      
        movem.l REGISTERS_DRAW_BITMAP,-(sp)             ;Save the registers
        
        lea     BackgroundImageData,a5                  
        lea     BackgroundImage,a0
        
        subi.w  #1,d2
        
        *Pass the arguements using stack
        move.l  #(EXPLOSION_SIZE+1),-(sp)
        move.l  #(EXPLOSION_SIZE+1),-(sp)        
        move.l  d1,-(sp)                                ;X offset of the image, which will be the same as X co-ordinate
        move.l  d2,-(sp)                                ;Y offset of the image, which will be the same as Y co-ordinate
        move.l  d1,-(sp)                                ;X co-ordinate on the screen
        move.l  d2,-(sp)                                ;Y co-ordinate on the screen
                       
        jsr DisplayImage
        add.l   #SIZEOF_DISPLAYIMAGE_PARAMS,sp          ;Add the parameter size to the stack pointer to point it back to the initial position
                    
        movem.l (sp)+,REGISTERS_DRAW_BITMAP             ;Reload the registers
        *--------------------------------------------------------------------------------------------------------------------------
                                      
        jsr     DetectCollision        
        bra     AROUNDNOINPUT

NOSPACEBARINPUT:
        move.b  #1,HAVE_HAD_NO_INPUT
AROUNDNOINPUT:
        rts   



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
