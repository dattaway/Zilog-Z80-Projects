;**************************************************************************
;
;PROJECT: SYSTEM SOFTWARE
;DAN HICKEY
;**************************************************************************


;**************************************************************************
;LCD DATA
;**************************************************************************

WRITE       .EQU        00H
READ        .EQU        02H
DATA_WRITE  .EQU        01H

;**************************************************************************
;SYSTEM INFORMATION
;**************************************************************************

ROMSTART    .EQU        $6250
ROMTOP      .EQU        $1000
RAMSTART    .EQU        $7200
RAMTOP      .EQU        $A000       ;TOP OF RAM, USED
                                    ;FOR THE STACK.

KEY_PORT    .EQU        $10


;*************************************************************************
;MENU FUNCTION NUMBERS
;THE MENU TEXT AND COMMAND INFORMATION IS STORED IN A
;TABLE SEQUENTIALLY AND ARE ASSIGNED A NUMBER.  THE
;MENU FUNCTION MAY BE CALLED BY SETTING THE MENU RAM
;VARIABLE WITH THE FUNCTION NUMBER AND CALLING THE
;'INPUT' SUBROUTINE.
;
;*************************************************************************
;
HIGHTEMP    .EQU        0
LOWTEMP     .EQU        1
TIME        .EQU        2
TEMP        .EQU        3
TIMEON      .EQU        4
TIMEOFF     .EQU        5
MEMORYSR    .EQU        6
MAINMENU    .EQU        9
WHOKNOWS    .EQU        10

;**************************************************************************
;CLOCK DATA
;**************************************************************************

CLKCNTRL                .EQU        20H
SECONDS                 .EQU        22H
TENS_SECONDS            .EQU        23H
MINUTES                 .EQU        24H
TENS_MINUTES            .EQU        25H
HOURS                   .EQU        26H
TENS_HOURS              .EQU        27H
DAYS                    .EQU        28H
TENS_DAYS               .EQU        29H
MONTHS                  .EQU        2AH
TENS_MONTHS             .EQU        2BH
SETTING                 .EQU        2FH


;**************************************************************************
;            RELAY & TEMP. SENSOR DATA
;**************************************************************************

RELAY           .EQU    40H
SENSOR          .EQU    30H
ON_OFF          .EQU    6250H


;**************************************************************************
;ROM AREA
;**************************************************************************

            ;START OF ROM DATA AREA --AFTER CODE
            .ORG        ROMSTART
;ROM         DI
;            LD          SP,RAMTOP
;            JP          ROMCHECK
;            .ORG        $08
;RST08LOC    JP          RST08PRG
;            .ORG        $10
;RST10LOC    JP          RST10PRG
;            .ORG        $18
;RST18LOC    JP          RST18PRG
;            .ORG        $20
;RST20LOC    JP          RST20PRG
;            .ORG        $28
;RST28LOC    JP          RST28PRG
;            .ORG        $30
;RST30LOC    JP          RST30PRG
;            .ORG        $38
;RST38LOC    JP          RST38PRG
;            .ORG        $66
NMILOC      JP          RSTNMIPRG
RST08PRG    RET
RST10PRG    RET
RST18PRG    RET
RST20PRG    RET
RST28PRG    RET
RST30PRG    RET
RST38PRG    RET
RSTNMIPRG   RET


;*************************************************************************
;ROMERR
;THIS SUBROUTINE PRINTS OUT TO THE LCD THAT THERE HAS
;BEEN A BUG IN THE ROM.  THE SYSTEM THEN HALTS
;
;*************************************************************************
;
ROMERR      CALL        LCD
            LD          HL,ROMBADMSG
            CALL        TEXTCLS     ;IF THE STACK IS BAD
                                    ;IN THE RAM, WHO CARES
                                    ;BECAUSE ALL WE NEED
                                    ;IS TO GET THE
                                    DISTRESS MESSAGE OUT
                                    ;THERE.
            HALT

ROMBADMSG   .TEXT       "INVALID ROM CHECKSUM!\000"

;*************************************************************************
;ROMCHECK
;THIS SUBROUTINE CHECKS THE ROM CHECKSUM WITH THE
;LAST TWO BYTES OF THE ROM, WHICH SHOULD STORE THE
;16 BIT SUM OF EACH SUCCESSIVE BYTE IN THE ROM.
;
;*************************************************************************
;
ROMCHECK    LD          HL,0        ;POINTER TO MEMORY
            LD          BC,ROMTOP-ROMSTART-2
            LD          DE,0
NEXTROM     LD          A,(HL)
            ADD         A,E
            LD          E,A
            LD          A,0
            ADC         A,D
            LD          D,A
            INC         HL
            DEC         BC
            LD          A,B
            OR          C
            JR          NZ,NEXTROM

            ;ROM CHECKSUM IS NOW CALCULATED

            LD          HL,(ROMTOP-2)
            XOR         A           ;CLEAR CARRY
            SBC         HL,DE       ;COMPARE
            JR          NZ,ROMERR

            ;ROM IS OK!!!

;*************************************************************************
;RAMCHECK
;THIS SUBROUTINE CHECKS OUT THE DATA BITS IN THE RAM
;TO ENSURE THIER INTEGRETY.  THE RAM CONTENTS ARE NOT
;DESTROYED.
;
;*************************************************************************
;
RAMCHECK    LD          HL,RAMSTART
            LD          BC,RAMTOP-RAMSTART
