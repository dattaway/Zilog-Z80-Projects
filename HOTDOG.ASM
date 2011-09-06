        .org    6300H
        LD      HL,VDMEM
        LD      BC,VDLEN
        CALL    VDCLS
        CALL    HEADERS
                LD      DE,0000H
REDRAW  CALL    DRAW
        CALL    SCANA
        JR      Z,REDRAW
        LD      B,UP
        CP      B
        JR      NZ,TRYDOWN
        INC     E
        JR      REDRAW
TRYDOWN LD      B,DOWN
        CP      B
        JR      NZ,TRYDOWN
        DEC     E
        JR      REDRAW
TRYRITE LD      B,RIGHT
        CP      B
        JR      NZ,TRYLEFT
        INC     D
        JR      REDRAW
TRYLEFT LD      B,LEFT
        CP      B
        JR      NZ,REDRAW
        DEC     D
        JR      REDRAW
HEADERS PUSH    BC
        PUSH    DE
        PUSH    HL
        LD      DE,VDMEM+9H
        LD      HL,HEADER1
        LD      BC,10D
        LDIR
        LD      DE,VDMEM+29H
        LD      HL,HEADER2
        LD      BC,7D
        LDIR
        POP     HL
        POP     DE
        POP     BC
        RET
VDCLS   PUSH    AF
VDLOOP  LD      (HL),SPACE
        INC     HL
        DEC     BC
        LD      A,C
        OR      B
        JR      NZ,VDLOOP
        POP     AF
        RET
DRAW    LD      BC,DTABLE1
        LD      HL,DTABLE
DRLOOP  LD      A,(HL)
        ADD     A,D
        OUT     (XPORT),A
        INC     HL
        DEC     BC
        LD      A,(HL)
        ADD     A,E
        OUT     (YPORT),A
        INC     HL
        DEC     BC
        LD      A,C
        OR      B
        JR      NZ,DRLOOP
        RET
VDMEM   .EQU    4000H
VDLEN   .EQU    3E8H
HEADER1 .TEXT   DAN HICKEY
HEADER2 .TEXT   JAYHAWK
SCANA   .EQU    00D7H
SPACE   .EQU    20H
UP      .EQU    1CH
DOWN    .EQU    1AH
RIGHT   .EQU    09H
LEFT    .EQU    18H
XPORT   .EQU    00H
YPORT   .EQU    01H
DTABLE1 .EQU    432D
        .ORG    6400H
DTABLE  .DB     45,45
        .END


