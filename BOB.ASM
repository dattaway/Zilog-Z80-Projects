        .org    6300h
ram     .equ    8000h
        ld      hl,ram
        ld      de,0800h
next    xor     a
        ld      (hl),a
        ld      b,(hl)
        cp      b
        jp      nz,error
        cpl
        ld      (hl),a
        ld      b,(hl)
        cp      b
        jp      nz,error
        inc     hl
        dec     de
        ld      a,e
        or      d
        jp      nz,next
        jp      done
error   ld      (hl),b
        jr      error
done    ld      d,20h
        ld      hl,4000h
        ld      bc,0200h
loop    ld      (hl),d
        inc     hl
        dec     bc
        ld      a,c
        or      b
        jp      nz,loop
        ld      hl,4000h
        ld      a,52h
        ld      (hl),a
        inc     hl
        ld      a,41h
        ld      (hl),a
        inc     hl
        ld      a,4dh
        ld      (hl),a
        inc     hl
        ld      a,20h
        ld      (hl),a
        inc     hl
        ld      a,49h
        ld      (hl),a
        inc     hl
        ld      a,53h
        ld      (hl),a
        inc     hl
        ld      a,20h
        ld      (hl),a
        inc     hl
        ld      a,4fh
        ld      (hl),a
        inc     hl
        ld      a,4bh
        ld      (hl),a
        halt
        .end



