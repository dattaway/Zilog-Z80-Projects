        ;JIM HAIGHT  -  6DA  FINLEY LAB #2
        ;
        ;TITLE: ACSII CHARACTER DISPLAY LAB #2
        ;
        ;DESCRIPTION: This lab will run a Power-On-Self-Test (POST) to check the
        ;segments on two 7 - Segment displays.  This program will light up the
        ;segments for 10 seconds.  The program will then go into display mode.
        ;In this mode, the 7 - Segment displays will show the ASCII code for a
        ;key pressed on the keyboard.  It will also display the character on
        ;the screen.
        ;
        ;FLAGS AFFECTED: A, B, C, D, E, F, H, L
        ;
        ;STACK SPACE USED: 6 bytes
        ;
        ;SUBROUTINES CALLED: 1) POST
        ;                    2) DELAY
        ;                    3) CLEAR
        ;                    4) BLANK
        ;                    5) DISP
        ;                    6) BLINE
        ;                    7) PROG
        ;                    8) PRGHDR
        ;                    9) KEYSCAN
        ;                   10) FOUND
        ;                   11) LOOKUP
        ;
        ;PROGRAM STARTS: 8500H
        ;
        .ORG    $9000                      ;Start
        .DB     $fe,$fd,$fb,$f7,$ef,$df    ;Define the formation
        .DB     $bf,$80                    ;of the POST display.
TEXT    .TEXT   "       JIM HAIGHT  6DA          ";Name Text
        .TEXT   " P.O.S.T. (POWER ON SELF TEST)  ";start up
        .TEXT   "      DISPLAY SEGMENT TEST      ";screen.
        .TEXT   "         PLEASE WAIT !          ";Please wait!
KEY     .TEXT   "    THE LETTER IS  [   ]        ";Run Text.
        .ORG    $9100                      ;Define the formation
        .DB     $C0,$F9,$A4,$B0,$99,$92    ;of the HEX numbers
        .DB     $82,$F8,$80,$98,$88,$83    ;0 - F.  Using a 0
        .DB     $A7,$A1,$86,$8E            ;for on segments and
                                           ;a 1 for off segments.
        .ORG    $9200
        .DB     $20,$20,$20,$20,$40,$20    ;ASCII LOOKUP TABLE
        .DB     $0D,$7F,$20,$2B,$3D,$20
        .DB     $2F,$3B,$2A,$5F,$5E,$2D
        .DB     $3A,$2E,$2C,$4C,$50,$20
        .DB     $30,$4F,$4B,$4D,$4E,$4A
        .DB     $49,$39,$38,$55,$48,$42
        .DB     $56,$47,$59,$37,$36,$54
        .DB     $46,$43,$58,$44,$52,$35
        .DB     $34,$45,$53,$5A,$20,$41
        .DB     $57,$33,$32,$51,$20,$20
        .DB     $20,$20,$20,$31
                           ;
                           ;
        .ORG    $8500      ;Start of Program
START   CALL    CLEAR      ;Clear the display
        LD      DE,$E000   ;Set pointer to beginning of Video Ram
        LD      HL,TEXT    ;Set pointer to text, DE and HL will be passed
        CALL    DISP       ;This routine will display one row of
        CALL    DISP       ;text to the CRT
        CALL    DISP       ;This routine will display one row of
        CALL    DISP       ;text to the CRT
        CALL    POST       ;Power-On-Self-Test that checks the displays
        CALL    BLANK      ;Clear the displays (set to 00)
        CALL    PROG       ;This routine is the routine that displays the ASCII value of the char
                           ;pressed on the keyboard.  It will also call a routine to display the
                           ;character on the screen
                           ;
                           ;
        ;**********************************************************************************************
        ;* DESCRIPTION: This is the Power-On-Self-Test for the displays.
        ;*                                                                                            *
        ;* FLAGS AFFECTED: All                                                                        *
        ;*                                                                                            *
        ;* REGISTERS AFFECTED: A, D, H, L, F                                                          *
        ;**********************************************************************************************
                           ;
                           ;
POST    LD      D,10       ;Loop through this subroutine 10 times
        LD      HL,9000H   ;Set up HL pointer to display test
AGAIN1  LD      A,$FC      ;Turn both displays on simultaneously
        OUT     (01),A     ;Send code to port 01
        LD      A,$FF      ;Clear all the segments on the displays
        OUT     (00),A     ;Clear the displays
