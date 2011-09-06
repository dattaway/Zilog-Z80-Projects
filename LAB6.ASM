;----------------------------------------
;                                       -
; NAME:  WAYNE A. GARDNER               -
; FINLEY LAB#3                          -
; COURSE:  EET 484L                     -
; DATE DUE:  5-9,1991                   -
; USING THE EDM-80'S MC8647, A PICTURE  -
; WILL APPEAR ON THE SCREEN USING THE   -
; X AND Y AXIS.  THE VERY FISRST ADD-   -
; RESS IS IN THE UPPER LEFT CORNER AND  -
; THE VERY FIRST POINT IS IN THE UPPER  -
; LEFT CORNER ALSO                      -
;                                       -
;ABUSED REGISTERS:  A,B,C,D,E,F,H,L     -
;                                       -
;----------------------------------------


;Main program

        .ORG    6300H

TABLE    .EQU    6500H
MONSTER  .EQU    8DH

BEGIN   CALL    CLS
        CALL    FIGURE
        HALT

;****************************************
;                                       *
; CLEARING THE VIDEO SCREEN IN GRAPHICS *
; MODE.                                 *
; ABUSED REGISTERS:  A,B,C,D,E,F,H,L    *
;                                       *
;****************************************

CLS     PUSH    AF
        PUSH    BC
        PUSH    DE
        PUSH    HL

   ;Clear screen

        LD      A,1FH
        OUT     (MONSTER),A
        LD      DE,4000H
        LD      BC,17FFH
ALIVE   LD      A,00H
        LD      (DE),A
        INC     DE
        DEC     BC
        LD      A,B
        OR      C
        JR      NZ,ALIVE

        POP     HL
        POP     DE
        POP     BC
        POP     AF
        RET

;****************************************
;                                       *
; This subroutine will display an       *
; apple on the video screen.            *
;                                       *
; REGISTERS USED:  A,B,C,F,H,L          *
;                                       *
; REGISTERS AFFECTED:  NONE             *
;                                       *
;****************************************

FIGURE  PUSH    AF
        PUSH    BC
        PUSH    DE
        PUSH    HL
        PUSH    IX

        LD      BC,72
        LD      IX,TABLE
INFO    PUSH    BC
        LD      B,(IX+0)
        LD      A,B
        SUB     00
        LD      B,A
        LD      DE,00
        XOR     A
        CP      B
LOOP    JP      Z,REPEAT
        ADD     A,20H
        JP      NC,OVERLAY
        INC     D
OVERLAY DEC     B
        JR      LOOP
REPEAT  LD      E,A
        LD      HL,57E0H
        XOR     A
        SBC     HL,DE
        INC     IX
        LD      A,(IX+0)
        LD      DE,00
REPEAT1 CP      08
        JP      C,END
        INC     E
        SUB     08
        JP      REPEAT1
END     XOR     A
        SBC     HL,DE
        LD      B,80H
        CP      0
REPEAT2 OR      0
        JP      Z,ENDING
        SRL     B
        DEC     A
        JP      REPEAT2
ENDING  LD      A,(HL)
        OR      B
        LD      (HL),A
        POP     BC
        DEC     BC
        INC     IX
        LD      A,B
        OR      C
        JR      NZ,INFO
        POP     IX
        POP     HL
        POP     DE
        POP     BC
        POP     AF
        RET


;****************************************
;                                       *
; THIS TABLE IS A PICTURE OF AN APPLE   *
; STARTING WITH THE Y AXIS.             *
;                                       *
;****************************************
        .ORG    6500H
TABLE   .DB     120,126,119,126,118,126
        .DB     117,127,116,126,115,125
        .DB     114,124,113,123,113,122
        .DB     113,121,113,120,113,119
        .DB     112,118,114,117,115,116
        .DB     116,117,118,114,119,114
        .DB     120,114,121,114,122,114
        .DB     123,114,124,115,125,116
        .DB     126,117,127,118,127,119
        .DB     127,120,127,121,127,122
        .DB     127,123,126,124,125,125
        .DB     124,126,123,127,122,133
        .DB     121,126,120,127,120,128
        .DB     120,129,121,130,121,131
        .DB     121,132,121,133,122,133
        .DB     123,133,124,133,123,132
        .DB     122,132,122,131,120,120
        .END





