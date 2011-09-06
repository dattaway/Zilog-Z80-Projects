;**************************************************
;CONTROL LAB#4                                    *
;PROF. MEADOR                                     *
;THIS IS THE EXCLUSIVE WORK OF:                   *
;TAN TA & MONCHAI ROJJANASRIRAT                   *
;OPEN LOOP MICROPROCESSOR-BASED CONTROL SYSTEM    *
;THIS PROGRAM WILL ACTIVATE THE MAR Z-80          *
;TO SEND OUT THE CURRENT TO FIRE THE SCR.         *
;REGISTER USED:  A, BC, DE, HL                    *
;**************************************************


         .ORG      9000H
         LD        HL,0E000H            ;set up location
         LD        B,20                 ;set space in reg B
         LD        DE,0200H             ;save pixels in reg DE
ONE:     LD        (HL),B               ;put space into memory
         DEC       DE                   ;decrement DE
         LD        A,E                  ;save the LSB into A
         OR        D                    ;or D with A
         INC       HL                   ;increment location
         JR        NZ,ONE               ;if not zero go to ONE
         LD        B,0D8H               ;save count in memory
         LD        HL,0E02CH            ;location to print label
         LD        DE,9500H             ;ptr of look up table
TWO:     LD        A,(DE)               ;save memory into reg A
         LD        (HL),A               ;load memory into HL
         INC       DE                   ;increment memory location
         INC       HL                   ;inc. location on screen
         DEC       B                    ;decrement counter
         JR        NZ,TWO               ;if not 0 go back to two
DO:      DI                             ;disable interrupt
MORE:    LD        C,00H                ;save address into reg C
         LD        A,0FH                ;load 0FH into reg A
         IN        B,(C)                ;read port C into reg C
         AND       B                    ;mask reg B with A
         LD        B,A                  ;save memory into reg B
         CALL      SCREEN               ;call screen subroutine
         BIT       4,B                  ;check bit # 4
         JP        NZ,MORE              ;not zero go back to more
         CALL      DELAY                ;call delay subroutine
         JP        DO                   ;go back to do

;************************************
;SCREEN SUBROUTINE                  *
;************************************
         .ORG      9060H
SCREEN:  LD        D,88H                ;high byte of the look up table
         LD        E,A                  ;save low byte in reg E
         LD        A,(DE)               ;save memory in reg A
         LD        HL,0E0E2H            ;location for label
         LD        C,A                  ;save memory in reg C
         CP        (HL)                 ;compare memory with reg A
         JR        Z,GO                 ;zero jump to GO
         LD        A,C                  ;save C into reg A
         LD        (HL),A               ;put A into (HL)
GO:      RET                            ;end of screen subroutine

;************************************
;DELAY SUBROUTINE                   *
;************************************
         .ORG      9080H
DELAY:   LD        A,B                  ;save input port to reg A
         AND       0FH                  ;mask high byte
         CP        00H                  ;compare 0 to reg A
         JP        Z,PRINT              ;zero go to print
THREE:   LD        C,67H                ;save 10 degree into reg A
FOUR:    DEC       C                    ;decrement degree
         JR        NZ,FOUR              ;not zero go to FOUR
         DEC       A                    ;dec # of input port
         JR        NZ,THREE             ;not zero go to THREE
PRINT:   OUT       (C),B                ;write to output port
         RET                            ;end of delay subroutine

         .END                           ;end of program

