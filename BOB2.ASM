        .ORG    8000H
        LD      BC,0200H
        LD      HL,4000H
        LD      A,20H
        LD      (HL),A
        INC     HL
        DEC     BC
        LD      A,C
        OR      B
        JP      NZ,8006H
        LD      BC,4000H
        LD      HL,8500H
        LD      D,10H
        LD      A,(HL)
        LD      (BC),A
        INC     HL
        INC     BC
        DEC     D
        JP      NZ,8018H
        LD      BC,4040H
        LD      D,0CH
        LD      A,(HL)
        LD      (BC),A
        INC     HL
        INC     BC
        DEC     D
        JP      NZ,8025H
        LD      BC,4080H
        LD      D,0BH
        LD      A,(HL)
        LD      (BC),A
        INC     HL
        INC     BC
        DEC     D
        JP      NZ,8032H
         HALT
        .END

