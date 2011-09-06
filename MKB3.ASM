      MIKE BRAZDA
      FINLEY LAB:  FREQUENCY COUNTER

      THIS PROGRAM PROMPTS THE USER TO EITHER ENTER A
      F TO  MEASURE THE VALUE OF FREQUENCY OR A T TO
      EXIT THE PROGRAM.

      REGISTERS USED:  ALL

;***************************************************************
;INITIALIZE GLOBAL VARIABLES AND POINTERS
;***************************************************************

        .ORG    7000H
VIDRAM  .EQU    4000H
CLSCR   .EQU    00BCH
SETXY   .EQU    00CEH
PRTSTG  .EQU    00D1H
CTC     .EQU    84H
CTC0    .EQU    CTC
CTC1    .EQU    CTC+1
CTC2    .EQU    CTC+2
CTC3    .EQU    CTC+3
BIN_DIG .EQU    02H

;***************************************************************
; MAIN PROGRAM
;***************************************************************

MAIN    CALL    CLSCR               ;Clear monitor screen
        CALL    PRTNAME             ;Prints name to the screen.
        LD      DE,$0C00
        CALL    SETXY
        LD      HL,CRTEXT1
        CALL    PRTSTG              ;Prints main program menu to the screen.
        CALL    VECTABL
        CALL    CTCINIT
DECIDE  DI                          ;Main keyboard loop
        RST     18H
        JR      Z,DECIDE
        CP      'C'
        JR      Z,CAPACIT
        CP      'F'
        JR      Z,FREQNCY
        CP      'Q'
        JP      Z,LAST              ;Terminate program if 'T' is pressed
        JR      DECIDE
CAPACIT LD      DE,0D00H            ;Capacitance loop
        CALL    SETXY
        LD      HL,CRTEXT2
        CALL    PRTSTG
        CALL    CTCINIT
PICK_C  CALL    CAPCRT
        RST     18H                 ;Scan the keyboard for a key pressed
        JR      Z,PICK_C
        CP      'M'
        JR      Z,MAIN              ;Redisplay menu if 'r' is pressed
        JR      PICK_C
FREQNCY LD      DE,0D00H            ;Frequency loop
        CALL    SETXY
        LD      HL,CRTEXT2
        CALL    PRTSTG
        CALL    CTCINIT
PICK_F  CALL    FREQCRT
        RST     18H
        JR      Z,PICK_F
        CP      'R'
        JR      Z,MAIN              ;Redisplay menu if 'r' is pressed
        JR      PICK_F



;**********************************************************
;    CTC Initialization Subroutine
;
;    This subroutine initializes the CTC
;
;    Registers AFFECTED:  A, C
;**********************************************************

CTCINIT DI
        IM      2
        LD      A,0
        LD      (FLAG3),A
        LD      (FLAG2),A
        LD      C,CTC0              ;Initialize timer mode
        LD      A,00110111B
        OUT     (C),A
        LD      A,200
        OUT     (C),A
        LD      C,CTC1              ;Count the pulses out of ch# 0
        LD      A,11011111B
        OUT     (C),A
        LD      A,70
        OUT     (C),A
        LD      C,CTC2              ;Initialize time mode
        LD      A,01010111B
        OUT     (C),A
        LD      A,100
        OUT     (C),A
        LD      C,CTC3              ;Count the frequency of ch# 2
        LD      A,11010111B
        OUT     (C),A
        LD      A,100
        OUT     (C),A    
        EI
        RET



;+---------------------------------------------------------+
;|    Interrupt Service Routine Update Subroutine          |
;|                                                         |
;|    This subroutine updates the ISR.  The contents of    |
;|    CTC counters are read.  The scratchpad memory        |
;|    locations are updated.                               |
;|                                                         |
;|    Registers Thrashed:  None                            |
;+---------------------------------------------------------+

