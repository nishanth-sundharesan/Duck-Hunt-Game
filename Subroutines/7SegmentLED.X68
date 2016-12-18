*---------------------------------------------------------------------------------------------
* Title      : 7 Segment display for numbers
* Written by : Nishanth Sundharesan
* Date       : 10-October-2016
* Description: This program takes a number as an input and draws each digit as a 7 Segment LED
*              It draws a maximum of 3 digits
*----------------------------------------------------------------------------------------------
*----------------------------------------------------
*Trap codes
*----------------------------------------------------
CLEAR_SCREEN_TRAP_CODE      EQU     11
PEN_WIDTH_TRAP_CODE         EQU     93
MOVE_GRAPHICS_XY_TRAP_CODE  EQU     86
DRAW_LINE_TRAP_CODE         EQU     85
*----------------------------------------------------
*Constant values
*----------------------------------------------------
LED_OFFSET                  EQU     2
LED_SIZE                    EQU     8
SEGMENT7                    EQU     7
DIGIT_PEN_WIDTH             EQU     3
DEFAULT_PEN_WIDTH           EQU     1
DIGIT_WIDTH                 EQU     LED_SIZE+LED_OFFSET+4
NUMBER_OF_DIGITS            EQU     3
BLACK_COLOR                 EQU     $00000000
*----------------------------------------------------

Display7Segment
        
    *Load the X and Y position of the score
    lea     Number_Position_X,a3
    lea     Number_Position_Y,a4
    
    *---------------------------------------------------------------------------------------------------------------------------
    ;Set the pen width
    move.l  #DIGIT_PEN_WIDTH,d1                 
    move.l  #PEN_WIDTH_TRAP_CODE,d0 
    TRAP    #15

    *Setting the color for the mask rectangle
    move.l  #BLACK_COLOR,d1                    ;Set the pen and fill color to black        
    move.l  #PEN_COLOR_TRAP_CODE,d0            ;Set the pen color
    TRAP    #15        
    move.l  #FILL_COLOR_TRAP_CODE,d0           ;Set the fill color
    TRAP    #15
    
    
    *Let's mask out the previously drawn numbers            
    move.l  (a3),d1                     ;Left top X co-ordinate
   
    move.l  (a4),d2                     ;Left top Y co-ordinate
    
    move.l  (a3),d3
    move.l  #DIGIT_WIDTH,d7
    mulu.w  #(NUMBER_OF_DIGITS),d7
    add.l   d7,d3                       ;Right bottom X co-ordinate

    move.l  (a4),d4                     ;Right bottom Y co-ordinate
    add.l   #LED_SIZE,d4
    add.l   #LED_SIZE,d4
           
    move.l  #DRAW_FILLED_RECTANGLE,d0   ;Draw filled rectangle
    TRAP    #15        
    *---------------------------------------------------------------------------------------------------------------------------
           
    move.l  #(NUMBER_OF_DIGITS-1),d4    ;Digit counter(In our case, 3 digits)
    
    ;Set the pen color
    move.l  #WHITE_COLOR,d1
    move.l  #PEN_COLOR_TRAP_CODE,d0
    TRAP    #15
          
PRINTNEXTDIGIT:
    divu.w  #10,d6                      ;Divide the score by 10 to get the least significant digit or remainder
    swap    d6                          ;Swap the register to get the remainder which is in the higher word
    move.w  d6,d0                       ;Move the remainder, which is the digit that will be drawn
    swap    d6                          ;Swap back the register to get the remaining digits
    ext.l   d6                          ;Extend the register to get rid of the remainder which is stored in the higher word
    
    move.l  #DIGIT_WIDTH,d7             ;Load the digit width
    mulu.w  d4,d7                       ;Multiply it with the counter to get the offset X position where the digit is to be drawn
    
    lea     DigitTable,a6               ;Load the DigitTable
    add.l   d0,a6                       ;Add the offset
                                        ;a6 now points to the appropriate digit to be drawn
       
    move.l  #0,d5                       ;Load the initial offset to 0
    move.b  (a6),d3                     ;Load the digit data
    
CHECKNEXTBIT:    
    lsr.l   #1,d3                       ;Left shift and check if it's 1 or a carry flag is set
    bcs     DrawLine                    ;If the carry flag is set then draw the 7segment line

