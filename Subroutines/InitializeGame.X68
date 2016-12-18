*-----------------------------------------------------------------------------
* Title      : Initialize Game
* Written by : Nishanth Sundharesan
* Date       : 10-October-2016
* Description: This subroutine is called when the game loads for the first time.
*              It initializes the game.
*------------------------------------------------------------------------------
InitializeGame
        *Clear the screen  
        move.b  #CLEAR_SCREEN_TRAP_CODE,d0      
        move.l  #$FF00,d1                                   ;#$FF00 is to clear the whole screen
        TRAP    #15
        
        *Load Menuscreen Sound
        lea	    MenuScreen_Sound,a1
        move.l  #MENU_SCREEN_SOUND_REF,d1
        move.l  #LOAD_SOUND_TRAP_CODE,d0
        TRAP    #15
        
        *Load the Duck falling Sound
        lea	    DuckFalling_Sound,a1
        move.l  #DUCK_FALLING_SOUND_REF,d1
        move.l  #LOAD_SOUND_TRAP_CODE,d0
        TRAP    #15
        
        *Play & Loop Menuscreen Sound
        move.l  #MENU_SCREEN_SOUND_REF,d1        
        move.l  #SOUND_LOOP_TRAP_CODE,d2
        move.l  #CONTROl_DIRECTX_TRAP_CODE,d0
	    TRAP    #15

        *Set the screen size
        move.l  #SCREEN_SIZE_TRAP_CODE,d0
        move.w  #SCREEN_WIDTH,d1                            ;Higher significant word should contain the width and lower significant word should contain the height
        swap    d1
        move.w  #SCREEN_HEIGHT,d1
        TRAP    #15
        
        *Turn on double buffering drawing mode
        move.b  #ENABLE_DOUBLE_BUFFER_TRAP_CODE, d1
        move.b  #DRAWING_MODE_TRAP_CODE, d0
        TRAP    #15
              
        *Display Loading Text
        lea     LoadingText,a1
        move.l  #(SCREEN_WIDTH/2)-LOADING_TEXT_WIDTH,d1
        move.l  #(SCREEN_HEIGHT/2)-LOADING_TEXT_WIDTH,d2
        move.l  #GRAPHIC_TEXT_TRAP_CODE,d0
        TRAP    #15
        
        jsr     DisplayFromBuffer
        
        *Load the Menu screen image data(width, height, etc)
        lea     MenuScreenImageData,a5                      ;Load the data variable to a5
        lea     MenuScreenImage,a0                          ;Load the image address to a0
        jsr     LoadImageData                                      
                      
        *--------------------------------------------------------------------------------------------------------------------
        *Draw Menu screen image
        lea     MenuScreenImageData,a5
        lea     MenuScreenImage,a0

        *Pass the arguements using stack
        move.l  #SCREEN_HEIGHT,-(sp)                   ;Height of the image
        move.l  #SCREEN_WIDTH,-(sp)                    ;Width of the image
        move.l  #0,-(sp)                               ;Image's X offset
        move.l  #0,-(sp)                               ;Image's Y offset
        move.l  #0,-(sp)                               ;X co-ordinate on the screen
        move.l  #0,-(sp)                               ;Y co-ordinate on the screen
                       
        jsr DisplayImage
        add.l   #SIZEOF_DISPLAYIMAGE_PARAMS,sp         ;Add the parameter size to the stack pointer to point it back to the initial position
        *--------------------------------------------------------------------------------------------------------------------
                                          
        jsr     DisplayFromBuffer
                
