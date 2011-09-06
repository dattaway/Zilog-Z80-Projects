;************************************************
;
; DARYL ANDERSON
; DAC INTERFACE LAB
; EET 484L
; MAY 09,1991
;
; This Program will interface DAC hardware with
; Z80. It also display a picture on the O-scope
; using X-Y axis coordinates. The picture should
; be able move using the arrow keys. The names
; of the Programmer and the picture will be dis-
; played at the top-center of the screen.
;
;************************************************
; MAIN PROGRAM
;************************************************

        .ORG    7500H
        CALL    DISNAME
        CALL    INITIAL
BACK    CALL    ART
        CALL    CHECK
        JR      BACK
NAME    .TEXT   " DARYL ANDERSON "
ARTNAME .TEXT   "AIR NIKE"

;************************************************
;
; This subroutine will display programmer's and
; picture names, and clear screen.
;
; Register used: A,B,C,D,E,F,H,L
;
;************************************************

DISNAME PUSH    AF
        PUSH    BC
        PUSH    DE
        PUSH    HL

        LD      A,0CH      ;clear screen
        RST     10H

        LD      HL,NAME    ;programmer's name
        LD      DE,4009H
        LD      BC,12
        LDIR

        LD      HL,ARTNAME ;picture name
        LD      DE,4029H
        LD      BC,8
        LDIR

        POP     HL
        POP     DE
        POP     BC
        POP     AF
        RET

;************************************************
;
; This subroutine will initialize the X-Y offset.
;
; Register used: D,E
;
;************************************************

INITIAL LD      DE,00
        RET

;************************************************
;
; This subroutine will display the picture on the
; O-scope .
;
; Register used: A,B,C,F,H,L
;
;************************************************

ART     PUSH    AF
        PUSH    BC
        PUSH    DE
        PUSH    HL
        LD      HL,BEGIN
        LD      BC,009DH
AGAIN   LD      A,(HL)
        ADD     A,E
        OUT     (01),A
        INC     HL
        LD      A,(HL)
        ADD     A,D
        OUT     (00),A
        INC     HL
        DJNZ    AGAIN
        POP     HL
        POP     DE
        POP     BC
        POP     AF
        RET

;************************************************
;
; This subroutine check pressed key and will also
; move the picture accordingly.
;
; Register used: A,D,E,F
;
; Register affected: D,E
;
;************************************************

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



;************************************************
;
; DATA TABLE
;
;************************************************

BEGIN   .DB     (10,12),(13,14),(13,16)
        .DB     (13,18),(16,16),(19,18)
        .DB     (13,20),(13,22),(21,19)
        .DB     (19,20),(16,22),(13,24)
        .DB     (10,26),(24,20),(25,16)
        .DB     (26,14),(27,13),(29,12)
        .DB     (30,11),(25,24),(26,27)
        .DB     (27,29),(34,10),(38,11)
        .DB     (39,12),(40,20),(38,20)
        .DB     (36,22),(35,24),(35,26)
        .DB     (35,28),(41,13),(43,15)
        .DB     (44,16),(45,18),(46,19)
        .DB     (47,21),(48,23),(46,22)
        .DB     (44,21),(42,20),(35,30)
        .DB     (28,31),(21,30),(18,30)
        .DB     (15,30),(12,30),(10,30)
        .DB     (29,33),(10,34),(12,34)
        .DB     (15,34),(18,34),(21,34)
        .DB     (30,35),(36,35),(14,36)
        .DB     (21,37),(31,37),(14,38)
        .DB     (37,38),(32,39),(21,39)
        .DB     (13,39),(15,40),(11,41)
        .DB     (33,41),(38,41),(10,42)
        .DB     (16,42),(20,42),(18,43)
        .DB     (34,43),(39,45),(35,46)
        .DB     (36,48),(40,48),(37,50)
        .DB     (41,51),(38,52),(39,54)
        .DB     (42,54),(40,56),(43,56)
        .DB     (41,58),(44,59),(42,60)
        .DB     (43,62),(45,63),(44,65)
        .DB     (46,66),(46,69),(47,69)
        .DB     (47,71),(48,71),(49,74)
        .DB     (50,76)
        .END

