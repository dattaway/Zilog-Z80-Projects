;*******************************************************
;*                                                     *
;* Cuong Nguyen                                        *
;* Microprocessor lab                                  *
;* Keyboard and Video                                  *
;*                                                      *
;*******************************************************

                .ORG    $6300
SEGPORT         .EQU    01
DISPLYPORT      .EQU    00
LED_TABLE       .EQU    $7300
ASCII_TABLE     .EQU    $7800
PC_PIO          .EQU    $8E
PA_PIO          .EQU    $8C
PB_PIO          .EQU    $8D
MAIN            .EQU    $6400
LEDTEST         .EQU    $6500
MYNAME          .TEXT   "CUONG NGUYEN"
;********************************************************
;*                                                      *
;* MAIN                                                 *
;*                                                      *
;********************************************************


                .ORG    $6400
MAIN            CALL    LEDCLEAR
                CALL    LEDTEST
                CALL    CLS
                CALL    NAME
LOOPS:          CALL    GET_KEY
                JR      C,NO_KEY
                CALL    UPDATE_LED
                CALL    UPDATE_CRT
                CALL    DEBOUNCE_UP
NO_KEY:         CALL    MSTEN_DELAY
                JR      LOOPS
                .END

;********************************************************
;*                                                      *
;* Blank Seven Segment Subroutine                       *
;*                                                      *
;* Registers Affected A,F,B,C  flags                    *
;*                                                      *
;* This subroutine blanks the LED display               *
;*                                                      *
;********************************************************


LEDCLEAR:       PUSH    AF
                LD      A,0FFH
                OUT     (SEGPORT),A
                POP     AF
                RET


;********************************************************
;*                                                      *
;* Seven Segment Self Test  Subroutine                  *
;*                                                      *
;* Registers Affected  A,F,B,C,H,L  flags               *
;                                                       *
;* This subroutine is used to check the operation       *
;* of the seven segment displays by checking            *
;* each segment.                                        *
;*                                                      *
;********************************************************



                .ORG    $6500
LEDTEST:        PUSH    AF
                PUSH    BC
                LD      A,$55
                LD      C,SEGPORT
                LD      B,$FE
LOOP1:          OUT     (DISPLYPORT),A
LOOP:           OUT     (C),B
                PUSH    BC
                LD      BC,500
                CALL    DELAYSUB
                POP     BC
                RLC     B
                JR      C,LOOP
                RLC     A
                JR      NC,LOOP1
                POP     BC
                POP     AF
                RET
                .END
     
;************************************************
;* Variable Delay Subroutine                    *
;*                                              *
;* Registers Affected A,F,B,C                   *
;*                                              *
;* This subroutine causes a delay to allow      *
;* observation of the LED's                     *
;* **********************************************


                
DELAYSUB:       PUSH    AF
                PUSH    DE
VT_LOOP:        LD      D,$FF
ONEMS_LOOP:     DEC     D
                JP      NZ,ONEMS_LOOP
                DEC     BC
                LD      A,B
                OR      C
                JR      NZ,VT_LOOP
                POP     DE
                POP     AF
                RET


;************************************************
;*                                              *
;* 10 ms Delay Loop                             *
;*                                              *
;* Registers Affected A,F,B,C,H,L               *
;*                                              *
;* This Subroutine uses a 10 ms delay to        *
;* to refresh the delays.                       *
;*                                              *
;************************************************

MSTEN_DELAY:    PUSH    AF
                PUSH    BC
                PUSH    HL
                LD      HL,LED_TABLE
                LD      A,(DIGIT0)
                LD      L,A
                LD      A,(HL)
                OUT     (SEGPORT),A
                LD      A,0FEH
                OUT     (DISPLYPORT),A
                LD      BC,05
                CALL    DELAYSUB
                LD      A,0FFH
                OUT     (DISPLYPORT),A
                LD      A,(DIGIT1)
                LD      L,A
                LD      A,(HL)
                OUT     (SEGPORT),A
                LD      A,0FDH
                OUT     (DISPLYPORT),A
                LD      BC,5
                CALL    DELAYSUB
                LD      A,0FFH
                OUT     (DISPLYPORT),A
                POP     HL
                POP     BC
                POP     AF
                RET

;************************************************
;*                                              *
;* Clear Screen                                 *
;*                                              *
;* Registers Affected A,F,B,C,D,E,H,L           *
;*                                              *
;* This subroutine clears the video display     *
;*                                              *
;************************************************

 

CLS:            PUSH    AF
                PUSH    BC
                PUSH    HL
                LD      HL,$4000
                LD      BC,$200
NDONE:          LD      A,$20
                LD      (HL),A
                INC     HL
                DEC     BC
                LD      A,B
                OR      C
                JR      NZ,NDONE
                POP     HL
                POP     BC
                POP     AF
                RET
