;
;JIM HAIGHT
;8D DATA COMM
;LAB #7
;
;PROFESSOR WHEELER
;
;UART WITH EDM-80 INTERFACE using XMODEM PROTOCOL
;ALLOWS FOR SERIAL COMMUNICATIONS VIA RS-232
;
;THE HOST WILL BE AN IBM PC SET UP ON 1200,N,8,1 WITHOUT HANDSHAKING
;THE DESIGN WILL ALLOW FULL DUPLEX COMMUNICATIONS WITH ERROR DETECTING
;
;
TXD     .EQU    $01             ;SET PORT ADDRESS TO READ TRANSMITTED DATA
RXD     .EQU    $02             ;SET PORT ADDRESS TO READ RECEIVED DATA
STATUS  .EQU    $04             ;SET PORT ADDRESS TO READ STATUS CONDITIONS
VID     .EQU    $4000           ;SETS POINTER TO START OF VIDEO RAM
LONG    .EQU    25              ;SETS LENGTH TEXT STRINGS TO DISPLAY
BLOCK   .EQU    $6F00           ;SETS UP 16 BIT POINTER FOR BLOCK COUNTER
DATAIN  .EQU    $6F02           ;POINTER TO CURRENT DATA IN POSITION
OLDDATA .EQU    $6F04           ;POINTS TO START OF CURRENT BLOCK DATA
TRIES   .EQU    $6F06           ;TRIES COUNTER
BCC_CHK .EQU    $6F08           ;LOCATION FOR BLOCK CHECK CHARACTER
;
NAK     .EQU    $15             ;HEX VALUE FOR "NAK"
ACK     .EQU    $06             ;HEX VALUE FOR "ACK"
;
;**********************************************************
;
        .ORG    $6500           ;START OF MAIN PROGRAM
        CALL    $00BC           ;CLEAR SCREEN AND HOME CURSOR
        CALL    HEADER          ;CALL NAME & CLASS HEADDER DISPLAY
;        CALL    DELAY           ;PAUSE FOR A COUPLE SECONDS TO READ NAME
;
        CALL    SETUP           ;SETUP POINTERS FOR DATA AND COUNTERS
NACK    LD      A,NAK           ;LOAD $15 TO START INCOMING DATA TRANSFER
        CALL    TXDATA          ;CHECK UART STATUS, SEND "NAK"
        IN      A,(STATUS)      ;READ IN DAV, (UART STATUS REGISTER)
        BIT     0,A             ;TEST FOR DAV==1, Z FLAG==0 IF YES
        JR      NZ,RDAV1        ;KEEP LOOKING FOR DATA AVAILABLE
LOOP    CALL    TIME            ;CHECK FOR 2 SEC TIME OUT
        IN      A,(STATUS)      ;READ IN UART STATUS REGISTER
        BIT     0,A             ;TEST FOR DAV==1, Z FLAG==0 IF YES
        JR      NZ,RDAV1        ;KEEP LOOKING FOR DATA AVAILABLE
        LD      A,(TRIES)       ;GET TRIES COUNTER VALUE
        DEC     A               ;DECREMENT TRIES COUNTER
        LD      (TRIES),A       ;SAVE NEW COUNTER VALUE
        JP      Z,$20           ;TRIES==0, TERMINATE PROGRAM (RST 20h)
        JP      LOOP            ;TRIES NOT==0, REPEAT LOOP
;
RDAV1   IN      A,(RXD)         ;GET DATA AT UART RECEIVER
        CP      $01             ;CHECK FOR START OF HEADDER
        JP      Z,SOH           ;JUMP TO SOH ROUTINE IF COMPARE IS VALID
        CP      $04             ;CHECK FOR END OF TRANSMISSION
        JP      Z,EOT           ;JUMP TO EOT ROUTINE IF COMPARE IS VALID
        JP      LOOP            ;GO BACK AND WAIT FOR A VALID CHARACTER
