        ;JIM HAIGHT  -  6DA FINLEY LAB #3
        ;
        ;PROGRAM STARTS:9000H
        ;
        ;
START   .ORG    $8300
DATA1   .DB     190,25,180,25,170,25,160,30,165,35,150,35,140,34
        .DB     130,33,120,35,110,34,100,33,90,33,89,26,80,25
        .DB     70,26,60,23,50,22,40,23,30,24,20,30,13,35
        .DB     12,40,11,45,11,50,11,55,11,60,11,65,11,70
        .DB     11,75,11,80,11,85,11,90,11,95,11,100,10,105
        .DB     10,110,10,115,10,120,11,125,13,130,17,136,17,140
        .DB     17,145,18,147,25,145,28,147,31,147,33,151,39,152
        .DB     45,153,50,154,55,154,57,153,62,154,66,154,70,155
        .DB     75,156,80,156,85,157,90,157,95,157,100,158,103,160
        .DB     107,170,108,175,112,180,114,185,117,190,121,195,125,198
        .DB     130,200,135,200,140,200,145,201,150,201,155,201,158,201
        .DB     163,198,169,197,175,193,180,190,185,187,190,193,195,178
        .DB     200,172,204,164,210,164,215,163,220,161,225,158,230,155
        .DB     232,150,233,145,237,143,240,140,236,138,236,132,236,126
        .DB     236,120,236,115,236,110,236,105,236,100,238,95,239,90
        .DB     240,85,241,80,240,75,239,70,238,65,237,60,234,55
        .DB     232,50,229,45,225,40,219,35,212,30,208,27,204,26
        .DB     198,24,150,30,145,31,140,32,135,34,130,37,125,42
        .DB     120,51,117,60,116,65,116,70,117,75,118,80,120,85
        .DB     122,90,125,95,128,100,134,105,150,110,150,114,155,115
        .DB     160,116,165,116,170,114,175,113,218,110,185,106,190,100
        .DB     192,95,194,90,195,85,195,80,194,75,194,70,193,65
        .DB     192,60,189,55,187,50,184,45,176,40,175,38,170,35
        .DB     166,32,160,31,155,30
XOFFSET .DB     00
YOFFSET .DB     00
HTXT    .TEXT   " JIM HAIGHT "  ;HEADER TEXT
MTXT    .TEXT   "MICROS LAB#3"  ;MORE TEXT
TITLE   .TEXT   " NIKON 8008 "  ;TITLE TEXT
        .ORG    $9000           ;START THE PROGRAM
        CALL    CLEAR           ;CLEAR THE CRT
        CALL    INIT            ;DISPLAY NAME AND CLASS
        LD      IX,XOFFSET      ;SET UP X OFFSET
        LD      IY,YOFFSET      ;SET UP Y OFFSET
RESTART LD      BC,164          ;INIT # OF PIXELS
        LD      DE,DATA1        ;POINTER TO DATA
        CALL    DISPLAY         ;DISPLAY TO SCOPE
        CALL    SCANKEY         ;SCAN KEYBOARD
        JP      Z,DLOOP2        ;NO KEY
        PUSH    AF              ;SAVE A
        CP      $10             ;UP ARROW?
        JP      Z,UP            ;YES, GOTO UP
        CP      $0F             ;LEFT ARROW?
        JP      Z,LEFT          ;YES, GOTO LEFT
        CP      $08             ;RIGHT ARROW?
        JP      Z,RIGHT         ;YES, GOTO RIGHT
        CP      $17             ;DOWN ARROW?
        JP      Z,DOWN          ;YES, GOTO DOWN
DLOOP   POP     AF              ;GET AF BACK
DLOOP2  JP      RESTART         ;NO ARROWS PRESSED
        ;
        ;
;**********************************************************************************************
; DESCRIPTION: This rountine will delay for the count of DE                                  *
;                                                                                            *
; REGISTERS AFFECTED: DE                                                                     *
;**********************************************************************************************
                           ;
                           ;
DELAY   PUSH    AF         ;Save contents of A
WAIT    LD      (IX+00),00 ;Use a lot of T-states (19)
        DEC     DE         ;Decrement delay counter
        LD      A,D        ;Check DE = 0
        OR      E          ;
        JR      NZ,WAIT    ;Repeat until DE = 0
        POP     AF         ;Reload A with original data
        RET                ;Return to main program
                           ;
                           ;
SCANKEY PUSH    BC         ;SAVE BC VALUE
        PUSH    DE         ;SAVE DE VALUE
        PUSH    HL         ;SAVE HL VALUE
        LD      HL,$F901   ;SET POINTER TO KEYBOARD
