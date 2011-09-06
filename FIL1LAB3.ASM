START   .ORG    6300H
CLS     .EQU    00BCH
XPORT   .EQU    00H
YPORT   .EQU    01H
COLPORT .EQU    8CH
ROWPORT .EQU    8EH
ENKEY   .EQU    8DH
NAME    .TEXT   "WAYNE A. GARDNER"
        .TEXT   "                "
        .TEXT   "THE OBJECT IS AN APPLE"
BUFFER  .DB

MAIN    .ORG    6350H
        CALL    WRNAME
        LD      B,00H
        LD      C,00H
REDRAW  LD      HL,PICTURE
CONTIN  LD      A,(HL)
        ADD     A,B
        OUT     (YPORT),A
        INC     HL
        LD      A,(HL)
        ADD     A,C
        OUT     (XPORT),A
        INC     HL
        LD      A,L
        CP      102
        ;END OF PICTURE

        JR      NZ,CONTIN
        CALL    SCANKEY
        JR      REDRAW

SCANKEY PUSH    BC
        LD      C,ROWPORT
        LD      A,0C0H          ;ENABLE KEYBOARD
        OUT     (ENKEY),A
        LD      B,01H           ;SET TO ROW 2
        OUT     (C),B
        IN      A,(COLPORT)
        CP      0FFH
        JR      NZ,ENCODEX
        LD      B,02H           ;SET TO ROW 3
        OUT     (C),B
        IN      A,(COLPORT)
        CP      0FFH
        JR      NZ,ENCODEY
        POP     BC
        RET

ENCODEX LD      C,11111110B     ;SET TO COLUMN 1
        CP      C
        JR      Z,MOVEUP
        LD      C,01111111B
        CP      C
        JR      Z,MOVEDWN
        POP     BC
        RET
MOVEUP  POP     BC
        LD      A,C
        ADD     A,10D
        LD      C,A
        RET
MOVEDWN POP     BC
        LD      A,C
        SUB     10
        LD      C,A
        RET

ENCODEY LD      C,11111110B
        CP      C
        JR      Z,MOVERT
        LD      C,01111111B
        CP      C
        JR      Z,MOVELT
        POP     BC
        RET
MOVERT  POP     BC
        LD      A,B
        ADD     A,10D
        LD      B,A
        RET
MOVELT  POP     BC
        LD      A,B
        SUB     10D
        LD      B,A
        RET

WRNAME  CALL    CLS
        LD      BC,54
        LD      HL,NAME
        LD      DE,4009H
        LDIR
        RET

PICTURE .ORG    7000H
        .DB     126,120,126,119,126,118
        .DB     127,117,126,116,125,115
        .DB     124,114,123,113,122,113
        .DB     121,113,120,113,119,113
        .DB     118,112,117,114,116,115
        .DB     117,116,114,118,114,119
        .DB     114,120,114,121,114,122
        .DB     114,120,114,121,114,122
        .DB     114,123,115,124,116,125
        .DB     117,126,118,127,119,127
        .DB     120,127,121,127,122,127
        .DB     123,127,124,126,125,125
        .DB     126,124,123,127,126,122
        .DB     126,121,127,120,128,120
        .DB     129,120,130,121,131,121
        .DB     132,121,133,121,133,122
        .DB     133,123,133,124,132,123
        .DB     132,122,131,122,120,120


        .END

