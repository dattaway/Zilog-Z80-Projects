

ADC             .EQU    0000H
ARROWS          .EQU    1809H
DAC             .EQU    0001H
TIME            .EQU    3000
DISPLAY         .EQU    4000H
MESSAGE1        .EQU    0024
MESSAGE2        .EQU    18
INTJV           .EQU    6013H
NMIJV           .EQU    6016H
CSCRN           .EQU    4009H
DLNTH           .EQU    0004
NLNTH           .EQU    0016
ROWSCALE        .EQU    0020H
COUNT           .EQU    5000
BUFFER          .EQU    6300H
SCRATCH         .EQU    7690H
CLS             .EQU    00BCH
LCST            .EQU    00FFH
SCALE           .EQU    769AH
SCALE1          .EQU    0010
SCALAR          .EQU    0001
VIDPORT         .EQU    008DH
VIDMODE         .EQU    0097H
SHIFT           .EQU    0080H
TAKETWO         .EQU    000DH
;
;
;
                .ORG    7700H
MAIN            DI
                IM      1
                CALL    CLS
                CALL    INIT
                CALL    WRNAME
BACK            RST     18H
                JR      Z,BACK
                CALL    RE_INIT
                OUT     (ADC),A
                EI
WAIT            LD      BC,(SCRATCH+4)
                LD      A,B
                OR      C
                JR      NZ,WAIT
                DI
                CALL    DONE
                CALL    DELAY
REDRAW          CALL    CLEARGS
                CALL    DRAW
                LD      DE,00
                LD      (SCRATCH+7),DE
                CALL    SCALER
                LD      DE,(SCRATCH+6)
                LD      A,TAKETWO
                CP      D
                JR      Z,MAIN
                JR      REDRAW
;
;
;
;
INIT            LD      HL,INT_ISR
                LD      (INTJV),HL
                LD      HL,NMI_ISR
                LD      (NMIJV),HL
                LD      HL,BUFFER
                LD      (SCRATCH),HL
                LD      HL,COUNT
                LD      (SCRATCH+2),HL
                LD      (SCRATCH+4),HL
                LD      A,SCALE1
                LD      (SCALE),A
                LD      A,00
                OUT     (VIDPORT),A
                RET
;
;
;
;
WRNAME          CALL    CLS
                LD      BC,NLNTH
                LD      HL,NAME
                LD      DE,CSCRN
                LDIR
                LD      BC,MESSAGE1
                LD      HL,PRESS
                LD      DE,CSCRN+59
                LDIR
                RET
;
;
;
;
RE_INIT         LD      HL,BUFFER
                LD      BC,COUNT
                RET
;
;
;
;
INT_ISR         OUT     (ADC),A
                IN      A,(ADC)
                LD      (HL),A
                INC     HL
                DEC     BC
                LD      (SCRATCH+4),BC
                EI
                RETI
;
;
;
;
NMI_ISR         PUSH    AF
                PUSH    BC
                LD      BC,(SCRATCH+4)
                LD      A,B
                OR      C
                JR      NZ,NOTYET
                PUSH    IX
                PUSH    IY
                PUSH    DE
                PUSH    HL
                LD      HL,(SCRATCH)
                LD      BC,(SCRATCH+2)
O_SCOPE         LD      A,(HL)
                OUT     (DAC),A
                INC     HL
                DEC     BC
                LD      A,B
                OR      C
                JR      NZ,DD
                JR      O_SCOPE
DD              CALL    RE_INIT
                POP     HL
                POP     DE
                POP     IY
                POP     IX
NOTYET          POP     BC
                POP     AF
                RETN
;
;
;
;
DONE            PUSH    HL
                PUSH    AF
                PUSH    BC
                PUSH    DE
                CALL    CLS
                LD      BC,DLNTH
                LD      HL,DONE2
                LD      DE,CSCRN
                LDIR
                LD      BC,MESSAGE2
                LD      HL,ONESEC
                LD      DE,CSCRN+64
                LDIR
                POP     DE
                POP     BC
                POP     AF
                POP     HL
                RET
;
;
;
;
DELAY           PUSH    AF
                PUSH    DE
                PUSH    HL
                LD      DE,TIME
LOOPMLT         LD      A,LCST
LOOPDEL         DEC     A
                JR      NZ,LOOPDEL
                DEC     DE
                LD      A,E
                OR      D
                JR      NZ,LOOPMLT
                POP     HL
                POP     DE
                POP     AF
                RET
;
;
;
;
DRAW            LD      A,VIDMODE
                OUT     (VIDPORT),A
                LD      BC,ROWSCALE
                LD      HL,DISPLAY
                LD      DE,8020H
                LD      IX,BUFFER
NEXT_PIXEL      LD      A,(IX)
                SRL     A
                PUSH    HL
TOADD           ADD     HL,BC
                DEC     A
                JR      NZ,TOADD
                LD      A,(HL)
                OR      D
                LD      (HL),A
                POP     HL
                LD      A,(SCALE)
STEP            INC     IX
                DEC     A
                JR      NZ,STEP
                RRC     D
                JR      NC,NEXT_PIXEL
                INC     HL
                DEC     E
                JR      NZ,NEXT_PIXEL
                RET
;
;
;
;
CLEARGS         LD      HL,DISPLAY
                LD      BC,1800H
                XOR     A
                LD      (HL),A
                LD      DE,DISPLAY+1
                LDIR
                RET
;
;
;
;
SCALER          LD      BC,(SCALE)
CHRIN           LD      DE,ARROWS
                RST     18H
                JR      Z,CHRIN
                CP      D
                JR      NZ,NEXT
                LD      HL,SCALAR
OVER            DEC     BC
                DEC     HL
                LD      A,H
                OR      L
                JR      NZ,OVER
                LD      (SCALE),BC
                JR      SCALE_DONE
NEXT            CP      E
                JR      NZ,CHRIN
                LD      HL,SCALAR
SCALE_DONE      RET
;
;
;
;
NAME            .TEXT   "WAYNE A. GARDNER"
DONE2           .TEXT   "DONE"
PRESS           .TEXT   "PRESS A KEY TO CONTINUE"
ONESEC          .TEXT   "PLEASE WAIT A SEC"
                .END

                                