NEWROW  LD      A,(HL)     ;READ FIRST ROW OF KEYBOARD
        CP      $FF        ;CHECK TO SEE IF A KEY WAS PRESSED
        JR      NZ,FOUND   ;FOUND A KEY BEING PRESSED
        RLC     L          ;NO KEY WAS PRESSED, TRY NEXT ROW
        JR      NC,NEWROW  ;TRY NEW ROWS UNTIL ALL HAVE BEEN SCANNED
        XOR     A          ;CLEAR A AND SET Z FLAG (NO KEY PRESSED)
DONE    POP     HL         ;GET HL BACK
        POP     DE         ;GET DE BACK
        POP     BC         ;GET BC BACK
        RET                ;RETURN TO MAIN PROGRAM
                           ;
                           ;
;**********************************************************************************************
; DESCRIPTION: THIS WILL CALCULATE THE LOOKUP VALUE TO BE USED IN
;              THE LOOKUP ROUTINE.
;                                                                                            *
; REGISTERS AFFECTED: A, F                                                                   *
;**********************************************************************************************
                           ;
                           ;
FOUND   LD      D,A        ;KEY WAS PRESSED, SAVE INTO D
        XOR     A          ;CLEAR ACCUMULATOR
COLUMN  RRC     D          ;ROTATE TO FIND COLUMN
        JP      NC,ROW     ;FOUND COLUMN
        INC     A          ;INCREMENT FOR EACH COLUMN IF CARRY IS DETECTED
        JP      COLUMN     ;KEEP SEARCHING FOR ACTIVE COLUMN
ROW     RRC     L          ;ROTATE TO FIND ROW
        JP      C,DONE     ;ROW FOUND, RETURN TO MAIN PROGRAM
        ADD     A,08       ;ADD 8 FOR EACH ROW WIHTOUT AN ACTIVE KEY
        JP      ROW        ;KEEP SEARCHING FOR ACTIVE ROW
        ;
        ;
DISPLAY LD      A,(DE)     ;GET X DATA
        ADD     A,(IX+00)  ;ADD X OFFSET
        OUT     (00),A     ;SEND X DATA
        INC     DE         ;MOVE TO Y DATA
        LD      A,(DE)     ;GET Y DATA
        ADD     A,(IY+00)  ;ADD Y OFFSET
        OUT     (01),A     ;SEND Y DATA
        INC     DE         ;MOVE TO X DATA
        DEC     BC         ;DEC NUMBER OF PIXELS
        LD      A,B        ;CHECK TO SEE
        OR      C          ;IF NUMBER OF
        JP      NZ,DISPLAY ;PIXELS = 0?
        RET                ;DONE DISPLAYING PICTURE
        ;
        ;
UP      INC     (IY+00)    ;GET Y OFFSET
        JP      DLOOP      ;RETURN
        ;
        ;
DOWN    DEC     (IY+00)    ;GET Y OFFSET
        JP      DLOOP      ;RETURN
        ;
        ;
LEFT    DEC     (IX+00)    ;GET X OFFSET
        JP      DLOOP      ;RETURN
        ;
        ;
RIGHT   INC     (IX+00)    ;GET X OFFSET
        JP      DLOOP      ;RETURN
        ;
        ;
;**************************************************
; DESCRIPTION: CLEARS THE SCREEN USING RST 10    *
;                                                *
; REGISTERS AFFECTED: A, E, F                    *
;*************************************************
        ;
        ;
CLEAR   LD      A,$0C           ;LOAD CLEAR CODE
        RST     10H             ;CLEAR SCREEN
        RET                     ;RETURN TO MAIN
        ;
        ;
;**************************************************
; DESCRIPTION: PRINTS NAME AND CLASS INFORMATION *
;                                                *
; REGISTERS AFFECTED: B, C, D, E, H, L,          *
;                                                *
;**************************************************
        ;
        ;        ;
INIT    LD      HL,HTXT         ;POINTER TO HEADER TXT
        LD      DE,$E000+10     ;POINTER TO VIDEO RAM
        LD      BC,12           ;# BYTES TO DISP
        LDIR                    ;DISPLAY TEXT
        LD      HL,MTXT         ;POINTER TO MORE TXT
        LD      DE,$E000+74     ;POINTER TO VIDEO RAM
        LD      BC,12           ;# BYTES TO DISPLAY
        LDIR                    ;DISPLAY TEXT
        LD      HL,TITLE        ;POINTER TO TITLE TEXT
        LD      DE,$E000+138    ;POINTER TO VIDEO RAM
        LD      BC,12           ;# BYTES TO DISPLAY
        LDIR                    ;DISPLAY TEXT
        RET                     ;RETURN  TO MAIN
        ;
        ;
        .END
