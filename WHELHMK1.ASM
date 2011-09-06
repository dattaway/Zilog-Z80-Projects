; JIM HAIGHT
; SECTION:RING BUFFER
; FOR:PROF. WHEELER
; NOTES - MONDAY  4-23-91
;
;**********************************************************
; INITALIZE SUBROUTINE
;    REGISTERS AFFECTED:HL
;    STACK SPACE USED:0 BYTES
;**********************************************************
;
BI_PTR  .DW     0               ;BUFFER IN POINTER
BO_PTR  .DW     0               ;BUFFER OUT POINTER
        .ORG    $7000           ;SET START ON LOGICAL PAGE BOUNDARY
BUFFER  .DEFS   $FF             ;SET SIZE OF BUFFER
        PUBLIC  INIT_           ;PUBLIC DOMAIN SOMETHING
INIT    LD      HL,+BUFFER      ;GET STARTING POINT OF BUFFER
        LD      (BI_PTR),HL     ;INITALIZE INPUT POINTER
        LD      (BO_PTR),HL     ;INITALIZE OUTPUT POINTER
        IM      1               ;SET UP INTERRUPT MODE
        EI                      ;ENABLE INTERRUPT
        RET                     ;RETURN FROM INITALIZE ROUTINE
;
;**********************************************************
; RECEIVE SUBROUTINE
;    REGISTERS AFFECTED:AF
;    STACK SPACE USED:8 BYTES INCLUDING THE CALL
;**********************************************************
;
RX      PUSH    HL              ;STORE CONTENTS ON STACK
        PUSH    DE              ;STORE CONTENTS ON STACK
        DI                      ;DISABLE INTERRUPT
        LD      HL,(BI_PTR)     ;GET CURRENT IN POSITION
        LD      DE,(BO_PTR)     ;GET CURRENT OUTPUT POINTER
        XOR     A               ;CLEAR CARRY FLAG
        SBC     HL,DE           ;CHECK FOR DATA IN BUFFER
        JR      Z,EXIT_RX       ;JUMP OUT IF NO DATA IS IN BUFFER
        LD      A,(DE)          ;DATA AVAILABLE - LOAD INTO ACCUMULATOR
        PUSH    AF              ;SAVE CONTENTS IN ACCUMULATOR
        INC     E               ;INCREMENT LOWER BYTE OF POINTER
        POP     AF              ;GET BACK ACCUMULATOR CONTENTS (DATA)
EXIT_RX POP     DE              ;RESTORE CONTENTS
        POP     HL              ;RESTORE CONTENTS
        EI                      ;ENABLE INTERRUPT
        RET                     ;RETURN FROM SUBROUTINE
;
;**********************************************************
; TRANSMIT INTERRUPT SUBROUTINE
;    -- UART IS THE ONLY INTERRUPTING DEVICE --
;    REGISTERS AFFECTED:NONE
;    STACK SPACE USED:2 BYTES INCLUDING THE CALL
;**********************************************************
;
        EX      AF,AF'          ;EXCHANGE WITH ALTERNATE REGISTER
        EXX                     ;EXCHANGE WITH ALTERNATE REGISTER SET
        LD      HL,(BI_PTR)     ;GET CURRENT IN POINTER POSITION
        IN      A,(RXDATA)      ;GET DATA FROM UART RECEIVE SECTION
        LD      (HL),A          ;LOAD DATA INTO BUFFER
        INC     L               ;INCREMENT LOWER BYTE OF POINTER
        LD      (BI_PTR),A      ;SAVE NEW INPUT POINTER LOCATION
        EXX                     ;GET BACK NORMAL REGISTER SET
        EX      AF,AF'          ;GET BACK NORMAL ACCUMULATOR AND FLAG REGISTER
        RETI                    ;RETURN FROM INTERRUPT ROUTINE
;
;**********************************************************
; MAIN PROGRAM
;**********************************************************
;
        CALL    INIT            ;SET UP INPUT AND OUTPUT POINTERS
LOOP    CALL    RX              ;GOTO RECEIVE SECTION AND WAIT FOR DATA
        JR      LOOP            ;REPEAT LOOP FOREVER
;
        .END
        