ISRRUS  PUSH    AF
        PUSH    BC
        PUSH    DE
        PUSH    HL
        PUSH    IX
        PUSH    IY
        LD      C,CTC0
        LD      A,00110011B         ;re-update timer and counter mode
        OUT     (C),A
        LD      C,CTC1
        LD      A,01011011B
        OUT     (C),A
        LD      C,CTC2
        IN      B,(C)
        LD      A,100
        SUB     B
        LD      (TIME1),A
        LD      C,CTC3
        IN      B,(C)
        LD      A,100
        SUB     B        
        LD      (TIME2),A
        CALL    BIN_BCD
        LD      A,(FLAG2)
        CP      0
        CALL    Z,PROGSEC
        LD      A,(FLAG2)
        CP      1
        CALL    Z,PROGMIL
        LD      A,(FLAG2)
        CP      1
        JR      NZ,REPROG
        LD      HL,MSD
        LD      A,(HL)
        DEC     HL
        OR      (HL)
        JR      NZ,REPROG
        DEC     HL
        LD      A,(HL)
        CP      010H
        JP      NC,REPROG
        LD      A,0
        LD      (FLAG2),A
        LD      (FLAG3),A
REPROG  LD      C,CTC2
        LD      A,01010111B
        OUT     (C),A
        LD      A,100
        OUT     (C),A        
        LD      C,CTC3
        LD      A,11010111B
        OUT     (C),A
        LD      A,100
        OUT     (C),A
        LD      A,1
        LD      (FLAG1),A
        POP     IX
        POP     IY          
        POP     HL
        POP     DE
        POP     BC
        POP     AF
        EI
        RETI



;+---------------------------------------------------------+
;|    Vector Table and I Register Subroutine               |
;|                                                         |
;|    This subroutine initializes the vector table and the |
;|    I register for the appropriate frequency or          |
;|    capacitance calculation areas.                       |
;|                                                         |
;|    Registers Thrashed:  A, H, I, L                      |
;+---------------------------------------------------------+

VECTABL LD      HL,LAST             ;find the end of program and set up table
        INC     H
        LD      L,00H
        LD      A,H
        LD      I,A
        PUSH    HL
        POP     IX
        LD      HL,ISRRUS
        LD      (IX+2),L
        LD      (IX+3),H
        LD      HL,OVERANG
        LD      (IX+6),L
        LD      (IX+7),H
        RET
         


;+---------------------------------------------------------+
;|    Overrange ISR Subroutine                             |
;|                                                         |
;|    This subroutine sets the flag signifying that the    |
;|    frequency value is out of range.  The CTC counter    |
;|    is reprogrammed.                                     |
;|                                                         |
;|    Registers Thrashed:  None                            |
;+---------------------------------------------------------+

OVERANG PUSH    AF
        PUSH    BC
        PUSH    DE
        PUSH    HL  
        PUSH    IX
        PUSH    IY
        LD      C,CTC2
        LD      A,01010111B
        OUT     (C),A
        LD      C,CTC3
        LD      A,11010111B
        OUT     (C),A
        LD      A,01
        LD      (FLAG2),A
        LD      A,(FLAG3)
        CP      1
        JR      NZ,SETFLAG
        LD      A,0
        LD      (FLAG3),A
        JR      GO_DOWN
SETFLAG LD      A,1
        LD      (FLAG3),A
        CALL    PROGMIL
GO_DOWN LD      C,CTC2
        LD      A,100
        OUT     (C),A
        LD      C,CTC3
        OUT     (C),A
        POP     IY
        POP     IX
        POP     HL
        POP     DE
        POP     BC
        POP     AF
        EI
        RETI



;+---------------------------------------------------------+
;|    Adjust And Display Frequency Subroutine              |
;|                                                         |
;|    This subroutine takes the calculated frequency and   |
;|    adjusts it so that it can be displayed to the CRT    |                          |
;|                                                         |
;|    Registers Thrashed:  A, D, E, H, L                   |
;+---------------------------------------------------------+

FREQCRT IN      A,(8EH)
        BIT     7,A
        JR      NZ,FREQCRT
        LD      HL,VIDRAM+0152H
        LD      DE,MSD
        LD      B,3
