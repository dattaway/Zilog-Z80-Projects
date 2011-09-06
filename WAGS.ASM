;*****************************************************
;  WAYNE GARDNER 6DA EET-484L
;  ITS AN APPLE....
;
;*****************************************************
;
;THIS IS THE INITIALIZATION OF THE PORTS, THE SCREEN,
;THE KEYBOARD AND THE TEXT
;
;*****************************************************

START   .ORG    6300H
CLS     .EQU    00BCH
XPORT   .EQU    00H
YPORT   .EQU    01H
COLPORT .EQU    8CH
ROWPORT .EQU    8EH
ENKEY   .EQU    8DH
PICTURE .EQU    7000H
NAME    .TEXT   "WAYNE A. GARDNER"
        .TEXT   "          "
        .TEXT   "IT IS AN APPLE  "
BUFFER  .DB

;*****************************************************
;
;THE MAIN PROGRAM CALLS THE CRT ROUTINE, DRAWS THE
;PICTURE ON THE O-SCOPE, AND CALLS THE ROUTINE TO SCAN
;THE KEYBOARD
;
;*****************************************************

MAIN    .ORG    6350H
        CALL    WRNAME
        LD      B,00H           ;INITIALIZE THE OFFSETS
        LD      C,00H           ;TO ZERO
REDRAW  LD      HL,PICTURE      ;PICTURE LOOKUP TABLE
CONTIN  LD      A,(HL)
        ADD     A,C             ;ADD OFFSET TO Y-AXIS
        OUT     (YPORT),A
        INC     HL              ;GET POINT X
        LD      A,(HL)
        ADD     A,B             ;ADD OFFSET TO X-AXIS
        OUT     (XPORT),A
        INC     HL              ;GET NEXT PIXEL

        LD      A,L             ;END OF PICTURE?
        CP      104D

        JR      NZ,CONTIN
        CALL    SCANKEY
        JR      REDRAW          ;KEEP DRAWING THE PICTURE

;*****************************************************
;
;THE SCANKEY ROUTINE CHECKS FOR A KEY PRESSED IN
;ROWS 2 AND 3.
;
;*****************************************************

SCANKEY PUSH    BC
        LD      C,ROWPORT
        LD      A,0C0H          ;ENABLE KEYBOARD
        OUT     (ENKEY),A
        LD      B,01H           ;SET TO ROW 2
        OUT     (C),B
        IN      A,(COLPORT)     ;WAS A KEY PRESSED?
        CP      0FFH
        JR      NZ,ENCODEX      ;CHANGE X-AXIS OFFSET
        LD      B,02H           ;SET TO ROW 3
        OUT     (C),B
        IN      A,(COLPORT)     ;WAS A KEY PRESSED?
        CP      0FFH
        JR      NZ,ENCODEY      ;CHANGE Y-AXIS OFFSET
        POP     BC
        RET

;*****************************************************
;
;THE ENCODEY ROUTINE DETERMINES WHETHER TO MOVE THE
;PICTURE EITHER UP/DOWN OR NOT AT ALL
;
;*****************************************************

ENCODEY LD      C,11111110B     ;SET TO COLUMN 1
        CP      C
        JR      Z,MOVEUP        ;MOVE IT UP?
        LD      C,01111111B     ;SET TO COLUMN 8
        CP      C
        JR      Z,MOVEDWN       ;MOVE IT DOWN?
        POP     BC
        RET
MOVEUP  POP     BC              ;PREVIOUS Y OFFSET
        LD      A,C
        ADD     A,2D
        LD      C,A             ;MOVE UP 2 PIXELS
        RET
MOVEDWN POP     BC              ;PREVIOUS Y OFFSET
        LD      A,C
        SUB     2
        LD      C,A             ;MOVE DOWN 2 PIXELS
        RET

;*****************************************************
;
;THE ENCODEX ROUTINE DETERMINES WHETHER TO MOVE THE
;PICTURE LEFT/RIGHT OR NOT AT ALL
;
;*****************************************************

ENCODEX LD      C,11111110B     ;SET TO COLUMN 1
        CP      C
        JR      Z,MOVERT        ;MOVE IT RIGHT?
        LD      C,01111111B     ;SET TO COLUMN 8
        CP      C
        JR      Z,MOVELT        ;MOVE IT LEFT?
        POP     BC
        RET
MOVERT  POP     BC              ;PREVIOUS X OFFSET
        LD      A,B
        ADD     A,2D
        LD      B,A             ;MOVE RIGHT 2 PIXELS
        RET
MOVELT  POP     BC              ;PREVIOUS X OFFSET
        LD      A,B
        SUB     2
        LD      B,A             ;MOVE LEFT 2 PIXELS
        RET

;*****************************************************
;
;THIS ROUTINE CLEARS THE CRT, THEN WRITES THE AUTHOR'S
;NAME AND PICTURE'S NAME TO THE CRT
;
;*****************************************************

WRNAME  CALL    CLS
        LD      BC,42
        LD      HL,NAME
        LD      DE,4009H
        LDIR
        RET

;*****************************************************
;
;THIS IS THE LOOKUP TABLE FOR THE PICTURE OF AN APPLE..
;
;*****************************************************

PICTURE .ORG    7000H
        .DB     120,156,119,156,118,156,117,157,116,156
        .DB     115,155,114,154,113,153,113,152,113,151
        .DB     113,150,113,148,114,147,115,146,116,145
        .DB     117,144,118,144,119,144,120,144,121,144
        .DB     122,144,123,144,124,145,125,146,126,147
        .DB     127,148,127,149,127,150,127,151,127,152
        .DB     127,153,126,154,125,155,124,156,123,127
        .DB     122,156,121,156,120,157,120,158,120,159
        .DB     121,160,121,161,121,162,121,163,122,163
        .DB     122,162,122,161,123,162,123,163,124,163

        .END
