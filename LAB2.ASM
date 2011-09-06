;*******************************************************
;                                                      *
;NAME:   THOMAS G. HARR                                *
;LAB     #2, KEYBOARD and VIDEO LAB                    *
;COURSE: EET 484L, 6DP                                 *
;                                                      *
;THIS PROGRAM SCANS THE KEYBOARD AND RETURNS THE ASCII *
;VALUE OF THE KEY PRESSED USING A LOOKUP TABLE.        *
;THE ASCII VALUE IS DISPLAYED ON THE THE TWO DIGIT     *
;SEVEN SEGMENT DISPLAY.  THE PROGRAM ALSO DISPLAYS THE *
;ASCII CHARACTER ON THE CRT.                           *
;                                                      *
;REGISTERS USED:  A, B, C, D, E, F, H, L               *
;                                                      *
;*******************************************************

;Main Program
        .ORG    6500H
        CALL    CLSCRT
        CALL    WRITNAM
        CALL    LEDOFF
        CALL    INITIAL
        CALL    LEDTEST
ONEMORE:CALL    UPDATE
        CALL    DISPLED
        CALL    ASCISUB
COMPARE:LD      HL,ASCII
        CP      (HL)
        JR      NZ,NEWDATA
        CALL    MSDLSD
        LD      A,(ASCII)
        LD      IX,VDSTART+CENTER
        LD      (IX),A
        JR      ONEMORE
NEWDATA:LD      HL,(ASCII)
        LD      (HL),A
        JR      ONEMORE
        HALT



;*******************************************************
;                                                      *
;Clear Screen Subroutine                               *
;                                                      *
;This subroutine will clear the screen on the CRT.     *
;                                                      *
;Registers used:  A, B, C, D, E, H, L                  *
;                                                      *
;*******************************************************

CLSCRT: LD      A,20H
        LD      (VDSTART),A
        LD      HL,VDSTART
        LD      DE,VDSTART+1
        LD      BC,511
        LDIR
        RET



;*******************************************************
;                                                      *
;Write Name Subroutine                                 *
;                                                      *
;This subroutine will place my name on the top line of *
;the CRT while centering it.                           *
;                                                      *
;Registers used:  A, B, C, D, E, H, L                  *
;                                                      *
;                                                      *
;*******************************************************

WRITNAM:LD      HL,NAME
        LD      DE,VDSTART
        LD      A,'.'
NAMLOOP:CP      (HL)
        RET     Z
        LDI
        JR      NAMLOOP


        

;*******************************************************
;                                                      *
;Variable Delay Subroutine                             *
;                                                      *
;This subroutine causes a delay for however much of a  *
;time delay is needed, in milliseconds.                *
;                                                      *
;Registers used:  A, D, E, F                           *
;                                                      *
;*******************************************************

DELAY:  PUSH    AF
MULTI:  LD      A,$FF
LOOP:   DEC     A
        JP      NZ,LOOP
        DEC     DE
        LD      A,E
        OR      D
        JR      NZ,MULTI
        POP     AF
        RET




;*******************************************************
;                                                      *
;Blank Seven Segment Display Subroutine                *
;                                                      *
;This subroutine turns off both of the Seven Segment   *
;Displays                                              *
;                                                      *
;Registers used:  A                                    *
;                                                      *
;*******************************************************

LEDOFF: LD      A,TURNOFF
        LD      C,DIGPORT
        OUT     (C),A
        RET

                                                        


;*******************************************************
;                                                      *
;Seven Segment Self Test Subroutine                    *
;                                                      *
;This subroutine will test each digit of both of the   *
;Seven Segment Displays.                               *
;                                                      *
;Registers used:  A, B, C, D, E, F                     *
;                                                      *
;*******************************************************

LEDTEST:LD      A,11111110B
        SCF
        LD      C,SEGPORT
AGAIN:  OUT     (C),A
        RL      A
        PUSH    DE
        LD      DE,1000
        CALL    DELAY
        POP     DE
        JR      C,AGAIN
        RET



