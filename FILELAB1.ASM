;----------------------------------------------
;  Name:  Dong Do V.                          -
;  Lab:  #1, add-on RAM                       -
;  Prof.:  Finley                             -
;  Course:  EET 484                           -
;                                             -
;  Description:  This program is written to   -
;  check every single location of the 2K x 8  -
;  RAM which will be added to the memory.     -
;  If the RAM is good, the GOOD - RAM will    -
;  display on the screen.  If the RAM is bad  -
;  the BAD - RAM will display.                -
;                                             -
;  Registers used:  A, B, C, D, E, F, H, L    -
;                                             -
;----------------------------------------------


     ;Start programing
     
        .ORG    7500H           ;First add. of the
                                ;program


     ;Display name:  This portion will clear the
     ;screen and display the programmer's name on
     ;the monitor.  Anything is written on the
     ;memory address 4000H to 4200H, which is video
     ;display area, will be displayed on screen.


        LD      A,0CH           ;Clear screen
        RST     10H             ;
        LD      HL,NAME         ;Set up pointer for NAME
        LD      DE,4000H        ;Add. to display name
        LD      BC,10           ;Number of characters in
                                ;name
        LDIR                    ;Display name


     ;Test RAM:  This part will test the add-on RAM
     ;and it will tell you if the RAM is good or bad
     
START:  LD      B,0             ;Set Z flag to zero so
                                ;it can be used to check
                                ;against the wave for error
        LD      HL,8000H        ;Starting add. of the
                                ;add-on RAM
        LD      DE,2048         ;Test 2k RAM
LOOP1:  LD      A,(HL)          ;Load data into A
        CPL                     ;Complement data
        LD      (HL),A          ;Send the wave out
        CP      (HL)            ;Compare to see if the
                                ;wave changed
        CALL    NZ,ERROR        ;The wave changed, call
                                ;up error message
        CPL                     ;Complement the wave
        LD      (HL),A          ;Send the wave out again
        CP      (HL)            ;Compare again
        CALL    NZ,ERROR        ;The wave changed, call
                                ;up error message
        INC     HL              ;Point to next add.
                                ;in RAM
        DEC     DE              ;Reduce a byte in 2k RAM
        LD      A,E
        OR      D               ;Is it at the end of
                                ;RAM ?
        JR      NZ,LOOP1        ;Not yet! Go back to
                                ;check again
        XOR     A               ;Set Acc. to zero
        CP      B               ;Is B equal to zero?
        LD      HL,GOOD         ;Get "GOOD RAM" message
        JR      Z,OVERBAD       ;B is zero
        LD      HL,BAD          ;Get "BAD RAM" message
OVERBAD:LD      DE,4080H        ;First add. on the
                                ;monitor to print out
                                ;message
        LD      BC,8            ;Number of characters of
                                ;messages
        LDIR                    ;Print out the whole
                                ;message
        JR      START           ;Start to check again

GOOD:   .TEXT   "GOOD RAM"      
BAD:    .TEXT   "BAD  RAM"
NAME:   .TEXT   "DONG DO V."
     

     ;Subroutine:  If there is any bad location in the
     ;RAM, the register B will be loaded with FF so the
     ;Z flag can be checked for error.
     ;
     ;Register affected: B

     
ERROR:  LD      B,0FFH          ;Error wave
        RET
        .END



 

