;***********************************************************
;       JIM HAIGHT
;       FINLEY LAB #5
;       OCTOBER 15, 1990
;
;***********************************************************
; INITIALIZE GLOBAL VARIABLES & POINTERS
;***********************************************************
        .ORG    8300H
NAME    .TEXT   "JIM HAIGHT"
LAB     .TEXT   "FINLEY LAB 5"
PA_CONT .EQU    81
PB_CONT .EQU    83
PA_DATA .EQU    80
PB_DATA .EQU    82
CTC_0   .EQU    84
CTC_1   .EQU    85
CTC_2   .EQU    86
COUNT   .BYTE   00
WORD    .BLOCK  1
WORD_M  .BLOCK  1
WORD_L  .BLOCK  1
VIDEOPT .EQU    0E000H
VIDH_P  .EQU    0E0CFH
VIDL_P  .EQU    0E0D0H
VIDH_C  .EQU    0E110H
VIDL_C  .EQU    0E111H
KEYPR   .EQU    0E08FH
;
;***********************************************************
;       LOOK-UP TABLE FOR PIO-CRT OUTPUT
;***********************************************************
        .ORG    9000H
        .dB     $30,$31,$32,$33,$34,$35
        .dB     $36,$37,$38,$39,$41,$42
        .dB     $43,$44,$45,$46
;
;***********************************************************
; SETTING UP ISR TABLE - REG: HL
;***********************************************************
        .ORG    8400H
        DI
        IM      2
        LD      HL,8800H
        LD      (HL),00
        INC     HL
        LD      (HL),85H
        INC     HL
        INC     HL
        INC     HL
        LD      (HL),00
        INC     HL
        LD      (HL),86H
;
;***********************************************************
;       INITIALIZE COUNTERS - REG: A
;***********************************************************
        LD      A,00
        LD      (COUNT),A
        LD      (WORD),A
        LD      (WORD_L),A
        LD      (WORD_M),A
;
;***********************************************************
; INITIALIZE I REGISTER - REG: A, I
;***********************************************************
        LD      A,88H           ; INITIALIZE
        LD      I,A             ; I REGISTER
;
;***********************************************************
; INITIALIZE PIO - REG: A
;***********************************************************
INIT_P  LD      A,01001111B     ; PORT A = MODE 1
        OUT     (PA_CONT),A     ; SEND CONTROL WORD
        LD      A,10000111B     ; PORT A INTERRUPT
        OUT     (PA_CONT),A     ; CONTROL WORD
        LD      A,00000000B     ; PORT A
        OUT     (PA_CONT),A
        LD      A,00001111B     ; PORT A = MODE 0
        OUT     (PB_CONT),A     ; SEND CONTROL WORD
        LD      A,00H
        OUT     (PB_CONT),A
        LD      A,00000111B     ; PORT B INTERRUPT
        OUT     (PB_CONT),A     ; CONTROL WORD
;
;***********************************************************
; INTITALIZE CTC - REG: A
;***********************************************************
INIT_C  LD      A,00100101B     ; CHANNEL CONTROL
        OUT     (CTC_0),A       ; WORD FOR CH #0
        LD      A,00H           ; TIME CONSTANT
        OUT     (CTC_0),A       ; EQUAL TO 256
        LD      A,00H           ; INTERRUPT VECTOR
        OUT     (CTC_0),A       ; WORD FOR CH #0
        LD      A,01100101B     ; CHANNEL CONTROL
        OUT     (CTC_1),A       ; WORD FOR CH #1
        LD      A,37H           ; TIME CONSTANT
        OUT     (CTC_1),A       ; EQUAL TO 55
        LD      A,11100101B     ; CHANNEL CONTROL
        OUT     (CTC_2),A       ; WORD FOR CH #2
        LD      A,05H           ; TIME CONSTANT
        OUT     (CTC_2),A       ; EQUAL TO 5
        CALL    CLEAR           ; CLEAR CRT
        CALL    DISPLAY         ; DISPLAY NAME ON CRT
        EI
MAIN    RST     18H             ; SCAN KEYBOARD
        JR      Z,MAIN          ; FOR A KEY PRESS
        LD      (KEYPR),A       ; VIDEO POINTER
        JR      MAIN
;
;***********************************************************
; CLEAR SCREEN SUBROUTINE - REG: A
;***********************************************************
CLEAR   LD      A,0CH
        RST     10H
        RET
;
;***********************************************************
; DISPLAY NAME AND LAB NUMBER - REG: BC, DE, HL
;***********************************************************
DISPLAY LD      HL,NAME         ; LOAD POINTER TO DATA
        LD      DE,0E000H+42    ; LOAD POINTER TO VIDEO RAM
        LD      BC,10           ; LOAD COUNT
        LDIR
        LD      HL,LAB          ; LOAD POINTER TO DATA
        LD      DE,0E000H+106    ; LOAD POINTER TO VIDEO RAM
        LD      BC,12           ; LOAD COUNT
        LDIR
        RET
;
;***********************************************************
; ISR_PIO MODULE - REG: ALL REGISTERS EXCHANGED
;***********************************************************
        .ORG    8500H