NEXTRAM     LD          A,(HL)
            CPL
            LD          B,A
            LD          (HL),A
            LD          A,(HL)
            CP          B
            JR          NZ,RAMERROR
            CPL
            LD          (HL),A
            LD          A,(HL)
            CP          B
            JR          NZ,RAMERROR
            INC         HL
            DEC         BC
            LD          A,B
            OR          C
            JR          NZ,NEXTRAM
            LD          HL,RAMOKMSG
            CALL        TEXT
            JP          MAIN        ;GOTO THE MAIN PROGRAM
                                    ;ALL ERROR CHECKING IS
                                    ;DONE.

RAMOKMSG    .TEXT       "ROM IS OK!\rRAM IS OK!\000"

            ;RAM IS OK!!!

RAMERROR        LD      A,38H       ;INITIALIZE THE LCD
            OUT     (WRITE),A
            CALL    LCD_DELAY
            LD      A,0FH
            OUT     (WRITE),A
            CALL    LCD_DELAY
            LD      A,01H
            OUT     (WRITE),A
            CALL    LCD_DELAY
            LD      A,06H
            OUT     (WRITE),A
            LD      HL,RAMERRMSG
            CALL    TEXTCLS         ;DON'T CARE ABOUT RETURNING
            HALT

RAMERRMSG   .TEXT       "RAM HAS ERRORS!\000"

;*******************************************************************************
;LCD TEST
;THIS SOPHISTICATED TEST USES THE PRINCIPLE, IF THE
;MESSAGE IS DISPLAYED, IT WORKS!!!
;
;*******************************************************************************
;
LCDTEST     CALL        LCD         ;INITIALIZE THE LCD
            LD          HL,LCDMSG
            CALL        TEXTCLS
            CALL        LCDSTAY
            LD          B,$14
            CALL        HOMER
            LD          DE,$0002
NEXTEST     CALL        RIGHTSCR
            CALL        DELAY2
            CALL        SETXY
            LD          A,' '
            CALL        CHROUT
            DJNZ        NEXTEST
            CALL        CLS
            RET

LCDMSG      .TEXT       "LCD WORKS!\000"


;*******************************************************************************
;LCDSTAY
;THIS SUBROUTINE IS A DELAY FOR THE MESSAGE ON THE LCD
;
;*******************************************************************************
;
LCDSTAY     PUSH        AF
            PUSH        HL
            LD          DE,900d
LOOP2       LD          A,$FF
LOOP1       DEC         A
            JR          NZ,LOOP1
            DEC         DE
            LD          A,E
            OR          D
            JR          NZ,LOOP2
            POP         HL
            POP         AF
            RET


;*******************************************************************************
;HOMER
;THIS SUBROUTINE PLACES THE CURSOR BACK IN THE HOME
;POSITION ON THE LCD
;
;*******************************************************************************
;
HOMER       PUSH        AF
            CALL        LCD_DELAY
            LD          A,00000010B
            OUT         (WRITE),A
            POP         AF
            RET

;*******************************************************************************
;DELAY2
;THIS SUBROUTINE DELAYS 100mS FOR VISUAL SCROLLING APPEAL
;
;*******************************************************************************
;
DELAY2      PUSH        AF
            PUSH        HL
            LD          HL,$CDDD
NEXTDELAY2  INC         HL
            LD          A,L
            OR          H
            JR          NZ,NEXTDELAY2
            POP         HL
            POP         AF
            RET