FIXFRQ1 LD      A,(DE)
        AND     0F0H
        SRL     A
        SRL     A
        SRL     A
        SRL     A
        OR      030H
        LD      (HL),A
        LD      A,(DE)
        AND     00FH
        OR      030H
        INC     HL
        LD      (HL),A
        INC     HL
        DEC     DE
        DJNZ    FIXFRQ1
        LD      HL,VIDRAM+0150H
        LD      BC,005H
        LD      A,030H
FIXFRQ2 CPI
        JR      NZ,FIXFRQ3
        LD      A,020H
        DEC     HL
        LD      (HL),A
        INC     HL
        LD      A,030H
        JP      PE,FIXFRQ2
FIXFRQ3 LD      HL,VIDRAM+0156H
        LD      (HL),20H
        INC     HL
        LD      A,(FLAG2)
        CP      1
        JR      NZ,SETUPHZ
        LD      (HL),'K'
        INC     HL  
SETUPHZ JR      Z,WRITEHZ
        LD      (HL),20H
        INC     HL
WRITEHZ LD      (HL),'H'
        INC     HL
        LD      (HL),'Z'
        RET



;+---------------------------------------------------------+
;|    Binary to Packed BCD Conversion Subroutine           |
;|                                                         |
;|    This subroutine converts binary to packed BCD        |
;|                                                         |
;|    Registers Thrashed:  A, B, C, H, L                   |
;+---------------------------------------------------------+

BIN_BCD XOR     A
        LD      HL,LSD
        LD      (HL),A
        INC     HL
        LD      (HL),A
        INC     HL
        LD      (HL),A
        LD      C,BIN_DIG
        LD      HL,TIME1
        LD      IX,LSD
COMPARE CP      (HL)
        JR      Z,NEXTBCD
        LD      B,(HL)
BIN_FIX LD      A,(IX+0)
        ADD     A,001H
        DAA
        LD      (IX+0),A
        JR      NC,CONTIN
        LD      A,(IX+1)
        ADD     A,001H
        DAA
        LD      (IX+1),A
CONTIN  DJNZ    BIN_FIX
NEXTBCD INC     HL
        INC     IX
        XOR     A
        DEC     C
        JR      NZ,COMPARE
        RET



;+---------------------------------------------------------+
;|    Packed BCD Division Subroutine                       |
;|                                                         |
;|    This subroutine divides packed BCD numbers           |
;|                                                         |
;|    Registers Thrashed:  A, C, D, IX, IY                 |
;+---------------------------------------------------------+

BCD_DIV LD      IY,LSD
        LD      IX,QUOTENT
        XOR     A
        LD      (IY+3),A
        LD      (IY+4),A
        LD      A,010H
        LD      (IY+5),A
        LD      A,000H
        LD      (IX+0),A
        LD      (IX+1),A
        LD      (IX+2),A
FIX_DIV LD      D,3
        LD      IY,LSD
        XOR	A
CONT_FX LD      A,(IY+3)
        SBC     A,(IY+0)
        DAA
        LD      (IY+3),A
        INC     IY
        DEC     D
        JR      NZ,CONT_FX
        JR      C,EXITDIV
        LD      A,(IX+0)
        ADD     A,1
        DAA
        LD      (IX+00),A
        JR      NC,FIX_DIV
        LD      A,(IX+1)
        ADD     A,1
        DAA
        LD      (IX+1),A
        JR      NC,FIX_DIV
        LD      A,(IX+2)
        ADD     A,1
        DAA
        LD      (IX+2),A
        JR      FIX_DIV
EXITDIV RET



;+---------------------------------------------------------+
;|    Adjust And Display Capacitance Subroutine            |
;|                                                         |
;|    This subroutine takes the calculated capacitance and |
;|    adjusts it so that it can be displayed to the CRT.   |
;|                                                         |
;|    Registers Thrashed:  A, B, C, D, E, H, L             |
;+---------------------------------------------------------+

CAPCRT  LD      A,(FLAG1)
	CP	1
        CALL    Z,BCD_DIV
	XOR	A
        LD      (FLAG1),A
	IN      A,(8EH)
        BIT     7,A
        JR      NZ,CAPCRT
        LD      HL,VIDRAM+0150H
        LD      DE,QUOTENT+2
        LD      A,(FLAG2)
        CP	1
        JP      Z,JMPDOWN
        LD      B,3