INCREMENTBITCOUNTER:    
    addi.l  #1,d5                       ;Counter to check the 7 bits, which also acts as an offset
    cmpi.l  #SEGMENT7,d5                ;Check if we have drawn all the segments
    bne     CHECKNEXTBIT                ;If not, then draw the next segment
    dbra    d4,PRINTNEXTDIGIT           ;Subtract the loop counter by 1 and check if it has reached -1, if not then branch it

    bra     ESCAPE7SEGMENT              

DrawLine:
    lsl.l   #2,d5                       ;Let's use this counter as an offset. Multiply it by 4 as the data is stored in long words
    
    lea     Led_Start_X1,a5             ;Load the X co-ordinate of the line start    
    add.l   d5,a5                       ;Add the offset to fetch the data of the appropriate segment in 7 segments        
    move.l  (a5),d1                     ;Load X1 into data register
    add.l   (a3),d1                     ;Add the X position
    add.l   d7,d1                       ;Add the digit's position(this changes for each digit)
    
    lea     Led_Start_Y1,a5             ;Load the Y co-ordinate of the line start
    add.l   d5,a5                       ;Add the offset to fetch the data of the appropriate segment in 7 segments 
    move.l  (a5),d2                     ;Load Y1 into data register
    add.l   (a4),d2                     ;Add the Y position
    
    move.l  #MOVE_GRAPHICS_XY_TRAP_CODE,d0  ;This trap code is used to move the drawing point.
    TRAP    #15
    
    
    lea     Led_End_X2,a5               ;Load the X co-ordinate of the line end
    add.l   d5,a5                       ;Add the offset to fetch the data of the appropriate segment in 7 segments        
    move.l  (a5),d1                     ;Load X1 into data register
    add.l   (a3),d1                     ;Add the X position
    add.l   d7,d1                       ;Add the digit's position(this changes for each digit)

    
    lea     Led_End_Y2,a5               ;Load the Y co-ordinate of the line end
    add.l   d5,a5                       ;Add the offset to fetch the data of the appropriate segment in 7 segments        
    move.l  (a5),d2                     ;Load X1 into data register
    add.l   (a4),d2                     ;Add the Y position



    move.l  #DRAW_LINE_TRAP_CODE,d0     ;This trap code draws the line from the drawing point to the set point.
    TRAP    #15

    lsr.l   #2,d5                       ;Divide it by 4 to get back our counter

    bra     INCREMENTBITCOUNTER

ESCAPE7SEGMENT:       
    ;Set the default pen width
    move.l  #DEFAULT_PEN_WIDTH,d1                 
    move.l  #PEN_WIDTH_TRAP_CODE,d0 
    TRAP    #15

    rts
   
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 7 SEGMENT LED
*
*X1 = X co-ordinate of the line start
*Y1 = Y co-ordinate of the line start
*X2 = X co-ordinate of the line end
*Y2 = Y co-ordinate of the line end
*
*    a  
*    __
* f |g | b 
*    --
* e |  | c
*    --
*    d
*--------------------------------a----------------------b----------------------c------------------------------d-----------------------e--------------------------------f------------------g----------------
Led_Start_X1    dc.l    LED_OFFSET,                LED_SIZE,            LED_SIZE,                       LED_OFFSET,            0,                               0,                      LED_OFFSET
Led_Start_Y1    dc.l    0,                         LED_OFFSET,          LED_SIZE+LED_OFFSET,            LED_SIZE+LED_SIZE,     LED_SIZE+LED_OFFSET,             LED_OFFSET,             LED_SIZE
Led_End_X2      dc.l    LED_SIZE-LED_OFFSET,       LED_SIZE,            LED_SIZE,                       LED_SIZE-LED_OFFSET,   0,                               0,                      LED_SIZE-LED_OFFSET
Led_End_Y2      dc.l    0,                         LED_SIZE-LED_OFFSET, LED_SIZE+LED_SIZE-LED_OFFSET,   LED_SIZE+LED_SIZE,     LED_SIZE+LED_SIZE-LED_OFFSET,    LED_SIZE-LED_OFFSET,    LED_SIZE
*--------------------------------a----------------------b----------------------c------------------------------d-----------------------e--------------------------------f------------------g-----------------
DigitTable      dc.b    $3F,$06,$5B,$4F,$66,$6D,$7D,$07,$7F,$67











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
