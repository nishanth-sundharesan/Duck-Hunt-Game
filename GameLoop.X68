*----------------------------------------------------------------------------------
* Title      : Dunk hunt game
* Written by : Nishanth Sundharesan
* Date       : 05-Ocotober-2016
* Description: This game tries to emulate the Dunk hunt game developed by Nintendo.
*              Use Arrow keys to position your aim and spacebar to shoot the duck.
*----------------------------------------------------------------------------------
*----------------------------------------------------
*Trap codes
*----------------------------------------------------
ENABLE_DOUBLE_BUFFER_TRAP_CODE      EQU     17
DRAWING_MODE_TRAP_CODE              EQU     92
DISPLAY_BUFFERED_TRAP_CODE          EQU     94
CLEAR_SCREEN_TRAP_CODE              EQU     11
KEY_INPUT_TRAP_CODE                 EQU     19
SCREEN_SIZE_TRAP_CODE               EQU     33
DRAW_FILLED_RECTANGLE               EQU     87
FILL_COLOR_TRAP_CODE                EQU     81
TIMER_TRAP_CODE                     EQU     8
PLAY_SOUND_TRAP_CODE                EQU     73
LOAD_SOUND_TRAP_CODE                EQU     74
CONTROl_DIRECTX_TRAP_CODE           EQU     77
GRAPHIC_TEXT_TRAP_CODE              EQU     95
SOUND_LOOP_TRAP_CODE                EQU     1
SOUND_STOP_TRAP_CODE                EQU     2
SOUND_PLAY_ONCE_TRAP_CODE           EQU     0
*----------------------------------------------------
*Registers
*----------------------------------------------------
ALL_REGISTERS                       REG     D0-D7/A0-A6
REGISTERS_DRAW_BITMAP               REG     D0-D7/A0-A4
REGISTERS_EXPLOSION                 REG     D3-D4
REGISTERS_COLLISION                 REG     D3-D6
REGISTERS_7SEGMENT_LED              REG     D3-D7/A6
*----------------------------------------------------
*Constant values
*----------------------------------------------------
FRAC_BITS                         EQU     8
SCREEN_WIDTH                      EQU     800
SCREEN_HEIGHT                     EQU     600
CROSSHAIR_HEIGHT                  EQU     68
CROSSHAIR_WIDTH                   EQU     68
DUCK_HEIGHT                       EQU     68
DUCK_WIDTH                        EQU     71
CROSSHAIR_TOPLEFT_X               EQU     0
CROSSHAIR_TOPLEFT_Y               EQU     0
GAMEOVER_HEIGHT                   EQU     80
GAMEOVER_WIDTH                    EQU     200
SIZEOF_DISPLAYIMAGE_PARAMS        EQU     24
CROSSHAIR_VELOCITY                EQU     1300
INITIAL_DUCK_VELOCITY             EQU     4000
UPDATE_DUCK_INTERVAL              EQU     8 
DUCK_FLAP_SOUND_INTERNAL          EQU     15
INITIAL_CROSSHAIR_X               EQU     375
INITIAL_CROSSHAIR_Y               EQU     200
CROSSHAIR_MAX_RIGHT               EQU     $2DC00                ;(SCREEN_WIDTH - CROSSHAIR_WIDTH) -> Converted to Hex
CROSSHAIR_MAX_DOWM                EQU     $1EC00                ;(SCREEN_HEIGHT - CROSSHAIR_HEIGHT - 40 Text height) -> Converted to Hex
CROSSHAIR_MAX_LEFT                EQU     $0
CROSSHAIR_MAX_TOP                 EQU     $0
WHITE_COLOR                       EQU     $00FFFFFF
EXPLOSION_OFFSET                  EQU     7
EXPLOSION_SIZE                    EQU     54
IS_DUCK_INCREMENT                 EQU     01
IS_DUCK_DECREMENT                 EQU     02
NUMBER_OF_DUCK_SPAWNS             EQU     3
NUM_OF_DUCK_PATHS                 EQU     8
DUCK_LEFT_SPAWN_POS_X             EQU     200<<FRAC_BITS        ;200 (left shifted by FRAC_BITS)
DUCK_MIDDLE_SPAWN_POS_X           EQU     400<<FRAC_BITS        ;400 (left shifted by FRAC_BITS)
DUCK_RIGHT_SPAWN_POS_X            EQU     600<<FRAC_BITS        ;600 (left shifted by FRAC_BITS)
DUCK_COMMON_SPAWN_POS_Y           EQU     410<<FRAC_BITS        ;410 (left shifted by FRAC_BITS)
QUANTUM_VELOCITY                  EQU     500
QUANTUM_VELOCITY_INCREMENT        EQU     10
VELOCITY_STOP_INCREMENTING        EQU     40
SHOTS_PER_DUCK                    EQU     3
LIVES                             EQU     3
SHOTS_POSITION_X                  EQU     96
SHOTS_POSITION_Y                  EQU     572
LIVES_POSITION_X                  EQU     388
LIVES_POSITION_Y                  EQU     572
SCORE_POSITION_X                  EQU     680
SCORE_POSITION_Y                  EQU     572
LOADING_TEXT_WIDTH                EQU     25
GRAVITY                           EQU     3100
SHOTDUCK_OFFSET_X                 EQU     0
DEADDUCK_OFFSET_X                 EQU     78
DEADDUCK_OFFSET_Y                 EQU     470
DEAD_DUCK_SPRITES                 EQU     2
DUCK_SPRITE_WIDTH                 EQU     78
MENU_SCREEN_SOUND_REF             EQU     1
DUCK_FALLING_SOUND_REF            EQU     2
SHOW_DEAD_DUCK_LOOPCOUNT          EQU     3
DUCK_QUACK_LOOPCOUNT              EQU     20
*----------------------------------------------------
*Key Codes
*----------------------------------------------------
KEY_LEFT_ARROW                      EQU     $25
KEY_RIGHT_ARROW                     EQU     $27
KEY_UP_ARROW                        EQU     $26
KEY_DOWN_ARROW                      EQU     $28
KEY_SPACEBAR                        EQU     $20
*----------------------------------------------------
*Registers used
*----------------------------------------------------
*d1 = Duck's X position
*d2 = Duck's Y position
*d5 = Crosshair's X position
*d6 = Crosshair's Y position
*d7 = Previous Frame's Time
*All labels which are in capital letters are Branch labels.
*All labels which are in pascal case are Subroutines.
*----------------------------------------------------

    ORG    $1000
