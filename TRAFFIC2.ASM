        .org    6FF9H
        IM      2
        LD      A,71H
        LD      I,A
        EI
START   LD      A,0DBH
        OUT     (40H),A
NEW     LD      A,0AH
LOOP    CALL    DELAY
        DEC     A
        JP      NZ,LOOP
        LD      B,0FFH
        IN      A,(40H)
        CP      B
        JP      Z,NEW
        LD      A,0DDH
        OUT     (40H),A
        CALL    DELAY
        LD      A,7EH
        OUT     (40H),A
        LD      A,05H
NEXT    CALL    DELAY
        DEC     A
        JP      NZ,NEXT
        LD      A,0BEH
        OUT     (40H),A
        CALL    DELAY
        JP      START
DELAY   NOP
        PUSH    BC
        PUSH    DE
        LD      C,04H
LAST    LD      D,0FFH
ORBIT   LD      B,0F5H
AGAIN   DEC     B
        JP      NZ,AGAIN
        DEC     D
        JP      NZ,ORBIT
        DEC     C
        JP      NZ,LAST
        POP     DE
        POP     BC
        RET
        .end