LOOP    LD      A,(HL)     ;First byte of display test
        OUT     (00),A     ;Send first byte to display
        PUSH    DE         ;Save DE
        LD      DE,$1600   ;Set DE for delay value
        CALL    DELAY      ;Call delay subroutine
        POP     DE         ;Get DE back
        INC     L          ;Next byte in self test
        BIT     3,L        ;Check for last segment
        JP      Z,LOOP     ;Repeat loop until all segments are done
        LD      L,0        ;Reset segment test to start position
        DEC     D          ;Decrement loop counter
        JP      NZ,AGAIN1  ;Repeat if not finished
        RET                ;Return to main program
                           ;
                           ;
        ;**********************************************************************************************
        ;* DESCRIPTION: This rountine will delay for the count of BC                                                               *
        ;*                                                                                            *
        ;* REGISTERS AFFECTED: DE                                                                     *
        ;*                                                                                            *
        ;* FLAGS AFFECTED: IN ROUTINE: Z                                                              *
        ;*                OUT ROUTINE: None                                                           *
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
        ;**********************************************************************************************
        ;* DESCRIPTION: THIS ROUTINE WILL CLEAR THE USER SCREEN IT WILL DO THIS USING THE RST10       *
        ;*              COMMAND LOADING A WITH 0CH TELLS THE RST10 WHAT TO DO.                        *
        ;*                                                                                            *
        ;* REGISTERS AFFECTED: NONE                                                                   *
        ;*                                                                                            *
        ;* FLAGS AFFECTED: NONE                                                                       *
        ;**********************************************************************************************
                           ;
                           ;
CLEAR   LD      A,0CH      ;Load Accumulator with code to clear screen
        RST     10H        ;Clear screen
        RET                ;Return to main program
                           ;
        ;**********************************************************************************************
        ;* DESCRIPTION: THIS ROUTINE BLANKS THE 7 - SEGMENT DISPLAYS.
        ;*                                                                                            *
        ;* REGISTERS AFFECTED: NONE                                                                   *
        ;*                                                                                            *
        ;* FLAGS AFFECTED: NONE                                                                       *
        ;**********************************************************************************************
                           ;
                           ;
BLANK   LD      A,$FC      ;Prepare to turn on both displays
        OUT     (01),A     ;Turn on both displays at port 01
        LD      A,$FF      ;Prepare to clear displays
        OUT     (00),A     ;Blank both displays at port 00.
        RET                ;Return to main program
                           ;
                           ;
        ;**********************************************************************************************
        ;* DESCRIPTION: THIS ROUTINE WILL DISPLAY ONE LINE OF TEXT STARTING AT
        ;*              DE.  THE TEXT POINTED TO BY HL WILL BE DISPLAYED.
        ;*                                                                                            *
        ;* REGISTERS AFFECTED: D, E, H, L, F                                                          *
        ;*                                                                                            *
        ;* FLAGS AFFECTED: P/V, N, H                                                                  *
        ;**********************************************************************************************
                           ;
                           ;
DISP    LD      BC,32      ;Load BC with one line length
        LDIR               ;Write text to screen
        CALL    BLINE      ;Insert blank line between text
        RET                ;Return to main program
                           ;
                           ;
        ;**********************************************************************************************
        ;* DESCRIPTION: THIS ROUTINE DISPLAYS A BLANK LINE TO MONITOR.                                                                       *
        ;*                                                                                            *
        ;* REGISTERS AFFECTED: B, D, E, F                                                             *
        ;*                                                                                            *
        ;* FLAGS AFFECTED: ALL BUT C                                                                  *
        ;**********************************************************************************************
                           ;
                           ;
BLINE   LD      B,32       ;Load B with one line length
LINE    INC     DE         ;Increment video pointer
        DEC     B          ;Decrement counter
        JP      NZ,LINE    ;Repeat until line is completely displayed
        RET                ;Return to display subroutine
                           ;
                           ;
        ;**********************************************************************************************
        ;* DESCRIPTION: THIS WILL USE A KEYSCAN ROUTINE TO SCAN THE KEYBOARD,
        ;*              UNPACK THE ASCII CODE AND DISPLAY IT TO THE 7 SEGMENT
        ;*              DISPLAYS.  IT WILL ALSO DISPLAY THE CHARACTER ON THE
        ;*              SCREEN.                                                      *
        ;*                                                                                            *
        ;* REGISTERS AFFECTED: A, B, D, H, L, F                                                       *
        ;*                                                                                            *
        ;* FLAGS AFFECTED: ALL                                                                        *
        ;**********************************************************************************************
                           ;
                           ;
PROG    CALL    HEADDER    ;Display headder text
        LD      H,$91      ;Load pointer to high byte of lookup table
        LD      DE,$0000   ;Set pointer 00
AGAIN   CALL    SCANKEY    ;Call scan keyboard (Z=1 means no key was pressed)
        CALL    LOOKUP     ;Lookup ASCII CODE and place it in Accumulator
        JP      Z,DISPLAY  ;No new key, display old character
        LD      D,A        ;New key pressed, put into D to unpack BCD
        LD      ($E055),A  ;Display character code to screen
        AND     $0F        ;Mask off lower nibble
        LD      E,A        ;Store lower nibble in E
        LD      A,D        ;Load ASCII code into A
        AND     $F0        ;Mask off upper nibble
        LD      B,4        ;Set rotate counter
MORE    RRC     A          ;Rotate upper four bits
        DJNZ    MORE       ;Repeat until done (B = 0)
        LD      D,A        ;New upper nibble stored in D
