            .ORG        $6300
MASK        .EQU        $0F
NBYTES      .EQU        4096
ROW         .EQU        32
NMIJP       .EQU        $6016
INTJP       .EQU        $6013
SETVID      .EQU        $8D
MODE        .EQU        $1F
ROTATE      .DB         $80
KEY         .DB         $0A
VIDEO       .EQU        $4000
BUFFER      .EQU        $6500
ADC         .EQU        $00
DAC         .EQU        $01
START       CALL        CLEAR
            DI
            IM          1
            CALL        SETUP
            CALL        NDISP
            CALL        PRIMES

HERE        RST         18H
            JP          Z, HERE
            CP          53H
            JP          NZ, HERE

            IN          A,(ADC)
            OUT         (ADC),A
            EI
WAIT        LD          A,B
            OR          C
            JP          NZ,WAIT
            CALL        DDISP
            CALL        CONT
            CALL        CLEAR
            CALL        HIGHRES


SETUP       LD          HL,INTISR
            LD          (INTJP),HL
            LD          HL,NMIISR
            LD          (NMIJP),HL
            RET

PRIMES      LD          HL,BUFFER
            LD          BC,NBYTES
            EX          AF,AF'
            EXX
            LD          HL,BUFFER
            LD          BC,NBYTES
            RET

NDISP       LD          HL,NTEXT
            LD          DE,VIDEO
            LD          BC,11
            LDIR
            RET

DDISP       LD          HL,DTEXT
            LD          DE,VIDEO+6+(3*ROW)
            LD          BC,5
            LDIR
            RET

CONT        LD          HL,CTEXT
            LD          DE,VIDEO+4+(14*ROW)
            LD          BC,13
            LDIR
SCAN2       RST         18H
            JP          Z,SCAN2
            RET

CLEAR       LD          A,$0C
            RST         10H
            RET

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
            RET

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

HIGHRES     LD          A,MODE
            OUT         (SETVID),A
REDISP      LD          HL,VIDEO
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
            JP          REDISP
NTEXT       .TEXT       "DONG VAN DO"
DTEXT       .TEXT       "DONE!"
CTEXT       .TEXT       "PRESS ANY KEY"
           .END

                        

