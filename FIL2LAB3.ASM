;*****************************************************
;  Dan Hickey 6DA EET-484L
;  Lab #3 WIN LOSE OR DRAW
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
NAME    .TEXT   "DAN HICKEY"
        .TEXT   "          "
        .TEXT   "ROCK CHALK JAYHAWK"
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
        CP      72D

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
        LD      BC,38
        LD      HL,NAME
        LD      DE,4009H
        LDIR
        RET

;*****************************************************
;
;THIS IS THE LOOKUP TABLE FOR THE PICTURE OF A PEACE SIGN
;
;*****************************************************

PICTURE .ORG    7000H
        .DB     60,86,60,88,61,89,61,90,62,92
        .DB     62,95,62,97,63,98,63,99,63,100
        .DB     64,101,64,102,64,103,65,104,66,106
        .DB     67,108,68,109,69,110,71,111,71,112
        .DB     72,113,73,114,74,115,75,116,76,116
        .DB     77,117,78,118,79,118,81,119,81,120
        .DB     82,121,83,121,84,122,85,122,86,122
        .DB     87,123,88,123,89,124,90,124,91,124
        .DB     92,124,93,124,94,125,95,125,96,125
        .DB     97,125,98,125,99,125,100,125,101,125
        .DB     102,125,103,124,104,124,105,123,106,123
        .DB     107,122,108,122,109,122,110,121,111,121
        .DB     112,120,113,120,114,119,115,118,116,118
        .DB     117,117,118,117,119,116,120,116,121,115
        .DB     122,115,123,114,124,113,125,112,126,112
        .DB     129,111,132,108,135,107,138,109,141,112
        .DB     144,113,147,115,63,86,66,88,69,91
        .DB     72,92,75,92,78,94,71,79,75,84,75,77
        .DB     78,89,78,79,78,77,82,95,82,88,82,85
        .DB     82,80,82,74,85,94,85,89,85,85,85,81
        .DB     85,73,88,93,88,90,88,85,88,82,88,72
        .DB     92,92,92,84,92,70,95,92,95,85,95,69
        .DB     98,91,98,86,98,68,101,90,101,87,101,68
        .DB     104,90,104,87,104,67,107,89,107,67,110,89
        .DB     110,67,113,90,113,69,116,90,116,69,119,91
        .DB     119,69,122,91,104,125,107,129,110,131,113,133
        .DB     116,132,119,131,122,134,122,70,125,134,125,113
        .DB     125,92,125,71,125,65,128,135,128,130,128,126
        .DB     128,122,128,121,128,120,128,118,128,116,128,114
        .DB     128,112,128,93,128,74,128,64,129,126,129,124
        .DB     129,122,129,120,129,118,129,116,129,114,129,112
        .DB     129,110,130,126,130,124,130,122,130,120,130,118
        .DB     130,116,130,114,130,112,130,110,131,135,131,130
        .DB     131,126,131,124,131,122,131,120,131,118,131,116
        .DB     131,114,131,112,131,110,131,108,131,95,131,77
        .DB     131,62,132,126,132,124,132,122,132,120,132,118
        .DB     132,116,132,114,132,112,131,110,131,108,132,128
        .DB     133,128,133,126,133,124,133,122,133,120,133,118
        .DB     133,116,134,134,134,130,134,128,134,106,134,97
        .DB     134,80,134,61,137,135,137,129,137,124,137,108
        .DB     137,101,137,83,137,59,140,132,140,128,140,122
        .DB     140,111,140,87,140,58,143,131,143,126,143,118
        .DB     143,112,143,92,143,66,146,131,146,122,146,116
        .DB     146,97,146,61,149,130,149,119,149,116,149,112
        .DB     149,110,149,59,152,130,152,116,152,57,155,129
        .DB     155,54,158,128,158,63,161,127,161,62,164,124
        .DB     164,58,167,121,167,55,170,118,170,53,173,115
        .DB     173,53,176,113,176,60,179,109,179,55,182,106
        .DB     182,52,185,103,185,98,185,90,185,62,188,103
        .DB     188,99,188,96,188,89,188,82,188,62,190,80
        .DB     192,76,193,68,191,102,191,92,191,86,191,61
        .DB     194,88,194,86,196,84
        .END