DISPLAY LD      L,D        ;Prepare to display upper nibble of ASCII code
        LD      A,$FE      ;Prepare to turn on left display
        OUT     (01),A     ;Activate left display (upper nibble)
        LD      A,(HL)     ;Goto lookup table for value
        OUT     (00),A     ;Display upper nibble
        PUSH    DE         ;Save DE value
        LD      DE,$03FF   ;Set delay counter
        CALL    DELAY      ;Goto delay subroutine
        POP     DE         ;Restore DE after delay
        LD      A,$FF      ;Prepare to blank display
        OUT     (00),A     ;Blank left display
        LD      L,E        ;Prepare to display lower nibble of ASCII code
        LD      A,$FD      ;Prepare to turn on right display
        OUT     (01),A     ;Activate right display (lower nibble)
        LD      A,(HL)     ;Goto lookup table for value
        OUT     (00),A     ;Display lower nibble
        PUSH    DE         ;Save DE value
        LD      DE,$03FF   ;Set delay counter
        CALL    DELAY      ;Goto delay subroutine
        POP     DE         ;Restore DE after delay
        JP      AGAIN      ;Scan keyboard again
                           ;
                           ;
        ;**********************************************************************************************
        ;* DESCRIPTION: THIS PRINTS THE OPENING SCREEN OF THE PROGRAM                                                                  *
        ;*                                                                                            *
        ;* REGISTERS AFFECTED: D, E, F, H, L                                                          *
        ;*                                                                                            *
        ;* FLAGS AFFECTED: NONE                                                                       *
        ;**********************************************************************************************
                           ;
                           ;
HEADDER CALL    CLEAR      ;Clear screen
        LD      DE,$E000   ;Set pointer to video ram
        LD      HL,TEXT    ;Set pointer to opening text
        CALL    DISP       ;Display one row of text and one blank line
        LD      HL,KEY     ;Set pointer to key text
        CALL    DISP       ;Display one row of text and one blank line
        RET                ;Return to main progran
                           ;
                           ;
        ;**********************************************************************************************
        ;* DESCRIPTION: THIS REPLACES THE RST 18 COMMAND.  IT WILL RETURN THE
        ;*              VALUE OF THE ASCII VALUE OF A KEY THAT IS PRESSED.
        ;*                                                                                            *
        ;* REGISTERS AFFECTED: A, F                                                                   *
        ;*                                                                                            *
        ;* FLAGS AFFECTED: ALL                                                                        *
        ;**********************************************************************************************
                           ;
                           ;
SCANKEY PUSH    BC         ;Save BC value
        PUSH    DE         ;Save DE value
        PUSH    HL         ;Save HL value
        LD      HL,$F901   ;Set pointer to keyboard
NEWROW  LD      A,(HL)     ;Read first row of keyboard
        CP      $FF        ;Check to see if a key was pressed
        JR      NZ,FOUND   ;Found a key being pressed
        RLC     L          ;No key was pressed, try next row
        JR      NC,NEWROW  ;Try new rows until all have been tried
        XOR     A          ;Clear A and set Z flag (no key pressed)
DONE    POP     HL         ;Get HL back
        POP     DE         ;Get DE back
        POP     BC         ;Get BC back
        RET                ;Return to main program
                           ;
                           ;
        ;**********************************************************************************************
        ;* DESCRIPTION: THIS WILL CALCULATE THE LOOKUP VALUE TO BE USED IN
        ;*              THE LOOKUP ROUTINE.
        ;*                                                                                            *
        ;* REGISTERS AFFECTED: A, F                                                                   *
        ;*                                                                                            *
        ;* FLAGS AFFECTED: ALL                                                                        *
        ;**********************************************************************************************
                           ;
                           ;
FOUND   LD      D,A        ;Key was pressed, save into D
        XOR     A          ;Clear Accumulator
COLUMN  RRC     D          ;Rotate to find column
        JP      NC,ROW     ;Found column
        INC     A          ;Increment for each column if carry is detected
        JP      COLUMN     ;Keep searching for active column
ROW     RRC     L          ;Rotate to find row
        JP      C,DONE     ;Row found, return to main program
        ADD     A,08       ;Add 8 for each row without an active key
        JP      ROW        ;Keep searching for active row
                           ;
                           ;
        ;**********************************************************************************************
        ;* DESCRIPTION: THIS ROUTINE WILL RETURN THE VALUE OF THE ASCII VALUE OF A KEY THATS PRESSED. *
        ;*                                                                                            *
        ;* REGISTERS AFFECTED: A, F                                                                   *
        ;*                                                                                            *
        ;* FLAGS AFFECTED: ALL                                                                        *
        ;**********************************************************************************************
                           ;
                           ;
LOOKUP  PUSH    HL         ;Save HL
        LD      HL,9200H   ;Load HL as pointer to lookup table
        LD      L,A        ;Load L with value from found subroutine
        LD      A,(HL)     ;Get ASCII character from lookup table
        POP     HL         ;Restore HL
        RET                ;Return to main program
       .END
