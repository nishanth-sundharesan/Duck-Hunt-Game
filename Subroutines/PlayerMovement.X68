*------------------------------------------------------------------------------------
* Title      : Handle Player Movement
* Written by : Nishanth Sundharesan
* Date       : 6-October-2016
* Description: This subroutine is used to accept the key input and move the crosshair
*------------------------------------------------------------------------------------

HandlePlayerInput             
        move.l  #KEY_RIGHT_ARROW,d1
        move.l  #KEY_INPUT_TRAP_CODE,d0
        TRAP    #15
        andi.l  #$FF,d1                                 ;Check for key press. $FF = Key pressed. $00 = Key not pressed
        beq     CHECK_LEFT_KEY_INPUT                    ;If Right arrow key is not pressed, then check for Left arrow key
        jsr     CoverCrossHairImage
        addi.l  #CROSSHAIR_VELOCITY,d5                  ;Increment the X co-ordinate        
        
        cmpi.l  #CROSSHAIR_MAX_RIGHT,d5                 ;Check if the Crosshair's X co-ordinate has reached it's max position
        ble     SKIPMAXRIGHT                            ;If not, then skip it
        move.l  #CROSSHAIR_MAX_RIGHT,d5                 ;If yes, then move the Crosshair's max X co-ordinate(which is ScreenWidth-CrosshairWidth in Hex) to the X position of Crosshair and display it
SKIPMAXRIGHT:        
        jsr     DisplayCrossHair                        ;Display the Crosshair
        
CHECK_LEFT_KEY_INPUT:
        move.l  #KEY_LEFT_ARROW,d1
        move.l  #KEY_INPUT_TRAP_CODE,d0
        TRAP    #15
        andi.l  #$FF,d1                                 ;Check for key press. $FF = Key pressed. $00 = Key not pressed
        beq     CHECK_UP_KEY_INPUT                      ;If Left arrow key is not pressed, then check for Up arrow key
        jsr     CoverCrossHairImage
        subi.l  #CROSSHAIR_VELOCITY,d5                  ;Decrement the X co-ordinate        
        
        cmpi.l  #CROSSHAIR_MAX_LEFT,d5                  ;Check if the Crosshair's X co-ordinate has reached the left side of the screen
        bge     SKIPMAXLEFT                             ;If not, then skip it
        move.l  #CROSSHAIR_MAX_LEFT,d5                  ;If yes, then move the Screen's beginning left X co-ordinate(which is 0) to the X position of Crosshair and display it
SKIPMAXLEFT:         
        jsr     DisplayCrossHair                        ;Display the Crosshair

        
CHECK_UP_KEY_INPUT:        
        move.l  #KEY_UP_ARROW,d1
        move.l  #KEY_INPUT_TRAP_CODE,d0
        TRAP    #15
        andi.l  #$FF,d1                                 ;Check for key press. $FF = Key pressed. $00 = Key not pressed
        beq     CHECK_DOWN_KEY_INPUT                    ;If Up arrow key is not pressed, then check for Down arrow key
        jsr     CoverCrossHairImage
        subi.l  #CROSSHAIR_VELOCITY,d6                  ;Decrement the Y co-ordinate
                
        cmpi.l  #CROSSHAIR_MAX_TOP,d6                   ;Check if the Crosshair's Y co-ordinate has reached the top of the screen
        bge     SKIPMAXUP                               ;If not, then skip it
        move.l  #CROSSHAIR_MAX_TOP,d6                   ;If yes, then move the Screen's top Y co-ordinate(which is 0) to the Y position of Crosshair and display it
SKIPMAXUP:        
        jsr     DisplayCrossHair                        ;Display the Crosshair


CHECK_DOWN_KEY_INPUT:        
        move.l  #KEY_DOWN_ARROW,d1
        move.l  #KEY_INPUT_TRAP_CODE,d0
        TRAP    #15
        andi.l  #$FF,d1                                 ;Check for key press. $FF = Key pressed. $00 = Key not pressed
        beq     EXITPLAYERINPUT                         ;If Down arrow key is not pressed, then exit the subroutine
        jsr     CoverCrossHairImage
        addi.l  #CROSSHAIR_VELOCITY,d6                  ;Increment the Y co-ordinate
        
        cmpi.l  #CROSSHAIR_MAX_DOWM,d6                  ;Check if the Crosshair's Y co-ordinate has reached the bottom of the screen
        ble     SKIPMAXDOWN                             ;If not, then skip it
        move.l  #CROSSHAIR_MAX_DOWM,d6                  ;If yes, then move the Crosshair's max Y co-ordinate(which is ScreenHeight-CrosshairHeight in Hex) to the Y position of Crosshair and display it
SKIPMAXDOWN:                
        jsr     DisplayCrossHair                        ;Display the Crosshair

EXITPLAYERINPUT:
        rts

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
