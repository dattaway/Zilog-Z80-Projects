
;************************************************
;                                               *
;  WAYNE GARDNER                                *
;
;                                               *
;                                               *
;                                               *
;************************************************
;
SEGPORT:        .EQU    01
DISPLAYPORT:    .EQU    00
LED_TABLE:      .EQU    6700H
ASCII_TABLE     .EQU    6800H
NAME:           .EQU    6711H
MAIN:           .EQU    6500H
LEDTEST:        .EQU    6520H
DELAYSUB:       .EQU    666FH
CLS_NAME:       .EQU    6580H
MSTEN_DELAY:    .EQU    65A0H
UPDATE_CRT:     .EQU    6680H
DEBOUNCE_UP:    .EQU    65E0H
UPDATE_LED:     .EQU    6600H
GET_KEY:        .EQU    6620H
PC_PIO:         .EQU    8EH
PA_PIO:         .EQU    8CH
PB_PIO:         .EQU    8DH
DIGIPRT         .EQU    OOH
SEGPORT         .EQU    O1H

;********************************************************
;*                                                      *
;* MAIN                                                 *
;*                                                      *
;********************************************************

                .ORG 6500H


                CALL    LEDTEST
                CALL    CLS_NAME
BUD:            CALL    GET_KEY
                JR      C,NO_KEY
                CALL    UPDATE_LED
                CALL    UPDATE_CRT
                CALL    DEBOUNCE_UP
NO_KEY:         CALL    MSTEN_DELAY
                JR      BUD
                .END



;********************************************************
;*                                                      *
;* Seven Segment Self Test  Subroutine                  *
;*                                                      *
;* Registers Affected  A,F,B,C,H,L                      *
;                                                       *
;* This subroutine is used to check the operation       *
;* of the seven segment displays using the look- up     *
;* table.                                               *
;*                                                      *
;********************************************************

                .ORG    6520H
LEDTEST         PUSH    AF
                PUSH    BC
                PUSH    HL
                LD      B,55H
                LD      C,DISPLAYPORT
                LD      HL,LED_TABLE
LOOP:           LD      A,(HL)
                OUT     (SEGPORT),A
                OUT     (C),B
                PUSH    BC
                LD      BC,500
                CALL    DELAYSUB
                POP     BC
                RLC     B
                OUT     (C),B
                PUSH    BC
                LD      BC,500
                CALL    DELAYSUB
                POP     BC
                INC     HL
                BIT     4,L
                JR      Z,LOOP
                POP     HL
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


                .ORG 666FH

DELAYSUB:       PUSH    AF
                PUSH    DE
VT_LOOP:        LD      D,255
ONEMS_LOOP:     DEC     D
                JP      NZ,ONEMS_LOOP
                DEC     BC
                LD      A,B
                OR      C
                JR      NZ,VT_LOOP
                POP     DE
                POP     AF
                RET
                .END

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
                .ORG    65A0H
MSTEN_DELAY:    PUSH    AF
                PUSH    BC
                PUSH    HL
                LD      HL,LED_TABLE
                LD      A,(DIGIT0)
                LD      L,A
                LD      A,(HL)
                OUT     (SEGPORT),A
                LD      A,0FEH
                OUT     (DISPLAYPORT),A
                LD      BC,05
                CALL    DELAYSUB
                LD      A,0FFH
                OUT     (DISPLAYPORT),A
                LD      A,(DIGIT1)
                LD      L,A
                LD      A,(HL)
                OUT     (SEGPORT),A
                LD      A,0FDH
                OUT     (DISPLAYPORT),A
                LD      BC,5
                CALL    DELAYSUB
                LD      A,0FFH
                OUT     (DISPLAYPORT),A
                POP     HL
                POP     BC
                POP     AF
                RET
                .END
;************************************************
;*                                              *
;* Clear Screen & Display Name Subroutine       *
;*                                              *
;* Registers Affected A,F,B,C,D,E,H,L           *
;*                                              *
;* This subroutine clears the video display     *
;* and outputs my name to the video monitor     *
;*                                              *
;************************************************

 
                .ORG 6580H
CLS_NAME:       PUSH    AF
                PUSH    BC
                PUSH    DE
                PUSH    HL
                LD      A,00CH
                RST     10H
                LD      HL,NAME
                LD      DE,4009H
                LD      BC,0DH
                LDIR
                POP     HL
                POP     DE
                POP     BC
                POP     AF
                RET
                .END
;************************************************
;*                                              *
;* Update display subroutine                    *
;*                                              *
;* Register Affected A,F                        *
;*                                              *
;* This subroutine updates the led displays     *
;*                                              *
;************************************************
                .ORG    6600H
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
                .END
;************************************************
;*                                              *
;* Update CRT subroutine                        *
;*                                              *
;* Registers Affected                           *
;*                                              *
;* Subroutine used to update CRT                *
;*                                              *
;************************************************
                .ORG    6680H
UPDATE_CRT:     LD      (406FH),A
                RET
                .END
;************************************************
;*                                              *
;* Debounce letup subroutine                    *
;*                                              *
;* No Registers Affected                        *
;*                                              *
;* Debounces key on letup                       *
;*                                              *
;************************************************
                .ORG    65E0H
DEBOUNCE_UP:    CALL    GET_KEY
                JP      NC, DEBOUNCE_UP
                CALL    MSTEN_DELAY
                RET
                .END
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
                .ORG    6620H

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
                JP      NZ,FOUND_KEY
OOPS:           INC     B
                BIT     3,B
                JR      Z,NEXT_ROW
                SCF
OUT_OF_HERE:    POP     HL
                POP     DE
                POP     BC
                RET
FOUND_KEY:      LD      D,A
                CALL    MSTEN_DELAY
                IN      A,(PA_PIO)
                CP      D
                JP      NZ,OOPS
                XOR     A
WHY:            RRC     D
                JR      NC,OUT
                INC     A
                JR      C,WHY
OUT:            DEC     B
                JP      M,LOOK_IT_UP
                ADD     A,8
                JR      OUT
LOOK_IT_UP:     LD      HL,ASCII_TABLE
                LD      L,A
                LD      A,(HL)
                JP      OUT_OF_HERE
                RET
                .END
;************************************************
;*                                              *
;* DATA TABLE  LED TEST - NAME                  *
;*                                              *
;************************************************

                .ORG    6700H

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
                .DB     10100111B
                .DB     10100001B
                .DB     10000110B
                .DB     10001110B
                .DB     01111111B
                .TEXT   "WAYNE GARDNER"
DIGIT0          .DB     00H
DIGIT1          .DB     00H
                .END

;************************************************
;*                                              *
;*      ASCII TABLE                             *
;*                                              *
;************************************************






                .ORG    6800H
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
