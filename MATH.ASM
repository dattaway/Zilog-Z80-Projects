;math subroutines -- Duane Attaway
;Ref: The Z80 Microcomputer Handbook, SAMS
; <*** Revision: Sun  08-04-1991  at 20:33:40 ***>   ;

;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณmult16 Subroutine:                                                           ณ
;ณRegisters Used:                                                              ณ
;ณStack Used:                                                                  ณ
;ณ                                                                             ณ
;ณThis subroutine takes DE and BC to form a 32 bit product in DEHL             ณ
;ณ                                                                             ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;
mult16      ld          a,16
            ld          hl,0
loop        ex          de,hl
            add         hl,hl
            push        af
            ex          de,hl
            add         hl,hl
            jp          nc,jump1
            inc         de
jump1       pop         af
            jp          nc,jump3
            add         hl,bc
jump2       jp          nc,jump3
            inc         de
jump3       dec         a
            ret         z
            jp          loop


;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณdvde16 Subroutine:                                                           ณ
;ณRegisters Used:                                                              ณ
;ณStack Used:                                                                  ณ
;ณ                                                                             ณ
;ณThis subroutine takes HLDE devides by BC and returns the result in DE with   ณ
;ณany remainder in HL.                                                         ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;
dvde16      ld          a,16
loop        add         hl,hl
            ex          de,hl
            add         hl,hl
            ex          de,hl
            jp          nc,jump2
            inc         hl
jump1       or          a
            sbc         hl,bc
            inc         de
            jp          nc,jump2
            add         hl,bc
            res         0,e
jump2       dec         a
            jp          nz,loop
            ret


;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณmpadd Subroutine:                                                            ณ
;ณRegisters Used:                                                              ณ
;ณStack Used:                                                                  ณ
;ณ                                                                             ณ
;ณThis subroutine provides n-precision adds.                                   ณ
;ณ                                                                             ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;
mpadd       ld          b,0
            add         hl,bc
            dec         hl
            ex          de,hl
            add         hl,bc
            dec         hl
            ex          de,hl
            or          a
loop        ld          a,(de)
            adc         a,(hl)
            ld          (hl),a
            dec         hl
            dec         de
            dec         c
            jr          nz,loop
            ret

;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณmpsub Subroutine:                                                            ณ
;ณRegisters Used:                                                              ณ
;ณStack Used:                                                                  ณ
;ณ                                                                             ณ
;ณThis subroutine provides n-precision adds.                                   ณ
;ณ                                                                             ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;
mpadd       ld          b,0
            add         hl,bc
            dec         hl
            ex          de,hl
            add         hl,bc
            dec         hl
            ex          de,hl
            or          a
loop        ld          a,(de)
            sbc         a,(hl)
            ld          (hl),a
            dec         hl
            dec         de
            dec         c
            jr          nz,loop
            ret


;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณasxbin Subroutine:                                                           ณ
;ณRegisters Used:                                                              ณ
;ณStack Used:                                                                  ณ
;ณ                                                                             ณ
;ณThis subroutine converts an ascii string of 0's and 1's to a binary number   ณ
;ณinto the A-Register.                                                         ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;
ascbin      ld          b,8
            ld          c,0
loop        sla         c
            ld          a,(hl)
            inc         hl
            sub         30h
            or          c
            ld          c,a
            djnz        loop
            ret

;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณasxhex Subroutine:                                                           ณ
;ณRegisters Used:                                                              ณ
;ณStack Used:                                                                  ณ
;ณ                                                                             ณ
;ณThis subroutine converts two ascii hex characters into     a binary number   ณ
;ณinto the A-Register.                                                         ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;
asxhex      ld          c,0
            ld          a,(hl)
            call        cvert
            inc         hl
            ld          a,(hl)
            call        cvert
            inc         hl
            ret
cvert       sla         c
            sla         c
            sla         c
            sla         c
            sub         30h
            cp          a,10
            jp          m,jump1
            sub         7
jump1       add         a,c
            ld          c,a
            ret

;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณasxbcd Subroutine:                                                           ณ
;ณRegisters Used:                                                              ณ
;ณStack Used:                                                                  ณ
;ณ                                                                             ณ
;ณThis subroutine converts 2 ascii bcd values             to a binary number   ณ
;ณinto the A-Register.                                                         ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;
asxbcd      ld          a,(hl)
            inc         hl
            sub         30h
            rlca
            rlca
            rlca
            rlca
            ld          c,a
            ld          a,(hl)
            sub         30h
            add         a,c
            inc         hl
            ret

