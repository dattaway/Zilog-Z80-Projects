START   .ORG    $8300
HTXT     .TEXT   "TIM SWAN"
MTXT     .TEXT   "MICROS LAB#4"
DTXT     .TEXT   "DIGITIZING DONE!"
CTXT    .TEXT   "PRESS ANY KEY TO CONTINUE!"
VIDEOPT .EQU    $E000
BUFFPT  .EQU    $8600
KEY     .DB     $01
        CALL    CLEAR           ;CLS
        DI                      ;DISABLE INT
        IM      1               ;IM1 READY
        LD      A,00            ;SET-UP
        LD      ($8013),A       ;FIRST INT
        LD      A,$84           ;SUB-
        LD      ($8014),A       ;ROUTINE
        LD      A,$00           ;SET-UP
        LD      ($8016),A       ;SECOND
        LD      A,$85           ;INTERRUPT
        LD      ($8017),A       ;SUB-NMI
        CALL    INIT            ;DISPLAY NAME AND CLASS
        LD      HL,BUFFPT       ;STORE DATA
        LD      BC,$1000        ;4096 BYTES
        EX      AF,AF'          ;EXCHANGE
        EXX                     ;EXCHANGE
        LD      HL,BUFFPT       ;MEMORY LOCATION
        LD      BC,$1000        ;4096
        IN      A,(01)          ;READ ADC
        OUT     (01),A          ;START ADC
        EI                      ;ENABLE INTERUPT
WAIT    LD      A,B             ;COUNT DOWN
        OR      C               ;CHECK
        JP      NZ,WAIT         ;WAITING FOR INT
        CALL    DIGTXT          ;DIGITIZING DONE
        CALL    CLEAR           ;CLS
WAIT1   CALL    HIGHRES         ;GRAPHICS - DOES NOT RETURN
        ;
        ;
        ;DONE
INTISR  .ORG    $8400
        PUSH    AF
        IN      A,(01)          ;READ ADC
        OUT     (01),A          ;START PULSE
        LD      (HL),A          ;DATA STORAGE
        INC     HL              ;
        DEC     BC              ;BYTE COUNT
        LD      A,B             ;CHECK
        OR      C               ;FOR
        JP      Z,AROUND        ;ZERO
        EI                      ;RE-ENABLE
AROUND  POP     AF              ;
        RETI                    ;DONE
        ;
        ;
        ;
        ;
NMI     .ORG    $8500
        EX      AF,AF'          ;
        EXX                     ;
        LD      A,(HL)          ;
        OUT     (00),A          ;
        INC     HL              ;
        DEC     BC              ;
        LD      A,B             ;
        OR      C               ;
        JP      NZ,SKIP         ;
        LD      BC,$1000        ;
        LD      HL,BUFFPT       ;
SKIP    EXX                     ;
        EX      AF,AF'          ;
        RETN                    ;
        ;
        ;
        ;
        ;
        ;
HIGHRES LD      HL,$F800        ;SET HIGH RES
        LD      (HL),$FE        ;
JUMP    LD      HL,$E000        ;SET UP
        LD      BC,6144         ;TO
CLHRES  LD      A,$00           ;CLEAR
        LD      (HL),A          ;CRT
        INC     HL              ;
        DEC     BC              ;DONE?
        LD      A,B             ;
        OR      C               ;
        JP      NZ,CLHRES       ;
DOIT    LD      IY,$E000        ;
        LD      B,32            ;
        LD      C,10000000B     ;
        LD      IX,BUFFPT       ;ADC INFO
        LD      DE,32           ;
LOOP2   PUSH    IY              ;
        POP     HL              ;
        LD      A,(IX)          ;
        SRL     A               ;
LOOP1   JP      Z,OUT           ;
        ADD     HL,DE           ;
        DEC     A               ;
        JP      LOOP1           ;
OUT     LD      A,(HL)          ;
        OR      C               ;
        LD      (HL),A          ;
        LD      A,(KEY)
MORE    INC     IX              ;
        DEC     A
        JP      NZ,MORE
        RRC     C               ;
        JP      NC,LOOP2        ;
        INC     IY              ;
        DJNZ    LOOP2           ;
MORE2   RST     18H             ;
        JP      Z,MORE2         ;
        AND     $0F             ;
        LD      (KEY),A         ;
        JP      JUMP            ;KEEP IT UP!
        ;
       ;
        ;
;**************************************************
;* DESCRIPTION: CLEARS THE SCREEN USING RST 10    *
;*                                                *
;* REGISTERS AFFECTED: A, E, F                    *
;*                                                *
;* FLAGS AFFECTED: CARRY                          *
;**************************************************
        ;
        ;
CLEAR   LD      A,$0C           ;LOAD CLEAR CODE
        RST     10H             ;CLEAR SCREEN
        RET                     ;RETURN TO MAIN
        ;
        ;
;**************************************************
;* DESCRIPTION: PRINTS NAME AND CLASS INFORMATION *
;*                                                *
;* REGISTERS AFFECTED: B, C, D, E, H, L,          *
;*                                                *
;* FLAGS AFFECTED: P/V, N, H                      *
;**************************************************
        ;
        ;        ;
INIT    LD      HL,HTXT         ;POINTER TO HEADER TXT
        LD      DE,$E000+12     ;POINTER TO VIDEO RAM
        LD      BC,8            ;# BYTES TO DISP
        LDIR                    ;DISPLAY TEXT
        LD      HL,MTXT         ;POINTER TO MORE TXT
        LD      DE,$E000+74     ;POINTER TO VIDEO RAM
        LD      BC,12           ;# BYTES TO DISPLAY
        LDIR                    ;DISPLAY TEXT
        RET                     ;RETURN  TO MAIN
        ;
        ;
        ;**********************************************
        ;
        ;
        ;
        ;
        ;
        ; *********************************************
DIGTXT  LD      HL,DTXT        ;DIGITIZING DONE
        LD      DE,VIDEOPT+8+(5*32)  ;POSITION
        LD      BC,15           ;
        LDIR                    ;JUST DO IT
        LD      HL,CTXT         ;CONTINUE
        LD      DE,VIDEOPT+3+(32*14)  ;
        LD      BC,26           ;
        LDIR                    ;
AGAIN   RST     18H             ;
        JP      Z,AGAIN         ;
        RET                     ;
       .end