START:                                                   ;First instruction of program
        jsr InitializeGame 
        
        jsr LoadDuckMovementData
GAMELOOP:
        jsr UpdateDuck
        
        jsr HandlePlayerInput

        jsr HandleExplosionInput

        bra GAMELOOP        
ENDGAME:
        jsr ExitGame         
    
        jsr DisplayFromBuffer
        
        SIMHALT                                         ;Halt the simulator


CoverCrossHairImage
        move.l  d5,d1                                   ;X co-ordinate on the screen
        move.l  d6,d2                                   ;Y co-ordinate on the screen
        
        lsr.l   #FRAC_BITS,d1                           ;Shift the X co-ordinate to come out of 2e-8 land
        lsr.l   #FRAC_BITS,d2                           ;Shift the Y co-ordinate to come out of 2e-8 land

        movem.l REGISTERS_DRAW_BITMAP,-(sp)             ;Save the registers
        
        lea     BackgroundImageData,a5
        lea     BackgroundImage,a0
        
        *Pass the arguements using stack
        move.l  #CROSSHAIR_HEIGHT,-(sp)
        move.l  #CROSSHAIR_WIDTH,-(sp)        
        move.l  d1,-(sp)                                ;X offset of the image, which will be the same as X co-ordinate
        move.l  d2,-(sp)                                ;Y offset of the image, which will be the same as Y co-ordinate
        move.l  d1,-(sp)                                ;X co-ordinate on the screen
        move.l  d2,-(sp)                                ;Y co-ordinate on the screen
                       
        jsr DisplayImage
        add.l   #SIZEOF_DISPLAYIMAGE_PARAMS,sp          ;Add the parameter size to the stack pointer to point it back to the initial position
                    
        movem.l (sp)+,REGISTERS_DRAW_BITMAP             ;Reload the registers
        
        rts
        
                
DisplayFromBuffer
        *Display from buffer
        move.l  #DISPLAY_BUFFERED_TRAP_CODE,d0
        TRAP    #15                         
        
        rts

CoverDuckImage
        move.l  d3,d1                                   ;Moving the X co-ordinate to d1
        move.l  d4,d2                                   ;Moving the Y co-ordinate to d2
        
        lsr.l   #FRAC_BITS,d1                           ;Shifting the X position to come out of 2e-8 land
        lsr.l   #FRAC_BITS,d2                           ;Shifting the Y position to come out of 2e-8 land

        movem.l REGISTERS_DRAW_BITMAP,-(sp)             ;Save the registers
        
        lea     BackgroundImageData,a5
        lea     BackgroundImage,a0
        
        *Pass the arguements using stack
        move.l  #DUCK_HEIGHT,-(sp)
        move.l  #DUCK_WIDTH,-(sp)                               
        move.l  d1,-(sp)                                ;X offset of the image, which will be the same as X co-ordinate
        move.l  d2,-(sp)                                ;Y offset of the image, which will be the same as Y co-ordinate
        move.l  d1,-(sp)                                ;X co-ordinate on the screen
        move.l  d2,-(sp)                                ;Y co-ordinate on the screen
                       
        jsr DisplayImage
        add.l   #SIZEOF_DISPLAYIMAGE_PARAMS,sp          ;Add the parameter size to the stack pointer to point it back to the initial position
                    
        movem.l (sp)+,REGISTERS_DRAW_BITMAP             ;Reload the registers
        
        rts        