;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณasxdec Subroutine:                                                           ณ
;ณRegisters Used:                                                              ณ
;ณStack Used:                                                                  ณ
;ณ                                                                             ณ
;ณThis subroutine converts 2 ascii bcd values             to a binary number   ณ
;ณinto the A-Register.                                                         ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;
asxdec      ld          b,5
            ld          hl,0
loop        add         hl,hl
            push        hl
            add         hl,hl
            add         hl,hl
            pop         de
            add         hl,de
            ld          a,(ix)
            sub         30h
            ld          e,a
            ld          d,0
            add         hl,de
            inc         ix
            djnz        loop
            ret

;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณbxasb  Subroutine:                                                           ณ
;ณRegisters Used:                                                              ณ
;ณStack Used:                                                                  ณ
;ณ                                                                             ณ
;ณThis subroutine converts 2 ascii bcd values             to a binary number   ณ
;ณinto the A-Register.                                                         ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;
bxasb       ld          b,8
loop        ld          a,30h
            bit         7,c
            jp          z,jump1
            inc         a
jump1       ld          (hl),a
            sla         c
            inc         hl
            djnz        loop
            ret

;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณbxash  Subroutine:                                                           ณ
;ณRegisters Used:                                                              ณ
;ณStack Used:                                                                  ณ
;ณ                                                                             ณ
;ณThis subroutine converts 2 ascii bcd values             to a binary number   ณ
;ณinto the A-Register.                                                         ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;
bxash       ld          a,$f0
            and         a,c
            rrca
            rrca
            rrca
            rrca
            call        cvert
            ld          a,$f0
            and         c
            call        cvert
            ret
cvert       add         a,30h
            cp          3ah
            jp          m,jump1
            add         a,7
jump1       ld          (hl),a
            inc         hl
            ret

;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณbxbcd  Subroutine:                                                           ณ
;ณRegisters Used:                                                              ณ
;ณStack Used:                                                                  ณ
;ณ                                                                             ณ
;ณThis subroutine converts 2 ascii bcd values             to a binary number   ณ
;ณinto the A-Register.                                                         ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;
bxbcd       ld          a,$f0
            and         c
            rrca
            rrca
            rrca
            rrca
            add         a,30h
            ld          (hl),a
            inc         hl
            ld          a,$0f
            and         c
            add         a,30h
            ld          (hl),a
            inc         hl
            ret

;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณbxdec  Subroutine:                                                           ณ
;ณRegisters Used:                                                              ณ
;ณStack Used:                                                                  ณ
;ณ                                                                             ณ
;ณThis subroutine converts 2 ascii bcd values             to a binary number   ณ
;ณinto the A-Register.                                                         ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;
bxdec       ld          iy,p10tab
loop0       xor         a
            ld          d,(iy+1)
            ld          e,(iy+0)
loop1       or          a
            sbc         hl,de
            jp          c,jump1
            inc         a
            jp          loop1
jump1       add         hl,de
            add         a,30h
            ld          (ix+0),a
            inc         ix
            inc         iy
            inc         iy
            ld          a,e
            cp          1
            jp          nz,loop0
            ret
p10tab      .dw         10000
            .dw         1000
            .dw         100
            .dw         10
            .dw         1

;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณdivide Subroutine:                                                           ณ
;ณRegisters Used:                                                              ณ
;ณStack Used:                                                                  ณ
;ณ                                                                             ณ
;ณThis subroutine converts 2 ascii bcd values             to a binary number   ณ
;ณinto the A-Register.                                                         ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;
divide      ld          hl,(divdnd)
            ld          a,(dvisor)
            neg
            ld          c,a
            ld          b,$ff
            ld          de,0
loop        add         hl,bc
            jr          nc,done
            inc         de
            jp          loop
done        ret

;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณmult   Subroutine:                                                           ณ
;ณRegisters Used:                                                              ณ
;ณStack Used:                                                                  ณ
;ณ                                                                             ณ
;ณThis subroutine converts 2 ascii bcd values             to a binary number   ณ
;ณinto the A-Register.                                                         ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;
mult        ld          l,0
            ld          h,a
            ld          c,b
            ld          b,0
            ld          a,8
loop        add         hl,hl
            jr          nc,jump1
            add         hl,bc
jump1       dec         a
            jr          nz,loop
done        ret

;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณdivide8 Subroutine:                                                          ณ
;ณRegisters Used:                                                              ณ
;ณStack Used:                                                                  ณ
;ณ                                                                             ณ
;ณThis subroutine converts 2 ascii bcd values             to a binary number   ณ
;ณinto the A-Register.                                                         ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;
devide8     ld          c,0
            ld          d,8
loop        add         hl,hl
            xor         a
            sbc         hl,bc
            inc         hl
            jp          nc,jump1
            add         hl,bc
            res         0,l
jump1       dec         d
            jr          nz,loop
done        ret