:*******************************************************
;                                                      *
;Initialization Subroutine                             *
;                                                      *
;This subroutine will set aside three scratch pads.    *
;These scratch pads include one to hold the least      *
;significant digit, one to hold the most significant   *
;digit, and one to hold the Ascii value.               *
;                                                      *
;Registers used:  A                                    *
;                                                      *
;*******************************************************

INITIAL:LD      A,$00
        LD      (ASCII),A
        LD      A,$FF
        LD      (MSD),A
        LD      (LSD),A
        RET




;*******************************************************
;                                                      *
;Update MSDLSD Subroutine                              *
;                                                      *
;This subroutine will update the most significant and  *
;the least significant digits of both of the Seven     *
;Segment Displays.                                     *
;                                                      *
;Registers used:  A                                    *
;                                                      *
;*******************************************************

UPDATE: LD      A,(ASCII)
        AND     $0F
        CALL    SEGLKUP
        LD      (LSD),A
        LD      A,(ASCII)
        SRL     A
        SRL     A
        SRL     A
        SRL     A
        CALL    SEGLKUP
        LD      (MSD),A
        RET




;*******************************************************
;                                                      *
;Seven Segment Display Lookup Subroutine               *
;                                                      *
;This subroutine will add an offset to the LED Table   *
;to acquire the number needed to light up the Seven    *
;Segment Displays                                      *
;                                                      *
;Registers used:  A, H, L                              *
;                                                      *
;*******************************************************

SEGLKUP:LD      HL,LEDTAB
        ADD     A,L
        LD      L,A
        JR      NC,GODOWN
        INC     H
GODOWN: LD      A,(HL)
        RET
                                                       

                                                       

;*******************************************************
;                                                      *
;Display the Seven Segment Displays Subroutine         *
;                                                      *
;This subroutine will first write the updated data to  *
;the least significant digit of the Seven Segment      *
;Display.  Then the subroutine calls a 10 ms debounce  *
;delay before it writes out the updates data to the    *
;most significant digit of the Seven Segment DIsplay.  *
;                                                      *
;Registers used:  A, C, D, E                           *
;                                                      *
;*******************************************************

DISPLED:LD      C,LEFTDIG
        LD      A,RITEDIG
        OUT     (C),A
        LD      C,DIGPORT
        LD      A,(MSD)
        OUT     (C),A
        LD      DE,10
        CALL    DELAY
        LD      C,LEFTDIG
        LD      A,LEFTDIG
        OUT     (C),A
        LD      C,DIGPORT
        LD      A,(LSD)
        OUT     (C),A
        LD      DE,10
        CALL    DELAY
        RET




;*******************************************************
;                                                      *
;Convert Key Press To Its Corresponding Number         *
;                                                      *
;This subroutine will convert the value of the key     *
;that was pressed into an equivalent number.           *
;                                                      *
;Registers used:  A, B, C, D, E, H, L                  *
;                                                      *
;*******************************************************

ASCISUB:CALL    KEYSCAN
        JP      Z,NOKEY
        LD      C,A
        XOR     A
COLUMN: BIT     0,C
        JR      Z,ROWS
        INC     A
        RRC     C
        JR      COLUMN
        INC     B
ROWS:   DEC     B
        JP      M,LOOKUP
        ADD     A,08
        JR      ROWS
LOOKUP: LD      HL,ASCITAB
        ADD     A,L
        LD      L,A
        JR      NC,OVER
        INC     H
OVER:   LD      A,(HL)
        LD      (ASCII),A
ENDIT:  RET
NOKEY:  PUSH    DE
        LD      DE,20
        CALL    UPDATE
        CALL    DISPLED
        POP     DE
        XOR     A
        RET