DisplayCrossHair
        move.b  ISDUCKDEAD,d0                           ;Check if the duck is dead or alive
        beq     SkipDeadDuck                            ;If the duck is dead, then display the dead duck and continue
        jsr     DisplayDeadDuck
        bra.s   SkipFlyingDuck  
SkipDeadDuck:        
        jsr     DisplayFlyingDuck                       ;Display flying duck
SkipFlyingDuck:
        
        *Always display the Duck and then the Crosshair because when the Crosshair moves on top of the Duck, the Duck flickers
        move.l  d5,d1                                   ;X co-ordinate on the screen        
        move.l  d6,d2                                   ;Y co-ordinate on the screen
        
        lsr.l   #FRAC_BITS,d1                           ;Shift the X co-ordinate from 2e-8 land
        lsr.l   #FRAC_BITS,d2                           ;Shift the Y co-ordinate from 2e-8 land
  
                
        movem.l REGISTERS_DRAW_BITMAP,-(sp)             ;Save the registers

        lea     CrossHairImageData,a5
        lea     CrossHairImage,a0
        
        *Pass the arguements using stack
        move.l  #CROSSHAIR_HEIGHT,-(sp)
        move.l  #CROSSHAIR_WIDTH,-(sp)        
        move.l  #CROSSHAIR_TOPLEFT_X,-(sp)              ;X offset of the image, which will always be 0
        move.l  #CROSSHAIR_TOPLEFT_Y,-(sp)              ;Y offset of the image, which will always be 0
        move.l  d1,-(sp)                                ;X co-ordinate on the screen
        move.l  d2,-(sp)                                ;Y co-ordinate on the screen
                       
        jsr DisplayImage
        add.l   #SIZEOF_DISPLAYIMAGE_PARAMS,sp          ;Add the parameter size to the stack pointer to point it back to the initial position
                
        movem.l (sp)+,REGISTERS_DRAW_BITMAP             ;Reload the registers

        jsr     DisplayFromBuffer                       ;Display from buffer(display the moved crosshair)

        rts

     
LoadDuckMovementData
        jsr     GetRandomByteIntoD0
        move.l  #NUMBER_OF_DUCK_SPAWNS,d1
        and.b   d0,d1                                   ;Use AND instruction to get a Random number from 0 to NUMBER_OF_DUCK_SPAWNS(In our case, from 0 to 3)
                                                        ;Note that we will get 4 Random numbers instead of 3
        
        jsr     GetRandomByteIntoD0
        move.l  #(NUM_OF_DUCK_PATHS-1),d2               
        and.b   d0,d2                                   ;Use AND instruction to get a Random number from 0 to (NUM_OF_DUCK_PATHS - 1)(In out case, from 0 to 7)

        move.l  TOTAL_DUCK_MOVEMENT,d0                  ;Move the Total duck movement, which is the length of the each path file
        mulu.w  d0,d2                                   ;Multiply it with the acquired random number to get the offset address of the random path file        
        
        
        cmpi.b  #0,d1                                   ;If the duck spawn random number is 0, then spawn the duck from the left of the screen
        bne     CHECKFOR1        
        move.l  #DUCK_LEFT_SPAWN_POS_X,d3               ;Load the X co-ordinate of left spawn position
        lea     DuckMovementAIFromLeft1,a1              ;Load the beginning address of the left spawning duck's path file
        add.l   d2,a1                                   ;Add the previously calculated offset to load the address of the random path file of only left spawning ducks
        bra.w   LOADSPAWNPOS_Y                          ;Branch to load the common Y co-ordinate of the spawn position
CHECKFOR1:
        cmpi.b  #1,d1                                   ;If the duck spawn random number is 1, then spawn the duck from the middle of the screen
        bne     CHECKFOR2                               
        move.l  #DUCK_MIDDLE_SPAWN_POS_X,d3             ;Load the X co-ordinate of middle spawn position
        lea     DuckMovementAIFromMiddle1,a1            ;Load the beginning address of the middle spawning duck's path file
        add.l   d2,a1                                   ;Add the previously calculated offset to load the address of the random path file of only center spawning ducks
        bra.w   LOADSPAWNPOS_Y                          ;Branch to load the common Y co-ordinate of the spawn position
