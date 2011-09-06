;******************************************
;                                         *
;  NAME:  DONG DO                         *
;  LAB #2,  7 segment diplay              *
;  COURSE:  EET 484                       *
;                                         *
;  THIS PROGRAM IS WRITTEN TO CHECK SEVEN *
;  DISPLAY AND PLACE ASCII CODE ON SCREEN *
;  FOR KEY PRESSED.                       *
;                                         *
;   Registers used:  A,B,C,D,E,F,H,L      *
;                                         *
;******************************************

;Main program

        .ORG    6500H

LTABLE  .EQU    7000H
TASCII  .EQU    7200H
PAPIO   .EQU    8CH
PBPIO   .EQU    8DH
PCPIO   .EQU    8EH
PORT0   .EQU    00H
PORT1   .EQU    01H

        CALL    SEGTEST
        CALL    CLEAR
        CALL    DISNAME
GO      CALL    GETKEY
        JR      C,GOOD          ;Key is not pressed
        CALL    UPPLAY
        CALL    UPCRT
        CALL    DLETUP
GOOD    CALL    DELAY1
        JP      GO

;************************************************
;                                               *
;The following are the subroutines to support   *
;the main program.                              *
;
;************************************************



;************************************************
;                                               *
;This subroutine will test each segment to see  *
;if they are all working.                       *
;                                               *
;Registers used:  A, B, C, D, E, F              *
;                                               *
;************************************************

SEGTEST  PUSH   AF
         PUSH   BC
         PUSH   DE
         LD     B,11111110B
         LD     C,00
         LD     D,10101010B
LOOP2    OUT    (C),B
         INC    C
         OUT    (C),D
         PUSH   BC
         LD     BC,25H
         CALL   VDELAY          ;Delay 500 ms
         POP    BC
         RLC    D
         OUT    (C),D
         PUSH   BC
         LD     BC,25H
         CALL   VDELAY          ;Delay 500 ms
         POP    BC
         DEC    C
         RLC    B
         JR     C,LOOP2
         POP    DE
         POP    BC
         POP    AF
         RET

;************************************************
;                                               *
;This subroutine will clear screen              *
;                                               *
;Registers used:  A                             *
;                                               *
;************************************************

CLEAR    PUSH   AF
         LD     A,0CH
         RST    10H
         POP    AF
         RET

;************************************************
;                                               *
;This subroutine will place the programmer's    *
;name on the top line of the screen and center  *
;it.                                            *
;                                               *
;Registers used:  B, C, D, E, H, L              *
;                                               *
;************************************************

DISNAME  PUSH   BC
         PUSH   DE
         PUSH   HL
         LD     HL,NAME
         LD     DE,4009H
         LD     BC,10
         LDIR
         POP    HL
         POP    DE
         POP    BC
         RET

;************************************************
;                                               *
;This subroutine will scan the keyboard and     *
;look for a key pressed.                        *
;                                               *
;Registers used:  B, C, D, E, H, L              *
;                                               *
;************************************************

GETKEY   PUSH   BC
         PUSH   DE
         PUSH   HL
         LD     A,0C0H          ;Turn on keyboard
         OUT    (PBPIO),A       ;Or enable row
         LD     B,00            ;Row
         LD     C,PCPIO         ;Port pointer
NEXTROW  OUT    (C),B
         IN     A,(PAPIO)       ;Read in column
         CP     0FFH
         JP     NZ,FOUNDK
OOPS     INC    B
         BIT    3,B
         JP     Z,NEXTROW
         SCF                    ;No key pressed
OUTHERE  POP    HL
         POP    DE
         POP    BC
         RET

;************************************************
;                                               *
;This subroutine will update the display        *
;                                               *
;Registers used:  A                             *
;                                               *
;************************************************

UPPLAY  PUSH    AF
        AND     0FH             ;Mask off hi-byte
        LD      (DIGIT0),A      ;Save low-byte
        POP     AF
        PUSH    AF
        SRL     A
        SRL     A
        SRL     A
        SRL     A
        LD      (DIGIT1),A      ;Save hi-byte
        POP     AF
        RET

;************************************************
;                                               *
;This subroutine will update the screen         *
;                                               *
;Registers used:  None                          *
;                                               *
;************************************************