;*******************************************************
;                                                      *
;Scan The Keyboard Subroutine                          *
;                                                      *
;This subroutine will scan the keyboard to check to    *
;see if a key has been pressed.                        *
;                                                      *
;Registers used:  A, B, C                              *
;                                                      *
;*******************************************************

KEYSCAN:IN      A,(PORTB)
        SET     6,A
        OUT     (PORTB),A
        LD      C,PORTC
        LD      B,7
SCANLUP:OUT     (C),B
        IN      A,(PORTA)
        CP      $FF
        RET     NZ
        DEC     B
        JP      P,SCANLUP
        XOR     A
        RET



;*******************************************************
;                                                      *
;MSDLSD Update Subroutine                              *
;                                                      *
;This subroutine will update the most significant and  *
;the least significant digits of both of the Seven     *
;Segment Displays                                      *
;                                                      *
;Registers used:  A                                    *
;                                                      *
;*******************************************************

MSDLSD: LD      A,(ASCII)
        AND     $0F
        CALL    SEGLKUP
        LD      (LSD),A
        LD      A,(ASCII)
        SRL     A
        SRL     A
        SRL     A
        SRL     A
        CALL    SEGLKUP
        LD      (MSD),A
        RET

        


:*******************************************************
;                                                      *
;Necessary Equates for correct program operation.      *
;                                                      *
;*******************************************************

VDSTART:.EQU    4000H
NAME:   .TEXT   "        THOMAS G HARR. "
SEGPORT:.EQU    00H
TURNOFF:.EQU    $FF
DIGPORT:.EQU    00H
PORTB:  .EQU    008DH
PORTC:  .EQU    008EH
PORTA:  .EQU    008CH
MSD:    .BLOCK  1
LSD:    .BLOCK  1
ASCII:  .BLOCK  1
LEFTDIG:.EQU    01H
RITEDIG:.EQU    02H
CENTER: .EQU    128




;*******************************************************
;                                                      *
;Seven Segment Display Data Table                      *
;                                                      *
;*******************************************************


LEDTAB: .DB     0C0H    ;0
        .DB     0F9H    ;1
        .DB     0A4H    ;2
        .DB     0B0H    ;3
        .DB     099H    ;4
        .DB     092H    ;5
        .DB     082H    ;6
        .DB     0F8H    ;7
        .DB     080H    ;8
        .DB     098H    ;9
        .DB     088H    ;A
        .DB     083H    ;b
        .DB     0A7H    ;c
        .DB     0A1H    ;d
        .DB     086H    ;E
        .DB     08EH    ;F

       

;*******************************************************
;                                                      *
;ASCII TABLE                                           *
;                                                      *
;*******************************************************

       
ASCITAB:.DB     00H
        .DB     00H
        .DB     00H
        .DB     00H
        .DB     40H
        .DB     00H
        .DB     0DH
        .DB     7FH
        .DB     00H
        .DB     2BH
        .DB     3DH
        .DB     1BH
        .DB     2FH
        .DB     3BH
        .DB     2AH
        .DB     5FH
        .DB     5EH
        .DB     2DH
        .DB     3AH
        .DB     2EH
        .DB     2CH
        .DB     4CH
        .DB     50H
        .DB     00H
        .DB     30H
        .DB     4FH
        .DB     4BH
        .DB     4DH
        .DB     4EH
        .DB     4AH
        .DB     49H
        .DB     39H
        .DB     38H
        .DB     55H
        .DB     48H
        .DB     42H
        .DB     56H
        .DB     47H
        .DB     59H
        .DB     37H
        .DB     36H
        .DB     54H
        .DB     46H
        .DB     43H
        .DB     58H
        .DB     44H
        .DB     52H
        .DB     35H
        .DB     34H
        .DB     45H
        .DB     53H
        .DB     5AH
        .DB     00H
        .DB     41H
        .DB     57H
        .DB     33H
        .DB     32H
        .DB     51H
        .DB     00H
        .DB     20H
        .DB     00H
        .DB     00H
        .DB     00H
        .DB     31H
        .END