CHECKFOR2:
        move.l  #DUCK_RIGHT_SPAWN_POS_X,d3              ;If the duck spawn random number is 2 or 3, then spawn the duck from the right of the screen.
                                                        ;Load the X co-ordinate of right spawn position
        lea     DuckMovementAIFromRight1,a1             ;Load the beginning address of the right spawning duck's path file
        add.l   d2,a1                                   ;Add the previously calculated offset to load the address of the random path file of only right spawning ducks                  
        
LOADSPAWNPOS_Y:
        move.l  #DUCK_COMMON_SPAWN_POS_Y,d4             ;Load the common Y co-ordinate of the spawn position                  
         
        move.l  TOTAL_DUCK_MOVEMENT,MAX_PATH_BEFOREFLY  ;Load the total duck movements in each file
                
        *Reload the shots per duck
        move.l  #SHOTS_PER_DUCK,SHOTS_LEFT
        
        *---------------------------------------------------------------------------------------------------------------------
        *Draw the Shots
        movem.l REGISTERS_7SEGMENT_LED,-(sp)            ;Save the registers
        
        move.l  #SHOTS_PER_DUCK,d6                      ;Move the shots left to a data register
        move.l  #SHOTS_POSITION_X,Number_Position_X
        move.l  #SHOTS_POSITION_Y,Number_Position_Y
        jsr     Display7Segment
        
        movem.l (sp)+,REGISTERS_7SEGMENT_LED            ;Load back the registers
        *--------------------------------------------------------------------------------------------------------------------- 
        
        ;Reload the dead duck loop count
        move.l  #0,ShotDuckLoopCount
        
        rts   

DetectCollision
        *d5 -> Crosshair's X
        *d6 -> Crosshair's Y
        *d3 -> Duck's X
        *d4 -> Duck's Y
        *Lets consider the CrossHair as rectangle1 and the duck as rectangle2
        *We will use the formula
        *if (rect1.x < rect2.x + rect2.width && rect1.x + rect1.width > rect2.x && rect1.y < rect2.y + rect2.height &&  rect1.y + rect1.height > rect2.y)
        *{
        *     Collision detected
        *}        

        movem.l REGISTERS_COLLISION,-(sp)             ;Save all the registers holding the position
                    
        ;Shift out all the registers from 2e-8 land            
        lsr.l   #FRAC_BITS,d5                          
        lsr.l   #FRAC_BITS,d6
        lsr.l   #FRAC_BITS,d3
        lsr.l   #FRAC_BITS,d4                 
                 
        *Add the Explosion offset to calculate collision detection only for the explosion inside the Crosshair        
        addi.w  #EXPLOSION_OFFSET,d5                    ;Add Explosion offset X
        addi.w  #EXPLOSION_OFFSET,d6                    ;Add Explosion offset Y

        move.w  d3,d0                                   *------------------------------------------
        addi.w  #DUCK_WIDTH,d0                          *if (rect1.x < rect2.x + rect2.width &&...
        cmp.w   d5,d0                                   *
        blt     NOCOLLISION                             *------------------------------------------
        
        move.w  d5,d0                                   *------------------------------------------
        addi.w  #EXPLOSION_SIZE,d0                      *if(...rect1.x + rect1.width > rect2.x &&...
        cmp.w   d0,d3                                   *------------------------------------------
        bgt     NOCOLLISION                             
        
        move.w  d4,d0                                   *------------------------------------------
        addi.w  #DUCK_HEIGHT,d0                         *if(...rect1.y < rect2.y + rect2.height &&...
        cmp.w   d6,d0                                   *------------------------------------------
        blt     NOCOLLISION
        
        move.w  d6,d0                                   *------------------------------------------
        addi.w  #EXPLOSION_SIZE,d0                      *if(...rect1.y + rect1.height > rect2.y)
        cmp.w   d0,d4                                   *------------------------------------------
        bgt     NOCOLLISION
        
        movem.l (sp)+,REGISTERS_COLLISION               ;Reload the registers
        
        *Set Duck dead to true
        move.b  #1,ISDUCKDEAD
        
        *Display the background to cover the duck
        jsr     CoverDuckImage
        
        *Increment the score 
        jsr     AddScoreAndVelocity                      

        move.l  #SHOTDUCK_OFFSET_X,CurrentDuckSpriteX                ;X offset of the Shot duck sprite image
        move.l  #DEADDUCK_OFFSET_Y,CurrentDuckSpriteY                ;Y offset of the Dead duck sprite image

        *--------------------------------------------------------------------------------------------------------------------
        *Play Duck falling soud 
        move.l  #DUCK_FALLING_SOUND_REF,d1        
        move.l  #SOUND_PLAY_ONCE_TRAP_CODE,d2
        move.l  #CONTROl_DIRECTX_TRAP_CODE,d0
	    TRAP    #15
        *--------------------------------------------------------------------------------------------------------------------

        rts
        
