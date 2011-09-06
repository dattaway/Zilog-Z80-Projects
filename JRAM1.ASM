;JIM HAIGHT - 6D
;
;FINLEY MICROS LAB #1  ->  TEST ADD-ON RAM MEMORY
;
;DESCRIPTION:  This Program will test a 2k x 8 Static Ram
;added at memory address A000 HEX.  It will read and write
;data to and from the SRAM and the CRT display will display
;the status of the RAM as "RAM OK" or "RAM BAD."  This program
;does a non-destructional test of the ram memory.
;
;INPUTS NEEDED: NONE
;
;OUTPUT: "RAM GOOD" = RAM RESPONDING PROPERELY
;        "RAM BAD " = RAM MALFUNCTION
;
;REGISTERS USED: A, B, C, D, E, F, H, L
;
;PROGRAM STARTS:841Ah
;
;SPACE USED ON STACK: 4 BYTES
;
;
        .ORG    $8400           ;START OF PROGRAM
GOOD    .TEXT   "RAM OK  "      ;RAM OK TEXT
BAD     .TEXT   "RAM BAD "      ;RAM BAD TEXT
NAME    .TEXT   "JIM HAIGHT"    ;NAME TEXT
        CALL    CLEAR           ;CLEAR THE CRT
        CALL    SETUP           ;DISPLAY NAME AND CLASS INFORMATION
AGAIN   LD      HL,$A000        ;POINTER TO 6116 SRAM
        LD      BC,2048         ;# BYTES IN RAM TO TEST
        LD      E,$00           ;SET E to 00h (CLEARS ERROR COUNTER)
LOOP    LD      A,(HL)          ;COPY MEMORY LOCATION TO ACCUMULATOR
        CALL    CHECK           ;CHECK BYTE OF MEMORY (COMPLEMENT FIRST)
        CALL    CHECK           ;CHECK BYTE OF MEMORY (BACK TO NORMAL)
        INC     HL              ;MOVE TO NEXT RAM LOCATION
        DEC     BC              ;CHECK TO SEE IF WE ARE AT END 2K * 8 RAM
        LD      A,B             ;
        OR      C               ;
        JR      NZ,LOOP         ;BC = 0 ?
        CALL    OK              ;DONE DISPLAY RAM OK OR RAM BAD
        JP      AGAIN           ;REPEAT
;
;DESCRIPTION: CLEARS THE SCREEN USING RST 10
;REGISTERS AFFECTED: A, E, F
;FLAGS AFFECTED: CY
;
CLEAR   LD      A,$0C           ;LOAD CODE FOR CLEARING SCREEN
        RST     10H             ;CLEAR SCREEN
        RET                     ;RETURN TO MAIN
;
;DESCRIPTION: PRINTS NAME AND CLASS INFORMATION
;REGISTERS AFFECTED: B, C, D, E, H, L,
;FLAGS AFFECTED: P/V, N, H
;
SETUP   LD      HL,NAME         ;SET POINTER TO NAME TEXT
        LD      DE,$E00A        ;SET POINTER TO VIDEO RAM
        LD      BC,0A           ;# BYTES TO DISPLAY FOR NAME
        LDIR                    ;DISPLAY NAME
        RET                     ;RETURN TO MAIN PROGRAM
;
;DESCRIPTION: CHECKS BYTES OF RAM BY COMPLEMENTING AND REWRITING
;IT BACK OUT, AND RE-READING IT.
;REGISTERS AFFECTED: A, F
;FLAGS AFFECTED: ALL
;
CHECK   CPL                     ;COMPLEMENTS BITS IN THE ACCUMULATOR
        LD      (HL),A          ;WRITE COMPLEMENT TO MEMORY LOCATION
        CP      (HL)            ;COMPARE BYTE IN MEMORY TO ACCUMULATOR
        CALL    NZ,ERROR        ;BAD RAM, GOTO ERROR SUBROUTINE
        RET                     ;RETURN TO MAIN PROGRAM
;
;DESCRIPTION: SET REGISTER E (ERROR) TO FF (-1) IF AN ERROR OCCURS.
;REGISTERS AFFECTED: E
;FLAGS AFFECTED: NONE
;
ERROR   LD      E,$FF           ;IF ERROR OCCURS, SET E TO FFh
        RET                     ;RETURN TO MAIN
;
;DESCRIPTION: CHECK E REGISTER FOR ERRORS. IF AN ERROR OCCURED
;DISPLAY BAD RAM TEXT OTHERWISE DISPLAY RAM OK TEXT.
;REGISTERS AFFECTED: A, B, C, D, E, H, L, F
;FLAGS AFFECTED: ALL
;
OK      LD      A,$FF           ;LOAD A WITH FFh TO CHECK FOR AN ERROR
        CP      E               ;CHECK ERROR REGISTER FOR FFh
        JP      Z,AROUND        ;GOTO "RAM BAD" DISPLAY SUBROUTINE
        LD      HL,GOOD         ;LOAD "RAM OK" TEXT
        LD      DE,$E08D        ;SET POINTER TO VIDEO RAM DISPLAY POINT
        LD      BC,8            ;SET NUMBER OF CHARACTERS TO DISPLAY
        LDIR                    ;DISPLAY "RAM OK" TEXT
        JP      BACK            ;GO BACK TO MAIN PROGRAM
AROUND  LD      HL,BAD          ;LOAD "RAM BAD" TEXT
        LD      DE,$E08D        ;SET POINTER TO VIDEO RAM DISPLAY POINT
        LD      BC,8            ;SET NUMBER OF CHARACTERS TO DISPLAY
        LDIR                    ;DISPLAY "RAM BAD" TEXT
BACK    RET                     ;GO BACK TO MAIN PROGRAM
        .END                    ;FINISHED
