           ;NAME:  TAN TA T.
           ;LAB6:  UART & MICROPROCESSOR INTERFACE
           ;CLAS:  EET-462L  8D
           ;PROF:  WHEELER
           ;DATE:  FEBUARY 3, 1991

;********************* MAIN PROGRAM **********************

         .ORG      9000H           ;start program

TDHR     .EQU      00H             ;WRITE
RDHR     .EQU      01H             ;READ
STATUS   .EQU      02H             ;READ
CUR_ON   .EQU      0EH             ;cur_on

          CALL     CLEAR           ;clear screen
          LD       A,CUR_ON        ;location of the cursor
          RST      10H             ;write to MAE monitor

RLOOP     CALL     RCVDATA         ;receiver subroutine

          JR       Z,MARZ          ;no intelligence is comming in
          RST      10H             ;write in comming data to the MARZ
          
MARZ      RST      18H             ;check keyboard if press
          JR       Z,RLOOP         ;wait if no key is press

          CALL     TXDATA          ;check if IBM send data

          JR       RLOOP           ;repeat the process


;******************** RECEIVER DATA MODULE ********************

         .ORG      9020H
RCVDATA   IN       A,(STATUS)      ;check UART status
          BIT      0,A             ;check DAV
          RET      Z               ;return if z flag is set
          XOR      A               ;clear A register
          INC      A               ;increment A
          IN       A,(RDHR)        ;receive data from IBM
          RET

;******************* TRANSMITTER DATA MODULE *****************

         .ORG      9030H
TXDATA    PUSH     AF              ;save data
TX1       IN       A,(STATUS)      ;check UART status
          BIT      1,A             ;test TBMT
          JR       Z,TX1           ;wait if TBMT == 0
          POP      AF              ;restore data
          OUT      (TDHR),A        ;write to IBM screen
          RET

;***************** CLEAR SCREEN MODULE *****************

         .ORG      9040H
CLEAR     LD       A,0CH
          RST      10H
          RET


         .END










          