NOCOLLISION:
        movem.l (sp)+,REGISTERS_COLLISION                ;Reload the registers   
        rts


AddScoreAndVelocity
        *Increment the score and velocity
        lea     Score,a6                                ;Load the score into a address register
        addi.l  #1,(a6)                                 ;Increment the score
               
        *---------------------------------------------------------------------------------------------------------------------
        *Draw the Score
        movem.l REGISTERS_7SEGMENT_LED,-(sp)            ;Save the registers
        
        move.l  (a6),d6                                 ;Move the score to a data register
        move.l  #SCORE_POSITION_X,Number_Position_X
        move.l  #SCORE_POSITION_Y,Number_Position_Y
        jsr     Display7Segment
        
        movem.l (sp)+,REGISTERS_7SEGMENT_LED            ;Load back the registers
        *---------------------------------------------------------------------------------------------------------------------
                        
        *Check and increment the duck velocity
        move.l  VELOCITY_INCREMENT,d0                   
        cmp.l   (a6),d0                                 ;Compare the score and check if the velocity needs to be incremented
        bne     ENDSCOREROUTINE                         ;If not, then escape the condition
        
        lea     DUCK_VELOCITY,a6                        ;If yes, then load the velocity
        addi.l  #QUANTUM_VELOCITY,(a6)                  ;And increment the velocity
            
        lea     VELOCITY_INCREMENT,a6                   
        cmpi.l  #VELOCITY_STOP_INCREMENTING,(a6)        ;Check if the maximum increment velocity has reached
        beq     ENDSCOREROUTINE                         ;If yes, then escape the condition
        addi.l  #QUANTUM_VELOCITY_INCREMENT,(a6)        ;If not, then increment the velocity increment variable

ENDSCOREROUTINE
        rts     


UpdateDuck
        *Calling timer
        move.l  #TIMER_TRAP_CODE,d0                      ;Trap code to get timer into d1, Timer is in hundredths of seconds since midnight						                                
    	TRAP	#15
        sub.l   d7,d1                                    ;Get the delta time

        cmpi.l  #UPDATE_DUCK_INTERVAL,d1                 ;Checking if the delta time is greater than the update duck interval time,if yes then draw the duck
        ble     EXITDUCKSUBROUTINE
                
        add.l   d1,d7                                    ;Add the delta time to set the previous time

        *Display the background to cover the duck
        jsr     CoverDuckImage
        
        
        move.b  ISDUCKDEAD,d0                            ;Check if the duck is alive or not
        beq     SHOWFLYINGDUCK                                
                
       *--------------------------------------------------------------------------------------------------------------------------
        cmpi.l  #DUCK_COMMON_SPAWN_POS_Y,d4              ;Check if the Duck's Y co-ordinate has reached the spawn position of the screen
        blt     .SKIPSOUND
        
        *Stop the Duck falling sound
        move.l  #DUCK_FALLING_SOUND_REF,d1
        move.l  #SOUND_STOP_TRAP_CODE,d2
        move.l  #CONTROl_DIRECTX_TRAP_CODE,d0
        TRAP    #15

        *Play the Duck hit ground sound        
        move.l  a1,-(sp)                                 ;Store duck movement data temporarily
        
        lea	    DuckHitGround_Sound,a1
        move.l  #PLAY_SOUND_TRAP_CODE,d0
	    TRAP    #15
        
        move.l  (sp)+,a1                                 ;Load back duck movement data
        *--------------------------------------------------------------------------------------------------------------------------    
.SKIPSOUND:                
        cmpi.l  #DUCK_COMMON_SPAWN_POS_Y,d4              ;Check if the Duck's Y co-ordinate has reached the spawn position of the screen
        bge     RELOADDUCK                               ;If yes, then reload the duck         
                    
        jsr     UpdateDeadDuckSprites
        jsr     DisplayCrossHair                         ;Display the Duck and Crosshair
        
        bra     EXITDUCKSUBROUTINE                    
SHOWFLYINGDUCK:
          
        *-----------------------------------------------------------------------------------------------------------------------------------------------------
        move.l  d7,d0                                    ;Make a copy of the current time
        
        *Checking if the Duck flap sound needs to be played
        lea     FlapSoundTime,a2
        sub.l   (a2),d0                                  ;Subtract the current time with the previous played time
        cmpi.l  #DUCK_FLAP_SOUND_INTERNAL,d0             ;Check if sufficient time has passed to play the duck flap sound
        blt     SKIPFLAPSOUND        
        move.l  d7,(a2)                                  ;Load the current time to FlapSoundTime
        
        *Playing Duck flap sound
        move.l  a1,-(sp)                                 ;Store duck movement data temporarily
        
        lea	    DUCK_FLYING_SOUND,a1
        move.l  #PLAY_SOUND_TRAP_CODE,d0
	    TRAP    #15	    
        
        move.l  (sp)+,a1                                 ;Load back duck movement data
        *-----------------------------------------------------------------------------------------------------------------------------------------------------        
