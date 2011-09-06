SOH         .EQU        $01         ;
EOT         .EQU        $04         ;
BUFFER      .EQU        $6300       ;
VIDEO       .EQU        $401F       ;
NAK         .EQU        $15         ;
ACK         .EQU        $06         ;


            .ORG        $7000       ;

Main        CALL        INIT
MAINAK      CALL        NEG_AK
            CALL        WAIT

COMPARE     CP          SOH         ;
            CALL        Z,GO_SOH    ; GOT AN SOH
            CP          EOT         ;
            CALL        Z,GO_EOT    ; GOT AN EOT

            CALL        NZ,WAIT     ; DO IT AGAIN
            CALL        Z,CHECKSUM  ; GOOD BLK CHECK
            CALL        NZ,ERROR    ; BAD BLK CHECK
            CALL        DATA        ; READ IN BLOCK
            CALL        Z,POS_AK    ; GOOD CHECKSUM
            CALL        NZ,ERROR    ; BAD CHECKSUM
            HALT                    ; DO IT AGAIN




;    *************************************************

INIT        LD          A,00
            LD          (TRIES),A   ; SET TRIES == 0
            LD          A,01        ; SET BLOCK NUMBER
            LD          (BLOCK),A   ; BLOCK == 0
            LD          IX,BUFFER   ; START OF BUFFER
            LD          A,$0C       ; CLEAR SCREEN, HOME CURSOR
            RST         10H         ;
            LD          HL,XMOD     ; HOLDS TEXT
            LD          DE,VIDEO    ;
            LD          BC,15       ; # OF CHARACTERS
            LDIR                    ;
            LD          D,8         ;
            LD          E,02        ;
            LD          A,03        ;
            RST         08H         ; 8,N,1 300 BPS
            RET


CH_OUT      PUSH        AF          ;
            LD          A,02        ; SETS RS232
            RST         30H         ;
            POP         AF          ;
            RST         10H         ; ASSUME A HOLDS DATA TO GO OUT
            RET

CH_IN       LD          A,02        ;
            RST         28H         ; CHKIN
            RST         18H         ; A WILL HOLD THE DATA
            RET

NEG_AK      LD          A,NAK       ;
            CALL        CH_OUT      ; SEND NAK OUT
            RET                     ;


WAIT        PUSH        AF          ;
            CALL        CH_IN       ;
            JP          Z,WAIT      ; Z==1 THEN NO CHARACTER
            POP         AF          ;
            RET                     ;


GO_SOH      CALL        CH_IN       ; LOOK FOR BLK #
            JP          Z,GO_SOH    ; Z==1 THEN NO CHARACTER
            LD          (BLOCK),A   ; STORES BLK NUMBER
AGAIN       CALL        CH_IN       ; LOOK FOR BLK NOT
            JP          Z,AGAIN     ; Z==1 THEN NO CHARCTER
            LD          E,(BLOCK)   ; LOAD BLK #
            XOR         E           ; RESULT SHOULD == FF
            CP          $FF         ;
            RET                     ;



CHECKSUM    PUSH        AF          ; SAVE FLAGS
            LD          A,00        ;
            LD          (CHKSUM),A  ; CLEAR CHECKSUM
            POP         AF          ;
            RET                     ;



DATA        LD          B,128       ; # BYTES IN BLOCK
            LD          H,(CHKSUM)  ; CLEARS ADDITION OF CHECKSUM
LOOP        CALL        CH_IN       ;
            JP          Z,LOOP      ; Z==1 NO CHARCTER
            LD          (IX),A      ; SAVE DATA
            INC         IX          ; INC BUFFER POINTER
            ADD         A,(HL)      ; CALCULATE CHECKSUM
            LD          A,(HL)      ; SAVE CHECKSUM
            DJNZ        LOOP        ; FINISH BLOCK
LOOP2       CALL        CH_IN       ; WAIT FOR BCC
            JP          Z,LOOP2     ; Z== 1
            PUSH        AF          ;
            LD          A,(CHKSUM)  ;
            LD          D,A         ;
            POP         AF          ;
            CP          D           ; DO CHECKSUM MATCH?
            RET                     ;

POS_AK      PUSH        AF          ;
            LD          A,ACK       ; SEND ACK
            CALL        CH_OUT      ; SEND TO TRANSMITTER
            LD          E,(BLOCK)   ;
            INC         E           ; INC BLOCK NUMBER
            POP         AF          ;
            RET                     ;



DELAY       PUSH        AF          ;
            PUSH        BC          ;
LOOPMU      LD          A,0FF       ;
ONEMS       DEC         A           ;
            JP          NZ,ONEMS    ;
            DEC         DE          ;
            LD          A,E         ;
            OR          D           ;
            JR          NZ,LOOPMU   ;
            POP         BC          ;
            POP         AF          ;
            RET                     ;


ERROR       PUSH        AF          ;
LOOP3       CALL        CH_IN       ; ANY CHARACTERS
            JP          NZ,LOOP3    ;
            LD          DE,$61      ;
            CALL        DELAY       ; MAKE SURE NO MORE CHARACTERS
            LD          A,(TRIES)   ;
            INC         A           ;
            LD          (TRIES),A   ;
            CP          $0A         ; TEN TRIES?
            JP          NZ,FAIL     ; LOCK UP YOUR DONE!
            POP         AF          ;
            JP          MAINAK      ; DO IT AGAIN, SAM
FAIL        RST         20H         ; ALL DONE!



GO_EOT      PUSH        AF          ;
            LD          A,ACK       ;
            CALL        CH_OUT      ;
LOOP4       CALL        CH_IN       ;
            JP          Z,LOOP4     ;
            CP          EOT         ;
            JP          NZ,ERROR1   ;
            JP          Z,SEND      ;
            POP         AF          ;
ERROR1      JP          ERROR       ;
SEND        LD          A,ACK       ;
            CALL        CH_OUT      ;
            LD          HL,DONE     ;
            CALL        $D1         ;
            HALT                    ; ALL DONE


DONE        .TEXT       "EOT RECEIVED\000"

XMOD        .TEXT       "XMODEM RECEIVER"
TRIES       .DB         1

BLOCK       .DB         1
CHKSUM      .DB         1
            .END



