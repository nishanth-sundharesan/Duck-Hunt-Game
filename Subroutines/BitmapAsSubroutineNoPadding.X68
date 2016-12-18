*-----------------------------------------------------------
* Title      : Bitmap as Subroutine
* Written by : Nishanth Sundharesan
* Date       : 05-October-2016
* Description: This program displays a chunk of a 256 color .bmp on the screen by calling a subroutine.
*-----------------------------------------------------------
*----------------------------------------------------
*Parameters used in the subroutine
*----------------------------------------------------
PARAM_BITMAP_CHUNK_HEIGHT           EQU     24
PARAM_BITMAP_CHUNK_WIDTH            EQU     20
PARAM_BITMAP_CHUNK_TOPLEFT_X        EQU     16
PARAM_BITMAP_CHUNK_TOPLEFT_Y        EQU     12
PARAM_SCREEN_LOCATION_TOPLEFT_X     EQU     8
PARAM_SCREEN_LOCATION_TOPLEFT_Y     EQU     4
*----------------------------------------------------
*Constant values
*----------------------------------------------------
FILE_OFFSET_TO_PIXELARRAY_BYTES   EQU     10
TRANSPARENT_REPLACEMENT_COLOR     EQU     $0080E0E0                     ;Yellow color will act as transparent color
*----------------------------------------------------
*Trap codes
*----------------------------------------------------
PEN_COLOR_TRAP_CODE       EQU     80
DRAW_PIXEL_TRAP_CODE      EQU     82
*----------------------------------------------------
LoadImageData
        *Let's point the address register to the pixel array in the bmp image
        move.l  a0,a1
        adda    #FILE_OFFSET_TO_PIXELARRAY_BYTES,a0         ;Add the static file offset to reach the pixel array       
        move.l  (a0)+,d7                                    ;Move the offset address of the pixel array and increment the address register
        jsr     LittleToBigEndianLong                       ;Call the subroutine to convert the offset from Little Endian format to Big Endian format
        add.l   d7,a1                                       ;Add the offset to the current address.
                                                            ;a1 now holds the address to the pixel array
                                                            
        move.l  a1,(a5)+                                    ;Store the address of the pixel array
        
        *a0 now points to the address where DIB's header size is placed
        move.l  a0,a2
        move.l  (a0)+,d7                                    ;Move the DIB's header size and increment the address register
        jsr     LittleToBigEndianLong                       ;Call the subroutine to convert the size from Little Endian format to Big Endian format
                                                            ;d7 now holds the size of the DIB header                                   
        add.l   d7,a2                                       ;Add the DIB header size to the current offset.
                                                            ;a2 will now hold the address to the color table
                                                            
        move.l  a2,(a5)+                                    ;Store the address of the color table
        
        *a0 now points to the image's width
        move.l  (a0)+,d7                                    ;Move the width of the image and increment the address register
        jsr     LittleToBigEndianLong                       ;Call the subroutine to convert the image width from Little Endian format to Big Endian format
        move.l  d7,d5                                       ;d5 now holds the width of the image
        
        move.l  d5,(a5)+                                    ;Store the width of the image

        
        *a0 now points to the image's height
        move.l  (a0),d7                                     ;Move the height of the image
        jsr     LittleToBigEndianLong                       ;Call the subroutine to convert the image height from Little Endian format to Big Endian format
        move.l  d7,d3                                       ;d3 now holds the height of the image
        
        move.l  d3,(a5)+                                    ;Store the height of the image
                                    
        rts

*This subroutine converts a long from Little Endian format to Big Endian format(68000). It uses d7 register. 
LittleToBigEndianLong
        ror.w   #$8,d7                  ;Rotate the word by 8 bits(less significant 16 bits)
        swap    d7                      ;Swap higer word to lower word
        ror.w   #$8,d7                  ;Rotate the word by 8 bits(less significant 16 bits)
        rts                             ;Return from subroutine

*This subroutine displays the chunk of the 256 color bitmap image.
DisplayImage
        move.l  (a5)+,a1                                        ;Load the address of the pixel array
        move.l  (a5)+,a2                                        ;Load the address of the color table
        move.l  (a5)+,d5                                        ;Load the width of the image
        move.l  (a5)+,d3                                        ;Load the height of the image
                                                                                                                           

        move.l  PARAM_SCREEN_LOCATION_TOPLEFT_Y(sp),d2          
        add.l   PARAM_BITMAP_CHUNK_HEIGHT(sp),d2                ;Y screen coordinate now points to the bottom left corner of the chunk image
        
                
        *Let's move the address of the pixel array to the bottom left corner of the chunk image        
        *Moving the Y offset
        move.l  #0,d6                                               ;Use data register as a loop counter
        move.l  d3,d7                                               ;Move the height of the image
        sub.l   PARAM_BITMAP_CHUNK_TOPLEFT_Y(sp),d7                 ;Subtract the chunk's Y offset
        sub.l   PARAM_BITMAP_CHUNK_HEIGHT(sp),d7                    ;Subtract the chunk height
         
        cmp.l   d7,d6                                               ;If the height of the chunk image if greater than or equal to the image, then don't loop
        bge     DontLoop 
         
        *We will now get the number of times to increment the Y offset