;*******************************************************************************
;TEMPTEST
;THIS SUBROUTINE TESTS FOR STRANGE READINGS FROM THE
;TEMPERATURE SENSOR.  IT IS RARE TO HAVE THE SENSOR
;TO READ FULL TILT TOWARD THE COLD OR HOT, SO THIS
;IS WHAT THIS ROUTINE TESTS FOR.
;IF IT IS HUNG UP ON ONE OF THE EXTREMES, THEN AN
;ERROR MESSAGE IS DISPLAYED (WHO'S ROOM IS 200ø OR -60ø)
;
;*******************************************************************************
;
TEMPTEST    IN          A,(SENSOR)
            OR          A
            JR          Z,TEMPERROR
            INC         A
            JR          Z,TEMPERROR
            LD          HL,TEMPOKMSG
            CALL        TEXT
            RET

TEMPERROR   .TEXT       "TEMP INVALID!\000"
TEMPOKMSG   .TEXT       "TEMP SENSOR OK!\000"


MENUS       .TEXT       "HIGH TEMPERATURE\000"
            .TEXT       "LOW TEMPERATURE\000"
            .TEXT       "TIME\000"
            .TEXT       "TEMPERATURE\000"
            .TEXT       "TIME ON\000"
            .TEXT       "TIME OFF\000"
            .TEXT       "MEMORY STORE/RECLL  TEMP:               TIME:\000"
            .TEXT       "\000"

;*******************************************************************************
;KEYTEST
;THIS SUBROUTINE TESTS THE KEYBOARD FOR THOSE KEYS
;THAT MIGHT BE STUCK, WHICH IS THE MOST LIKELY ERROR.
;
;*******************************************************************************
KEYTEST     IN          A,(KEY_PORT)
            AND         10000000B
            JR          Z,KEYOK
            LD          HL,KEYBADMSG
            CALL        TEXT
            RET

KEYOK       LD          HL,KEYOKMSG
            CALL        TEXT
            RET

KEYBADMSG   .TEXT       "KEYBOARD STUCK!\000"
KEYOKMSG    .TEXT       "KEYBOARD OK!\000"

;********************************************************************************
;                    MAIN
;THE MAIN PORTION OF THIS PROGRAM WILL GET IT ON!
;
;********************************************************************************

;            .ORG    7000H
MAIN        DI
            CALL    LCDTEST
            CALL    TEMPTEST
            CALL    KEYTEST
            LD      A,01H
            LD      (ON_OFF),A  ;SOFTWARE RELAY
            OUT     (RELAY),A   ;INITIALIZE HARDWARE


;********************************************************************************
;                LCD
;THIS ROUTINE INITIALIZES THE LCD AND SETS THE CURSOR
;TO THE FIRST POSITION.
;********************************************************************************
;
LCD         LD      A,38H
            OUT     (WRITE),A
            CALL    LCD_DELAY
            LD      A,0FH
            OUT     (WRITE),A
            CALL    LCD_DELAY
            LD      A,01H
            OUT     (WRITE),A
            CALL    LCD_DELAY
            LD      A,06H
            OUT     (WRITE),A
            RET

;*******************************************************************************
;CHROUT
;THIS SUBROUTINE PRINTS OUT A SINGLE CHARACTER TO THE
;LCD SCREEN.
;
;ANY CHARACTER LESS THAN $20 IS RECONGIZED AS A
;CONTROL CODE, SUCH AS FOLLOWS:
;
;           $00:        NO OPERATION                        0000
;           $01:        CLEAR DISPLAY                       0001
;           $02:        HOME CURSOR AT ULC                  0010
;           $03:        HOME CURSOR AT ULC                  0011
;           $04:        SET CURSOR LEFT                     0100
;           $05:        SHIFT DISPLAY LEFT AND SET SCL      0101
;           $06:        SET CURSOR RIGHT                    0110
;           $07:        SHIFT DISPLAY RIGHT AND SET SCR     0111
;           $08:        CURSOR                              1000
;
;*******************************************************************************
;
CHROUT      CALL        LCD_DELAY
            OUT         (DATA_WRITE),A
            RET

;********************************************************************************
;               TEXT
;THIS ROUTINE OUTPUTS THE TEXT TO THE DISPLAY ONE
;CHARACTER AT A TIME.  THE END OF THE STRING IS
;TERMINATED WITH A '\000'
;*******************************************************************************
;
TEXTCLS     LD          A,01H
            CALL        LCD_DELAY
            OUT         (WRITE),A
            CALL        LCD_DELAY
            LD          A,00001100B
            OUT         (WRITE),A   ;TURN CURSOR OFF
            CALL        LCD_DELAY

TEXT        LD          A,(HL)
            OR          A
            RET         Z
            OUT         (DATA_WRITE),A
            CALL        LCD_DELAY
            INC         HL
            JR          TEXT


;*******************************************************************************
;LCD_DELAY
;THIS SUBROUTINE CHECKS THE LCD TO SEE IF ANOTHER
;OPERATION CAN BE PERFORMED (THE LCD IS A SLOW DUDE)
;
;*******************************************************************************
;
LCD_DELAY   PUSH        AF
LCDDELAY2   IN          A,(READ)
            AND         10000000B
            JR          NZ,LCDDELAY2
            POP         AF
            RET

;*******************************************************************************
;CURSORON SUBROUTINE
;THIS SUBROUTINE TURNS THE CURSOR ON
;
;*******************************************************************************
;
CURSORON    PUSH        AF
            CALL        LCD_DELAY
            LD          A,00001111B
            OUT         (WRITE),A
            POP         AF
            RET

;*******************************************************************************
;CURSOROFF SUBROUTINE
;THIS SUBROUTINE TURNS THE CURSOR OFF
;
;*******************************************************************************
;
CURSOROFF   PUSH        AF
            CALL        LCD_DELAY
            LD          A,00001100B
            OUT         (WRITE),A
            POP         AF
            RET

;*******************************************************************************
;CLS SUBROUTINE
;THIS SUBROUTINE CLEARS THE SCREEN
;
;*******************************************************************************
;
CLS         PUSH        AF
            CALL        LCD_DELAY
            LD          A,00000001B
            OUT         (WRITE),A
            POP         AF
            RET

;*******************************************************************************
;HOME SUBROUTINE
;THIS SUBROUTINE HOMES IN THE CURSOR ONTO THE SCREEN
;
;*******************************************************************************
;
HOME        PUSH        AF
            CALL        LCD_DELAY
            LD          A,00000010B
            OUT         (WRITE),A
            POP         AF
            RET

;*******************************************************************************
;LEFT SUBROUTINE
;THIS SUBROUTINE MOVES THE CURSOR LEFT ON THE SCREEN.
;
;*******************************************************************************
;
LEFT        PUSH        AF
            CALL        LCD_DELAY
            LD          A,00010000B
            OUT         (WRITE),A
            POP         AF
            RET

;*******************************************************************************
;RIGHT SUBROUTINE
;THIS SUBROUTIEN MOVES THE CURSOR RIGHT ON THE SCREEN
;
;*******************************************************************************
;
RIGHT       PUSH        AF
            CALL        LCD_DELAY
            LD          A,00010100B
            OUT         (WRITE),A
            POP         AF
            RET

;*******************************************************************************
;RIGHTSCR SUBROUTINE
;THIS SUBROUTIEN SHIFTS THE SCREEN RIGHT ONE LOCATION
;
;*******************************************************************************
;
RIGHTSCR    PUSH        AF
            CALL        LCD_DELAY
            LD          A,00011100B
            OUT         (WRITE),A
            POP         AF
            RET


;*******************************************************************************
;INCDEC SUBROUTINE
;THIS SUBROUTINE RETURNS A POSITIVE OR NEGATIVE ONE
;TO ADJUST A MEMORY REGISTER.  THE A-REGISTER RETURNS THIS.
;
;B-REGISTER RETURNS THE NUMBER OF THE NUMBER SLOT TO BE
;ADJUSTED (0-3).
;
;A ZERO WILL BE RETURNED IN THE A-REGISTER IF SOME WIERD
;KEY HAS BEEN PRESSED.
;*******************************************************************************
;
INCDEC      PUSH        HL
            PUSH        DE
            LD          D,C
            CALL        SET_POS
            CALL        SETXY
            CALL        CHRIN
            LD          B,A
            LD          HL,FUNCTBL  ;FIND OUT FUNCTION

NEXTCHR     LD          A,(HL)
            INC         HL
            CP          B
            JR          Z,GETFUNCT
            INC         HL
            JR          NEXTCHR

GETFUNCT    LD          A,(HL)      ;THE FUNCTION AND INC/DEC IS IN ON BYTE
            CP          5           ;NO FUNCTION DECLARED CONSTANT
            JR          Z,NOGOOD

            LD          C,A         ;SEPERATE THE FUNCTION
            SRL         A
            SRL         A
            SRL         A
            SRL         A
            LD          B,A
            LD          A,C
            AND         $F          ;RETAIN THE INC/DEC VALUE
            CP          $F
            CALL        Z,MAKEFF
            LD          C,D
            POP         DE
            POP         HL
            RET

NOGOOD      LD          A,0         ;NO VALID VALUES FOUND
            LD          BC,0
            POP         DE
            LD          C,D
            POP         HL
            RET

;****************************************************
;MAKEFF
;CONVERT THE A-REGISTER TO $FF.
;
;****************************************************
;
MAKEFF      LD          A,$FF
            RET

;*******************************************************************************
;FUNCTBL
;THIS TABLE DEFINES THE KEYS ACCORDING TO FUNCTION
;CLASS ACCORDING TO THE HIGH BYTE, AND
;INCREMENT OR DECREMENTING WITH THE LOW BYTE:
;           A 1 INCREMENTS
;           A F DECREMENTS
;
;*******************************************************************************
;

FUNCTBL     .DB         1,$5
            .DB         2,$5
            .DB         3,$5
            .DB         4,$5
            .DB         5,$5
            .DB         6,$5
            .DB         7,$01
            .DB         8,$11
            .DB         9,$21
            .DB         $A,$0F
            .DB         $0,$1F
            .DB         $B,$2F
            .DB         $C,$5
            .DB         $D,$5
            .DB         $E,$41
            .DB         $F,$4F

;*******************************************************************************
;SET_POS
;THIS SUBROUTINE SIMPLY SETS THE CURSOR POSITION ON
;THE SCREEN FOR THE INCDEC SUBROUTINE THROUGH THE
;B-REGISTER (FORMATTED AS FOLLOWS:)
;
;          XX:00:00:00  <<-- WHAT'S ON THE LCD
;           0  1  2  3  <<-- B-REGISTER LOCATION
;
;THE X,Y LOCATION OF THE CURSOR IS RETURNED IN THE
;DE-REGISTER
;
;*******************************************************************************
;
SET_POS     LD          A,B
            OR          A
            LD          A,B
            JR          Z,NOMULT

MULTPOS     ADD         A,A         ;*3
            INC         A
            DJNZ        MULTPOS

NOMULT      ADD         A,7d        ;ADD THE SCREEN X-OFFSET
            LD          E,1
            RET



;*******************************************************************************
;INPUT
;THIS SUBROUTINE DISPLAYS THE CURRENT MENU.
;IN ADDITION, THIS SUBROUTINE IS THE MENU INPUT ROUTINE THAT
;ALLOWS THE USER TO SCAN THE MENUS, ALTER STUFF, AND
;WHATEVER THEY WANT
;THIS SUBROUTINE MAY DESTROY ALL REGISTERS.
;*******************************************************************************
;
INPUT       LD          B,A
            LD          HL,MENUS
            CALL        SEARCHTXT   ;GET THE HEADERS ADDRESS
            CALL        TEXTCLS
                        ;THE ELEMENTS OF THE STATUS
                        ;LINE DISPLAYED NEXT.  FOUR ELEMENTS
                        ;ARE PRINTED STARTING AT THE LEFT THEN
                        ;OVER TO THE RIGHT.  THE MENU CONTROL
                        ;TABLE DETERMINES WHICH SLOTS ARE HIDDEN,
                        ;AND WHICH HAVE VALID INFORMATION THAT
                        ;SHOULD BE DISPLAYED.

            CALL        PRINTCOMMND ;LET THIS SUBROUTINE PRINT OUT THOSE PRETTY
                        ;UP AND DOWN ARROWS THAT PROMPT THE USER
                        ;WHAT THEY CAN DO...

            ;HERE IS WHERE THE "WHAT TO DO" LOGIC IS.
            ;THE MENU IS ON THE SCREEN, AND ALL WE NEED NOW IS INPUT...

            CALL        CHRIN       ;THE A-REGISTER HOLDS THE KEY

            PUSH        AF          ;INIALIZE SCREEN FOR ALL FUNCTIONS
            CALL        TEXTCLS
            CALL        COMMAND
            POP         AF

            ;THIS SUBROUTINE ENDS BY BRANCHING INTO THE FINAL LOGIC
            ;NEEDED TO BE PERFORMED BY JUMPING INTO THE PARTICULAR
            ;ROUTINE:

            LD          C,A
            LD          A,(MENU)
            CP          HIGHTEMP
            JP          Z,DOHIGHTEMP
            CP          LOWTEMP
            JP          Z,DOLOWTEMP
            CP          TIME
            JP          Z,DOTIME
            CP          TEMP
            JP          Z,DOTEMP
            CP          TIMEON
            JP          Z,DOTIMEON
            CP          TIMEOFF
            JP          Z,DOTIMEOFF
            CP          MEMORYSR
            JP          Z,DOMEMORYSR
            CP          WHOKNOWS
            JP          Z,DOWHOKNOWS
            CP          MAINMENU
            JP          Z,MENUMAIN

;**********************************************************************************************************
;MENUMAIN SUBROUTINE
;THIS SUBROUTINE SIMPLY DISPLAYS THE STATUS OF THE TIME AND TEMPERATURE.
;THE USER IS ALSO PROMPTED TO ENTER THE TIME
;**********************************************************************************************************
;
MENUMAIN    LD          DE,0601     ;HEADER ALLREADY DISPLAYED
            CALL        SETXY
            CALL        GETIME      ;DISPLAY TIME        ;MEMORY STORE/RCLL
            CALL        DISPELEMT                        ;TIME:
            LD          DE,0602                          ;TEMP:
            CALL        SETXY                            ;PRESS ANY KEY
            CALL        GETTEMP     ;DISPLAY TEMPERATURE
            CALL        DISPELEMT
            LD          DE,0003
            CALL        SETXY
            LD          HL,PRESSMSG ;DISPLAY MESSAGE
            CALL        TEXT

PRESSMSG    .TEXT       "PRESS ANY KEY\000"

;*******************************************************************************
;GETTEMP
;THIS SUBROUTINE GETS THE TEMPERATURE AND PLACES IT
;INTO THE BUFFER.
;
;*******************************************************************************
;
GETTEMP     PUSH        AF
            PUSH        HL
            IN          A,(SENSOR)
            LD          HL,BUFFER
            INC         HL
            INC         HL
            INC         HL
            LD          (HL),A
            POP         HL
            POP         AF          ;FILTER DOWN AND SET THE ATTRIBUTES

SETTEMPATTR PUSH        AF
            PUSH        HL
            LD          HL,CONTROL
            XOR         A
            LD          (HL),A
            INC         HL
            LD          (HL),A
            INC         HL
            LD          (HL),A
            INC         HL
            INC         A           ;DISPLAY RIGHTMOST DIGIT ONLY
            LD          (HL),A
            POP         HL
            POP         AF
            RET

;*******************************************************************************
;GETIME
;THIS SUBROUTINE PLACES THE TIME INTO THE BUFFER.
;
;*******************************************************************************
;
GETIME      PUSH        AF
            PUSH        BC
            PUSH        HL
            LD          HL,BUFFER
            IN          A,(TENS_HOURS)
            LD          B,A
            IN          A,(HOURS)
            LD          C,A
            CALL        HEXBCD      ;CONVERT TO BINARY INTO A-REGISTER
            INC         HL          ;POINT TO HOURS IN BUFFER
            LD          (HL),A
            IN          A,(TENS_MINUTES)
            LD          B,A
            IN          A,(MINUTES)
            LD          C,A
            CALL        HEXBCD
            INC         HL
            LD          (HL),A
            IN          A,(TENS_SECONDS)
            LD          B,A
            IN          A,(SECONDS)
            LD          C,A
            CALL        HEXBCD
            INC         HL
            LD          (HL),A
            CALL        SETTIMEATTR
            POP         HL
            POP         BC
            POP         AF
            RET

;*******************************************************************************
;GETOFFTIME
;THIS SUBROUTINE TRANSFERS THE OFF-TIME LIMIT AND TRANSFERS IT INTO THE BUFFER.
;
;*******************************************************************************
;
GETOFFTIME  PUSH        AF
            PUSH        BC
            PUSH        DE
            PUSH        DE
            LD          HL,OFFTIME
            LD          DE,BUFFER
            LD          BC,4
            LDIR
            POP         HL
            POP         DE
            POP         BC
            POP         AF
            RET

;*******************************************************************************
;GETONTIME
;THIS SUBROUTINE TRANSFERS THE ON-TIME LIMIT AND TRANSFERS IT INTO THE BUFFER.
;
;*******************************************************************************
;
GETONTIME   PUSH        AF
            PUSH        BC
            PUSH        DE
            PUSH        DE
            LD          HL,ONTIME
            LD          DE,BUFFER
            LD          BC,4
            LDIR
            POP         HL
            POP         DE
            POP         BC
            POP         AF
            RET

;*******************************************************************************
;GETLOWTEMP
;THIS SUBROUTINE TRANSFERS THE LOW-TEMP LIMIT AND TRANSFERS IT INTO THE BUFFER.
;
;*******************************************************************************
;
GETLOWTEMP  PUSH        AF
            PUSH        BC
            PUSH        DE
            PUSH        DE
            LD          HL,LOTEMP
            LD          DE,BUFFER
            LD          BC,4
            LDIR
            POP         HL
            POP         DE
            POP         BC
            POP         AF
            RET

;*******************************************************************************
;GETHITEMP
;THIS SUBROUTINE TRANSFERS THE HI-TEMP LIMIT AND TRANSFERS IT INTO THE BUFFER.
;
;*******************************************************************************
;
GETHITEMP   PUSH        AF
            PUSH        BC
            PUSH        DE
            PUSH        DE
            LD          HL,HITEMP
            LD          DE,BUFFER
            LD          BC,4
            LDIR
            POP         HL
            POP         DE
            POP         BC
            POP         AF
            RET

;*******************************************************************************
;SETTIMEATTR
;THIS SUBROUTINE SETS THE HIDDEN/DISPLAY ATTRIBUTES
;FOR THE PRINTING ROUTINE THAT PRINTS OUT THE NUMBERS
;INTO BCD ON THE SCREEN
;
;*******************************************************************************
;
SETTIMEATTR PUSH        AF
            PUSH        HL
            LD          HL,CONTROL
            XOR         A
            LD          (HL),A      ;HIDE LEFTMOST (NOTHING THERE)
            INC         A           ;MAKE NON-ZERO DISPLAY FLAG
            INC         HL
            LD          (HL),A      ;SHOW HOURS
            INC         HL
            LD          (HL),A      ;SHOW MINUTES
            INC         HL
            LD          (HL),A      ;SHOW SECONDS
            POP         HL
            POP         AF
            RET

;*******************************************************************************
;HEXBCD (BCD>HEX)
;THIS SUBROUTINE TAKES THE BCD VALUE IN THE BC-REGISTER
;AND CONVERTS IT INTO A DECIMAL VALUE IN A-REGISTER
;
;*******************************************************************************
;
HEXBCD      PUSH        BC
            LD          A,B         ;CONVERT THE MSN FIRST BY *16 INTO A-REG
            OR          A
            LD          A,0
            JR          Z,MSNDONE   ;NO VALUE IN THE TEN'S PLACE?

            ;CALCULATE THE HEX VALUE OF THE TENS PLACE HERE:
HIBYTE      ADD         A,10d       ;ADD 10 FOR EACH INCRMENT OF THE TEN'S PLACE
            DEC         B
            JR          NZ,HIBYTE

            ;ADD IN THE HEX VALUE OF THE ONES PLACE:
MSNDONE     ADD         A,C         ;ADD IN THE ONE'S PLACE
            POP         BC
            RET

;*******************************************************************************
;BCDHEX (HEX>BCD)
;THIS SUBROUTINE TAKES THE VALUE OF THE A-REGISTER
;INTO A BCD VALUE STORED IN BC (HIGH,LOW AS EXPECTED)
;*******************************************************************************
;
BCDHEX      PUSH        AF
            PUSH        DE
            LD          C,A
            SRL         A
            SRL         A
            SRL         A
            SRL         A
            CALL        BCDFIXUP
            LD          B,A
            LD          A,C
            AND         $F
            CALL        BCDFIXUP
            LD          C,A
            POP         DE
            POP         AF
            RET


;*******************************************************************************
;BCDFIXUP
;THIS SUBROUTINE IS USED BY BCDHEX TO FIXUP BCD VALUES.
;
;*******************************************************************************
;
BCDFIXUP    ADD         A,'0'
            CP          '9'+1
            RET         M
            ADD         A,'A'-'9'
            RET


;*******************************************************************************
;DISPELEMT (DISPLAY ELEMENT)
;THIS SUBROUTINE PRINTS OUT THE CONTENTS OF THE BUFFER
;AT THE CURRENT PRINTING LOCATION.  THE BUFFER CONTROL
;REGISTER DETERMINES WHAT GETS PRINTED AND WHAT IS
;HIDDEN.
;
;*******************************************************************************
;
DISPELEMT   PUSH        AF
            PUSH        BC
            PUSH        DE
            PUSH        HL
            LD          HL,CONTROL
            LD          DE,BUFFER
            LD          B,3

NEXTDIG     INC         HL
            INC         DE
            LD          A,(CONTROL)
            OR          A  
            JR          Z,NXTFINISH ;PASS OVER AND PRINT 3 SPACES

            PUSH        BC          ;PRINT THE BCD NUMBER
            LD          A,(DE)
            CALL        BCDHEX
            LD          A,B
            CALL        CHROUT
            LD          A,C
            CALL        CHROUT
            POP         BC

            LD          A,B         ;PRINT THE COLON IF MORE DIGITS ARE TO THE LEFT
            CP          1           ;LAST DIGIT?
            JR          Z,CONTINUE
            LD          A,':'
            CALL        CHROUT
            JR          CONTINUE

NXTFINISH   LD          A,' '       ;PASS OVER 3 SPACES
            CALL        CHROUT
            CALL        CHROUT
            CALL        CHROUT
            JR          CONTINUE

CONTINUE    DEC         B           ;SEE IF ANY MORE DIGITS ARE TO BE DONE.
            JR          NZ,NEXTDIG


ENDISP      POP         HL
            POP         DE
            POP         BC
            POP         AF
            RET

;*******************************************************************************
;DOHIGHTEMP SUBROUTINE
;THIS SUBROUTINE
;*******************************************************************************
;
DOHIGHTEMP

;*******************************************************************************
;DOLOWTEMP SUBROUTINE
;THIS SUBROUTINE
;*******************************************************************************
;
DOLOWTEMP

;*******************************************************************************
;DOTIME SUBROUTINE
;THIS SUBROUTINE
;*******************************************************************************
;
DOTIME

;*******************************************************************************
;DOTEMP SUBROUTINE
;THIS SUBROUTINE
;*******************************************************************************
;
DOTEMP

;*******************************************************************************
;DOTIMEON SUBROUTINE
;THIS SUBROUTINE
;*******************************************************************************
;
DOTIMEON

;*******************************************************************************
;DOTIMEOFF SUBROUTINE
;THIS SUBROUTINE
;*******************************************************************************
;
DOTIMEOFF

;*******************************************************************************
;DOMEMORYSR SUBROUTINE
;THIS SUBROUTINE
;*******************************************************************************
;
DOMEMORYSR

;*******************************************************************************
;DOWHOKNOWS SUBROUTINE
;THIS SUBROUTINE
;*******************************************************************************
;
DOWHOKNOWS



;*******************************************************************************
;DISPLAYLOC
;THIS SUBROUTINE SHOWS THE SET OF COMMANDS.
;0
;1   NEXT  12:15:00    _
;2      ^   ^  ^  ^     \___commands
;3      v   v  v  v    _/
; 0123456789ABCDEF01234
;*******************************************************************************
;
DISPLAYLOC  PUSH        AF
            PUSH        DE
            PUSH        HL
            LD          B,0         ;B-REG CARRIES THE COMMAND ITERATION (0-3)
ITERATION   LD          A,(MENU)
            SLA         A           ;MULTIPLY BY 4 TO GET PARAMETERS ON TABLE
            SLA         A
            LD          HL,MENUCODES
            ADD         A,B         ;ADD ITERATION OFFSET
            ADD         A,L
            LD          L,A
            LD          A,0
            ADC         A,H
            LD          H,A
            LD          A,(HL)      ;PICK UP THE DISPLAY ATTRIBUTE
            OR          A
            JR          Z,NOPRINT   ;INVISIBLE? SKIP THE PRINTING SECTION.

            LD          HL,DISPLAYTBL           ;X-OFFSET FOR EACH ARROW
            LD          A,B
            ADD         A,L         ;HERE IS WHERE THE PRINTING IS DONE:
            LD          L,A
            LD          A,0
            ADC         A,H
            LD          H,A
            LD          A,(HL)
            LD          D,A
            LD          E,2

            LD          A,'^'
            CALL        SETXY
            CALL        CHROUT
            INC         E
            LD          A,'v'
            CALL        SETXY
            CALL        CHROUT

NOPRINT     INC         B
            LD          A,B
            CP          3+1
            JR          NZ,ITERATION

            POP         HL
            POP         DE
            POP         AF
            RET

DISPLAYTBL  .DB         $6,$A,$D,$10

;*******************************************************************************
;MENUCODES --ROM!!!
;CONTROL CODES FOR MENUS
;A 0 HIDES THE NUMBER, A 1 SHOWS THE VALUE
;THESE CONTROL CODES CORRESPOND TO THE MENU SELECTION
;ACCORDING TO THE MENU NUMBER IN MENU CONTROL
;
;FOR EXAMPLE:
;  THE HIGH TEMPERATURE MENU ONLY NEEDS ONE NUMBER
;  TO BE DISPLAYED.  IF A ONE IS ON THE RIGHTMOST
;  CONTROL CODE, ONE NUMBER WILL BE DISPLAYED.
;
;  IF TWO ONES NEXT TO EACHOTHER, A COLON WILL BE
;  USED TO SEPERATE THEM, AS IN THE TIME.
;*******************************************************************************
;
MENUCODES   .DB         0,0,0,1     ;HIGH TEMP  #1
            .DB         0,0,0,1     ;LOW TEMP   #2
            .DB         0,1,1,1     ;TIME       #3
            .DB         0,0,0,1     ;TEMP       #4
            .DB         0,1,1,1     ;TIME ON    #5
            .DB         0,1,1,1     ;TIME OFF   #6
            .DB         0,0,1,1     ;STORE/RECAL#7
            .DB         0,0,0,0     ;MAINMENU   #8

;*******************************************************************************
;SEARCHTXT
;THIS SUBROUTINE IS USED TO FIND THE B-REGISTER
;ELEMENT OF THE ARRAY POINTED TO BY HL.  HL POINTS
;TO THE ELEMENT.  THE ELEMENTS START AT 0.
;
;*******************************************************************************
;
SEARCHTXT   PUSH        AF
            PUSH        BC
NEXTELEMENT LD          A,B
            OR          A
            JR          Z,ENDSEARCH

CONTSEARCH  LD          A,(HL)      ;SKIP ON THROUGH ONE ELEMENT
            INC         HL
            OR          A
            JR          NZ,CONTSEARCH
            INC         HL          ;SKIP OVER ZERO AND POINT TO NEXT ELEMENT
            DEC         B           ;COUNT FOR NEXT ELEMENT
            JR          NZ,NEXTELEMENT

ENDSEARCH   POP         BC
            POP         AF
            RET                     ;FOUND ARRAY ELEMENT
;

;*******************************************************************************
;CHKCURRENT
;THIS SUBROUTINE FINDS OUT IF THE KEY PRESSED SHOULD
;INCREMENT OR DECREMENT THE VARIABLE DESIRED IN THE
;SCAN SUBROUTINE.  THE ZERO FLAG IS SET IF ANOTHER
;REGISTER SHOULD BE MODIFIED OTHER THAN THE ONE THAT
;IS BEING WORKED ON.
;B-REGISTER HOLDS THE VARIABLE (0-3) TO BE WORKED ON.
;A-REGISTER IS DESTROYED
;*******************************************************************************
;
CHKCURRENT  PUSH        HL
            PUSH        BC
            LD          C,A
            LD          HL,COLUMNCHK
            LD          A,B
            ADD         A,A         ;*2
            ADD         A,L
            LD          A,0
            ADC         A,H
            LD          H,A
            LD          A,(HL)
            CP          C
            JR          Z,CHECKOFF
            INC         HL
            LD          A,(HL)
            CP          C
            JR          Z,CHECKOFF
NOCHECK     POP         BC
            POP         HL
            XOR         A
            RET

CHECKOFF    POP         BC
            POP         HL
            LD          A,1
            OR          A
            RET

COLUMNCHK   .DB         $2,$0       ;7.
            .DB         $A,$8       ;80
            .DB         $6,$4       ;9_
            .DB         $E,$C       ;+-

;*******************************************************************************
;CHRIN SUBROUTINE
;THIS SUBROUTINE POLLS THE KEYBOARD AND WAITS
;UNTIL A KEY IS PRESSED.
;
;*******************************************************************************
;
CHRIN       IN          A,(KEY_PORT)
            AND         10000000B
            JR          Z,CHRIN
            IN          A,(KEY_PORT)
            AND         $F

            PUSH        HL
            LD          HL,KEYUPDOWN
            ADD         A,L
            LD          L,A
            LD          A,0
            ADC         A,H
            LD          H,A
            LD          A,(HL)
            POP         HL

            RET

KEYUPDOWN   .DB         $A          ;0
            .DB         4           ;1
            .DB         7           ;2
            .DB         1           ;3
            .DB         $D          ;4
            .DB         6           ;5
            .DB         9           ;6
            .DB         3           ;7
            .DB         0           ;8
            .DB         5           ;9
            .DB         8           ;A
            .DB         2           ;B
            .DB         $F          ;C
            .DB         $D          ;D
            .DB         $E          ;E
            .DB         $C          ;F

;*******************************************************************************
;SETXY SUBROUTINE
;THIS SUBROUTINE TAKES THE DE-REGISTER AND SETS THE
;(X,Y) COORDINATES ACCORDINGLY.  THE VALUES CAN BE
;(0-$13,0-$3).
;*******************************************************************************
;
;
SETXY       PUSH        AF
            PUSH        BC
            PUSH        DE
            PUSH        HL

            LD          HL,XYTABLE  ;PREPARE THE X,Y CALCULATIONS
            LD          C, $14
            LD          B,E
            XOR         A
            INC         B
            DEC         B
            JP          Z,ENDMULT
MULT        ADD         A,C
            DJNZ        MULT
ENDMULT     ADD         A,D         ;ADD THE FINAL X
                                    ;OFFSET
            ADD         A,L         ;GET THE BYTE IN THE TABLE
            LD          L,A
            LD          A,0
            ADC         A,H
            LD          H,A
            LD          A,(HL)

            CALL        LCD_DELAY
            OUT         (WRITE),A   ;OUTPUT TO THE SCREEN

            POP         HL
            POP         DE
            POP         BC
            POP         AF
            RET

;THIS TABLE WILL CONVERT THE (X,Y) SCREEN POSITION TO THE
;ADDRESS NEEDED TO PLACE THE CURSOR ONTO THE SCREEN.
;COLUMN IS

XYTABLE     .DB         $80, $81, $82, $83, $84, $85, $86, $87
            .DB         $88, $89, $8A, $8B, $8C, $8D, $8E, $8F
            .DB         $90, $91, $92, $93
            .DB         $C0, $C1, $C2, $C3, $C4, $C5, $C6, $C7
            .DB         $C8, $C9, $CA, $CB, $CC, $CD, $CE, $CF
            .DB         $D0, $D1, $D2, $D3
            .DB         $94, $95, $96, $97, $98, $99, $9A, $9B
            .DB         $9C, $9D, $9E, $9F, $A0, $A1, $A2, $A3
            .DB         $A4, $A5, $A6, $A7
            .DB         $D4, $D5, $D6, $D7, $D8, $D9, $DA, $DB
            .DB         $DC, $DD, $DE, $DF, $E0, $E1, $E2, $E3
            .DB         $E4, $E5, $E6, $E7


;********************************************************************************
;RAM AREA
;********************************************************************************

;            .ORG    RAMSTART    ;START OF RAM DATA
;*******************************************************************************
;RAMVARS
;THESE ARE THE VARIABLES IN RAM THAT DETERMINE WHICH
;IS THE ACTIVE MENU TO BE DISPLAYED ONTO THE SCREEN,
;BUFFER FOR THE CURRENT MENU SELECTION, THE TIME,
;TEMPERATURE, HIGH TEMPERATURE, LOW TEMPERATURE, AND
;THE STORE/RECALL PRESETS.
;
;EACH OF THESE VARIABLES ARE STORED IN A FOUR BYTE
;BLOCK FOR SIMPLICITY, EXCEPT FOR THE STORE/RECALL
;PRESETS (WHICH TAKE UP ONE).
;*******************************************************************************
;
MENU        .DS         4           ;THE NUMBER OF THE MENU
BUFFER      .DS         4           ;TEMPORARY BUFFER OF CURRENT MENU SELECTION
CONTROL     .DS         4           ;DETERMINES WHICH BUFFER LOCATIONS PRINT
TIMEVAL     .DS         4           ;CURRENT TIME LOCATION, UPDATED REGULARLY
TEMPVAL     .DS         4           ;CURRENT TEMPERATURE, UPDATED REGULARLY
HITEMP      .DS         4           ;HIGH TEMPERATURE REFERENCE
LOTEMP      .DS         4           ;LOW TEMPERATURE REFERENCE
OFFTIME     .DS         4           ;TIME TO DISABLE SYSTEM OUTPUT
ONTIME      .DS         4           ;TIME TO ENABLE SYSTEM OUTPUT
MEMORY      .DS         256         ;SYSTEM SETTINGS STORE/RECALL SCRATCHPAD

            .END
