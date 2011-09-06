        .org    7000h
        ld      a,0ch
        rst     10h
        ld      hl,name
        ld      de,4000h
        ld      bc,80d
        ldir
        halt
name    .text   "ROBERT L. CROUCH"
        .text   "                "
        .text   "  506-15-1556   "
        .text   "                "
        .text   "   5-17-1991    "
        .end



