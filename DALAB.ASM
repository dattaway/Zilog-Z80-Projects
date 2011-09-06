;*****************************************************
;Name:    Daryl Anderson
;Term:    6DA
;Lab #3:  WIN, LOSE, or DRAW: AIR NIKE
;Date:    May 16, 1991
;*****************************************************
;INITIALIZE
;*****************************************************
DATA            .EQU    $6700
PORT_Y          .EQU    01
PIXELS          .EQU    157
;*****************************************************
;MAIN
;*****************************************************
                .ORG    $6500
                CALL    CLS
                CALL    PICTURE
                RET
;*****************************************************
;CLEAR SCREEN AND DISPLAY NAME
;REGISTERS AFFECTED:  A, B, C, D, E, F, H, L
;*****************************************************
CLS             LD      A,000CH
                RST     10H
                LD      HL,NAME
                LD      DE,4009H
                LD      BC,14
                LDIR
                LD      HL,PIC_NAME
                LD      DE,$4026
                LD      BC,8
                LDIR
                RET
;*****************************************************
;PICTURE SUBROUTINE
;*****************************************************
PICTURE         LD      C,PORT_Y
                LD      IX,OFFSET
LOOP            LD      HL,DATA
                LD      B,PIXELS
LOOP1           LD      A,(HL)
                ADD     A,(IX+0)
                OUT     (C),A
                INC     HL
                LD      A,(HL)
                ADD     A,(IX+1)
                DEC     C
                OUT     (C),A
                INC     C
                INC     HL
                DEC     B
                JR      NZ,LOOP1
                RST     18H
                CP      $09;CHECK FOR RIGHT KEY
                JR      NZ,LEFT
                INC     (IX+1)
                INC     (IX+1)
                INC     (IX+1)
                JR      LOOP
LEFT            CP      $18;CHECK FOR LEFT KEY
                JR      NZ,DOWN
                DEC     (IX+1)
                DEC     (IX+1)
                DEC     (IX+1)
                JR      LOOP
DOWN            CP      $1A;CHECK FOR DOWN KEY
                JR      NZ,UP
                DEC     (IX+0)
                DEC     (IX+0)
                DEC     (IX+0)
                JR      LOOP
UP              CP      $1C;CHECK FOR UP KEY
                JR      NZ,QUIT
                INC     (IX+0)
                INC     (IX+0)
                INC     (IX+0)
                JR      LOOP
QUIT            CP      $20;SPACE BAR FOR QUIT
                JR      NZ,LOOP
                RST     20H
                RET
;*****************************************************
;NAME AND PICTURE DESCRIPTION
;*****************************************************
                .ORG    $6400
NAME            .TEXT   "DARYL ANDERSON"
PIC_NAME        .TEXT   "AIR NIKE"
;*****************************************************
;DATA TABLE
;*****************************************************
OFFSET          .DB     00,00
DATA            .ORG    $6700
                .DB     10,12,13,14,13,16,13,18,16,16
                .DB     19,18,13,20,13,22,21,19,19,20
                .DB     16,22,13,24,10,26,24,20,25,16
                .DB     26,14,27,13,29,12,30,11,25,24
                .DB     26,27,27,29,34,10,38,11,39,12
                .DB     40,20,38,20,36,22,35,24,35,26
                .DB     35,28,41,13,43,15,44,16,45,18
                .DB     46,19,47,21,48,23,46,22,44,21
                .DB     42,20,35,30,28,31,21,30,18,30
                .DB     15,30,12,30,10,30,29,33,10,34
                .DB     12,34,15,34,18,34,21,34,30,35
                .DB     36,35,14,36,21,37,31,37,14,38
                .DB     37,38,32,39,21,39,13,39,15,40
                .DB     11,41,33,41,38,41,10,42,16,42
                .DB     20,42,18,43,34,43,39,45,35,46
                .DB     36,48,40,48,37,50,41,51,38,52
                .DB     39,54,42,54,40,56,43,56,41,58
                .DB     44,59,42,60,43,62,45,63,44,65
                .DB     46,66,46,69,47,69,47,71,48,71
                .DB     49,74,50,76
                .END
                