ISR_PIO EX      AF,AF'
        EXX
        IN      A,(PA_DATA)     ; DATA FROM PORT A
        LD      (WORD),A        ; SAVE DATA
        CP      100             ; OVER 99
        JR      C,SMALL         ; IF NOT SKIP
        LD      A,$FF           ; LOAD THE ACC. WITH
        OUT     (PB_DATA),A     ; OUTPUT FF TO LEDS
        LD      A,(WORD)        ; LOAD ACC. WITH DATA
        AND     11110000B       ; MASK OFF LOW BITS
        LD      B,04            ; SETUP COUNT
LOOP    RRC     A               ; ROTATE HIGH BITS
        DEC     B               ; TO LOWER BITS
        JR      NZ,LOOP
        LD      H,90H           ; POINTER TO LOOK-UP TABLE
        LD      L,A
        LD      A,(HL)          ; LOAD ACC. WITH CODE
        LD      (VIDH_P),A      ; FOR VIDEO RAM
        LD      A,(WORD)        ; RELOAD THE ORIGINAL DATA
        AND     00001111B       ; MASK OFF HIGH BITS
        LD      L,A             ; LOAD L FOR TABLE
        LD      A,(HL)          ; LOAD ACC. WITH CODE
        LD      (VIDL_P),A      ; OUTPUT TO VIDEO RAM
        JR      NONO
SMALL   CALL    BCD_CON         ; UNPACK INTO BCD
        LD      A,(WORD_L)      ; RELOAD LSB
        ADD     A,30H           ; SET UP LSB FOR VIDEO
        LD      (VIDL_P),A      ; OUTPUT LSB TO VIDEO RAM
        LD      A,D
        ADD     A,30H
        LD      (VIDH_P),A      ; OUTPUT MSB TO VIDEO RAM
        LD      B,4             ; REPACK BCD
        LD      A,(WORD_M)      ;
ROTA    RLC     A               ; ROTATE FROM LOWER TO
        DEC     B               ; HIGHER BITS
        JR      NZ,ROTA         ; UNTIL COUNT = ZERO
        LD      D,A             ; SAVE MSB IN D
        LD      A,(WORD_L)      ; LOAD LSB INTO ACC.
        ADD     A,D             ; REPACKED BCD
        OUT     (PB_DATA),A     ; OUTPUT TO LEDS
        LD      A,01001111B     ; PORT A = MODE 1
        OUT     (PA_CONT),A     ; SEND CONTROL WORD
        LD      A,10000111B     ; PORT A INTERRUPT
        OUT     (PA_CONT),A     ; CONTROL WORD
        LD      A,00000000B     ; PORT A
        OUT     (PA_CONT),A
        LD      A,00001111B     ; PORT A = MODE 0
        OUT     (PB_CONT),A     ; SEND CONTROL WORD
        LD      A,00H
        OUT     (PB_CONT),A
        LD      A,00000111B     ; PORT B INTERRUPT
        OUT     (PB_CONT),A     ; CONTROL WORD
NONO    EX      AF,AF'
        EXX
        EI
        RETI
;
;***********************************************************
; ISR_CTC MODULE - REG: ALL REGISTERS EXCHANGED
;***********************************************************
        .ORG    8600H
ISR_CTC EX      AF,AF'
        EXX
        LD      A,(COUNT)       ; LOAD ACC. WITH COUNT
        INC     A               ; INCREMENT COUNT
        LD      (COUNT),A       ; RESAVE NEW COUNT
        LD      (WORD),A        ; SAVE FOR OUT TO VIDEO RAM
        CALL    BCD_CON         ; UNPACK BINARY TO BCD
        LD      A,(WORD_L)      ; RELOAD LSB
        ADD     A,30H           ; SET UP LSB TO BE
        LD      (VIDL_C),A      ; OUTPUTED TO VIDEO RAM
        LD      A,D             ; SET UP MSB TO BE
        ADD     A,30H           ; OUTPUTED TO VIDEO RAM
        LD      (VIDH_C),A
        EX      AF,AF'
        EXX
        EI
        RETI
;
;***********************************************************
; BCD CONVERSION SUBROUTINE - CONVERTS A BINARY INPUT
;     TO A BCD VALUE FOR OUTPUT - REG: A ,C, D
;***********************************************************
        .ORG    8700H
BCD_CON LD      D,0             ; SET REG. D TO 00
        LD      A,(WORD)        ; LOAD ACC WITH DATA
REPEAT  CP      10              ; IS DATA LESS THAN 10
        JR      C,STOP          ; IF YES SKIP THE REST
        INC     D               ; INCREMENT THE MSB
        SUB     10              ; REDUCE LSB BY 10
        JR      REPEAT          ; REPEAT UNTIL LSB IS
                                ; LESS THAN 10 DECIMAL
STOP    LD      (WORD_L),A      ; SAVE LSB OF UNPACKED BCD
        LD      A,D             ; LOAD ACC. WITH MSB
        LD      (WORD_M),A      ; SAVE MSB OF UNPACKED BCD
        RET
        .END