DONTENTERGAME:    
        move.l  #KEY_SPACEBAR,d1
        move.l  #KEY_INPUT_TRAP_CODE,d0
        TRAP    #15
        andi.l  #$FF,d1                                     ;Check for key press. $FF = Key pressed. $00 = Key not pressed
        beq     DONTENTERGAME                               ;If spacebar is pressed then Enter the game, or else loop again        
        
        *Clear the screen  
        move.b  #CLEAR_SCREEN_TRAP_CODE,d0      
        move.l  #$FF00,d1                                   ;#$FF00 is to clear the whole screen
        TRAP    #15
                
        *Display Loading Text
        lea     LoadingText,a1
        move.l  #(SCREEN_WIDTH/2)-LOADING_TEXT_WIDTH,d1
        move.l  #(SCREEN_HEIGHT/2)-LOADING_TEXT_WIDTH,d2
        move.l  #GRAPHIC_TEXT_TRAP_CODE,d0
        TRAP    #15

        jsr     DisplayFromBuffer          
                                
        *Load the Background image data(width, height, etc)
        lea     BackgroundImageData,a5                      ;Load the data variable to a5
        lea     BackgroundImage,a0                          ;Load the image address to a0
        jsr     LoadImageData                               
        
        *Load the Crosshair image data(width, height, etc)
        lea     CrossHairImageData,a5                       ;Load the data variable to a5
        lea     CrossHairImage,a0                           ;Load the image address to a0
        jsr     LoadImageData
        
        *Load the Sprite image data(width,height,etc)
        lea     SpriteImageData,a5                          ;Load the data variable to a5
        lea     SpriteImage,a0                              ;Load the image address to a0
        jsr     LoadImageData
        
        *Load the GameOver image data(width,height,etc)
        lea     GameOverImageData,a5                        ;Load the data variable to a5
        lea     GameOverImage,a0                            ;Load the image address to a0
        jsr     LoadImageData
        
        *--------------------------------------------------------------------------------------------------------------------
        *Draw background image
        lea     BackgroundImageData,a5
        lea     BackgroundImage,a0

        *Pass the arguements using stack
        move.l  #SCREEN_HEIGHT,-(sp)                   ;Height of the image
        move.l  #SCREEN_WIDTH,-(sp)                    ;Width of the image
        move.l  #0,-(sp)                               ;Image's X offset
        move.l  #0,-(sp)                               ;Image's Y offset
        move.l  #0,-(sp)                               ;X co-ordinate on the screen
        move.l  #0,-(sp)                               ;Y co-ordinate on the screen
                       
        jsr DisplayImage
        add.l   #SIZEOF_DISPLAYIMAGE_PARAMS,sp         ;Add the parameter size to the stack pointer to point it back to the initial position
        *--------------------------------------------------------------------------------------------------------------------
                
        
        *--------------------------------------------------------------------------------------------------------------------        
        *Draw Crosshair
        lea     CrossHairImageData,a5
        lea     CrossHairImage,a0

        *Pass the arguements using stack
        move.l  #CROSSHAIR_HEIGHT,-(sp)                  ;Height of the image
        move.l  #CROSSHAIR_WIDTH,-(sp)                   ;Width of the image
        move.l  #CROSSHAIR_TOPLEFT_X,-(sp)               ;Image's X offset
        move.l  #CROSSHAIR_TOPLEFT_Y,-(sp)               ;Image's Y offset
        move.l  #INITIAL_CROSSHAIR_X,-(sp)               ;X co-ordinate on the screen
        move.l  #INITIAL_CROSSHAIR_Y,-(sp)               ;Y co-ordinate on the screen
                       
        jsr DisplayImage
        add.l   #SIZEOF_DISPLAYIMAGE_PARAMS,sp           ;Add the parameter size to the stack pointer to point it back to the initial position
        *--------------------------------------------------------------------------------------------------------------------

        *Let's move the initial position to our position registers        
        move.l  #INITIAL_CROSSHAIR_X,d5
        move.l  #INITIAL_CROSSHAIR_Y,d6
        
        lsl.l   #FRAC_BITS,d5                            ;Left shifting CrossHair's X co-ordinate to move to 2e-8 land
        lsl.l   #FRAC_BITS,d6                            ;Left shifting CrossHair's Y co-ordinate to move to 2e-8 land               
        
        *Setting Initial Timer
        move.l  #TIMER_TRAP_CODE,d0                      ;Trap code to get timer into d1, Timer is in hundredths of seconds since midnight						                                
    	TRAP	#15
        move.l  d1,d7                                    ;Storing the time in d7 through out the entire game
        
        move.l  d7,FlapSoundTime                         ;Initializing the flap time sound
        
        jsr     SeedRandomNumber
        
        *Load the total number of movements for each duck
        move.l  #(LengthOfDataFile-DuckMovementAIFromLeft1),TOTAL_DUCK_MOVEMENT
        
        *Load the initial velocity of the duck
        move.l  #INITIAL_DUCK_VELOCITY,DUCK_VELOCITY
        
        *Load the shots per duck
        move.l  #SHOTS_PER_DUCK,SHOTS_LEFT
        
        *Load the lives, which is the maximum number of ducks that a player can leave
        move.l  #LIVES,LIVES_LEFT
        
        *Load the number of sprites for the dead duck animation
        move.l  #1,DeadDuckSprites
        
        *Initializing the Duck quack sound index        
        move.l  #0,DuckQuackLoopCount
        
        *---------------------------------------------------------------------------------------------------------------------
        *Draw the Shots
        movem.l REGISTERS_7SEGMENT_LED,-(sp)            ;Save the registers
        
        move.l  #SHOTS_PER_DUCK,d6                      ;Move the shots left to a data register
        move.l  #SHOTS_POSITION_X,Number_Position_X
        move.l  #SHOTS_POSITION_Y,Number_Position_Y
        jsr     Display7Segment
        
        movem.l (sp)+,REGISTERS_7SEGMENT_LED            ;Load back the registers
        *---------------------------------------------------------------------------------------------------------------------        
        
        *---------------------------------------------------------------------------------------------------------------------
        *Draw the Lives
        movem.l REGISTERS_7SEGMENT_LED,-(sp)            ;Save the registers
        
        move.l  #LIVES,d6                               ;Move the lives left to a data register
        move.l  #LIVES_POSITION_X,Number_Position_X
        move.l  #LIVES_POSITION_Y,Number_Position_Y
        jsr     Display7Segment
        
        movem.l (sp)+,REGISTERS_7SEGMENT_LED            ;Load back the registers
        *---------------------------------------------------------------------------------------------------------------------                
        
        *---------------------------------------------------------------------------------------------------------------------
        *Draw the Score
        movem.l REGISTERS_7SEGMENT_LED,-(sp)            ;Save the registers
        
        move.l  SCORE,d6                                ;Move the score to a data register
        move.l  #SCORE_POSITION_X,Number_Position_X
        move.l  #SCORE_POSITION_Y,Number_Position_Y
        jsr     Display7Segment
        
        movem.l (sp)+,REGISTERS_7SEGMENT_LED            ;Load back the registers
        *---------------------------------------------------------------------------------------------------------------------
        
        *Stop the Menu screen sound
        move.l  #SOUND_STOP_TRAP_CODE,d2
        move.l  #CONTROl_DIRECTX_TRAP_CODE,d0
        TRAP    #15
        
        jsr     DisplayFromBuffer

        rts






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