FIXCAP1 LD      A,(DE)
        AND     0F0H
        SRL     A
        SRL     A
        SRL     A
        SRL     A
        OR      030H
        LD      (HL),A
        LD      A,(DE)
        AND     00FH
        OR      030H
        INC     HL
        LD      (HL),A
        INC     HL
        DEC     DE
        DJNZ    FIXCAP1
        LD      HL,VIDRAM+0150H
        LD      BC,005H
        LD      A,030H
FIXCAP2 CPI
        JR      NZ,WRITENF
        LD      A,020H
        DEC     HL
        LD      (HL),A
        INC     HL
        LD      A,030H
        JP      PE,FIXCAP2
WRITENF LD      HL,VIDRAM+0156H
        LD	(HL),20H
        INC	HL
        LD	(HL),'N'
        INC	HL
        LD	(HL),'F'
        JP      SKIPIT
JMPDOWN INC     HL
	INC	HL
	INC	HL
	LD	B,2
        LD      A,(DE)
        AND     0F0H
        SRL     A
        SRL     A
        SRL     A
        SRL     A
        OR      030H
        LD      (HL),A
        LD      A,(DE)
        AND     00FH
        OR      030H
        INC     HL
        LD      (HL),A
        INC     HL
        DEC     DE
        LD      A,(DE)
        AND     0F0H
        SRL     A
        SRL     A
        SRL     A
        SRL     A
        OR      030H
        LD      (HL),A
        INC	HL
        LD	(HL),20H
        INC	HL
        LD	(HL),'P'
        INC	HL
        LD	(HL),'F'
SKIPIT RET


        
;+---------------------------------------------------------+
;|    CTC One Second Reprogram Subroutine                  |
;|                                                         |
;|    This subroutine reprograms the CTC for a one second  |
;|    delay.                                               |
;|                                                         |
;|    Registers Thrashed:  A, C                            |
;+---------------------------------------------------------+

PROGSEC LD      C,CTC0
        LD      A,00110111B
        OUT     (C),A
        LD      A,200
        OUT     (C),A
        LD      C,CTC1
        LD      A,11011111B
        OUT     (C),A
        LD      A,70
        OUT     (C),A        
        RET


        
;+---------------------------------------------------------+
;|    CTC One Millisecond Reprogram Subroutine             |                                       *
;|                                                         |
;|    This subroutine reprograms the CTC for a one         |
;|    millisecond delay.                                   |
;|                                                         |
;|    Registers Thrashed:  A, C                            |
;+---------------------------------------------------------+

PROGMIL LD      C,CTC0
        LD      A,00010111B
        OUT     (C),A
        LD      A,14
        OUT     (C),A
        LD      C,CTC1
        LD      A,11011111B
        OUT     (C),A
        LD      A,16
        OUT     (C),A               
        RET



;+---------------------------------------------------------+
;|     Print The Programmers Name Subroutine:              |
;|                                                         |
;|     This subroutine takes the programmers name and      |
;|     displays it to the screen.                          |
;|                                                         |
;|     Registers Thrashed:  D, E, H, L                     |
;+---------------------------------------------------------+

PRTNAME LD      DE,0
        CALL    SETXY
        LD      HL,NAMESTR
        CALL    PRTSTG
        RET



;+---------------------------------------------------------+
;|    Necessary Equates for Correct Program Operation      |
;+---------------------------------------------------------+

NAMESTR .TEXT   "MIKE BRAZDA"
CRTEXT1 .TEXT   " F - FREQUENCY"
CRTEXT2 .TEXT   "M - MAIN MENU   Q - QUIT PROGRAM\r\r\000"
LSD     .DB     0
MSD     .DB     0
QUOTENT .BLOCK  3
TIME1   .DB     0
TIME2   .DB     0
FLAG1   .BLOCK  1
FLAG2   .BLOCK  1
FLAG3   .BLOCK  1
LAST    .END
