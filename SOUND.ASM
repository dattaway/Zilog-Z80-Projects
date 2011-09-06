npint       .org        $6260
nxtchr      .equ        $cce
skpchr      .equ        $ccd
gethex      .equ        $cdc
command     .equ        $bba
monitor     .equ        $bc6
pr2hex      .equ        $f5
return      .equ        $0d
#define     CHROUT      rst         10h
soundpt     .equ        $00


;*******************************************************************************
;main --
;*******************************************************************************
;

sound       .org        npint
            jp          main

main        push        bc
            pop         hl
            call        nxtchr
            call        gethex
            call        dosound
            ld          b,$ff
            ld          d,b
nextdo      call        dosounde
            dec         d
            inc         e
            djnz        nextdo
            ret

dosounde    push        de
            push        bc
dosound     ld          a,e
nextsound   sla         a
            ld          b,a
wait        djnz        wait
            ld          b,d
wait2       djnz        wait2
            sra         a
            sla         a
            out         (soundpt),a
            jr          c,nextsound
            dec         d
            jr          nz,dosound
            pop         bc
            pop         de
            ret

            .end
