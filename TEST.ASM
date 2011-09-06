;test.asm
;duane p. attaway
;sio initialization and testing proceedure
;

ctc         .equ        $04
ctc0        .equ        ctc
ctc1        .equ        ctc+1
ctc2        .equ        ctc+2
ctc3        .equ        ctc+3

sio2        .equ        $0c
sioad       .equ        sio2
siobd       .equ        sio2+1
sioac       .equ        sio2+2
siobc       .equ        sio2+3

ctrla       .equ        1
ctrlb       .equ        2
ctrlc       .equ        3
ctrld       .equ        4
ctrle       .equ        5
ctrlf       .equ        6
ctrlg       .equ        7
ctrlh       .equ        8
ctrli       .equ        9
ctrlj       .equ        10
ctrlk       .equ        11
ctrll       .equ        12
ctrlm       .equ        13
ctrln       .equ        14
ctrlo       .equ        15
ctrlp       .equ        16
ctrlq       .equ        17
ctrlr       .equ        18
ctrls       .equ        19
ctrlt       .equ        20
ctrlu       .equ        21
ctrlv       .equ        22
ctrlw       .equ        23
ctrlx       .equ        24
ctrly       .equ        25
ctrlz       .equ        26
backspace   .equ        $08
down        .equ        $1a
esc         .equ        $1b
left        .equ        $18
return      .equ        $0d
right       .equ        $19
space       .equ        $20
tab         .equ        $c
up          .equ        $1c
escape      .equ        $1b

;<*** old ROM Interface ***>
#define     CHROUT      rst         10h
#define     CHRIN       rst         18h
chroutvect  .equ        $6004
command     .equ        $bc6
dflti       .equ        $6018
dflto       .equ        $6019
getchar     .equ        $434
getchrvct   .equ        $6007
par_prn     .equ        $a83
prtc        .equ        $54d
ncint       .org        $6254
njint       .org        $6254
nkint       .org        $6257
nlint       .org        $625a
nnint       .org        $625d
npint       .org        $6260
nqint       .org        $6263
nvint       .org        $6266
nxint       .org        $6269
nyint       .org        $626c
nzint       .org        $626f
n0int       .org        $6272
            jp          init
n1int       .org        $6275
            jp          readmon
n2int       .org        $6278
            jp          txmon
n3int       .org        $627b
n4int       .org        $627e
n5int       .org        $6281
n6int       .org        $6284
n7int       .org        $6287
n8int       .org        $628a
n9int       .org        $628d

init        .org        $7f00
sioreset    .equ        00000000b
sioch0      .equ        00000000b
sioch2      .equ        00000010b
sioch4      .equ        00000100b
sioch3      .equ        00000011b
sioch5      .equ        00000101b
sioch1      .equ        00000001b
sioextres   .equ        00010000b

            ld          c,sioac                 ;reset sio
            ld          a,sioreset            ;
            out         (c),a
            ld          a,sioch0
            out         (c),a
            ld          a,00010100b
            out         (c),a
            ld          a,00110100b
            out         (c),a
            ld          a,sioch3
            out         (c),a
            ld          a,11000001b
            out         (c),a
            ld          a,sioch5
            out         (c),a
            ld          a,11101000b
            out         (c),a
            ld          a,sioch1
            out         (c),a
            ld          a,00000000b
            out         (c),a
            ret

readmon     call        rx
            jr          z,readmon
            CHROUT
            CHRIN
            cp          escape
            jr          z,exitall
            jr          readmon

exitall     jp          $0bc6

txmon       ld          a,$20
nxmon       call        tx
            inc         a
            cp          $80
            jr          nz,nxmon
            jp          txmon

rx          push        af
nrx         xor         a
            out         (sioac),a
            nop
            in          a,(sioac)
            and         1
            jr          z,nrx
            pop         af
            in          a,(sioad)
            or          a
            ret

tx          push        af
ntx         xor         a
            out         (sioac),a
            nop
            in          a,(sioac)
            and         00000100b
            jr          z,ntx
            pop         af
            out         (sioad),a
            ret

            .end
