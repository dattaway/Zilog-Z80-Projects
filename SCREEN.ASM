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

START    .EQU    6700H
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
; This subroutine will display an AND   *
; gate on the video screen.             *
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

        LD      BC,72           ;PAIR OF X-Y
        LD      IX,START        ;X-Y TABLE
DATA    PUSH    BC
        LD      B,(IX+0)        ;GET DATA
        LD      A,B
        SUB     00
        LD      B,A
        LD      DE,00
        XOR     A
        CP      B
LOOP    JP      Z,NEXT
        ADD     A,20H
        JP      NC,OVER
        INC     D
OVER    DEC     B
        JR      LOOP
NEXT    LD      E,A
        LD      HL,57E0H        ;SET UP 1st ADDR
        XOR     A
        SBC     HL,DE           ;GO UPWARD
        INC     IX
        LD      A,(IX+0)
        LD      DE,00
LOOP2   CP      08
        JP      C,END
        INC     E
        SUB     08
        JP      LOOP2
END     XOR     A
        SBC     HL,DE
        LD      B,80H
        CP      0
LOOP3   OR      0
        JP      Z,DONE
        SRL     B
        DEC     A
        JP      LOOP3
DONE    LD      A,(HL)
        OR      B
        LD      (HL),A
        POP     BC
        DEC     BC
        INC     IX
        LD      A,B
        OR      C
        JR      NZ,DATA

        POP     IX
        POP     HL
        POP     DE
        POP     BC
        POP     AF
        RET


;****************************************
;                                       *
; THIS TABLE IS A PICTURE OF AND GATE   *
; STARTING WITH THE Y AXIS.             *
;                                       *
;****************************************
        .ORG    6700H

START   .DB     115,65,115,70,115,75
        .DB     115,80,115,85,75,65
        .DB     75,70,75,75,75,80
        .DB     75,85,130,160,130,155
        .DB     130,150,130,145,130,140
        .DB     130,135,130,130,130,125
        .DB     130,120,130,115,130,110
        .DB     130,105,130,100,130,95
        .DB     130,90,125,90,120,90
        .DB     115,90,110,90,105,90
        .DB     100,90,95,90,90,90
        .DB     85,90,80,90,75,90
        .DB     70,90,65,90,60,90
        .DB     60,95,60,100,60,105
        .DB     60,110,60,115,60,120
        .DB     60,125,60,130,60,135
        .DB     60,140,60,145,60,150
        .DB     60,155,60,160
        .DB     00,00,65,170,70,175
        .DB     75,180,80,183,85,186
        .DB     90,188,95,190,100,188
        .DB     105,186,110,183,115,180
        .DB     120,175,125,170,00,00
        .DB     95,190,95,200,95,205
        .DB     95,210





        .END





