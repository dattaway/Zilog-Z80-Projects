;****************************************
;                                       *
; NAME: Wayne A. Gardner                *
; LAB #4, ADC 0804                      *
; COURSE:  EET 484                      *
; DATE:  May   ,1991                    *
;                                       *
; This program is written to digitize   *
; the incoming signal.  It first will   *
; clear the screen then place the       *
; programmer's name on it.  It reads    *
; 5000 samples by using INT.  It will   *
; display the word "DONE!" arter        *
; reading the samples.  It uses high    *
; resolution graphics mode to display   *
; the waveform on the screen.  Keyboard *
; is used to change the rate of the     *
; pixels by hitting from 1 to 9.        *
;                                       *
; Registers used:  A,B,C,D,E,F,H,L      *
;                  IX,IY                *
;                                       *
;****************************************
            .ORG        6300H
            
MASK        .EQU        0FH
NBYTES      .EQU        4096
ROW         .EQU        32
NMIJP       .EQU        6025H
INTJP       .EQU        6020H
SETVID      .EQU        8DH
MODE        .EQU        1FH
ROTATE      .DB         80H
KEY         .DB         0AH
VIDEO       .EQU        4000H
BUFFER      .EQU        6500H
ADC         .EQU        00
DAC         .EQU        01


;****************************************
;                                       *
; Main program                          *
;                                       *
;****************************************

            .ORG        6305H

START       CALL        CLEAR
            DI
            IM          1
            CALL        INITIAL
            CALL        NDISP
           

HERE        RST         18H
            JP          Z, HERE
            CP          53H
            JP          NZ, HERE
            CALL        INITIAL1






            IN          A,(ADC)
            OUT         (ADC),A
            EI
WAIT        LD          A,B
            OR          C
            JP          NZ,WAIT
            CALL        DDISP
            CALL        CONT
            CALL        CLEAR
            CALL        GRAGH

;****************************************
;                                       *
; This subroutine will clear the        *
; screen.                               *
;                                       *
; Registers affected:  None             *
;                                       *
;****************************************

CLEAR       PUSH        AF

            LD          A,$0C
            RST         10H

            POP         AF
            RET


;****************************************
;                                       *
; This subroutine initialize the vector *
; pointers for INT and NMI              *
;                                       *
; Registors affected:  None             *
;                                       *
;****************************************


INITIAL     PUSH        HL

            LD          HL,INTISR
            LD          (INTJP),HL
            LD          HL,NMIISR
            LD          (NMIJP),HL

            POP         HL
            RET

;****************************************
;                                       *
; This subroutine initialize the        *
; storage pointer and the length of     *
; the it                                *
;                                       *
; Resisters affected:  B,C,H,L          *
;                                       *
;****************************************

INITIAL1    LD          HL,BUFFER
            LD          BC,NBYTES
            EX          AF,AF'
            EXX
            LD          HL,BUFFER
            LD          BC,NBYTES
            RET

;****************************************
;                                       *
; This subroutine displays the          *
; programmer's name on screen           *
;                                       *
; Registers affected:  None             *
;                                       *
;****************************************


NDISP       PUSH        BC
            PUSH        DE
            PUSH        HL

            LD          HL,NAME
            LD          DE,VIDEO
            LD          BC,16
            LDIR

            LD          HL,PRESS
            LD          DE,4045H
            LD          BC,23
            LDIR



            POP         HL
            POP         DE
            POP         BC

            RET

;****************************************
;                                       *
; This subroutine displays the word     *
; "DONE!" on screen.                    *
;                                       *
; Registers affected:  None             *
;                                       *
;****************************************

DDISP       PUSH        BC
            PUSH        DE
            PUSH        HL

            LD          HL,GONE
            LD          DE,4066H
            LD          BC,5
            LDIR

            POP         HL
            POP         DE
            POP         BC

            RET

;****************************************
;                                       *
; This subroutine puts a press-a-key    *
; message on screen.                    *
;                                       *
; Registers affected:  None             *
;                                       *
;****************************************


CONT        PUSH        BC
            PUSH        DE
            PUSH        HL

            LD          HL,GO_ON
            LD          DE,41C4H
            LD          BC,25
            LDIR
SCAN2       RST         18H
            JP          Z,SCAN2

            POP         HL
            POP         DE
            POP         BC

            RET


;****************************************
;                                       *
; This subroutine does the INT-ISR      *
;                                       *
; Registers affected:  B,C,H,L          *
;                                       *
;****************************************

INTISR      .ORG        $6400

            PUSH        AF
            IN          A,(ADC)
            OUT         (ADC),A
            LD          (HL),A
            INC         HL
            DEC         BC
            LD          A,B
            OR          C
            JP          Z,PASS
            EI
PASS        POP         AF

            RETI

;****************************************
;                                       *
; This subroutine does the NMI-ISR      *
;                                       *
; Registers affected:  B,C,H,L          *
;                                       *
;****************************************

NMIISR      .ORG        $6450

            EX          AF,AF'
            EXX
            LD          A,(HL)
            OUT         (DAC),A
            INC         HL
            DEC         BC
            LD          A,B
            OR          C
            JP          NZ,PASS2
            LD          BC,NBYTES
            LD          HL,BUFFER
PASS2       EXX
            EX          AF,AF'

            RETN

;****************************************
;                                       *
; This subroutine sets the hardware     *
; into the high resolution graphics     *
; mode and displays the waveform on     *
; the screen.                           *
;                                       *
; Registers affected:  A,B,C,H,L,IX,IY  *
;                                       *
;****************************************

GRAGH       LD          A,MODE
            OUT         (SETVID),A
REDONE      LD          HL,VIDEO
            LD          BC,NBYTES+(NBYTES/2)
CLRSCR      LD          A,$00
            LD          (HL),A
            INC         HL
            DEC         BC
            LD          A,B
            OR          C
            JP          NZ,CLRSCR
            LD          IY,VIDEO
            LD          BC,$2080
            LD          IX,BUFFER
            LD          DE,ROW
LOOP2       PUSH        IY
            POP         HL
            LD          A,(IX)
            SRL         A
LOOP1       JR          Z,OUT
            ADD         HL,DE
            DEC         A
            JP          LOOP1
OUT         LD          A,(HL)
            OR          C
            LD          (HL),A
            LD          A,(KEY)
INCR        INC         IX
            DEC         A
            JP          NZ,INCR
            RRC         C
            JP          NC,LOOP2
            INC         IY
            DJNZ        LOOP2
SCAN        RST         18H
            JP          Z,SCAN
            AND         MASK
            LD          (KEY),A
            JP          REDONE

NAME        .TEXT       "WAYNE A. GARDNER"
PRESS       .TEXT       "PRESS S KEY TO CONTINUE"
GONE        .TEXT       "DONE!"
GO_ON       .TEXT       "PRESS ANY KEY TO CONTINUE"

           .END

                        

