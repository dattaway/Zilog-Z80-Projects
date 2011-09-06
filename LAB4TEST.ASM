        .org    $8300
        im      1
        ld      hl,$8600
        ld      bc,4096
        ei
        out     ($00),a
wait    nop
        jp      nz,wait
        halt
        .org    $8012
        jp      ADCISR
ADCISR  .org    $8400
        in      a,($00)
        ei
        ld      (hl),a
        inc     hl
        dec     bc
        ld      a,b
        or      c
        out     ($00),a
        ret
        .end