SKIPFLAPSOUND:
       
        *-----------------------------------------------------------------------------------------------------------------------------------------------------
        *Checking if the Duck quack sound needs to be played
        lea     DuckQuackLoopCount,a2
        addi.l  #1,(a2)                                 ;Increment the loop counter or index and check if the quack sound needs to be played.
        cmpi.l  #DUCK_QUACK_LOOPCOUNT,(a2)              ;If the index matches, then play the sound
        bne     SKIPQUACKSOUND                          ;Or else don't play the sound
        
        *Play the quack sound alternatively when the index reaches from 0 to DUCK_QUACK_LOOPCOUNT
        *Or index reaches from DUCK_QUACK_LOOPCOUNT/2 to DUCK_QUACK_LOOPCOUNT
        move.b  DuckQuackAlternate,d0
        beq     .STARTINTERVAL
        move.l  #DUCK_QUACK_LOOPCOUNT/2,(a2)            ;Initialize the index to DUCK_QUACK_LOOPCOUNT/2. Next sound is played when the index reaches to DUCK_QUACK_LOOPCOUNT                                                        
        move.b  #0,DuckQuackAlternate                    
        bra.s   .PLAYQUACK       
.STARTINTERVAL 
        move.b  #1,DuckQuackAlternate 
        move.l  #0,(a2)                                 ;Initialize the index to 0. Next sound is played when the index reaches to DUCK_QUACK_LOOPCOUNT

.PLAYQUACK      
        *Playing the Duck Quack sound
        move.l  a1,-(sp)                                ;Store duck movement data temporarily
        
        lea	    DuckQuack_Sound,a1
        move.l  #PLAY_SOUND_TRAP_CODE,d0
	    TRAP    #15	    
        
        move.l  (sp)+,a1                       
        *-----------------------------------------------------------------------------------------------------------------------------------------------------        
        
SKIPQUACKSOUND:            
        move.l  DUCK_VELOCITY,d0                         ;Load the duck velocity to d0
        
        *Display the duck               
        cmp.l   #IS_DUCK_INCREMENT,(a1)+                 ;Check if the velocity needs to be added to the X co-ordinate
        bne     NOADDXVELOCITY
        add.l   d0,d3                                    ;If yes, then ADD the velocity to X co-ordinate(The bird will fly towards right)
        bra     NOSUBTRACTXVELOCITY
NOADDXVELOCITY:        
        cmp.l   #IS_DUCK_DECREMENT,-4(a1)                ;Check if the velocity needs to be subtracted to the X co-ordinate
        bne     NOSUBTRACTXVELOCITY                      
        sub.l   d0,d3                                    ;If yes, then SUBTRACT the velocity to X co-ordinate(The bird will fly towards left)
NOSUBTRACTXVELOCITY:        
        cmp.l   #IS_DUCK_INCREMENT,(a1)+                 ;Check if the velocity needs to be subtracted to the Y co-ordinate
        bne     NOSUBTRACTYVELOCITY
        sub.l   d0,d4                                    ;If yes, then SUBTRACT the velocity to the Y co-ordinate(The bird will fly upwards)
        bra     NOADDYVELOCITY      
NOSUBTRACTYVELOCITY:
        cmp.l   #IS_DUCK_DECREMENT,-4(a1)                ;Check if the +velocity needs to be added to the Y co-ordinate
        bne     NOADDYVELOCITY
        add.l   d0,d4                                    ;If yes, then ADD the velocity to the Y co-ordinate(The bird will fly downwards)
        bra     NOADDYVELOCITY  
NOADDYVELOCITY:
        
        cmpi.l  #CROSSHAIR_MAX_TOP,d4                   ;Check if the Duck's Y co-ordinate has reached the top of the screen
        ble     CHECKLIVES                              ;If yes, then check for lives and reload the duck                                

        move.l  (a1)+,CurrentDuckSpriteX                ;X offset of the sprite image
        move.l  (a1)+,CurrentDuckSpriteY                ;Y offset of the sprite image                       

        ;Draw the Duck and Crosshair here
        jsr     DisplayCrossHair                        ;Display the Crosshair
                                                        ;Drawing cross hair because we always want the Crosshair on top of the duck
                                        
        *This code is used for keeping the game running, in case the duck moves out of the screen.
        *Ideally the following compare shouldn't succeed
        lea     MAX_PATH_BEFOREFLY,a6
        sub.l   #1,(a6)        
        cmp.l   #0,(a6)
        bne     EXITDUCKSUBROUTINE