LoopBack:
        add.l   d5,a1                                               ;Add the width of the image to the address of the pixel arrray
        addi.l  #1,d6                                               ;Increment the loop counter
        cmp.l   d7,d6                                               ;Check if the loop counter has reached the Y offset, if not then loop back
        bne     LoopBAck

DontLoop:       
        *Moving the X offset        
        add.l  PARAM_BITMAP_CHUNK_TOPLEFT_X(sp),a1                  ;For moving the X offset just add the chunk image's X position     
  
        *Calculating the width of the chunk to be drawn with respect to screen co-ordinates                                 
        move.l  PARAM_SCREEN_LOCATION_TOPLEFT_X(sp),d4              ;Move the Screen's X co-ordinate
        add.l   PARAM_BITMAP_CHUNK_WIDTH(sp),d4                     ;Add the chunk image's width. d4 will now point to the width of the image to be drawn from the 0th position of screen
                                                                    
        
        *Calculating the remaining width of the image that has be incremented after drawing each row of pixels
        lea     RemainingWidthOfBMP,a4
        move.l  d5,(a4)                                             ;Move the width of the image
        move.l  PARAM_BITMAP_CHUNK_WIDTH(sp),d6                     ;Move the chunk image's width
        sub.l   d6,(a4)                                             ;Subtract the chunk image's width
        move.l  PARAM_BITMAP_CHUNK_TOPLEFT_X(sp),d6                 ;Move the chunk's X offset
        sub.l   d6,(a4)                                             ;Subtract the chunk's X offset. a4 will now point to the remaining width of the image
    
        clr.l   d6

        *Drawing of the pixels starts here
DrawEachRow:
        move.l  PARAM_SCREEN_LOCATION_TOPLEFT_X(sp),d7              ;d7 will contain the X corordinate of the screen             
          
DrawEachPixel:
        clr.w   d6
        
        move.b  (a1)+,d6                                    ;Load the offset address of the color table and increment the address register
        lsl.l   #$02,d6                                     ;Multiple the offset address by 4 because each color on color table is 4 bytes long
        move.l  (a2,d6),d1                                  ;Load the color of the pixel to data register. The color has to be in d1 register
        lsr.l   #$8,d1                                      ;Shift out the least significant byte because this byte is added for padding
                                                            ;Set the pen color. We now have the color of the pixel in BGR format
        cmp.l   #TRANSPARENT_REPLACEMENT_COLOR,d1
        beq     JumpTransparent                                      
                          
        move.l  #PEN_COLOR_TRAP_CODE, d0                    ;Set the proper trap code to set the pen color
        trap    #15                                         ;Pen color is now set
        
        
        *Draw the pixel on the X,Y co-ordinate
        move.l  d7,d1                                        ;X co-ordinate should be kept in d1 register
                                                             ;Y co-ordinate should be kept in d2 register
        move.l  #DRAW_PIXEL_TRAP_CODE,d0                     ;Set the proper trap code to draw the pixel using the set pen color
        trap    #15

JumpTransparent:        
       *Increment the X co-ordinate
        addi.w    #1,d7

        cmp.w   d4,d7                                      ;Check if the chunk width has been reached, if not continue drawing with the same row
        bne     DrawEachPixel
        
        
        *Increment the pixel array by the remaining width of the image
        add.l   (a4),a1
        
       *Pixel array is now pointing to the beginning of the new row of the image
        
        *Add the X offset to draw pixels in the new row
        add.l  PARAM_BITMAP_CHUNK_TOPLEFT_X(sp),a1
        
        *Decrement the Y co-ordinate
        subi.w  #1,d2

        cmp.l   PARAM_SCREEN_LOCATION_TOPLEFT_Y(sp),d2      ;Check if the Y co-ordinate has reached the top most row of the image, if not draw another row.
        bne     DrawEachRow
                
        rts
  
RemainingWidthOfBMP     ds.l    1
CrossHairImageData      ds.l    4
BackgroundImageData     ds.l    4
SpriteImageData         ds.l    4
GameOverImageData       ds.l    4 
MenuScreenImageData     ds.l    4









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
