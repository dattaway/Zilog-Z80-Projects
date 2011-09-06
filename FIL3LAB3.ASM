;****************************************
;                                       *
; NAME:  DONG VAN DO                    *
; LAB #3, Interfacing DAC               *
; COURSE:  EET 484                      *
; DATE:  JAN 15,1991                    *
;                                       *
; THIS PROGRAM IS WRITTEN TO GO WITH    *
; THE INTERFACING DAC HARDWARE.  IT     *
; WILL DRAW A PICTURE ON THE OSCOPE BY  *
; USING THE X-Y AXIS.  THE PICTURE ALSO *
; MOVES BASED ON THE ARROW KEYS.  THE   *
; PROGRAMMER'S NAME AND THE NAME OF THE *
; PICTURE WILL BE PLACED ON THE CRT     *
;                                       *
; REGISTERS USED:  A,B,C,D,E,F,H,L      *
;                                       *
;****************************************


;Main program

        .ORG    6500H

        CALL    CLNAME
        CALL    INITIAL
GOOD    CALL    PICTURE
        CALL    CHECK
        JR      GOOD


;****************************************
;                                       *
; This subroutine will clear the screen *
; then display the programmer's name    *
; and the name of the picture           *
;                                       *
; REGISTERS USED:  A,B,C,D,E,F,H,L      *
;                                       *
; REGISTERS AFFECTED:  NONE             *
;                                       *
;****************************************

CLNAME  PUSH    AF
        PUSH    BC
        PUSH    DE
        PUSH    HL

   ;Clear screen

        LD      A,0CH
        RST     10H

   ;Display programmer's name

        LD      HL,NAME
        LD      DE,4009H
        LD      BC,10
        LDIR

   ;Display the name of the picture

        LD      HL,NAMEPIC
        LD      DE,4025H
        LD      BC,24
        LDIR

        POP     HL
        POP     DE
        POP     BC
        POP     AF
        RET

;****************************************
;                                       *
; This subroutine will initialize the   *
; offsets X and Y                       *
;                                       *
; REGISTERS AFFECTED:  D,E              *
;                                       *
;****************************************

INITIAL LD      DE,00

        RET

;****************************************
;                                       *
; This subroutine will display the      *
; picture on the scope                  *
;                                       *
; REGISTERS USED:  A,B,C,F,H,L          *
;                                       *
; REGISTERS AFFECTED:  NONE             *
;                                       *
;****************************************

PICTURE PUSH    AF
        PUSH    BC
        PUSH    DE
        PUSH    HL
        
        LD      HL,START
        LD      BC,007CH
LOOP    LD      A,(HL)
        ADD     A,E
        OUT     (01),A
        INC     HL
        LD      A,(HL)
        ADD     A,D
        OUT     (00),A
        INC     HL
        DJNZ    LOOP

        POP     HL
        POP     DE
        POP     BC
        POP     AF
        RET

;****************************************
;                                       *
; This subroutine will check for a      *
; arrow key pressed then move the       *
; picture based on that arrow key       *
;                                       *
; REGISTERS USED:  A,D,E,F              *
;                                       *
; REGISTERS AFFECTED:  D,E              *
;                                       *
;****************************************

CHECK   PUSH    AF

        RST     18H
        JR      Z,OUT

        CP      1CH
        JR      NZ,DOWN
        INC     D
        INC     D
        INC     D
        JR      OUT

DOWN    CP      1AH
        JR      NZ,RIGHT
        DEC     D
        DEC     D
        DEC     D
        JR      OUT

RIGHT   CP      09H
        JR      NZ,LEFT
        INC     E
        INC     E
        INC     E
        JR      OUT

LEFT    CP      18H
        JR      NZ,OUT
        DEC     E
        DEC     E
        DEC     E

OUT     POP     AF
        RET

NAME    .TEXT   "DONG DO V."
NAMEPIC .TEXT   "THIS PICTURE IS THE FISH"

START   .DB     24,112,28,108,32,104,36,102,40,101
        .DB     44,100,48,99,52,98,56,97,60,96
        .DB     64,97,68,98,72,99,76,100,80,101
        .DB     84,102,88,103,92,104,96,105,100,106
        .DB     104,107,108,108,112,109,116,111,120,114
        .DB     124,116,128,118,132,119,136,121,140,122
        .DB     144,124,148,125,152,126,156,128,160,129
        .DB     164,130,168,131,172,132,176,133,180,134
        .DB     184,134,188,134,192,133
        .DB     190,128,186,124,185,120,182,116,180,112
        .DB     180,108,179,104,178,100,177,96,177,92
        .DB     177,88,178,84,179,80,180,76,182,72
        .DB     183,68,184,64,186,60,188,56,190,52
        .DB     192,48
        .DB     188,52,184,54,180,56,176,60,172,62
        .DB     168,66,164,70,160,74,157,78,156,80
        .DB     152,84,152,88,150,92,144,96,141,100
        .DB     137,104,133,108,129,112,126,116,120,120
        .DB     116,124,112,126,108,128,104,129,100,131
        .DB     96,132,92,133,88,134,84,135,80,136
        .DB     76,137,72,137,68,136,64,135,60,134
        .DB     56,133,52,132,48,130,44,128,40,126
        .DB     36,124,32,120,28,116
        .DB     60,134,64,138,66,140,68,144,70,148
        .DB     76,146,78,144,84,140,88,138,92,136
        .DB     96,132
        .DB     33,112,38,120,40,118,42,114,40,110
        .DB     38,108
        
        .END





