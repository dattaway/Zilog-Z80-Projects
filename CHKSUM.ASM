npint       .org        $6260
nxtchr      .equ        $cce
skpchr      .equ        $ccd
gethex      .equ        $cdc
command     .equ        $bba
monitor     .equ        $bc6
pr2hex      .equ        $f5
return      .equ        $0d
#define     CHROUT      rst         10h


;*******************************************************************************
;main -- for 8K
;*******************************************************************************
;

chksume     .org        npint
            jp          main
            .org        $6300

main        push        bc
            pop         hl
            call        nxtchr
            call        gethex
            call        chksum
            call        pr2hex
            ret

chksum      ld          hl,$c000
            ld          bc,$1fff
            ld          de,$0000
nextbyte    ld          a,(hl)
            add         a,e
            ld          e,a
            ld          a,0
            adc         a,d
            ld          d,a
            inc         hl
            dec         c
            jr          nz,nextbyte
            dec         b
            jr          nz,nextbyte
            ret

            .end
