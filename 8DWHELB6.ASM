;
;JIM HAIGHT
;8D DATA COMM
;LAB #6
;
;PROFESSOR WHEELER
;
;UART WITH EDM-80 INTERFACE EMULATING A "DCE" TERMINAL
;ALLOWS FOR SERIAL COMMUNICATIONS VIA RS-232
;
;THE HOST WILL BE AN IBM PC SET UP ON 1200,N,8,1 WITHOUT HANDSHAKING
;THE DESIGN WILL ALLOW FULL DUPLEX COMMUNICATIONS WITHOUT ERROR CORRECTION
;
;
TXD     .EQU    $01
RXD     .EQU    $02
STATUS  .EQU    $04
VID     .EQU    $4000
LONG    .EQU    25
;
;
        .ORG    $6500           ;START OF MAIN PROGRAM
        CALL    $00BC           ;CLEAR SCREEN AND HOME CURSOR
        CALL    HEADER          ;CALL NAME & CLASS HEADDER DISPLAY
        CALL    DELAY           ;PAUSE FOR A COUPLE SECONDS TO READ NAME
AGAIN   CALL    RX_CHK          ;CHECK FOR INCOMING DATA FROM IBM
        JP      Z,NODATA        ;IF NO DATA, SKIP READ DATA ROUTINE
        CALL    RXDATA          ;GET DATA AT UART RECEIVE DATA PORT
        RST     10h             ;DISPLAY INCOMING DATA ON SCREEN
NODATA  RST     18h             ;CHECK KEYBOARD FOR A CHARACTER (KEY PRESSED)
        JP      Z,AGAIN         ;NO KEY PRESSED, REPEAT LOOP
        CALL    TXDATA          ;KEY WAS PRESSED, GOTO TRANSMIT ROUTINE
        JP      AGAIN
;
;**********************************************************
; RECEIVE DATA CHECK ROUTINE -> RX_CHK
;**********************************************************
;
RX_CHK  IN      A,(STATUS)      ;READ IN UART STATUS REGISTER
        BIT     0,A             ;TEST FOR DAV==1
        RET                     ;RETURN TO MAIN PROGRAM
;
;**********************************************************
; RECEIVE DATA SUB ROUTINE -> RXDATA
;**********************************************************
RXDATA  IN      A,(STATUS)      ;READ IN UART STATUS REGISTER
        RET                     ;RETURN TO MAIN PROGRAM
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
        OUT     (TXDATA),A      ;SEND DATA TO UART TO BE TRANSMITTED
        RET                     ;RETURN TO MAIN PROGRAM
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
        LD      DE,VID+67       ;SET POINTER TO VIDEO RAM
        LD      BC,LONG         ;LENGHT OF CLASS STRING
        LDIR                    ;WRITE CLASS TO SCREEN
        RET                     ;RETURN TO MAIN PROGRAM
;
;**********************************************************
; DELAY ROUTINE -> DELAY
;**********************************************************
;
DELAY   LD      HL,$0000        ;LOAD POINTER ADDRESS TO ANYWHERE
        LD      DE,$0000        ;LOAD POINTER ADDRESS TO ANYWHERE
        LD      BC,$FFFF        ;LONG DELAY TIME
        LDIR                    ;WAIT A WHILE
        RET                     ;RETURN TO MAIN PROGRAM
;
;**********************************************************
; NAME AND CLASS TEXT STRINGS -> NAME, CLASS
;**********************************************************
;
NAME    .TEXT   "JIM HAIGHT - 8D DATA COMM"
CLASS   .TEXT   "PROFESSOR WHEELER - LAB 6"
;

   .END