UPCRT   LD      (408CH),A
        RET

;************************************************
;                                               *
;This subroutine will give delay time after     *
;key is released.                               *
;                                               *
;Registers used:  None                          *
;                                               *
;************************************************

DLETUP  CALL    GETKEY
        JP      NC,DLETUP
        CALL    DELAY1          ;Debounce delay
        RET
                      
;************************************************
;                                               *
;This subroutine is part of GET-KEY subroutine. *
;If a key is pressed, it will read that key and *
;return the ASCII value by using the ASCII table*
;                                               *
;Registers used:  A, B, D, F                    *
;                                               *
;************************************************

FOUNDK   LD     D,A             ;Save key pressed
         CALL   DELAY1          ;Debounce time
         IN     A,(PAPIO)       ;Read key again
         CP     D               ;Is it same key?
         JP     NZ,OOPS         ;Not same key,
                                ;don't want it
         XOR    A               ;Set Acc. to zero
BACK     RRC    D
         JR     NC,OUT
         INC    A
         JR     C,BACK
OUT      DEC    B
         JP     M,LOOKUP
         ADD    A,08
         JR     OUT
LOOKUP   LD     HL,TASCII
         LD     L,A
         LD     A,(HL)
         JP     OUTHERE

;************************************************
;                                               *
;This subroutine gives delay of 500 ms          *
;                                               *
;Registers used:  A, B, C, D, E, F              *
;                                               *
;************************************************

VDELAY  PUSH    DE
        PUSH    AF
        PUSH    BC
LOOP1   LD      DE,100H
WAIT    DEC     DE
        LD      A,D
        OR      E
        JP      NZ,WAIT
        DEC     C
        JP      NZ,LOOP1
        POP     BC
        POP     AF
        POP     DE
        RET

;************************************************
;                                               *
;This subroutine will make a delay of 10 ms to  *
;support the Debounce subroutine.  During the   *
;debounce time, it goes out to refresh the      *
;segments.                                      *
;                                               *
;Registers used:  A, B, C, H, L                 *
;                                               *
;************************************************

DELAY1  PUSH    AF
        PUSH    BC
        PUSH    HL
        LD      HL,LTABLE
        LD      A,(DIGIT0)
        LD      L,A
        LD      A,(HL)
        OUT     (PORT0),A
        LD      A,0FEH
        OUT     (PORT1),A
        LD      BC,05
        CALL    VDELAY
        LD      A,0FFH
        OUT     (PORT1),A          ;Turn display off
        LD      A,(DIGIT1)
        LD      L,A
        LD      A,(HL)
        OUT     (PORT0),A
        LD      A,0FDH
        OUT     (PORT1),A
        LD      BC,05
        CALL    VDELAY
        LD      A,0FFH
        OUT     (PORT1),A
        POP     HL
        POP     BC
        POP     AF
        RET
          
NAME    .TEXT   "DONG DO V."
DIGIT0  .DB     00H
DIGIT1  .DB     00H

;************************************************
;                                               *
;The following is the reserved table            *
;for segments                                   *
;                                               *
;************************************************

        .ORG    7000H

LTABLE  .DB     0C0H
        .DB     0F9H
        .DB     0A4H
        .DB     0B0H
        .DB     099H
        .DB     092H
        .DB     082H
        .DB     0D8H
        .DB     080H
        .DB     090H
        .DB     088H
        .DB     083H
        .DB     0C6H
        .DB     0A1H
        .DB     086H
        .DB     08EH
        .DB     07FH
        RET
  
;************************************************
;                                               *
;This is the ASCII table                        *
;                                               *
;************************************************

        .ORG    7200H

TASCII  .DB     20H,20H,20H,20H,40H,20H,20H,20H
        .DB     20H,2BH,3DH,20H,2FH,3BH,20H,20H
        .DB     00H,00H,3AH,2EH,2CH,4CH,50H,20H
        .DB     30H,4FH,4BH,4DH,4EH,4AH,49H,39H
        .DB     38H,55H,48H,42H,76H,47H,59H,37H
        .DB     36H,54H,46H,43H,58H,4FH,52H,35H
        .DB     34H,45H,53H,5AH,00H,41H,57H,33H
        .DB     32H,51H,20H,20H,20H,20H,20H,31H

        .END