CHECKLIVES:       
        lea     LIVES_LEFT,a6                           ;Load the remaining lives into a address register
        cmpi.l  #0,(a6)                                 ;Check if all the lives all over
        beq     ENDGAME                                 ;If yes, then exit the game
        subi.l  #1,(a6)                                 ;If not, then subtract a life and reload the duck
        
        *---------------------------------------------------------------------------------------------------------------------
        *Draw the Lives
        movem.l REGISTERS_7SEGMENT_LED,-(sp)            ;Save the registers
        
        move.l  (a6),d6                                 ;Move the lives left to a data register
        move.l  #LIVES_POSITION_X,Number_Position_X
        move.l  #LIVES_POSITION_Y,Number_Position_Y
        jsr     Display7Segment
        
        movem.l (sp)+,REGISTERS_7SEGMENT_LED            ;Load back the registers
        *---------------------------------------------------------------------------------------------------------------------  
        jsr     DisplayFromBuffer
        
RELOADDUCK:        
        jsr     LoadDuckMovementData                    ;Reload the duck        
        move.b  #0,ISDUCKDEAD                           ;Set Duck dead to false                                      
EXITDUCKSUBROUTINE:   
        rts


DisplayDeadDuck                      
        move.l  d3,d1                                   ;Move the X co-ordinate to d1
        move.l  d4,d2                                   ;Move the Y co-ordinate to d2
        
        lsr.l   #FRAC_BITS,d1                           ;Shift out from 2e-8 land
        lsr.l   #FRAC_BITS,d2                           ;Shift out from 2e-8 land
                        
        *--------------------------------------------------------------------------------------------------------------------------------------
        ;Draw the dead duck
        movem.l REGISTERS_DRAW_BITMAP,-(sp)             ;Save the registers
        
        lea     SpriteImageData,a5
        lea     SpriteImage,a0
        
        *Pass the arguements using stack
        move.l  #DUCK_HEIGHT,-(sp)
        move.l  #DUCK_WIDTH,-(sp)        
        move.l  CurrentDuckSpriteX,-(sp)                ;X offset of the sprite image
        move.l  CurrentDuckSpriteY,-(sp)                ;Y offset of the sprite image                       
        move.l  d1,-(sp)                                ;X co-ordinate on the screen
        move.l  d2,-(sp)                                ;Y co-ordinate on the screen
                       
        jsr DisplayImage
        add.l   #SIZEOF_DISPLAYIMAGE_PARAMS,sp          ;Add the parameter size to the stack pointer to point it back to the initial position
                    
        movem.l (sp)+,REGISTERS_DRAW_BITMAP             ;Reload the registers
        *--------------------------------------------------------------------------------------------------------------------------------------        
                                     
        rts


DisplayFlyingDuck
        move.l  d3,d1                                   ;Move the X co-ordinate to d1
        move.l  d4,d2                                   ;Move the Y co-ordinate to d2
        
        lsr.l   #FRAC_BITS,d1                           ;Shift out from 2e-8 land
        lsr.l   #FRAC_BITS,d2                           ;Shift out from 2e-8 land

        *--------------------------------------------------------------------------------------------------------------------------------------
        ;Draw the duck
        movem.l REGISTERS_DRAW_BITMAP,-(sp)             ;Save the registers
        
        lea     SpriteImageData,a5
        lea     SpriteImage,a0
        
        *Pass the arguements using stack
        move.l  #DUCK_HEIGHT,-(sp)
        move.l  #DUCK_WIDTH,-(sp)        
        move.l  CurrentDuckSpriteX,-(sp)                ;X offset of the sprite image
        move.l  CurrentDuckSpriteY,-(sp)                ;Y offset of the sprite image                       
        move.l  d1,-(sp)                                ;X co-ordinate on the screen
        move.l  d2,-(sp)                                ;Y co-ordinate on the screen
                       
        jsr DisplayImage
        add.l   #SIZEOF_DISPLAYIMAGE_PARAMS,sp          ;Add the parameter size to the stack pointer to point it back to the initial position
                    
        movem.l (sp)+,REGISTERS_DRAW_BITMAP             ;Reload the registers
        *--------------------------------------------------------------------------------------------------------------------------------------    
        rts

*Shot duck -> The duck sprite which has it's mouth wide open and the eyes are popped out
UpdateDeadDuckSprites
        *Check if the shot duck still needs to be displayed
        lea     ShotDuckLoopCount,a6
        cmpi.l  #SHOW_DEAD_DUCK_LOOPCOUNT,(a6)          ;Compare with the shot duck count and check if it still needs to be displayed
        beq     .LOADSPRITE                             ;If not, then load the next sprite image
        addi.l  #1,(a6)                                 ;Increment the shot duck loop count
        cmpi.l  #SHOW_DEAD_DUCK_LOOPCOUNT,(a6)
        bne     .EXIT        
        move.l  #DEADDUCK_OFFSET_X,CurrentDuckSpriteX   
        bra     .EXIT

