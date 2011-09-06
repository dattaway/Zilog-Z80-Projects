;Wayne Gardner
;Lab #4: ADC, DAC
;
;
PORT_B          .EQU    $8D
MASK_BIT        .EQU    10000000B
CLS             .EQU    $00BC
SCANNING        .EQU    &00D7
ARROW_R         .EQU    9
ARROW_L         .EQU    $18
CR              .EQU    $0D
OFF_MAX         .EQU    20
PRTSTG          .EQU    $00D1
DELAY_CNT       .EQU    5000
MILLI_CNT       .EQU    $FF
SAMPLEOFNUM     .EQU    5120
ROW_SIZE        .EQU    $20
LAST_ROW        .EQU    $57E0
DAC             .EQU    $01
ADC             .EQU    $00
SCRN_SIZE       .EQU    $17FF
TOPOFSCRN       .EQU    $4000
TEXT_MODE       .EQU    $80
MODE_GRAP       .EQU    $97
;
;
;
        .ORG    $6012
        JP      ADC
        JP      DAC
;
;THE MAIN PROGRAM BEGINS
;
        .ORG    $6300
MAIN    CALL    INTS_INT
        CALL    WAIT
        CALL    DONE
        CALL    CLR_SCREEN
        CALL    DRAWING_WAVE
        RST     20H

;
;
;
;INTS_INT SUBROUTINE
;
;
INTS_INT        LD      HL,SAMPLEOFNUM
                LD      (CRAZY),HL
                LD      HL,DATA_RAM
                LD      (CRAZY+2),HL
                LD      HL,SAMPLEOFNUM
                LD      (CRAZY),HL
                LD      HL,DATA_RAM
                LD      (CRAZY+2),HL
                IM      1
                OUT     (ADC),A
                EI
                OUT     (ADC),A
                RET
;
;
;DAC_ISR SUBROUTINE
;
DAC_ISR         PUSH    AF
                PUSH    HL
                LD      HL,(CRAZY+2)
                LD      A,(HL)
                OUT     (DAC),A
                INC     HL
                LD      (CRAZY+2),HL
                LD      HL,(CRAZY)
                DEC     HL
                LD      A,L
                OR      H
                JR      NZ,END_DAC
                LD      HL,SAMPLEOFNUM
                LD      (CRAZY),HL
                LD      HL,DATA_RAM
                LD      (CRAZY+2),HL
END_DAC         POP     HL
                POP     AF
                RETN
;
;
;SHOW AND WAIT SUB
;
;
WAIT            CALL    CLS
                LD      HL,NAME
                CALL    PRTSTG
WAITING         LD      HL,(CRAZY)
                LD      A,L
                OR      H
                JR      NZ,WAITING
                RET
;
;
;DONE SUB
;
;
SAY_DONE        LD      HL,DONE
                CALL    PRTSTG
                LD      HL,DELAY_CNT
OUT             LD      A,MILLI_CNT
IN              DEC     A
                JR      NZ,IN
                DEC     HL
                LD      A,L
                OR      H
                JR      NZ,OUT
                RET
;
;
;DRAWING A WAVE SUB
;
;
DRAWING_WAVE    LD      A,MODE_GRAP
                OUT     (PORT_B),A
                LD      BC,ROW_SIZE
                LD      HL,LAST_ROW
                LD      D,MASK_BIT
                LD      E,ROW_SIZE
HOMEY           CALL    CLR_SCREEN
                LD      IX,DATA_RAM
NEXT            LD      A,(IX)
                SRL     A
                PUSH    HL
                OR      A
                JR      Z,CONTIN
LOOP            SBC     HL,BC
                DEC     A
                JR      NZ,LOOP
CONTIN          LD      A,(HL)
                OR      D
                LD      (HL),A
                POP     HL
                LD      A,(OFFSET)
                PUSH    BC
                LD      C,A
                ADD     IX,BC
                POP     BC
                RRC     D
                JR      NC,NEXT
                INC     HL
                DEC     E
                JR      NZ,NEXT
                CALL    SCAN_KEY
                JR      C,HOMEY
                LD      A,TEXT_MODE
                OUT     (PORT_B),A
                RET
;
;
;CLEAR SCREEN SUB
;
;
CLR_SCREEN      PUSH    AF
                PUSH    BC
                PUSH    DE
                PUSH    HL
                XOR     A
                LD      HL,TOPOFSCRN
                LD      (HL),A
                LD      DE,TOPOFSCRN+1
                LD      BC,SCRN_SIZE
                LDIR
                POP     HL
                POP     DE
                POP     BC
                POP     AF
                RET
;
;
;SCAN KEY SUB
;
;
SCAN_KEY        CALL    SCANNING
                JR      Z,SCAN_KEY
                CP      ARROW_R
                JR      NZ,LEFT_CHECK
                LD      A,(OFFSET)
                INC     A
                CP      OFF_MAX+1
                JR      Z,SCAN_KEY
                JR      C_SET
LEFT_CHECK      CP      ARROW_L
                JR      NZ,CR_CHECK
                LD      A,(OFFSET)
                DEC     A
                JR      Z,SCAN_KEY
C_SET           LD      (OFFSET),A
                SCF
                JR      ENDING
CR_CHECK        CP      CR
                JR      NZ,SCAN_KEY
                OR      A
ENDING          RET
;
;
;ADC SUB
;
;
ADC_ISR         OUT     (ADC),A
                PUSH    AF
                PUSH    HL
                LD      HL,(CRAZY+2)
                IN      A,(ADC)
                LD      (HL),A
                INC     HL
                LD      (CRAZY+2),HL
                LD      HL,(CRAZY)
                DEC     HL
                LD      (CRAZY),HL
                LD      A,L
                OR      H
                JR      Z,NO_MORE
                POP     HL
                POP     AF
                EI
                RETI
NO_MORE         POP     HL
                POP     AF
                RETI
;
;
;DATA
;
;
NAME            .TEXT           "WAYNE A. GARDNER\R\N"
                .DB             0
DONE            .TEXT           "I HOPE ITS DONE!!\R\N"
                .DB             0
OFFSET          .DB             1
CRAZY           .BLOCK          4       ;THIS IS FOR ADC AND DAC
DATA_RAM        .BLOCK          SAMPLEOFNUM
                .END



