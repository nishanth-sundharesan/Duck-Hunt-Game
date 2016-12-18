*---------------------------------------------------------------------------------------
* Title      : Level design files
* Written by : Nishanth Sundharesan
* Date       : 9-October-2016
* Description: This file contains all the inclusions of the duck movement path files.
*              The duck spawns from the left, middle or from the right. For each spawn
*              position, there are 8 different types of path that a duck takes. Once the
*              velocity varies, the same path file will give the illusion that the duck
*              is taking a different path.
*---------------------------------------------------------------------------------------
DuckMovementAIFromLeft1      INCBIN      "DesignFiles/DuckMovementAIFromLeft1.dat"
LengthOfDataFile:           
DuckMovementAIFromLeft2      INCBIN      "DesignFiles/DuckMovementAIFromLeft2.dat"
DuckMovementAIFromLeft3      INCBIN      "DesignFiles/DuckMovementAIFromLeft3.dat"
DuckMovementAIFromLeft4      INCBIN      "DesignFiles/DuckMovementAIFromLeft4.dat"
DuckMovementAIFromLeft5      INCBIN      "DesignFiles/DuckMovementAIFromLeft5.dat"
DuckMovementAIFromLeft6      INCBIN      "DesignFiles/DuckMovementAIFromLeft6.dat"
DuckMovementAIFromLeft7      INCBIN      "DesignFiles/DuckMovementAIFromLeft7.dat"
DuckMovementAIFromLeft8      INCBIN      "DesignFiles/DuckMovementAIFromLeft8.dat"

DuckMovementAIFromMiddle1    INCBIN      "DesignFiles/DuckMovementAIFromMiddle1.dat"
DuckMovementAIFromMiddle2    INCBIN      "DesignFiles/DuckMovementAIFromMiddle2.dat"
DuckMovementAIFromMiddle3    INCBIN      "DesignFiles/DuckMovementAIFromMiddle3.dat"
DuckMovementAIFromMiddle4    INCBIN      "DesignFiles/DuckMovementAIFromMiddle4.dat"
DuckMovementAIFromMiddle5    INCBIN      "DesignFiles/DuckMovementAIFromMiddle5.dat"
DuckMovementAIFromMiddle6    INCBIN      "DesignFiles/DuckMovementAIFromMiddle6.dat"
DuckMovementAIFromMiddle7    INCBIN      "DesignFiles/DuckMovementAIFromMiddle7.dat"
DuckMovementAIFromMiddle8    INCBIN      "DesignFiles/DuckMovementAIFromMiddle8.dat"

DuckMovementAIFromRight1     INCBIN      "DesignFiles/DuckMovementAIFromRight1.dat"
DuckMovementAIFromRight2     INCBIN      "DesignFiles/DuckMovementAIFromRight2.dat"
DuckMovementAIFromRight3     INCBIN      "DesignFiles/DuckMovementAIFromRight3.dat"
DuckMovementAIFromRight4     INCBIN      "DesignFiles/DuckMovementAIFromRight4.dat"
DuckMovementAIFromRight5     INCBIN      "DesignFiles/DuckMovementAIFromRight5.dat"
DuckMovementAIFromRight6     INCBIN      "DesignFiles/DuckMovementAIFromRight6.dat"
DuckMovementAIFromRight7     INCBIN      "DesignFiles/DuckMovementAIFromRight7.dat"
DuckMovementAIFromRight8     INCBIN      "DesignFiles/DuckMovementAIFromRight8.dat"

*---------------------------------------------------------------------------------------
*Format of the path(design) file:
*First 4 bytes(long) : X position increment
*Second 4 bytes(long): Y position increment
*Third 4 bytes(long) : X position of the sprite
*Fourth 4 bytes(long): Y position of the sprite
*Later on, the format repeats
*---------------------------------------------------------------------------------------


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