;************************************************
;*                                              *
;* PRINT NAME                                   *
;*                                              *
;* Registers affected: b,c,h,l,d,e  flags       *
;*                                              *
;* This subroutine will print my name           *
;* at the center of the screen.                 *
;*                                              *
;************************************************
NAME:           PUSH    BC
                PUSH    HL
                PUSH    DE
                LD      HL,MYNAME
                LD      DE,$400A
                LD      BC,$C
                LDIR
                POP     DE
                POP     HL
                POP     BC
                RET

;************************************************
;*                                              *
;* Update display subroutine                    *
;*                                              *
;* Register Affected A,F                        *
;*                                              *
;* This subroutine updates the led displays     *
;*                                              *
;************************************************

UPDATE_LED:     PUSH    AF
                AND     0FH
                LD      (DIGIT0),A
                POP     AF
                PUSH    AF
                SRL     A
                SRL     A
                SRL     A
                SRL     A
                LD      (DIGIT1),A
                POP     AF
                RET

;************************************************
;*                                              *
;* Update CRT subroutine                        *
;*                                              *
;* Registers Affected                           *
;*                                              *
;* Subroutine used to update CRT                *
;*                                              *
;************************************************

UPDATE_CRT:     LD      (406FH),A
                RET

;************************************************
;*                                              *
;* Debounce letup subroutine                    *
;*                                              *
;* No Registers Affected                        *
;*                                              *
;* Debounces key on letup                       *
;*                                              *
;************************************************

DEBOUNCE_UP:    CALL    GET_KEY
                JP      NC, DEBOUNCE_UP
                CALL    MSTEN_DELAY
                RET

;************************************************
;*                                              *
;* Get Key Subroutine                           *
;*                                              *
;* Registers Affected A,F,B,C,D,E,H,L           *
;*                                              *
;* This subroutine is used to monitor the       *
;* the keyboard and input any key that is       *
;* pressed.                                     *
;*                                              *
;************************************************


GET_KEY:        PUSH    BC
                PUSH    DE
                PUSH    HL
                LD      A,0C0H
                OUT     (PB_PIO),A
                LD      B,0
                LD      C,PC_PIO
NEXT_ROW:       OUT     (C),B
                IN      A,(PA_PIO)
                CP      0FFH
                JP      NZ,FNDKEY
NODONE:         INC     B
                BIT     3,B
                JR      Z,NEXT_ROW
                SCF
OUT_OF_HERE:    POP     HL
                POP     DE
                POP     BC
                RET
FNDKEY:         LD      D,A
                CALL    MSTEN_DELAY
                IN      A,(PA_PIO)
                CP      D
                JP      NZ,NODONE
                XOR     A
AGAIN:            RRC     D
                JR      NC,OUT
                INC     A
                JR      C,AGAIN
OUT:            DEC     B
                JP      M,LOOK_UP
                ADD     A,08
                JR      OUT
LOOK_UP:        LD      HL,ASCII_TABLE
                LD      L,A
                LD      A,(HL)
                JP      OUT_OF_HERE
                RET

;************************************************
;*                                              *
;* DATA TABLE  LED TEST - NAME                  *
;*                                              *
;************************************************

                .ORG    7300H

LED_TABLE:      .DB     11000000B
                .DB     11111001B
                .DB     10100100B
                .DB     10110000B
                .DB     10011001B
                .DB     10010010B
                .DB     10000010B
                .DB     11111000B
                .DB     10000000B
                .DB     10011000B
                .DB     10001000B
                .DB     10000011B
                .DB     11000110B
                .DB     10100001B
                .DB     10000110B
                .DB     10001110B
                .DB     01111111B

DIGIT0          .DB     00H
DIGIT1          .DB     00H
                .END

;************************************************
;*                                              *
;*      ASCII TABLE                             *
;*                                              *
;************************************************






                .ORG    7800H
ASCII_TABLE     .DB     20H
                .DB     20H
                .DB     20H
                .DB     20H
                .DB     40H
                .DB     5CH
                .DB     20H
                .DB     20H
                .DB     20H
                .DB     2BH
                .DB     3DH
                .DB     20H
                .DB     2FH
                .DB     3BH
                .DB     2AH
                .DB     20H
                .DB     20H
                .DB     2DH
                .DB     3AH
                .DB     2EH
                .DB     2CH
                .DB     4CH
                .DB     50H
                .DB     20H
                .DB     30H
                .DB     4FH
                .DB     4BH
                .DB     4DH
                .DB     4EH
                .DB     4AH
                .DB     49H
                .DB     39H
                .DB     38H
                .DB     55H
                .DB     48H
                .DB     42H
                .DB     56H
                .DB     47H
                .DB     59H
                .DB     37H
                .DB     36H
                .DB     54H
                .DB     46H
                .DB     43H
                .DB     58H
                .DB     44H
                .DB     52H
                .DB     35H
                .DB     34H
                .DB     45H
                .DB     53H
                .DB     5AH
                .DB     20H
                .DB     41H
                .DB     57H
                .DB     33H
                .DB     32H
                .DB     51H
                .DB     20H
                .DB     20H
                .DB     20H
                .DB     20H
                .DB     20H
                .DB     31H
                .END
                .END
