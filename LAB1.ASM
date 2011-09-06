
;*******************************************************
; Name:           Thomas Harr                          *
; Lab:            #1, Add-on 2K * 8 Ram memory chip    *
; Professor:      Finley                               *
; Course:         EET 484L                             *
;                                                      *
; Description:    The purpose of this program is to    *
;                 check all the locations of a         *
;                 2K * 8 Ram add-on memory chip.       *
;                 If the Ram test succeeds, then the   *
;                 message Ram Ok along with my name    *
;                 is printed out to the screen.  If    *
;                 the Ram test fails, then the message *
;                 Ram Bad along with my name is        *
;                 printed out to the screen.           *
;                                                      *
; Registers used: A, B, C, F, H, L                     *
;*******************************************************



        ;Initialization
CLS     .EQU    00BCH
COUNT   .EQU    2048
HITOP   .EQU    8000H
TOHI    .EQU    88H
LOTOP   .EQU    80H
MESAGE  .EQU    00D1H
BADRAM  .EQU    6400H
OKRAM   .EQU    6450H



        ;Main Program
        .ORG    6500H
        CALL    CLS
        CALL    DTACHK
        CALL    ADDCHK
        RST     20H



        ;Subroutine to write data to Ram locations,
        ;complement the data, and read back the data
        ;while comparing it to the correct data.  If
        ;the data check passes then the program
        ;proceeeds.  Otherwise a subroutine is called
        ;to place a Bad Ram message to the screen.

DTACHK: LD      HL,HITOP
        LD      BC,COUNT
AGAIN:  LD      A,(HL)
        CPL
        LD      (HL),A
        CP      (HL)
        JP      NZ,RAMBAD
        CPL
        LD      (HL),A
        CP      (HL)
        JP      NZ,RAMBAD
        INC     HL
        DEC     BC
        LD      A,C
        OR      B
        JP      NZ,AGAIN
        RET



        ;Subroutine to fill Ram with a pattern and then
        ;read it back.  If the information is the same
        ;then the program proceeds, otherwise a
        ;subroutine to write Bad Ram to the screen is
        ;called.

ADDCHK: LD      HL,HITOP
LOOP:   LD      (HL),L
        INC     L
        JR      NZ,LOOP
LOOP2:  LD      A,(HL)
        CP      L
        JR      NZ,RAMBAD
        INC     L
        JR      NZ,LOOP2
        LD      A,TOHI
LOOP3:  LD      (HL),H
        INC     H
        CP      H
        JR      NZ,LOOP3
        LD      H,LOTOP
LOOP4:  LD      A,(HL)
        CP      H
        JR      NZ,RAMBAD
        LD      A,TOHI
        INC     H
        CP      H
        JR      NZ,LOOP4
        JR      RAMOK
        RET



        ;Subroutine to write Bad Ram to the screen

RAMBAD: LD      HL,BADRAM
        CALL    MESAGE
        HALT



        ;Subroutine to write Ok Ram to the screen

RAMOK:  LD      HL,OKRAM
        CALL    MESAGE
        HALT
        .END