;
;**********************************************************
; SETUP POINTERS
;**********************************************************
;
SETUP   LD      A,$01           ;SET UP BLOCK NUMBER COUNTER
        LD      (BLOCK),A       ;SAVE BLOCK P[OINTER NUMBER TO MEM LOCATION
        LD      DE,$0000        ;PREPARE TO INITIALIZE BLOCK CHECK
        LD      (BCC_CHK),DE    ;SET BCC CHECK TO $00
        LD      DE,$7000        ;SET POINTER TO START OF DATA AREA
        LD      (DATAIN),DE     ;SET INPUT DATA POINTER
        LD      (OLDDATA),DE    ;SET UP POINTER IN CASE OF BLOCK FAILURE
        LD      A,$0A           ;SET TRIES COUNTER TO 10 TIMES
        LD      (TRIES),A       ;SAVE TO TRIES POINTER IN MEMORY
        RET                     ;RETURN TO MAIN PROGRAM
;
;**********************************************************
; TIME DELAY ROUTINE
;**********************************************************
;
TIME    LD      HL,$8000        ;LOAD POINTER ADDRESS TO ANYWHERE
        LD      DE,$8000        ;LOAD POINTER ADDRESS TO ANYWHERE
        LD      BC,$8000        ;LONG DELAY TIME
        LDIR                    ;WAIT A WHILE
        LD      HL,$8000        ;LOAD POINTER ADDRESS TO ANYWHERE
        LD      DE,$8000        ;LOAD POINTER ADDRESS TO ANYWHERE
        LD      BC,$8000        ;LONG DELAY TIME
        LDIR                    ;WAIT A WHILE
        RET                     ;RETURN TO MAIN PROGRAM
;
;**********************************************************
; START OF HEADDER RECEIVED - GET DATA AND CHECK FOR BLOCK & BCC ERRORS
;**********************************************************
;
SOH     LD      HL,(DATAIN)     ;SET POINTER TO DATA INPUT LOCATION
        LD      A,(BLOCK)       ;GET BLOCK NUMBER
        LD      DE,VID+121      ;SET LOCATION TO DISPLAY BLOCK NUMBER
        LD      (DE),A          ;WRITE BLOCK NUMBER TO CRT
        LD      C,A             ;PUT BLOCK NUMBER INTO C REGISTER
        LD      DE,(BCC_CHK)    ;SET UP POINTER FOR BCC CHECK BLOCK
RDAV2   CALL    DAV             ;CHECK FOR DATA AVAILABLE
        CP      C               ;COMPARE DATA RECEIVED TO BLOCK NUMBER
        JP      Z,BLK_OK        ;IF BLOCK # OK, CONTINUE
        LD      HL,(OLDDATA)    ;GET ORIGINAL STARTING POINT TO DATA IN AREA
        LD      (DATAIN),HL     ;RESET POINTER TO CORRECT STARTING PLACE
        JP      NACK            ;JUMP BACK AND SEND "NAK", REPEAT LOOP
;
BLK_OK  CALL    DAV             ;CHECK FOR DATA AVAILABLE
        ADD     A,C             ;ADD BLOCK # WITH 1's COMP BLOCK #
        INC     A               ;INC ACCUM
        JP      NZ,NACK         ;BLOCK # ERROR -> SEND "NAK" and REPEAT LOOP
;
        LD      HL,(DATAIN)     ;POINT TO MEMORY LOCATION FOR DATA
        LD      C,128           ;SET COUNTER FOR NUMBER OF DATA BYTES
D_BLK   LD      B,(BCC_CHK)     ;GET RUNNING BCC VALUE INTO B REGISTER
        CALL    DAV             ;CHECK FOR DATA AVAILABLE
        LD      (HL),A          ;SAVE BYTE INTO MEMORY LOCATION
        ADD     A,B             ;REVISE BCC VALUE
        LD      (BCC_CHK),A     ;SAVE NEW BCC VALUE INTO RAM LOCATION
        INC     HL              ;POINT TO NEXT MEMORY LOCATION
        DEC     C               ;DECREASE POINTER FOR NUMBER OF DATA BYTES
        JP      NZ,D_BLK        ;REPEAT LOOP UNTIL ALL DATA IS READ
;
        LD      B,A             ;SAVE BCC VALUE INTO B FOR COMPARASON
        CALL    DAV             ;CHECK FOR DATA AVAILABLE
        CP      B
        JP      Z,NEW_BLK       ;BLOCK OK, SETUP FOR NEXT BLOCK
;
        LD      HL,(OLDDATA)    ;GET OLD DATA STARTING ADDRESS
        LD      (DATAIN),HL     ;RESTORE OLD STARTING POINT FOR DATA BLOCK
        JP      NACK            ;BLOCK FAILED, RETRY TRANSMISSION & DEC TRIES
;
NEW_BLK LD      A,10            ;RESET NUMBER OF TRIES
        LD      (TRIES),A       ;SAVE TO POINTER IN MEMORY
        LD      A,(BLOCK)       ;GET CURRENT BLOCK COUNTER
        INC     A               ;INCREMENT BLOCK COUNTER
        LD      (BLOCK),A       ;SAVE NEW BLOCK COUNTER VALUE
        LD      A,$00           ;PREPARE TO RESET BCC CHECK VALUE
        LD      (BCC_CHK),A     ;RESET BLOCK CHECK TO $0000
        LD      HL,(DATAIN)     ;GET CURRENT STARTING POINT FOR DATA BLOCK
        LD      (OLDDATA),HL    ;SAVE NEW DATA STARTING ADDRESS
        LD      A,ACK           ;GET "ACK" CHARACTER READY TO SEND
        CALL    TXDATA          ;SEND "ACK" TO IBM
        JP      LOOP            ;GO BACK AND GET ANOTHER BLOCK !
;
;**********************************************************
; TRANSMIT DATA SUB ROUTINE -> TXDATA
;**********************************************************
;
TXDATA  PUSH    AF              ;SAVE ACCUMULATOR CONTENTS
WAIT    IN      A,(STATUS)      ;READ IN UART STATUS REGISTER
        BIT     1,A             ;TEST FOR TBMT==1
        JP      Z,WAIT          ;WAIT FOR TRANSMIT BUFFER TO CLEAR OUT
        POP     AF              ;GET BACK DATA IN ACCUMULATOR
        OUT     (TXD),A         ;SEND DATA TO UART TO BE TRANSMITTED
        RET                     ;RETURN TO MAIN PROGRAM
;
;**********************************************************
; CHECK FOR DATA AVAILABLE -> DAV
;**********************************************************
;
DAV     IN      A,(STATUS)      ;READ IN UART STATUS REGISTER
        BIT     0,A             ;TEST FOR DAV==1, WILL SET Z==0 FOR YES
        JR      Z,DAV           ;KEEP LOOKING FOR DATA AVAILABLE
        IN      A,(RXD)         ;GET DATA AT UART RECEIVER
        RET                     ;RETURN TO MAIN PROGRAM
;
;**********************************************************
; RECEIVE DATA SUB ROUTINE -> RXDATA
;**********************************************************
;
RXDATA  IN      A,(RXD)         ;READ IN UART STATUS REGISTER
        RET                     ;RETURN TO MAIN PROGRAM
;
;**********************************************************
; END OF TRANSMISSION SUBROUTINE
;**********************************************************
;
EOT     LD      A,NAK           ;GET "ACK" CHARACTER READY TO SEND
        CALL    TXDATA          ;SEND "ACK" TO IBM
        CALL    DONE            ;EOT RECEIVED, ALL DONE
        RST     20h
;        JP      LOOP            ;GO BACK AND GET ANOTHER BLOCK !
;
;**********************************************************
; HEADER DISPLAY ROUTINE -> HEADER
;**********************************************************
;
HEADER  LD      HL,NAME         ;LOAD NAME STRING FOR DISPLAY
        LD      DE,VID+35       ;SET POINTER TO VIDEO RAM
        LD      BC,LONG         ;LENGHT OF NAME STRING
        LDIR                    ;WRITE NAME TO SCREEN
        LD      HL,CLASS        ;LOAD CLASS STRING FOR DISPLAY
        LD      DE,VID+99       ;SET POINTER TO VIDEO RAM
        LD      BC,LONG         ;LENGHT OF CLASS STRING
        LDIR                    ;WRITE CLASS TO SCREEN
        CALL    DELAY           ;PAUSE FOR TIME TO READ OPENING HEADDER
        LD      HL,TITLE        ;LOAD TITLE STRING FOR DISPLAY
        LD      DE,VID+35       ;SET POINTER TO VIDEO RAM
        LD      BC,LONG         ;LENGHT OF NAME STRING
        LDIR                    ;WRITE TITLE TO SCREEN
        LD      HL,BLK_NUM      ;LOAD BLOCK NUMBER STRING FOR DISPLAY
        LD      DE,VID+99       ;SET POINTER TO VIDEO RAM
        LD      BC,LONG         ;LENGHT OF CLASS STRING
        LDIR                    ;WRITE STRING TO SCREEN
        RET                     ;RETURN TO MAIN PROGRAM
;
;**********************************************************
;
DSPBLK  LD      A,(BLOCK)       ;GET BLOCK NUMBER
        LD      DE,VID+121      ;SET LOCATION TO DISPLAY BLOCK NUMBER
        LD      (DE),A          ;WRITE BLOCK NUMBER TO CRT
        RET                     ;RETURN TO CALLING ROUTINE
;
;**********************************************************
;
DONE    LD      HL,ALLDONE      ;LOAD DONE STRING FOR DISPLAY
        LD      DE,VID+153      ;SET POINTER TO VIDEO RAM
        LD      BC,LONG         ;LENGHT OF CLASS STRING
        LDIR                    ;WRITE STRING TO SCREEN
;
;**********************************************************
; DELAY ROUTINE
;**********************************************************
;
DELAY   LD      HL,$8000        ;LOAD POINTER ADDRESS TO ANYWHERE
        LD      DE,$8000        ;LOAD POINTER ADDRESS TO ANYWHERE
        LD      BC,$8000        ;LONG DELAY TIME
        LDIR                    ;WAIT A WHILE
        LD      HL,$8000        ;LOAD POINTER ADDRESS TO ANYWHERE
        LD      DE,$8000        ;LOAD POINTER ADDRESS TO ANYWHERE
        LD      BC,$8000        ;LONG DELAY TIME
        LDIR                    ;WAIT A WHILE
        LD      HL,$8000        ;LOAD POINTER ADDRESS TO ANYWHERE
        LD      DE,$8000        ;LOAD POINTER ADDRESS TO ANYWHERE
        LD      BC,$8000        ;LONG DELAY TIME
        LDIR                    ;WAIT A WHILE
        LD      HL,$8000        ;LOAD POINTER ADDRESS TO ANYWHERE
        LD      DE,$8000        ;LOAD POINTER ADDRESS TO ANYWHERE
        LD      BC,$8000        ;LONG DELAY TIME
        LDIR                    ;WAIT A WHILE
        RET                     ;RETURN TO MAIN PROGRAM
;
;**********************************************************
; NAME AND CLASS TEXT STRINGS -> NAME, CLASS
;**********************************************************
;
NAME    .TEXT   "JIM HAIGHT - 8D DATA COMM"
CLASS   .TEXT   "PROFESSOR WHEELER - LAB 7"
TITLE   .TEXT   "     XMODEM RECEIVER     "
BLK_NUM .TEXT   "   BLOCK NUMBER  =>      "
ALLDONE .TEXT   "EOT RECEIVED   ALL DONE !"
;
;
   .END