.LOADSPRITE
        addi.l  #GRAVITY,d4                             ;Add the gravity for the falling duck
        
        lea     CurrentDuckSpriteX,a6
        lea     DeadDuckSprites,a5                      ;Sprite index
        
        *We have only 2 sprites for Death animation
        cmpi.l  #DEAD_DUCK_SPRITES,(a5)                 ;Check if the index has reached the last sprite               
        bne     .NEXTSPRITE                             ;If not then load the next sprite
        move.l  #DEADDUCK_OFFSET_X,(a6)                 ;If yes, then reload the sprite
        move.l  #1,(a5)                                 ;And reset the index
        bra     .EXIT
.NEXTSPRITE
        addi.l  #DUCK_SPRITE_WIDTH,(a6)
        addi.l  #1,(a5)
.EXIT
        rts


ExitGame:
        *-------------------------------------------------------------------------------------------------------------------------- 
        *Play GameOver Sound
        lea	    GameOver_Sound,a1
        move.l  #PLAY_SOUND_TRAP_CODE,d0
	    TRAP    #15

   
        *Draw GameOver Image      
        movem.l REGISTERS_DRAW_BITMAP,-(sp)             ;Save the registers
        
        lea     GameOverImageData,a5                  
        lea     GameOverImage,a0
              
        *Pass the arguements using stack
        move.l  #GAMEOVER_HEIGHT,-(sp)
        move.l  #GAMEOVER_WIDTH,-(sp)        
        move.l  #0,-(sp)                                        ;X offset of the image
        move.l  #0,-(sp)                                        ;Y offset of the image
        move.l  #(SCREEN_WIDTH/2)-(GAMEOVER_WIDTH/2),-(sp)      ;X co-ordinate on the screen
        move.l  #(SCREEN_HEIGHT/2)-GAMEOVER_WIDTH,-(sp)         ;Y co-ordinate on the screen
                       
        jsr     DisplayImage
        add.l   #SIZEOF_DISPLAYIMAGE_PARAMS,sp          ;Add the parameter size to the stack pointer to point it back to the initial position
                    
        movem.l (sp)+,REGISTERS_DRAW_BITMAP             ;Reload the registers
        *--------------------------------------------------------------------------------------------------------------------------

        rts  
     
          
DrawBitmap          INClUDE     "Subroutines/BitmapAsSubroutineNoPadding.X68"
RandomNumbers       INClUDE     "Subroutines/RandomNumbers.X68"
PlayerMovement      INClUDE     "Subroutines/PlayerMovement.X68"
PlayerShot          INClUDE     "Subroutines/PlayerShot.X68"
InitializeGame      INClUDE     "Subroutines/InitializeGame.X68"
DuckMovementData    INCLUDE     "Subroutines/DuckMovementData.X68"
NumberDisplay       INCLUDE     "Subroutines/7SegmentLED.X68"
MenuScreenImage     INCBIN      "Images/MenuScreen.bmp"
BackgroundImage     INCBIN      "Images/Background.bmp"
CrossHairImage      INCBIN      "Images/Crosshair.bmp"
SpriteImage         INCBIN      "Images/SpriteImage.bmp"
GameOverImage       INCBIN      "Images/GameOver.bmp"
DuckQuackAlternate  dc.b        0
DuckQuackLoopCount  ds.l        1
ShotDuckLoopCount   ds.l        1
FlapSoundTime       ds.l        1
Have_Had_No_Input   ds.b        1
Max_Path_BeforeFly  ds.l        1
Total_Duck_Movement ds.l        1
Random_Value        ds.l        1
Duck_Velocity       ds.l        1
Score               dc.l        0
IsDuckDead          dc.b        0
Velocity_Increment  dc.l        10
Shots_Left          ds.l        1
Lives_Left          ds.l        1
Number_Position_X   ds.l        1
Number_Position_Y   ds.l        1
CurrentDuckSpriteX  ds.l        1
CurrentDuckSpriteY  ds.l        1
DeadDuckSprites     ds.l        1
Duck_Flying_Sound   dc.b        'Audio/DuckFlyingSound.wav',0
Explosion_Sound     dc.b        'Audio/ExplosionSound.wav',0
GameOver_Sound      dc.b        'Audio/GameOverSound.wav',0
DuckHitGround_Sound dc.b        'Audio/DuckHitGroundSound.wav',0
MenuScreen_Sound    dc.b        'Audio/MenuScreenSound.wav',0
DuckFalling_Sound   dc.b        'Audio/DuckFallingSound.wav',0
DuckQuack_Sound     dc.b        'Audio/DuckQuackSound.wav',0
LoadingText         dc.b        'Loading...',0
    END    START                                        ;Last line of source code








































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
