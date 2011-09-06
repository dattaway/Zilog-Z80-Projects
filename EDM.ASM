; <*** Revision: Wed  09-18-1991  at 20:06:43 ***>   ;
;EDM-80 Rom Disassembly Listing
;Sample listing to demonstrate "good programming"

#define     rst_filem   rst         08h
#define     rst_chrout  rst         10h
#define     rst_chrin   rst         18h
#define     rst_break   rst         20h
#define     rst_chkin   rst         28h
#define     rst_chkout  rst         30h
;memory allocation:
;
romstart    .equ        0000h
video       .equ        4000h
sysmem      .equ        6000h
videosize   .equ        01ffh
grsize      .equ        1800h
ramtop      .equ        0bfffh
stack       .equ        ramtop+1

;system variable allocation:
;
sys_vars    .org        sysmem
rst1        .block      3h          ;6000h
rst2        .block      3h          ;6003h
rst3        .block      3h          ;6006h
rst4        .block      3h          ;6009h
rst5        .block      3h          ;600ch
rst6        .block      3h          ;600fh
rst7        .block      3h          ;6012h
nmiv        .block      3h          ;6015h
dflti       .block      1h          ;6018h
dflto       .block      1h          ;6019h
status      .block      1h          ;601ah
filenam      .block      20
status_len  .equ        baudof-filenam
baudof      .block      1h          ;602fh
baud1       .block      2h
baud2       .block      2h
bitnum      .block      1h          ;6034h
inbuf       .block      128         ;6035h
bufpt       .block      2h
bufln       .equ        0fh
rx_flag     .block      1h
tx_flag     .block      1h
;
column      .block      1h          ;60b9h
row         .block      1h          ;60bah
addr        .block      2h          ;60bbh
cursor      .block      1h          ;60bdh
char_curs   .block      1h          ;60beh
cursor_mode .block      1h          ;60bfh
video_mode  .block      1h          ;60c0h not used
;
mask        .block      9h          ;60c1h
shift       .block      1h          ;60cah
ctrl        .block      1h          ;60cbh
caps        .block      1h          ;60cch
repeat      .block      1h          ;60cdh
repeat_cnt  .block      1h          ;60ceh
rpt_count   .block      1h          ;60cfh
repeat_wait .block      2h          ;60d0h
rpt_wait    .block      2h          ;60d2h

inbufr      .block      128         ;60d4h
escchars    .block      16          ;6154h
flash_crsr  .block      1h          ;6164h
crsr_rate   .block      2h          ;6165h
crsr_count  .block      2h          ;6167h

auto_flag   .block      8h          ;6169h
auto_addr   .block      2h          ;6171h
gaddr       .block      2h          ;6173h
gmask       .block      3h          ;6175h
break_hold  .block      3h          ;61c8h
break_addr  .block      2h          ;61c9h
asciiflag   .block      1h          ;61afh
no_instr    .block      1h          ;6215h

;ascii and text configuration:
;
ylen        .equ        0fh
xlen        .equ        1fh
space       .equ        20h

;hardware addresses:
;
pio         .equ        80h
cntrla      .equ        pio+1       ;pio, ctrl a
piopa       .equ        pio         ;pio, port a
cntrlb      .equ        pio+3       ;pio, ctrl b
piopb       .equ        pio+2       ;pio, port b

ctc         .equ        84h
ctc0        .equ        ctc
ctc1        .equ        ctc+1
ctc2        .equ        ctc+2
ctc3        .equ        ctc+3

sio         .equ        88h
sioad       .equ        sio
siobd       .equ        sio+1
sioac        .equ        sio+2

;8255 controller
;   76543210    *** control word ***  --for ppicntrl port
;   ³³³³³³³³
;   ³³³³³³³ÀÄÄÄÄport c-- 1/input; 0/output  (lower bits-pc3-pc0) ¿
;   ³³³³³³ÀÄÄÄÄÄport b-- 1/input; 0/output                       ³mode group a
;   ³³³³³ÀÄÄÄÄÄÄmode selection--  0/mode 0; 1/mode 1             Ù
;   ³³³³ÀÄÄÄÄÄÄÄport c-- 1/input; 0/output  (upper bits-pc7-pc4) ¿
;   ³³³ÀÄÄÄÄÄÄÄÄport a-- 1/input; 0/output                       ³mode group b
;   ³³ÀÄÄÄÄÄÄÄÄÄÚmode selection-- 00 mode 0, 01 mode1,           ³
;   ³ÀÄÄÄÄÄÄÄÄÄÄÀ                 1x mode 2                      Ù
;   ÀÄÄÄÄÄÄÄÄÄÄÄ 1= i/o mode;  2= bsr mode (bit-set-reset)
;
;   76543210
;   ³³³³³³³³
;   ³³³³³³³ÀÄÄÄÄs/r:  1= set, 0= reset
;   ³³³³ÀÁÁÄÄÄÄÄbit:  000 bit0, 001 bit1, 010 bit2, 011 bit3, ect...
;   ³ÀÁÁÄÄÄÄÄÄÄÄxxx:  not used, set to zero
;   ÀÄÄÄÄÄÄÄÄÄÄÄbsr:  0
;
ppi         .equ        8ch
ppia        .equ        ppi
ppib        .equ        ppi+1
ppic        .equ        ppi+2
ppicntrl    .equ        ppi+3

parl        .equ        90h

adc         .equ        94h




;rom listing:
;
start       .org        romstart
            di
            xor         a
            ld          sp,stack
            jp          pwrup       ;go do the power-on self-test
l008        jp          rst1        ;rst 08h vector
msg1        .text       "ram  "     ;msg: ram failure
l010        jp          rst2        ;rst 10h vector
            .text       "rom  "     ;msg: rom checksum bad
            jp          rst3        ;rst 18h
            .text       "8255 "     ;msg: keyboard failure
            jp          rst4        ;rst 20h
            .text       "sio  "     ;msg: z80 sio failure
            jp          rst5        ;rst 28h
            .text       "pio  "     ;msg: z80 pio failure
            jp          rst6        ;rst 30h
            .text       "vdg  "     ;msg: 6487 vdg failure
            jp          rst7        ;rst 38h

;power up routine -- do a ram test from $800 to $9fff, halt if any
;errors.  if ram test is ok, check the system rom by doing a checksum (the
;checksum of the rom should be $00.  if this is ok, initialize the ram
;vectors, test keyboard (stuck keys) and 6847 vdg (see if the horizontal
;sync and vertical sync are present).
;
;in addition, bit 7 of the pio will be
;"flashed" on and off a number of times, according to the following code:
;
;
;     # flashes          meaning
;----------------------------------------------
;        1          ram failure
;        2          rom checksum bad
;        3          keyboard failure (not clear)
;        4          z80 sio not responding
;        5          z80 pio not responding
;        6          mc6847 vdg appers dead (no h or v sync)
;
;the pattern of flashes repeats indefinitely.
;

pwrup       ld          bc,0ffffh   ;produce a long wait period to prevent
wait        dec         bc          ;sporatic resets
            ld          a,b
            or          c
            jr          nz,wait
            ld          hl,sysmem   ;bottom of ram
pwr1        ld          a,(hl)      ;get original ram data
            cpl                     ;flip all bits
            ld          (hl),a      ;try to store it back in
            cp          (hl)        ;see if it is stored correctly
            ld          e,01        ;error code #1
            jr          nz,pwr_error;not ok--ram error
            cpl
            ld          (hl),a      ;restore the data
            inc         hl
            ld          a,h
            cp     (sysmem+200h)>>8 ;test until we reach top of system area
            jr          nz,pwr1     ;go back & test another location

;ramtest ok, now permissible to use the stack
;
            call        pwrup2      ;copy the power-up vector table into ram
            call        video_init  ;initialize the '6847 if possible
            ld          e,06h       ;error #6
            jr          c,pwr_error ;6847 dead!
            ld          hl,0000h    ;start summing at 0000h
            jr          chksumi
            nop
n0066       jp          nmihandler  ;nmi vectored jump
chksumi     ld          e,00h       ;checksum holding register
chksum      ld          a,e         ;recall checksum
            add         a,(hl)      ;add in the current byte
            ld          e,a         ;store checksum
            inc         hl          ;point to next byte in rom
            ld          a,h         ;check to see if we're done
            cp          40h         ;highest address summed=3fffh
            jr          nz,chksum
            ld          a,e
            ld          e,02h       ;error #2 rom bad
            xor         a           ;rom checksum=$00 if ok
            jr          nz,pwr_error;tests ok, proceed to powerup phase 2
            jp          chksum
;
;power up error handled here. the numbered message is directly written to
;the video, in case the 6847 is working.  the vidlatch d7 bit is toggled
;to match the error code in (e).
;
pwr_error   ld          a,e
            exx
            ld          e,a         ;save it in e', stack may be useless
            exx
            ld          de,0008h    ;offset between messages
            ld          hl,0003h    ;where to begin
            ld          b,a         ;error # for addr. calculation

pwr_err1    add         hl,de
            djnz        pwr_err1    ;calc address of message
            ld          a,0fh       ;setup 6847 (if it is alive)
            out         (cntrla),a
            ld          bc,0005h    ;message length
            ld          de,video
            ldir                    ;write msg to display
;
;flash led according to error code
;
flash       exx
            ld          a,e         ;recall error code
            exx
            ld          b,a         ;flash counter
fl1         ld          hl,0000     ;delay count: 65536
            ld          a,80h       ;led "on"
fl1b        out         (piopa),a
fl1a        dec         l
            jr          nz,fl1a
            dec         h
            jr          nz,fl1a
            xor         80h         ;led "off"
            jp          m,fl2       ;jump out if turning back "on" (2loops)
            jr          fl1b
fl2         djnz        fl1         ;flash <b> times
            ld          b,05h       ;very long wait with led off
fl3         dec         hl          ;so that user can count the flashes
            ld          a,h
            or          l
            jr          nz,fl3
            djnz        fl3         ;b3
            jr          flash       ;97

;
;j-table -- standard monitor routine jump addresses
;
cls         jp          clsv        ;4bf  bc s   ;clears the screen
input       jp          inputv      ;92f  bf  k  ;standard line input
linei       jp          lineiv      ;932  c2  k  ;line input with modified escape
scrdn       jp          scrdnv      ;4a2  c5 s   ;scrolls down
scrup       jp          scrupv      ;c8   c8 s   ;scrolls normally up
scroll      jp          scrollv     ;cb   cb s   ;
setxy       jp          setxyv      ;415  ce s
prtstg      jp          prtstgv     ;40e  d1 s
scan        jp          scanv       ;78c  d4  k
scana       jp          scanav      ;6e1  d7  k
clear_line  jp          clear_linev ;480  da s
screendump  jp          screendumpv ;69e  dd s
set_pix     jp          set_pixv    ;196  e0   g
reset_pix   jp          reset_pixv  ;1ab  e3   g
xor_pix     jp          xor_pixv    ;1c2  e6   g
draw_line   jp          draw_linev  ;206  e9   g
draw_to     jp          draw_tov    ;1fd  ec   g
cls_gr      jp          cls_grv     ;0fe  ef   g
prhex       jp          prhexv      ;aac  f2    a
pr2hex      jp          pr2hexv     ;a9f  f5    a
p_int       jp          p_intv      ;b21  f8    a
bin2asc     jp          bin2ascv    ;acf  fb    a

;
;graphics routines:
;
;
;cls_gr--clears the entire graphics page with pattern held in a-register.
;af, bc, de, & hl are destroyed.
;
cls_grv     ld          hl,video    ;clears the entire graphics area
            ld          (hl),a
            ld          de,video+1h
            ld          bc,grsize   ;do one full graphics page
            ldir
            ret

;10b
;get address
;
getaddr     push        hl
            push        bc
            ld          a,l
            and         07h
            ld          (gmask),a
            srl         l
            srl         l
            srl         l
            ld          h,00
            push        hl
            ld          l,c
            ld          h,00
            add         hl,hl
            add         hl,hl
            add         hl,hl
            add         hl,hl
            add         hl,hl
            ld          de,video
            add         hl,de
            pop         de
            add         hl,de
            ld          (gaddr),hl
            pop         bc
            pop         hl
            ret

;
;130
;
            ld          hl,0000
temp1       srl         b
            jr          nc,temp2
            add         hl,de
temp2       ret         z
            ex          de,hl
            add         hl,hl
            ex          de,hl
            jr          temp1

;
;13e
;
            push        af
            push        bc
            ld          c,l
            ld          a,h
            ld          hl,0000
            ld          ix,0000
            ld          b,10
temp4       sla         c
            rl          a
            rl          l
            rl          h
            add         ix,ix
            inc         ix
            or          a
            sbc         hl,de
            jr          nc,temp3
            add         hl,de
            dec         ix
temp3       djnz        temp4
            pop         bc
            pop         af
            ret
 ;
 ;164
 ;
            push        ix
            push        bc
            ld          a,l
            ld          l,h
            ld          h,00
            ld          e,00
            ld          b,10h
            ld          ix,0000
temp7       add         hl,hl
            rla
            jr          nc,temp5
            inc         l
temp5       add         ix,ix
            inc         ix
            or          a
            sbc         hl,de
            jr          nc,temp6
            add         hl,de
            dec         ix
temp6       djnz        temp7
            ld          a,h
            push        ix
            pop         hl
            pop         bc
            pop         ix
            ret

;
;18e
;
gtable      .db         80h, 40h, 20h, 10h, 08h, 04h, 02h, 01h

;196
;set_pix  --hl holds (x,y) to set a pixel.  af is destroyed.
;
set_pixv    push        hl
            call        cdsplit     ;transfer hl coords into   hl: x,  bc: y
            call        019fh       ;set the pixel on the screen
            pop         hl
            ret

;19f
;write a coordinate
;
writecoord  call        getaddr     ;get address
            call        01d7h
            ld          hl,(gaddr)
            or          (hl)
            ld          (hl),a
            ret

;1ab
;reset_pix--hl holds (x,y) to clear a pixel.  af is destroyed.
;
reset_pixv  push        hl
            call        01f8h       ;transfer hl coords into   hl: x,  bc: y
            call        01b4h
            pop         hl
            ret

;
;1b4 -- clear a pixel of hl,bc
;
            call        getaddr     ;get address of pixel
            call        01d7h
            xor         0ffh
            ld          hl,(gaddr)
            and         (hl)
            ld          (hl),a
            ret

;1c2
;xor_pix  --hl points to (x,y) to xor a coordinate. af is destroyed.
;
xor_pixv    push        hl
            call        01f8h       ;transfer hl coords into   hl: x,  bc: y
            call        01cbh
            pop         hl
            ret

;
;1cb
;
            call        getaddr
            call        01d7h
            ld          hl,(gaddr)
            xor         (hl)
            ld          (hl),a
            ret

;
;1d7
;
tcall2      ld          de,(gmask)
            ld          d,00
            ld          hl,gtable
            add         hl,de
            ld          a,(hl)
            ret

;
;1e3
;
            push        de
            bit         7,h
            jr          z,01efh
            ld          de,0000
            ex          de,hl
            or          a
            sbc         hl,de
            pop         de
            ret

;
;1f1
;
            or          a
            jp          p,01f7h
            neg
            ret

;
;1f8  -- seperates coordinates in hl (x,y) into (hl: x, bc: y)
;
cdsplit     ld          c,l         ;bc now hols y
            ld          l,h
            ld          h,00        ;leave only the x coordinate in hl
            ret

;1fd
;draw_to --line segments are drawn to de. a-register holds style pattern
;a:  0-set 1-reset 2-dotted 3-xor.  af is destroyed.
;
draw_tov    push        hl
            ld          hl,(6190h)
            call        0206h
            pop         hl
            ret

;206
;draw_line --line segments are drawn with a holding the style code:
;a:  0-set 1-reset, 2-dotted, 3-xor;  hl, de hold endpoints.  af destroyed.
;
draw_linev  push        af
            push        bc
            push        de
            push        hl
            push        ix
            ld          (6190h),de
            call        021ah
            pop         ix
            pop         hl
            pop         de
            pop         bc
            pop         af
            ret

;21a
;
;
            ld          (6177h),a
            call        01f8h
            ld          b,e
            ld          e,d
            ld          d,00
            push        hl
            or          a
            sbc         hl,de
            pop         hl
            jr          nz,024dh
            ld          a,c
            cp          b
            jr          nz,0232h
            jp          0317h
            call        03d6h
            ld          bc,(617dh)
            ld          e,b
            ld          hl,(6179h)
            call        0317h
            ld          a,c
            cp          e
            jr          z,024ch
            ld          bc,(618fh)
            add         a,c
            ld          c,a
            jr          023dh
            ret

;
;24d
;
            ld          a,c
            cp          b
            jr          nz,0275h
            call        03d6h
            ld          hl,(6179h)
            ld          de,(617bh)
            ld          bc,(617dh)
            call        0317h
            push        hl
            ld          bc,(617bh)
            or          a
            sbc         hl,bc
            pop         hl
            jr          z,0274h
            ld          bc,(618dh)
            add         hl,bc
            jr          025bh
            ret

;
;275
;
            call        03d6h
            ld          hl,(6181h)
            call        01e3h
            ld          (618bh),hl
            ld          hl,0000
            ld          (6185h),hl
            ld          hl,(617fh)
            call        01e3h
            ld          (6189h),hl
            ld          a,h
            or          a
            jp          nz,0348h
            ld          a,(618bh)
            cp          l
            jp          c,0348h
            ld          l,a
            ld          h,00
            ld          de,(6189h)
            inc         de
            ld          (6189h),de
            call        013eh
            ld          (6187h),hl
            xor         a
            ld          (6188h),a
            push        ix
            pop         hl
            ld          a,(618fh)
            or          a
            jp          p,02c2h
            ex          de,hl
            ld          hl,0000
            sbc         hl,de
            ld          (6183h),hl
            ld          a,(617dh)
            ld          hl,(6183h)
            add         a,l
            ld          hl,(6185h)
            ld          de,(6187h)
            add         hl,de
            ld          (6185h),hl
            ld          de,(6189h)
            or          a
            sbc         hl,de
            jr          c,02e7h
            ld          (6185h),hl
            ld          hl,(618fh)
            add         a,l
            ld          hl,(6179h)
            ld          bc,(617dh)
            ld          e,a
            ld          (617dh),a
            call        0317h
            ld          a,c
            cp          e
            jr          z,0301h
            ld          bc,(618fh)
            add         a,c
            ld          c,a
            jr          02f2h
            push        hl
            ld          bc,(617bh)
            or          a
            sbc         hl,bc
            pop         hl
            jr          z,0316h
            ld          de,(618dh)
            add         hl,de
            ld          (6179h),hl
            jr          02c5h
            ret

;
;317
;
            push        af
            push        bc
            push        de
            push        hl
            ld          a,(6177h)
            cp          02          ;31e
            jr          z,033bh
            cp          03
            jr          z,032eh
            or          a
            jr          nz,0333h
            call        019fh
            jr          0336h
            call        01cbh
            jr          0336h
            call        01b4h
            pop         hl
            pop         de
            pop         bc
            pop         af
            ret

;
;33b
;
            ld          a,(6178h)
            inc         a
            and         03
            ld          (6178h),a
            srl         a
            jr          031eh
            ld          a,(618bh)
            inc         a
            ld          e,a
            ld          (618bh),a
            ld          d,00
            ld          hl,(6189h)
            call        013eh
            ld          (6187h),hl
            push        ix
            pop         hl
            ld          a,(618eh)
            or          a
            jp          p,036bh
            ex          de,hl
            ld          hl,0000
            sbc         hl,de
            ld          (6183h),hl  ;36bh
            ld          hl,(6185h)
            ld          de,(6187h)
            add         hl,de
            ld          (6185h),hl
            ld          hl,(6179h)
            ld          de,(6183h)
            add         hl,de
            ld          (617bh),hl
            ld          hl,(6185h)
            ld          de,(618bh)
            ld          d,00
            or          a
            sbc         hl,de
            jr          c,03a0h
            ld          (6185h),hl
            ld          de,(618dh)
            ld          hl,(617bh)
            add         hl,de
            ld          (617bh),hl
            ld          a,(617dh)   ;3a0h
            ld          c,a
            ld          hl,(6179h)
            ld          de,(617bh)
            call        0317h       ;3abh
            push        hl
            or          a
            sbc         hl,de
            pop         hl
            jr          z,03beh
            push        bc
            ld          bc,(618dh)
            add         hl,bc
            pop         bc
            jr          03abh
            ld          hl,(617bh)  ;3beh
            ld          (6179h),hl
            ld          a,(617eh)
            cp          c
            jr          z,03d5h
            ld          a,c
            ld          bc,(618fh)
            add         a,c
            ld          (617dh),a
            jr          036eh
            ret                     ;3d5h

;
;3d6
;
            ld          (6179h),hl
            ld          (617bh),de
            ld          (617dh),bc
            or          a
            ex          de,hl
            sbc         hl,de
            ld          (617fh),hl
            ld          de,0ffffh
            ld          a,h
            or          a
            jp          m,03f3h
            ld          de,0001
            ld          (618dh),de  ;3f3h
            ld          h,00
            ld          l,b
            ld          b,00
            ld          e,0ffh
            or          a
            sbc         hl,bc
            ld          (6181h),hl
            jp          m,0409h
            ld          e,01
            ld          a,e         ;409h
            ld          (618fh),a
            ret

;
;video driver routines
;
;prtstg--print a string to the video display at the current cursor
;        position.  hl points to the string, which must be terminated
;        with 00h.
;
prtstgv     ld          a,(hl)
            or          a
            ret         z
            rst_chrout              ;chrout--output character
            inc         hl
            jr          prtstgv

;setxy--set the cursor (x,y) position. e=x=column, 0-31; d=y=row, 0-15.
;       values are not error checked!
;
setxyv      push        bc
            push        de
            push        hl
            ld       a,(cursor_mode);see if cursor is on
            or          a
            call        nz,temp_off ;shut off if on
            ld          a,e
            ld          (column),a
            ld          a,d
            ld          (row),a
            call        calc_addr
            ld          (addr),hl   ;get new cursor address
            call        cursor_fix  ;fix the cursor if needed
            pop         hl
            pop         de
            pop         bc
            ret

;getchar--fetch character at cursor position (into a-register), advance
;cursor one place forward
;
getchar     push        bc
            push        de
            push        hl
            ld       a,(cursor_mode);see if cursor is on
            or          a
            jr          z,not_on    ;cursor not on, must fetch from ram
            ld         a,(char_curs);cursor on, (char_curs) holds the char
;return the character
;
retchar     push        af
            ld          a,19h       ;command: advance
            call        prtc        ;print it, adv. cursor
            pop         af
            pop         hl
            pop         de
            pop         bc
            ret

not_on      ld          hl,(addr)   ;get cursor address
            ld          a,(hl)      ;get character at that address
            jr          retchar

;calculate a video memory address from row (d) and column (e), and
;return it in hl.
;
calc_addr   push        de
            ld          l,d         ;l=row # (0-15)
            ld          h,00
            add         hl,hl       ;2*row
            add         hl,hl       ;4*row
            add         hl,hl       ;8*row
            add         hl,hl       ;16*row
            add         hl,hl       ;32*row
            ld          d,00        ;prepare for 16 bit add
            add         hl,de       ;32*row + column# (0-15)
            ld          de,video
            add         hl,de       ;32*row + column# +video_base_address
            pop         de
            ret

;scroll up entire video display by 1 line
;
scrollv     ld          bc,ylen     ;0,15
;
;scroll a portion of the video display up by one line.
;b=row# of top of scrolled area,
;c=row# of bottom of scrolled area
;
;af is destroyed.
;
scrupv      push        hl
            push        de
            push        bc
            ld          d,b         ;row# top
            ld          e,00        ;col#0
            call        calc_addr   ;find the address of top line in area
            push        hl          ;save it a moment
            ld          a,c         ;a=bottom row#
            sub         d           ;a=(bottom-top)=# of rows to scroll
            call        bytcnt      ;get the byte count in (bc)
            pop         de          ;recall top address
            ld          hl,0020h    ;will move it from next row down
            add         hl,de
            ldir                    ;do it!
            pop         bc
            pop         de
            pop         hl
            ld          a,c         ;now setup to clear bottom line
;clear a line on the display to $20 pattern (blank). a=line # to blank.
;
clear_linev push        bc
            push        de
            push        hl
            ld          e,00        ;column 0
            ld          d,a         ;row #
            call        bytcnt      ;find start of this line...
            ld          b,20h       ;# of bytes on this line to clear
            ld          c,space     ;what to write in
cli1        ld          (hl),c      ;clear it
            inc         hl
            djnz        cli1
            pop         hl
            pop         de
            pop         bc
            ret

;calculate how many bytes in a particular screen scroll. a=#of total rows to
;scroll. returns count in bc.
;
bytcnt      ld          hl,0000h
            ld          bc,0020h
scr1        add         hl,bc
            dec         a
            jr          nz,scr1     ;#bytes to move is 32*rows to scroll
            push        hl
            pop         bc          ;setup for block move of video
            ret

;scroll a portion of the video display down by one line.
;b=row# of top of scrolled area,
;c=row# of bottom of scrolled area
;
;af is destroyed
;
scrdnv      push        hl
            push        de
            push        bc
            ld          d,c         ;row# bottom
            ld          e,xlen      ;col#31
            call        calc_addr   ;find address of bottom line in area
            push        hl          ;save it a moment
            ld          a,c         ;a=bottom row#
            sub         b           ;a=(bottom-top)=# of rows to scroll
            call        bytcnt      ;get the byte count in (bc)
            pop         de          ;recall bottom address
            ld          hl,0ffe0h   ;will move it from next row up
            add         hl,de
            lddr                    ;do it!
            pop         bc
            pop         de
            pop         hl
            ld          a,b         ;address of top line
            jp          clear_line  ;clear it off

;clear video display to $20 pattern
;
clsv        push        hl
            push        de
            push        bc
            ld          hl,video
            ld          (addr),hl   ;set cursor address to ulh corner
            xor         a
            ld          (column),a  ;rolumn=0
            ld          (row),a     ;row=0
            ld          de,video+1
            ld          (hl),space
            ld          bc,videosize
            ldir
            call        cursor_fix  ;fixup the cursor if necessary
            pop         bc
            pop         de
            pop         hl
            ret

;initialize the video controller, see if the '6847 if functioning.
;due to limitations of hardware design, we can only check the *field
;sync signal to see if it is active, and the video ram to see if it
;can be written to/read from.  only the first 1k of video ram is tested.
;
;return: c=0 means hardware checks out ok; c=1 means an error in the video
;section.
;
video_init  ld          a,98h
            out         (ppicntrl),a;write to video controller
            ld          a,80h
            out         (ppib),a
            ld          a,08h
            ld          (ppic),a
            ld          a,2ah
            ld      (cursor),a      ;let cursor = some sorta character
            xor         a
            ld       (cursor_mode),a;cursor off, initially

;initial device i/o testing -- see if the '6847 is outputting a *fs signal.
;check that the period of the signal is correct.
;
            in          a,(ppic)
            and         80h         ;isolate *[field sync]
            xor         80h         ;what *fs should become in < 16.6ms
            ld          e,a         ;save it
            ld          hl,0000     ;??? counter for 16.6ms
vid_init2   in          a,(ppic)    ;read it
            and         80h         ;isolate *fs
            cp          e           ;has it flipped state yet?
            jr          z,vidchk    ;yes, give 6847 clean bill of health
            dec         hl          ;no--wait a bit longer
            ld          a,h
            or          l
            jr          nz,vid_init2;but only so long
vid_err     scf                     ;error--6847 not producing f-sync
            ret                     ;it's probably dead
;
;the 6847 seems to be producing sync, see if we can access video ram
;
vidchk      ld          hl,video    ;first location of video ram
vidram1     ld          a,(hl)      ;fetch a byte
            cpl                     ;flip all bits
            ld          (hl),a      ;jam it back in
            cp          (hl)        ;see if we can read it back
            jr          nz,vid_err  ;did not read in ok, report error
            cpl
            ld          (hl),a
            inc         hl
            ld          a,h
            cp          41h         ;top page to test
            jr          nz,vidram1
;
;video hardware tests ok as far as we can tell, complete initialization
;and return with c=0
;
            jp          clsv        ;then clear the screen

;fixup the cursor after an i/o operation--if it is supposed to be "on",
;turn it on.  the bios turns the cursor off during its internal operations
;but does not update the "cursor_mode" flag, thus the routine is necessary
;to restore original conditions.
;
cursor_fix  ld       a,(cursor_mode)
            or          a
            ret         z           ;it's supposed to be off, do nothing
;
;turn the cursor on, set the system cursor flag, save character underneath
;the cursor
;
cursor_on   ld          a,01
            ld       (cursor_mode),a
            push        hl
            ld          hl,(addr)   ;current video address
            ld          a,(hl)      ;get character "under" cursor
            ld     (char_curs),a    ;save it
            ld          a,(cursor)
            ld          (hl),a
            pop         hl
            ret

;turn the cursor off, restore the character underneath it (if it was
;on before), set the system cursor flag.
;
;entry point "temp_off" turns cursor off for internal operations, but
;does not update cursor_mode flag.
;
cursor_off  ld       a,(cursor_mode)
            or          a
            ret         z           ;already off--do nothing
            xor         a
            ld       (cursor_mode),a

temp_off    push        hl
            ld          hl,(addr)
            ld         a,(char_curs)
            ld          (hl),a
            pop         hl
            ret

;*** print character in a-register to video display. all registers
;    preserved. ***
;
prtc        pop         af
            push        af
            push        bc
            push        de
            push        hl
            cp          20h         ;check on control characters
            jr          c,control_ch;<32 means a control code, process
;check to see if lower case, if so, display as an inverse letter
;
            cp          'a'
            jr          c,not_lower ;<"a" not lower case
            cp          'z'+1
            jr          nc,not_lower;>"z" not lower case
            xor         0a0h        ;was lower case, flip to upper/inverse
;display character at current cursor position
;
not_lower   ld          hl,(addr)   ;fetch video address
            ld          (hl),a      ;write character to display
            inc         hl          ;get next video address
            ld          (addr),hl   ;save it
;see if scroll to next line, if so, zero out column counter
;
            ld          a,(column)
            inc         a
            ld          (column),a
            cp          20h         ;check on new column #
            jr          c,vdone     ;done if column < 32
;cursor will be spilling over into next line, see if a scroll is in order
;
            xor         a
            ld          (column),a  ;new column# is zero
            ld          a,(row)
            inc         a
            ld          (row),a
            cp          10h
            jr          c,vdone     ;row < 16, not to bottom of display yet

;*** scroll required ***
;
            dec         a           ;force it to row# 15
            ld          (row),a
            call        scroll      ;bump up display by 1 line
            ld      de,ylen*100h+00h;row 15, column #0
            call        calc_addr   ;get proper addr for bottom line
            ld          (addr),hl   ;save it
;
;*** all video routines exit here ***
;
vdone       call        cursor_fix  ;fix the cursor if necessary
vdone2      pop         hl          ;video return w/o cursor fixup
            pop         de
            pop         bc
            pop         af
            ret

;control characters are handled here.
;
control_ch  push        af
            ld       a,(cursor_mode)
            or          a
            call        nz,temp_off ;get rid of the cursor, if on
            pop         af          ;restore character
;
;see which control character to deal with, if any, and jump to
;appropriate routine to handle it
;
            ld          hl,ctrl_tbl ;disp
            ld          e,a         ;char to search for
ctrl_srch   ld          a,(hl)
            or          a
            jp          z,vdone     ;no such contrl char--abort
            cp          e           ;is it ours?
            jr          z,ctrl_srch2;yes--jump to it
            inc         hl
            inc         hl
            inc         hl
            jr          ctrl_srch   ;search next entry
;
;found a valid contrl code, do it...
;
ctrl_srch2  inc         hl
            ld          e,(hl)      ;get address-lsb
            inc         hl
            ld          d,(hl)      ;get address-msb
            ex          de,hl
            ld          de,+vdone
            push        de
            jp          (hl)        ;go do it, then be "done"

;dispatcher table for video control functions. format is
;[character code],[routine address ]
;table ends with a zero character code.
;
ctrl_tbl    .db         0dh         ;carriage return
            .dw         crg_rtn
            .db         08h         ;backspace
            .dw         bksp
            .db         0ch         ;clear screen
            .dw         text
            .db         18h         ;cursor-left
            .dw         cur_left
            .db         19h         ;cursor-right
            .dw         cur_right
            .db         1ch         ;cursor-up
            .dw         cur_up
            .db         1ah         ;cursor-down
            .dw         cur_down
            .db         09h         ;tab to next 8 char partition
            .dw         tab
            .db         0eh         ;cursor on
            .dw         cur_on
            .db         0fh         ;cursor off
            .dw         cur_off
            .db         01h         ;graphics mode
            .dw         graphics
            .db         02h         ;text mode
            .dw         text
            .db         00h

;turn the cursor on.  if it is already on, do nothing.
;
cur_on      ld       a,(cursor_mode);see if it si on or not
            or          a
            ret         nz          ;already on-abort
            call        cursor_on   ;it was off--turn it on
            jp          temp_off    ;prepare for video exit

;turn the cursor off.  all that needs to be done is reset the mode flag.
;
cur_off     xor         a
            ld       (cursor_mode),a;reset the mode flag
            ret                     ;and exit

;carriage return handled here
;
crg_rtn     ld          a,(row)     ;row #
            inc         a
            cp          ylen+1      ;< 16?
            jr          c,cr2       ;yes--normal processing
            call        scroll      ;no--need to scroll, we're at bottom
            ld          a,ylen      ;and row# will now be 15
cr2         ld          (row),a
            ld          d,a         ;current row #
            xor         a
            ld          (column),a  ;now on column #0
            ld          e,a         ;column #0
            call        calc_addr   ;get address of this row #
            ld          (addr),hl   ;save it
            ret
;01
;graphics - initialize the 6847 for low level graphics.
;
graphics    ld          a,97h       ;0610
            out         (ppib),a
            ret
;02
;text - initialize and clear the screen for the text mode.
;
text        ld          a,80h
            out         (ppib),a
            call        cls
            pop         de
            jp          vdone2
;
;backspace processing
;
cur_left    ld          e,18h       ;flag: left-arrow (cursor left)
            .db         01h         ;skip 2 bytes (ld bc,xxxx)
            ld          e,8         ;flag: backspace
bksp        ld          a,(column)
            or          a
            jr          z,cur_up
            dec         a
bksp2       ld          (column),a
            ld          hl,(addr)   ;fetch video address
            dec         hl
            ld          (addr),hl
            ld          a,e         ;check if we're doing 08h or 18h
            cp          18h
            ret         z           ;non-destructive backspace, return
            ld          (hl),space  ;wipe out character there
            ret                     ;and return/fixup

check_row   ld          a,(row)
            or          a           ;can't backspace if already in ulh
            ret         z           ;corner of video display!

            dec         a
            ld          (row),a     ;fixup row #
            ld          a,xlen      ;new column #
            jr          bksp2       ;go back & update vidram
;
;move cursor to the right (non-destructive)
;
cur_right   ld          a,(column)
            cp          xlen
            jr          z,check_row2;column =31, see if row=15
            inc         a           ;column++ increment

currgt2     ld          (column),a  ;save new column #
            ld          hl,(addr)   ;fetch video address
            inc         hl
            ld          (addr),hl
            ret                     ;and return/fixup

check_row2  ld          a,(row)
            cp          ylen        ;are we at bottom rh corner?
            ret         z           ;if so, can't advance further

            inc         a
            ld          (row),a     ;fixup row #
            xor         a           ;new column # (next row down)
            jr          currgt2     ;go back & update vidram
;
;tab -- tabs are located at columns 0,8,16, and 24.
;
tab         ld          a,(column)  ;progress test
            ld          e,a         ;save
            call        cur_right   ;move cursor to right
            ld          a,(column)
            cp          e
            ret         z           ;cursor stuck for some reason
            and         07h
            ret         z           ;must now be at 0,8,16, or 24
            jr          tab         ;if not, go back and take another try
;
;cursor down
;
cur_down    ld          a,(row)
            cp          ylen
            ret         z           ;can't go down any further!
            inc         a
            ld          (row),a     ;row++ increment
            ld          de,0020h

new_addr    ld          hl,(addr)
            add         hl,de
            ld          (addr),hl   ;new video addr
            ret
;
;cursor_up
;
cur_up      ld          a,(row)
            or          a
            ret         z           ;can't go up any further!
            dec         a
            ld          (row),a
            ld          de,-20h
            jr          new_addr    ;go fixup addr & exit


screendumpv push        bc
            ld          c,00
waitsc      djnz        waitsc
            in          a,(ppic)
            bit         4,a
            jr          nz,scrd1
            dec         c
            jr          nz,06a1h
            jr          06b6h
scrd1       ld          a,0d0h
            ld          (video),a
            xor         a
            pop         bc
            ret

            push        de
            push        hl
            call        06d7h
            ld          b,10h
            ld          hl,video
            push        bc
            ld          b,space
            ld          a,(hl)
            and         7fh
            call        0a84h
            inc         hl
            djnz        06c3h
            call        06d7h
            pop         bc
            djnz        06c0h
            pop         hl
            pop         de
            pop         bc
            xor         a
            ret

            ld          a,0dh
            call        0a84
            ld          a,0a
            jp          0a84

;
;keyboard scan routine. supports n-key rollover, returns ascii codes.
;variable location (caps), if set to a non-zero value, will force all
;alpha codes returned to be upper-case.  otherwise, upper/lower case
;values are returned.
;
;entry points: scanav - scan for ascii code. z=1 no key pressed. key value
;                      returned in a-register. bc,de,hl preserved.
;
;              scan  - scan for new make/break codes. used internally by
;                      "scanav." bc,de,hl destroyed.
;
;scan for an ascii code
;
scanav      push        bc
            push        de
            push        hl
            call        repeat_check
            call        scan        ;check if key
            or          a
            jr          z,scanae
            jp          p,scan_ok   ;positive means make code
            xor         a
            jr          scanae

scan_ok     call        getasc
            cp          10h
            jr          nz,???
            ld        de,(shift)
            inc         e
            dec         e
            jr          z,0705h
            call        069eh

scanae      pop         hl
            pop         de
            pop         bc
            or          a
            ret
;
;get an ascii code from a "make" code in a-register.  returns code in
;a-reigister.
getasc      ld          hl,asciit-1
            ld          d,00
            ld          e,a         ;e=key make-code
            add         hl,de       ;get to table posn
            ld          e,(hl)      ;fetch char
            ld          a,e
            or          a
            jr          z,capslok   ;0 in table means no code returned
            ld          a,(ctrl);
            or          a
            jr          nz,ctrl_p   ;convert to control code
            ld         a,(shift);
            or          a
            jr          nz,shift_p  ;convert to shifted code
            ld         a,(caps);
            or          a
            jr          nz,capslok  ;cpas lock is on--done
;
;caps lock is off, no shift-convert to lower case letters
;
            ld          a,e         ;recall character
            cp          'a'
            ret         c           ;<'a' means not alpha
            cp          'z'+1
            ret         nc          ;>'z' means not alpha
            xor         20h         ;conv to lower case
            ret

capslok     ld          a,e
            ret
;
;ctrl key--subtract 40h to compute the code
;
ctrl_p      ld          a,e
            sub         40h
            ret
;
;*** shift pressed. return upper case if alpha, or convert to top
;key-code if non-alpha ***
;
shift_p     ld          a,e         ;fetch char
            cp          '@'
            ret         nc          ;>="@" do nothing, already ok code

shiftp2     cp          '1'
            jr          c,shiftp3   ;<'1' not 1 thru 9
            sub         10h
            ret

shiftp3     cp          30h
            ret         nc          ;>"/"
            cp          2ah
            ret         c           ;< "*"
            add         a,10h       ;must be 2a-2f codes, convert
            ret

;
;*** ascii code lookup table ***
;
;the position in the table corresponds with the unshifted "make" code
;for each key.
;
asciit      .db            32h, 51h, 20h, 20h     ;2  q
            .db            03h, 00h, 0ch, 31h     ;.  .  .  1
            .db            34h, 45h, 53h, 5ah     ;4  e  s  z
            .db            00h, 41h, 57h, 33h     ;.  a  w  3
            .db            36h, 54h, 46h, 43h     ;6  t  f  c
            .db            58h, 44h, 52h, 35h     ;x  d  r  5
            .db            38h, 55h, 48h, 42h     ;8  u  h  b
            .db            56h, 47h, 59h, 37h     ;v  g  y  7
            .db            30h, 4fh, 4bh, 4dh     ;0  o  k  m
            .db            4eh, 4ah, 49h, 39h     ;n  j  i  9
            .db            1ch, 2dh, 3ah, 2eh     ;.  -  :  .
            .db            2ch, 4ch, 50h, 1ah     ;,  l  p  .
            .db            09h, 2bh, 3dh, 1bh     ;.  +  =  .
            .db            2fh, 3bh, 2ah, 18h     ;/  ;  *  .
            .db            00h, 00h, 00h, 00h     ;.  .  .  .
            .db            40h, 5ch, 0dh, 08h     ;@  \  .  .

;78c
;scan for a make or break code
;
scanv       in          a,(ppib)    ;row6
            or          40h
            out         (ppib),a
            ld          a,0eh
            out         (ppic),a
            in          a,(ppia)
            and         10h
            xor         10h
            ld          (shift),a
            ld          a,0fh
            out         (ppic),a
            in          a,(ppia)
            and         20h
            xor         20h
            ld          (ctrl),a
            ld          e,08h
            ld          hl,mask     ;matrix address
            ld          b,08h       ;row counter

scan2       ld          a,e         ;scan a row
            out         (ppic),a
            in          a,(ppia)
            cp          (hl)        ;compare it with key mask
            jr          nz,validate
            inc         e
            inc         hl
            djnz        scan2
            xor         a
            jr          tempe       ;80a

tempc       pop         bc          ;   7c2
            pop         de
            jr          scan2

validate    push        de
            push        bc
            ld          bc,(6162h)
            ld          e,a

v1          in          a,(ppia)    ;check on value again
            cp          e
            jr          nz,tempc    ;it's bad, try reading again
            dec         c
            jr          nz,v1
            dec         b
            jr          nz,v1       ;fall through if key valid
            pop         bc          ;restore b, ...
            pop         de

;
;a key has changed, figure out which one and return it as a make/break
;code.  update the mask for the next scan call.
;
;at this point: a=scan result, (hl)=mask compared against, b=row # scanned
;
            push        bc          ;save row#
            ld          d,00        ;initially assume a 'make' code
            ld          e,(hl)      ;call up mask value
            ld          b,00        ;shift chounter for mask re-compute
            xor         e           ;now a="delta key"

;
;find out the lowest bit in "delta key" that is turned on.  that will be
;the key to isolate.  the mask is rotated simulaneously through the f'
;register for make/break determination.
;
mb1         inc         b
            ex          af,af'
            rr          e
            ex          af,af'
            rra
            jr          nc,mb1      ;keep going till we find it
            ld          e,b         ;now we know the key# on row

;
;c=1 means we are now on the delta key, examine f' to see if the
;corresponding mask bit is 1 (a make code) or 0 (a break code)
;
            ex          af,af'      ;f' cy bit is desired info
            jr          c,mb2       ;1=a 'make' code
            ld          d,80h       ;was zero, it's a break code

;
;key # on row is now in e-register, and original af holds the delta-key
;value.  will continue the rotate through 9 positions to bring delta-key back
;to original alignment.  all subsequent positions in delta-key will be
;zeroed, so that only "this" key will be written onto the mask.
;
mb2         ld          a,09h       ;will be a', terminate value
            ex          af,af'      ;a is now delta-key

mb3         ex          af,af'
            cp          b           ;have 9 shifts been done??
            jr          z,mb4       ;yes, we're almost done
            ex          af,af'
            rra                     ;rotate delta-key back
            or          a           ;clear cy flag, zero other 1's
            inc         b           ;update shift-count
            jr          mb3

;
;at this point, e=key# in row, a=corrected version of delta-key
;
mb4         ex          af,af'      ;get back delta-key bit
            xor         (hl)        ;calculate new mask
            ld          (hl),a      ;save it
            pop         bc          ;recall row #
            dec         b           ;make in range (0-7)
            sla         b
            sla         b
            sla         b
            ld          a,e         ;col#(1-8)
            add         a,b         ;+8*row #(0-7)
            or          d           ;.or. make/break value

tempe       push        af          ;80a
            in          a,(ppib)
            and         0bfh
            out         (ppib),a
            pop         af
            ret

;
;check on the repeat mode
;
repeat_check ld      a,(repeat);
            or          a
            ret         z

;
;check to see if any character keys are pressed.  if so, repeat may be
;required. note that [ctrl] and [shift] are not character-producing
;keys, and they have to be ignored by this routine.
;
            in          a,(ppib)
            or          40h
            out         (ppib),a
            ld          c,0ffh
            ld          e,08h
key1        ld          a,e
            out         (ppic),a
            ld          b,02h
            djnz        0827h
            in          a,(ppia)
            and         c
            ld          c,a
            inc         e
            ld          a,e
            cp          0eh
            jr          nz,key1
            inc         e
            out         (ppic),a
            ld          b,02h
waitkey     djnz        waitkey
            in          a,(ppia)
            or          10h
            and         c
            ld          c,a
            ld          a,e
            out         (ppic),a
            ld          b,02h
waitkey2    djnz        waitkey2
            in          a,(ppia)
            or          20h         ;mask ctrl key
            and         c
            inc         a
            jr          nz,key_held

;
;no keys detected, reset the timers for both initial repeat delay, and
;inter-key delay
;
            ld      hl,(repeat_wait)
            ld         (rpt_wait),hl
            ld      a,(repeat_cnt)  ;re-prime wait timer
            ld         (rpt_count),a
            ret

key_held    ld         hl,(rpt_wait);check on countdown
            ld          a,h
            or          l
            jr          z,repeat_it ;countdown=0, see if repeat
            dec         hl
            ld         (rpt_wait),hl;not done yet...
            ret

repeat_it   ld         a,(rpt_count)
            dec         a
            jr          z,do_repeat
            ld         (rpt_count),a
            ret

do_repeat   ld        a,(repeat_cnt)
            ld         (rpt_count),a
            ld          b,08h
            ld          hl,mask
            ld          (hl),0ffh
            inc         hl
            djnz        087dh
            ret
;
;initialize keyboard driver
;
kbinit      ld          b,08h
            ld          hl,mask
            ld          a,0ffh

kbi1        ld          (hl),a
            inc         hl
            djnz        kbi1        ;turn on caps lock
;
;set auto-repeat parms
;
            ld         (caps),a
            ld       (repeat),a     ;enable auto-repeat
            ld          hl,0578h
            ld      (repeat_wait),hl
            ld          a,30h
            ld        (repeat_cnt),a

            ld          hl,09ffh
            ld          (6162h),hl
            ret

            call        pwrup2      ;initialize system jump vectors
            xor         a
            ld        (flash_crsr),a;cursor_flash flag - 0-dont flash
            ld          hl,0280h
            ld       (crsr_rate),hl ;rate of cursor flash
            rst_filem               ;restore i/o channels to default
            call        kbinit      ;initialize the keyboard driver
            jp          mon         ;on to phase 3 & monitor

;power_up vector table--to be copied into ram
;
vect_tbl
rst1a       jp          filem       ;rst 08h - file manager
rst2a       jp          chrout      ;rst 10h - chrout (character to device)
rst3a       jp          getin       ;rst 18h - getin (character to device)
rst4a       jp          breakpt     ;rst 20h - user breakpoint (monitor)
rst5a       jp          chkin       ;rst 28h - chkin (set input device)
rst6a       jp          chkout      ;rst 30h - chkout (set output device)
rst7a       jp          im1         ;rst 38h - im1 vector (rs232/disk)
nmiva       jp          trace       ;0066h - trace re-entry
            nop
vect_tble

;
;kernal file manager. actually, no files are managed at all; all that
;happens here is i/o redirection, and maintenence of system pointers
;for input-output operations.
;
;
;commands are passed in the a-register. parameters are passed in other
;registers as necessary. c=1 means error.
;
;command summary:
;
;  00       clrchn      clear all i/o channels to default values
;  01       open        open a file, allocate fcb
;  02       close       close a file, free up fcb
;  03       set_232     set rs232 parameters
;  04       set_exec    set up the autoexecution mode
;
;
;

filem        or          a
             jr          nz,not_init ;a=0?

;
;command #0: clrchn --  clear all i/o channels, close any open files,
;                       set default i/o back to keyboard and screen.
;warning: dirty buffers not automatically purged--use #2, close.
;

clrchn      xor         a           ;restore i/o channels to default states
            ld          (dflto),a   ;output -> screen
            ld          (status),a  ;no current file operation
            inc         a
            ld          (dflti),a   ;input <-keyboard
            or          a
            ret

not_init    dec         a           ;#1, open?
            jr          nz,not_open
            ld          a,(status)  ;any file open right now??
            or          a
            jr          z,ok_2open  ;no, ok to open one
err_file    scf                     ;error: file already open
            ret

;
;open file: d=file mode (1=read, 2=write, 3=read/write)
;           e=device #
;           a=01
;           hl=pointer to name of file, asciiz format
;           (some devices may not require the name.)
;

ok_2open    ld          a,d
            ld       (status),a     ;save status
            ld         de,filenam
            ld        bc,status_len ;copy in the filename
            ldir
            or          a
            ret

;
;close file e=device # for file
;           a=02
;
;warning: supplying incorrect device # may cause improper write to
;wrong device!
;

not_open    dec         a           ;#2 close?
            jr          nz,not_close
            xor         a           ;cmd: clrchn
            rst_filem               ;initialize all i/o states
            ret

not_close   dec         a           ;# 3 set_rs232 rate?
            jr          nz,not_232
            jp          set_rate    ;set the baud rate

not_232     dec         a           ;#03 set autoexec status
            jr          nz,err_file ;bad command #, syntax error

;
;set autoexec status.
;
;to force system to "jump" to user's routine directly on power up--
;
;entry: a=04
;       b=01
;       de=address of routine to jump to on power up
;
;
;to disable the system jump (happens automatically on each power up--
;user's program must re-enable the jump by rst 08h if it wants to
;execute on next power up cycle.)
;
;entry: a=04
;       b=00
;       de=don't care
;

set_status  ld        (auto_addr),de;save offset of user's routine
            ld          a,b         ;get parm
            ld          e,-1        ;"not ok"
            and         01          ;reset or set it?
            jr          z,set_st2
            ld          e,01        ;"ok to run"
set_st2     xor         a           ;array starting value
            ld          b,08        ;# of bytes to write
            ld          hl,auto_flag;flag array
set_st1     ld          (hl),a
            add         a,e
            inc         hl
            djnz        set_st1     ;set the array
            ret

;
;chkin -- set input device. a=device#
;
chkin       ld          (dflti),a
            ret

;
;chkout -- set output device. a=device #
;
chkout      ld          (dflto),a
            ret


genesc      .db         1bh, 03h, 00h

;general line-input.  allows ^c and [esc] as an exit sequence.
;
;
;calling parameters: b=maximum length of string
;                    l=memory buffer to store string in
;
;return: string stored at (hl), zero-terminated.
;        c=0 means return via <return> key
;        c=1 means return via one of the <escape> keys, either ctrl-c or [esc]
;        (af holds code)
;

inputv      ld          de,genesc   ;general escape characters

;
;input line of characters from default input device.
;
;calling parameters from default input device.
;
;calling parameters:    b=maximum length of string
;                       hl=memory buffer to store string in
;                       de=pointer to list of allowable escape characters,
;                         null (00) terminated.
;                         (if any of these characters are typed, routine exits.)
;                       if (flash_crsr) is non-zero, the cursor flashes at the
;                       rate (crsr_rate) indicates (0001=fast....ffff=slow)
;
;note: input redirection to the pseudo-rs232-device will not flash cursor.
;
;return:    string stored at (hl), zero-terminated.
;           c=0 means return via <return> key
;           c=1 means return via one of the <escape> keys, and af holds the
;               code of the key that was pressed.
;           cursor is always "off" when the routine terminates.
;
;           if user types enough characters to fill buffer ('b'), routine
;           returns to caller will buffer contents.
;

lineiv      push        hl          ;save buffer pointer for user
            push        de

            ld         (escchars),de;save pointer to escape characters

            ld          a,0eh       ;cursor on
            rst_chrout              ;print it--turn cursor on
            ld       de,(crsr_rate)
            ld       (crsr_count),de;crsr rate -> crsr_count (prime)
            ld          d,00        ;length counter
line1a      ld          (hl),00     ;terminate the buffer
line1v      rst_chrin               ;getin, is character available?
            push        af          ;save character
            push        hl          ;save buffer_ptr
            ld        a,(flash_crsr);check flash cursor flag
            or          a
            jr          z,no_flash  ;no flash if zero
            ld       hl,(crsr_count);check counter
            ld          a,h
            or          l           ;--count==0?
            dec         hl
            ld       (crsr_count),hl;save count
            jr          nz,no_flash
            ld       hl,(crsr_rate)
            ld       (crsr_count),hl;re-prime counter

;
;counter reached zero, time to flash cursor
;
            ld       a,(cursor_mode);see if on or not
            or          a
            jr          z,flash_on
            ld          a,0fh       ;cursor off
            jr          flash_c

flash_on    ld          a,0eh       ;cursor on
flash_c     rst_chrout              ;display
no_flash    pop         hl          ;restore buffer_ptr
            pop         af          ;restore character if any
            and         7fh         ;strip off d7, don't need it
            jr          z,line1v    ;no, keep waiting

;
;check for one of the special escape characters...
;
line5       push        hl          ;save buffer pointer
            ld          e,a         ;character to test
            ld         hl,(escchars);point to user's array

line6       ld          a,(hl)      ;fetch one of the user's characters
            cp          e           ;is it the one that got typed?
            jr          z,legal_esc ;yes, it's a legal escape
            inc         hl          ;point to next item in escchars table
            or          a           ;test for end-of-table
            jr          nz,line6
            pop         hl          ;restore buffer pointer
            ld          a,e         ;restore character
            jp          line2       ;and proceed with line input

legal_esc   pop         hl          ;restore buffer pointer
            call        cursor_off  ;shut off the cursor
            ld          a,e         ;restore character for caller
            scf
            jr          line_rtn

line2       cp          20h         ;is it a control character?
            jr          c,in_ctrl   ;yes--see if it is valid

;
;character ok, print it & buffer it
;
            ld          (hl),a
            rst_chrout              ;chrout -- send character to device
            inc         d
            inc         hl

;
;see if reached buffer limit-- if so, return the typed string immediately.
;otherwise, go back for more key input.
;
            ld          a,d         ;get line counter
            cp          b           ;compare with set limit
            jr          c,line1a    ;length is still ( < max ), keep going

;
;buffer full -- return to user. no escape code returned.
;
            xor         a
            ld          (hl),a
            jr          ln_rtn2     ;cursor off, c=0, return to caller

;
;control characters testing.  only <cr> and <bs> are tested. escape
;characters have higher priority.  <cr> and <bs> may be listed as
;"escape" characters if desired by caller.
;
in_ctrl     cp          08h         ;backspace sequence?
            jr          z,backspace ;^h?
            cp          0dh         ;carriage-return?
            jr          nz,line1v   ;not cr or bs, illegal -- ignore
            rst_chrout              ;print the <cr>
ln_rtn2     call        cursor_off
            xor         a           ;reset the carry flag & char. flag

line_rtn    pop         de
            pop         hl
            ret

backspace   inc         d
            dec         d
            jr          z,line1v    ;nothing to backspace over
            rst_chrout              ;print ^h
            dec         hl
            dec         d
            jr          line1a

;
;default places for ram vector jumps
;
breakpt     ret                    ;rst-20h vector
im1         reti                    ;irq-vector
trace       retn                    ;nmi (trace) intercepted by monitor

;power up phase 2: all connected devices check ok, initialize ram
;vectors, and turn control over to the monitor.
;
pwrup2      ld          hl,vect_tbl
            ld          de,sysmem   ;ram
            ld bc,vect_tbl-vect_tble;length
            ldir
            ret

rx          xor         a
            out         (sioac),a
            in          a,(sioac)
            and         01
            ret         z
            in          a,(sioad)
            push        de
            ld          e,a
            inc         e
            cp          e
            pop         de
            ret

            dec         b
            c
            ld          a,b
            or          c
            jr          nz,09d8h
            ret
;
;transmit a character through the rs232 interface
;
;parameters are set by the filemanager (rst 08h)
;
;call: a=character to transmit
;
;return: no registers are altered.  the character is transmitted through
;the port.  formatting is automatic.
;
tx          pop         af
            push        af
            xor         a
            out         (sioac),a
tx1         in          a,(sioac)
            bit         2,a
            jr          z,tx1
            pop         af
            out         (sioad),a
            ret

baud1t      .db         11h, 12h, 12h, 07h, 01h, 2fh, 01h, 0ch, 01h
            .db         06h, 01h, 03h, 8ah
baud2t      .db         01h, 81h,0cah, 41h,0aah,0c1h,0eah

;
;set the rs-232 parameters.  e=value for data rate, as follows:
;
; 00 = 50 bps   01 = 110 bps  02 = 300 bps    03 = 1200 bps  04 = 2400 bps
; 05 = 4800 bps 06 = 9600 bps 07 = ff invalid
;
; d=number of bits per character, normally 5 to 8. not range checked.
;
;exit: de,bc,hl destroyed.
;
set_rate    push        de
            push        hl
            push        de
            ld          hl,baud1t   ;9ed
            ld          a,e
            ld          (baudof),a
            ld          a,d
            ld          (bitnum),a
            sla         e
            ld          d,00
            add         hl,de
            ld          a,05h       ;00000101
            out         (ctc0),a
            ld          a,(hl)
            out         (ctc0),a
            inc         hl
            ld          a,45h
            out         (ctc1),a
            ld          a,(hl)
            out         (ctc1),a
            xor         a
            out         (sioac),a
            inc         a
            out         (sioac),a
            xor         a
            out         (sioac),a
            ld          a,04h
            out         (sioac),a
            ld          a,44h
            out         (sioac),a
            pop         af
            sub         05h
            sla         a
            ld          e,a
            ld          d,00
            ld          hl,baud2t   ;9f9
            add         hl,de
            ld          a,03h
            out         (sioac),a
            ld          a,(hl)
            inc         hl
            out         (sioac),a
            ld          a,05h
            out         (sioac),a
            ld          a,(hl)
            out         (sioac),a
            pop         hl
            pop         de
            ret

;
;getin --   get character from current input device.
;           waits until character is present, except in the case of the
;           keyboard (01). in this case, 00h is returned if no character
;           is present. c=1 means an i/o error has occurred.
;
getin       ld          a,(dflti)
            or          a
            jp          z,getchar   ;00--video display?
            dec         a
            jp          z,scana     ;01--keyboard?
            dec         a
            jp          z,rx        ;02--rs232 input?
            scf                     ;error--undef' input device
            ret
;
;chrout -- write character to current output device (dflto).
;          returns c=1 if an i/o error. a=character to write.
;          af is preserved, e-register is destroyed.
;
chrout      push        af
            ld          a,(dflto)
            or          a
            jp          z,prtc      ;00: video output.
            cp          02
            jp          z,tx        ;02: rs232 output.
            cp          04
            jp          z,par_prn   ;04: parallel printer.
            pop         af
            scf                     ;?device not present.
            ret

nmihandler  push        af          ;used by trace function of monitor
            in          a,(ppib)
            or          80h
            out         (ppib),a
            pop         af
            jp          nmiv
;
;output to parallel printer port:
;
par_prn     pop         af
            push        af
            push        bc
            out         (parl),a
par1        in          a,(ppic)    ;check the +busy line
            bit         4,a
            jr          nz,par1     ;wait if (busy==1)
            in          a,(ppic)
            res         3,a
            out         (ppic),a    ;load onto data lines
            ld          b,80h
par2        djnz        par2        ;wait a bit
            set         3,a
            out         (ppic),a    ;strobe data pulse to latch data
            pop         bc
            pop         af
            ret

pr2hexv     push        af
            push        de
            ld          a,d
            call        0aach
            ld          a,e
            call        0aach
            pop         de
            pop         af
            ret

prhexv      push        af
            push        bc
            push        de
            ld          c,a
            srl         a
            srl         a
            srl         a
            srl         a
            call        0ac7h
            rst_chrout
            ld          a,c
            and         0fh
            call        0ac7h
            rst_chrout
            pop         de
            pop         bc
            pop         af
            ret

alphafix    add         a,'0'       ;convert the binary to ascii
            cp          '9'+1
            ret         m
            add         a,07        ;if this is "a" or greater, fix it.
            ret
;
;bin2asc -- this subroutine converts an unsigned int type in hl into decimal
;ascii that is stored in a buffer pointed by de.  it is used internally by
;p_int and has potential use where formatted integer output is required.
;
;call must load hl with the value and point de to a suitable buffer area.
;the buffer must be at least 6 characters in length, as bin2asc will fill it
;with up to a 5 digit number, and a zero terminator byte.  bin2asc performs
;leading zero suppression (leading zeroes are converted to 20h space codes).
;on return, hl and de will have their original values.
;
bin2ascv    push        af
            push        bc
            push        de
            push        hl
            push        ix
            push        de
            push        de
            ld          b,05
            ld          a,'0'
bin2asc1    ld          (de),a
            inc         de
            djnz        bin2asc1
            xor         a
            ld          (de),a
            pop         ix
            ld          bc,bintbl
bin2asc4    ld          a,(bc)
            ld          e,a
            inc         bc
            ld          a,(bc)
            ld          d,a
            inc         bc
            or          e
            jr          z,bin2asc2
bin2asc3    or          a
            sbc         hl,de
            jr          c,bin2asc4
            inc         (ix+00)
            jr          bin2asc3
bin2asc4    add         hl,de
            inc         ix
            jr          bin2asc4
bin2asc2    pop         hl
            ld          b,04
bin2asc5    ld          a,(hl)
            or          a
            jr          z,binexit
            cp          '0'
            jr          nz,binexit
            ld          (hl),space
            inc         hl
            djnz        bin2asc5
binexit     pop         ix
            pop         hl
            pop         de
            pop         bc
            pop         af
            ret

bintbl      .db         10h, 27h,0e8h, 03h, 64h, 00h, 0ah
            .db         00h, 01h, 00h, 00h, 00h

;p_int -- prints the contents of the hl register pair as an unsigned decimal
;integer.  leading zero suppression is automatic, and no spaces are printed on
;either side of the number.  output goes to the current output device, normally
;the screen.  load hl with the value to print and call p_int.  10 bytes of stack
;are required.
;
p_intv      push        hl
            push        de
            push        af
            ex          de,hl
            ld          hl,0fff8h
            add         hl,sp
            ld          sp,hl
            ex          de,hl
            call        bin2asc
            ld          a,(de)
            cp          20
            jr          nz,p_int1
            inc         de
            jr          0b2e
p_int1      ex          de,hl
            call        prtstg      ;b37
            ld          hl,0008h
            add         hl,sp
            ld          sp,hl
            pop         af
            pop         de
            pop         hl
            ret

mon         jp          pwrup3      ;b50

            jp          gethex      ;b53

pwrup3      ld          hl,pwronmsg ;print the "power-on" message
            call        prtstg
            ld          a,03        ;set the rs232 paramters:
            ld          de,0805h    ;4800bps, 8bits/char
            rst_filem               ;do it.
            ld          sp,620bh    ;we'll use a little stack here.
            ld          hl,123eh
            ld          (600ah),hl
            ld          hl,stack    ;store the stack pointer value
            ld          (61c6h),hl
            ld          hl,0000
            ld          (61c9h),hl
            ld          a,0d3h
            ld          (620ch),a
            ld          hl,0f18dh
            ld          (620dh),hl
            ld          hl,15b2h
            ld       (nmiv+1),hl
            ld          e,01
            call        0bac
            jr          nz,0b9c
            ld          hl,(6171)
            push        hl
            ld          b,00
            ld          a,04
            rst_filem
            pop         de
            jp          0fb1

            ld          e,0ffh      ;b9c
            call        0bac
            jp          z,0bba
            ld          a,04        ;reset the autoexec flag
            ld          b,00
            rst_filem
            jp          0000

            ld          hl,auto_flag;bac
            ld          b,08
            xor         a
            cp          (hl)        ;bb2
            ret         nz
            inc         hl
            add         a,e
            djnz        0bb2
            xor         a
            ret

            call        0d64h       ;bba
            ld          hl,cmdmsg   ;prompt the user with "command?"
            call        prtstg
            ld          a,0dh       ;print a return
            rst_chrout
prompt      ld          a,3eh       ;print ">"
            rst_chrout
            ld          hl,0000
            ld          (6212),hl
            ld          hl,60d4h
            ld          b,7f
            call        input
            jr          c,0bc3
            dec         hl
            call        cmdadv
            jr          z,prompt
            push        hl
            pop         bc
            inc         bc
            ld          hl,0bf5
            ld          de,0003
            call        0d41
            jr          nc,0bba
            ld          hl,0c93
            call        prtstg
            jr          0bba

                     .db            'e'
                     .dw            edit        ;0fd6h
                     .db            'g'
                     .dw            goto        ;0fa1h
                     .db            'r'
                     .dw            register    ;15fbh
                     .db            'b'
                     .dw            break       ;1329h
                     .db            't'
                     .dw            trace       ;1499h
                     .db            'i'
                     .dw            inputv       ;0e4eh
                     .db            'o'
                     .dw            output      ;0dd6h
                     .db            'm'
                     .dw            move        ;0d7ah
                     .db            'h'
                     .dw            help        ;1a68h
                     .db            'u'
                     .dw            unassemble  ;1723h
                     .db            '$'
                     .dw            rs232       ;17ebh
                     .db            '@'
                     .dw            autoexec    ;18cfh
                     .db            'f'
                     .dw            fill        ;192dh
                     .db            's'
                     .dw            search      ;1969h
                     .db            'w'
                     .dw            write       ;295bh
                     .db            '!'
                     .dw            terminal    ;29cbh
                     .db            'a'
                     .dw            assemble    ;2adfh
                     .db            'c'
                     .dw            6251h
                     .db            'j'
                     .dw            6254h
                     .db            'k'
                     .dw            6257h
                     .db            'l'
                     .dw            625ah
                     .db            'n'
                     .dw            625dh
                     .db            'p'
                     .dw            6260h
                     .db            'q'
                     .dw            6263h
                     .db            'v'
                     .dw            6266h
                     .db            'x'
                     .dw            6269h
                     .db            'y'
                     .dw            626ch
                     .db            'z'
                     .dw            626fh
                     .db            '0'
                     .dw            6272h
                     .db            '1'
                     .dw            6275h
                     .db            '2'
                     .dw            6278h
                     .db            '3'
                     .dw            627bh
                     .db            '4'
                     .dw            627eh
                     .db            '5'
                     .dw            6281h
                     .db            '6'
                     .dw            6284h
                     .db            '7'
                     .dw            6287h
                     .db            '8'
                     .dw            628ah
                     .db            '9'
                     .dw            628dh
                     .db            00h
                     .text          "\rtype "h" for help/command list\r\r\000"
cmdmsg               .text          "\rcommand?\000"
                     .text          "bad command. type \"h\""
                     .text          " for\rcommand list\r\000"

            cp          '9'+1
            jr          c,0cc5
            cp          'a'
            ret         nc
            cp          a
            ret

            cp          '0'
            ret         nc
            cp          ' '+1
            ret         c
            cp          a
            ret

cmdadv      inc         hl
cmdget      ld          a,(hl)
            or          a
            ret         z
            cp          ' '
            jr          z,cmdadv
            cp          09
            jr          z,cmdadv
            cp          0dh
            ret

gethex      push        bc
            push        ix
            call        cmdget
            push        hl
            pop         ix
            ld          de,0000
            ld          b,00
            ld          a,(hl)
            or          a
            push        hl
            jr          z,0d0c
            pop         hl
            cp          30
            jr          nz,0cf9
            inc         hl
            inc         ix
            jr          0cea
            ld          a,(hl)
            or          a
            push        hl
            jr          z,0d0c
            call        0d32
            jr          c,0d0c
            pop         hl
            inc         b
            inc         hl
            ld          a,b
            cp          04
            jr          nz,0cf9
            push        hl
            ld          a,b
            or          a
            jr          z,0d22
            ld          a,(ix+00)
            call        0d27
            ex          de,hl
            add         hl,hl
            add         hl,hl
            add         hl,hl
            add         hl,hl
            or          l
            ld          l,a
            ex          de,hl
            inc         ix
            djnz        0d10
            pop         hl
            pop         ix
            pop         bc
            ret

            cp          41
            jr          c,0d2d
            sub         07
            sub         30
            and         0f
            ret

            cp          41
            jr          c,0d3a
            cp          47
            ccf
            ret

            cp          30
            ret         c
            cp          3a
            ccf
            ret

            push        bc
            ld          c,a
            ld          a,(hl)
            or          a
            jr          z,0d4d
            cp          c
            jr          z,0d50
            add         hl,de
            jr          0d43
            pop         bc
            scf
            ret

            inc         hl
            pop         bc
            ld          de,0d5c
            push        de
            ld          e,(hl)
            inc         hl
            ld          d,(hl)
            inc         hl
            ex          de,hl
            jp          (hl)
            or          a
            ret

            ld          a,01
            ld        (flash_crsr),a
            ret

            xor         a
            jr          0d60
            push        hl
            or          a
            sbc         hl,de
            pop         hl
            jr          c,0d71
            ldir
            ret

            add         hl,bc
            dec         hl
            ex          de,hl
            add         hl,bc
            dec         hl
            ex          de,hl
            lddr
            ret

            push        bc
            pop         hl
            ld          b,03
            call        cmdget
            jr          z,0ddb
            call        0d32
            jr          nc,0d8b
            call        cmdadv
            call        gethex
            push        de
            djnz        0d7e
            pop         de
            pop         hl
            pop         bc
            push        de
            push        hl
            push        bc
            push        bc
            or          a
            sbc         hl,bc
            push        hl
            pop         bc
            pop         hl
            inc         bc
            call        0d67
            ld          hl,0dc1
            call        prtstg
            pop         de
            call        pr2hex
            ld          a,2d
            rst_chrout
            pop         de
            call        pr2hex
            ld          hl,0dcb
            call        prtstg
            pop         de
            call        pr2hex
            ld          a,0d
            rst_chrout
            ret

            .db         42h
            .text       "block at \000"
            .text       "moved to \000"

            push        bc
            pop         hl
            call        cmdget
            ld          b,01
            jp          z,0f0e
            cp          4c
            push        af
            jr          nz,0df0
            call        cmdadv
            push        hl
            ld          hl,0e34
            call        prtstg
            pop         hl
            ld          c,02
            call        194e
            pop         de
            pop         bc
            ld          a,e
            call        prhex
            push        de
            ld          hl,0e1a
            call        prtstg
            pop         de
            ld          a,c
            call        prhex
            push        de
            ld          a,0d
            rst_chrout
            pop         de
            out         (c),e
            pop         af
            cp          4c
            ret         nz
            push        af
            rst_chrin
            cp          1b
            jr          nz,0e0c
            pop         af
            ret

            .text       "written to port address \000"
            .text       "press [esc] to exit loop\r\000"

            push        bc
            pop         hl
            call        cmdget
            ld          b,01
            jp          z,0f0e
            ld          b,a
            cp          4c
            jr          nz,0e6a
            call        cmdadv
            jr          z,0e53
            push        hl
            ld          hl,0ebf
            call        prtstg
            pop         hl
            push        bc
            push        hl
            ld          b,00
            call        cmdget
            jr          z,0ea4
            call        gethex
            ld          a,(hl)
            or          a
            jr          z,0e82
            call        0d32
            jr          nc,0e82
            call        cmdadv
            push        hl
            push        de
            ld          hl,0ef6
            call        prtstg
            pop         de
            push        de
            ld          a,e
            call        prhex
            ld          hl,0f08
            call        prtstg
            pop         de
            ld          c,e
            in          a,(c)
            call        prhex
            ld          a,0d
            rst_chrout
            inc         b
            pop         hl
            jr          0e6e
            pop         hl
            pop         af
            cp          4c
            ret         nz
            ld          c,a
            rst_chrin
            cp          1b
            ret         z
            ld          a,c
            push        af
            ld          a,1c
            rst_chrout
            djnz        0eb2
            ld          bc,5000
            dec         bc
            ld          a,b
            or          c
            jr          nz,0eb8
            jr          0e6b

                     .text      "\r\rcontinuous port reading mode.\r"
                     .text      "press [esc] to halt.\r\r\000"
                     .text      "port contents at \000"
                     .text      " are \000"

            ld          hl,0f21
            call        cmdadv
            jr          nz,0f11
            djnz        0f11
            inc         hl
            call        prtstg
            ld          sp,620b
            jp          0bba

                     .text      "missing address parameter.\000"
                     .text      "argument out of range\000"
                     .text      "invalid command option\000"
                     .db        00h
                     .text      "45.5 bps\000"
                     .text      "110 bps\000"
                     .text      "300 bps\000"
                     .text      "1200 bps\000"
                     .text      "2400 bps\000"
                     .text      "4800 bps\000"
                     .db        00h, 00h

            push        bc
            pop         hl
            call        cmdget
            jr          nz,0fae
            ld          de,(61ba)
            jr          0fb1
            call        gethex
            ld          (6210),de
            ld          a,0c3
            ld          (620f),a
            ld          sp,61b0
            pop         af
            pop         bc
            pop         de
            pop         hl
            pop         ix
            pop         iy
            ex          af,af'
            pop         af
            ex          af,af'
            exx
            pop         bc
            pop         de
            pop         hl
            pop         iy
            exx
            ld          sp,(61c6)
            jp          620f

edit        push        bc
            pop         hl
            call        cmdget
            ld          de,(61ba)
            jr          z,0fe4
            call        gethex
            ld          (61ad),de
            call        0d5e
            ld          hl,11ea
            call        prtstg
            ld          de,0f00
            call        setxy
            ld          hl,122d
            call        prtstg
            xor         a
            ld          (asciiflag),a
            call        119d
            ld          de,0300
            call        setxy
            ld          de,(column)
            push        de
            ld          de,0f10
            call        setxy
            ld          de,(61ad)
            call        pr2hex
            pop         de
            call        setxy
            ld          de,(61ad)
            ld          a,e
            and         07
            ld          c,a
            add         a,a
            add         a,c
            add         a,06
            ld          e,a
            ld          a,(row)
            ld          d,a
            call        setxy
            ld          de,(column)
            push        de
            ld          a,(asciiflag)
            add         a,02
            ld          b,a
            ld          hl,60d4h
            ld          de,109f
            call        linei
            push        af
            pop         ix
            ld          a,(asciiflag)
            or          a
            jr          z,105d
            ld          a,(hl)
            or          a
            jr          nz,105d
            push        ix
            pop         af
            cp          20
            jr          nz,105d
            ld          (hl),a
            ld          a,(hl)
            or          a
            jr          z,1072
            ld          a,(asciiflag)
            or          a
            jr          z,106a
            ld          a,(hl)
            jr          e106e

            call        gethex
            ld          a,e
e106e       ld          hl,(61ad)
            ld          (hl),a
            ld          hl,(61ad)
            pop         de
            call        setxy
            ld          a,(asciiflag)
            or          a
            ld          a,(hl)
            jr          z,e1088
            call        prlchar
            ld          a,space
            rst_chrout
            jr          e108b

e1088       call        prhex
e108b       push        ix
            pop         af
            or          a
            jr          nz,1093
            ld          a,09
            ld          hl,10b3
            ld          de,0003
            call        0d41
            jp          100a

            jr          10aa

            inc         e
            ld          a,(de)
            dec         de
            jr          nz,10b4
            ld          bc,cd00
            rlc         b
            pop         hl
            pop         hl
            ld          de,0f00
            jp          setxy
            dec         de
            xor         b
            djnz        10cf
            ld          hl,(0911)
            call        p,2010
            call        p,0e10
            ld          h,l
            ld          de,9101
            ld          de,e01a
            djnz        10e5
            call        z,chrout
            ld          de,fff8
            ld          hl,(61ad)
            add         hl,de
            ld          (61ad),hl
            ld          de,(column)
            dec         d
            call        setxy
            jr          1141

            ld          de,0008
            ld          hl,(61ad)
            add         hl,de
            ld          (61ad),hl
            ld          de,(column)
            inc         d
            call        setxy
            jr          1109

            ld          de,(61ad)
            inc         de
            ld          (61ad),de
            ld          a,e
            and         07
            ret         nz
            ld          de,(column)
            inc         d
            call        setxy
            ld          a,d
            cp          0e
            ret         c
            ld          b,03
            ld          c,0d
            call        scrup
            dec         d
            ld          e,00
            call        setxy
            ld          hl,(61ad)
            ld          a,l
            and         0f8
            ld          l,a
            call        editline
            ld          de,0d05
            jp          setxy
            ld          de,(61ad)
            dec         de
            ld          (61ad),de
            ld          a,e
            and         07
            cp          07h
            ret         nz
            ld          de,(column)
            dec         d
            call        setxy
            ld          a,d
            cp          03
            ret         nc
            ld          b,03
            ld          c,0d
            call        scrdn
            inc         d
            ld          e,00
            call        setxy
            ld          hl,(61ad)
            ld          a,l
            and         0f8
            ld          l,a
            call        editline
            ld          de,0305
            jp          setxy
            dec         c
            dec         de
            nop
            pop         de
            pop         de
            ld          de,0f10
            push        de
            call        setxy
            ld          a,space
            rst_chrout
            rst_chrout
            rst_chrout
            rst_chrout
            pop         de
            call        setxy
            ld          b,04
            ld          de,1162
            ld          hl,60d4h
            call        linei
            cp          1b
            jr          z,118e
            call        gethex
            ld          (61ad),de
            jp          1001
            pop         de
            pop         de
            ld          a,(asciiflag)
            cpl
            ld          (asciiflag),a
            jp          1001
            ld          de,0300
            call        setxy
            ld          hl,(61ad)
            ld          a,l
            and         0f8
            ld          l,a
            ld          a,(row)
            cp          0e
            ret         nc
            call        editline
            ld          a,0d
            rst_chrout
            jr          11aa

;editline -- prints out a two bye address in ascii followed by eight bytes
;            in the ascii or hex format.
;

editline    push        hl
            pop         de
            call        pr2hex
            ld          a,':'
            rst_chrout
            ld          a,space
            rst_chrout
            ld          b,08        ;do 8 characters per line
editline2   ld          a,(asciiflag)
            or          a
            jr          nz,asciiedit
            ld          a,(hl)
            call        prhex
            ld          a,space
            rst_chrout

asciiret    inc         hl
            djnz        editline2
            ret

;asciiedit - displays ascii characters in the edit format. the character is
;            fixed, then displayed in the proper sequence.
;
asciiedit   ld          a,(hl)      ;get the character.
            call        prlchar     ;print a corrected value.
            ld          a,space     ;move over two spaces.
            rst_chrout
            rst_chrout
            jr          asciiret

;prlchar -- prints a corrected character to the screen.  non-standard characters
;           are replaced by a period to the screen.  used by the edit program.
;
prlchar     and         7f          ;convert to standard ascii format
            cp          20          ;eliminate control characters with a '.'
            jr          nc,prlchar1
            ld          a,'.'
prlchar1    rst_chrout
            ret

                     .db        0ch, 0eh
                     .text      "ctrl [a] ascii/hex  "
                     .text      "[esc] to exitctrl [n] new "
                     .text      "addr   [arrows] move\000"
                     .text      "current address:\000"

            push        af
            ld          a,01
            ld          (6214),a
            pop         af
            inc         sp
            inc         sp
            ld          (61c6),sp
            ld          sp,61c6
            push        iy
            exx
            push        hl
            push        de
            push        bc
            ex          af,af'
            push        af
            ld          hl,(61c6)
            dec         hl
            dec         hl
            ld          e,(hl)
            inc         hl
            ld          d,(hl)
            ld          a,(6214)
            or          a
            jr          z,1265
            dec         de
            push        de
            push        ix
            exx
            push        hl
            push        de
            push        bc
            ex          af,af'
            push        af
            ld          sp,620b
            exx
            push        de
            xor         a
            rst_filem
            ld          a,(6214)
            or          a
            jr          nz,1281
            ld          hl,14b1
            push        hl
            retn
            ld          hl,12a5
            call        prtstg
            pop         de
            call        pr2hex
            ld          a,0d
            rst_chrout
            call        12b0
            ld          hl,(61c9)
            ld          a,h
            or          l
            jr          z,12a2
            ld          a,(61c8)
            ld          (hl),a
            ld          hl,0000
            ld          (61c9),hl
            jp          0bc3

                     .text      "break at \000"

            push        hl
            push        de
            push        bc
            ld          hl,1307
            call        prtstg
            ld          b,0c
            ld          hl,61b0
            ld          e,(hl)
            inc         hl
            ld          d,(hl)
            inc         hl
            call        pr2hex
            ld          a,space
            rst_chrout
            ld          a,b
            cp          07
            jr          nz,12d0
            ld          a,0d
            rst_chrout
            djnz        12be
            ld          a,0d
            rst_chrout
            ld          a,(61b0)
            ld          c,a
            ld          hl,12fe
            ld          a,(hl)
            cp          0ff
            jr          z,12f6
            or          a
            jr          z,12fa
            rst_chrout
            ld          a,3d
            rst_chrout
            rr          c
            ld          a,30
            adc         a,00
            rst_chrout
            ld          a,space
            rst_chrout
            rst_chrout
            inc         hl
            jr          12dc

            rr          c
            jr          12f3

            pop         bc
            pop         de
            pop         hl
            ret

                     .db        'c', 'n', 'v', 0ffh, 'h', 0ffh, 'z', 's', 00h
                     .text      "\r\034af   bc   de   hl   ix/iy pc/sp\r\000"

            push        bc
            pop         hl
            call        cmdget
            jr          z,136c
            ld          de,(61c9)
            ld          a,d
            or          e
            jr          z,134f
            ld          a,(61c8)
            ld          (de),a
            push        hl
            push        de
            ld          hl,137c
            call        prtstg
            pop         de
            call        pr2hex
            ld          hl,138f
            call        prtstg
            pop         hl
            call        gethex
            push        de
            ld          (61c9),de
            ld          a,(de)
            ld          (61c8),a
            ld          a,0e7
            ld          (de),a
            ld          hl,1399
            call        prtstg
            pop         de
            call        pr2hex
            ld          a,0d
            rst_chrout
            ret

            ld          de,(61c9)
            ld          a,d
            or          e
            push        de
            jr          nz,135e
            pop         de
            ld          hl,13ac
            jp          prtstg

                     .text      "previous break at \000"
                     .text      " removed\r\000"
                     .text      "breakpoint now at \000"
                     .text      "no breakpoint set.\r\000"
                     .text      "use spacebar to step, [m]"
                     .text      " to do multiple steps, [r]"
                     .text      " to alter a register, or"
                     .text      " [esc] to end trace \000"
                     .text      "how many instructions?\000"
                     .text      "press the [esc] key to halt"
                     .text      "the execution of the program."
                     .text      "       instructions remaining:"
                     .text      "         \000"

            push        bc
            pop         hl
            call        cmdget
            jr          z,14a7
            call        gethex
            ld          (61ba),de
            call        cls
            ld          de,0001
            ld          (6212),de
            ld          a,0f
            call        clear_line
            ld          de,0c00
            call        setxy
            call        12b0
            ld          bc,040a
            call        scrup
            ld          de,0a00
            call        setxy
            ld          hl,(61ba)
            call        15ce
            ld          hl,(6212)
            dec         hl
            ld          (6212),hl
            ld          a,h
            or          l
            jr          nz,14f6
            ld          de,0000
            call        setxy
            ld          hl,13c0
            call        prtstg
            rst_chrin
            jr          z,14e8
            ld          de,0003
            ld          hl,150b
            call        0d41
            jr          14e8

            ld          de,0217
            call        setxy
            ld          de,(6212)
            call        pr2hex
            rst_chrin
            cp          1b
            jp          nz,1584
            jr          14dc
            jr          nz,1588
            dec         d
            dec         de
            ld          l,a
            dec         d
            ld          d,d
            ld          h,a
            dec         d
            ld          c,l
            jr          152c

            nop
            ld          a,0f
            call        clear_line
            ld          de,0f00
            call        setxy
            ld          hl,1421
            call        prtstg
            call        0d5e
            ld          b,04
            ld          hl,60d4h
            ld          de,1564
            call        linei
            cp          1b
            jr          z,1556
            ld          a,(hl)
            or          a
            jr          z,1556
            call        gethex
            ld          (6212),de
            ld          de,0000
            call        setxy
            ld          hl,1438
            call        prtstg
            pop         hl
            pop         hl
            jr          1584

            ld          a,0f
            call        clear_line
            ld          de,0c00
            call        setxy
            jp          12b0
            dec         c
            dec         de
            nop
            pop         hl
            pop         hl
            call        15fb
            jp          14a7
            ld          sp,620b
            ld          de,0f00
            call        setxy
            jp          0bba
            pop         hl
            pop         hl
            ld          de,0001
            ld          (6212),de
            ld          de,(61ba)
            ld          (6210),de
            ld          a,0c3
            ld          (620f),a
            ld          sp,61b0
            pop         af
            pop         bc
            pop         de
            pop         hl
            pop         ix
            pop         iy
            ex          af,af'
            pop         af
            ex          af,af'
            exx
            pop         bc
            pop         de
            pop         hl
            pop         iy
            exx
            ld          sp,(61c6)
            push        af
            in          a,(ppib)
            and         7f
            jp          620c

            push        af
            in          a,(ppib)
            or          80
            out         (ppib),a
            push        hl
            ld          hl,(6212)
            ld          a,h
            or          l
            jr          z,15ca
            xor         a
            ld          (6214),a
            pop         hl
            pop         af
            jp          1245

            pop         hl
            pop         af
            retn
            push        hl
            push        hl
            call        unassmbl
            pop         de
            call        pr2hex
            ld          a,3a
            rst_chrout
            ld          a,(no_instr)
            or          a
            ld          b,a
            pop         hl
            ret         z
            push        af
            ld          a,(hl)
            inc         hl
            call        prhex
            djnz        15e2
            pop         af
            add         a,a
            neg
            add         a,0b
            ld          b,a
            ld          a,space
            rst_chrout
            djnz        15f0
            ld          hl,inbuf
            jp          prtstg

            call        cls
            call        12b0
            ld          de,0600
            call        setxy
            ld          hl,16a2
            call        prtstg
            ld          d,00
            call        168a
            call        0d5e
            ld          b,04
            ld          hl,60d4h
            push        de
            ld          de,171b
            call        linei
            pop         de
            push        af
            ld          a,(hl)
            or          a
            jr          z,163d
            push        de
            ld          e,d
            ld          d,00
            push        hl
            ld          hl,61b0
            add         hl,de
            add         hl,de
            push        hl
            pop         bc
            pop         hl
            call        gethex
            push        bc
            pop         hl
            ld          (hl),e
            inc         hl
            ld          (hl),d
            pop         de
            pop         af
            ld          c,d
            ld          de,0003
            ld          hl,1654
            call        0d41
            ld          de,0000
            call        setxy
            ld          d,c
            call        12b0
            jr          160f
            jr          nz,16c5
            ld          d,18
            ld          (hl),l
            ld          d,09
            ld          l,a
            ld          d,1c
            ld          a,d
            ld          d,1a
            add         a,d
            ld          d,1b
            ld          h,a
            ld          d,00
            pop         de
            pop         de
            ld          de,0c00
            jp          setxy
            ld          a,c
            cp          0b
            ret         nc
            inc         c
            ret

            ld          a,c
            or          a
            ret         z
            dec         c
            ret

            ld          a,c
            cp          06
            ret         c
            sub         06
            ld          c,a
            ret

            ld          a,c
            cp          06
            ret         nc
            add         a,06
            ld          c,a
            ret

            push        de
            push        bc
            ld          e,01
            ld          a,d
            cp          06
            jr          c,1696
            inc         e
            sub         06
            ld          d,e
            ld          b,a
            add         a,a
            add         a,a
            add         a,b
            ld          e,a
            call        setxy
            pop         bc
            pop         de
            ret

            .text       "edit z80 registers\r\r"
            .text       "use cursor keys to select a\r"
            .text       "register, then type in the new\r"
            .text       "value.\r\r"
            .text       "use [esc] when you are done.\r\000"

            dec         c
            jr          1727
            inc         e
            ld          a,(de)
            dec         de
            jr          nz,1723

            push        bc
            pop         hl
            call        cmdget
            ld          de,(61ba)
            jr          z,1731
            call        gethex
            push        de
            call        cls
            ld          hl,17c7
            call        prtstg
            ld          b,0d
            pop         hl
            push        hl
            push        bc
            call        15ce
            pop         bc
            pop         hl
            ld         de,(no_instr)
            ld          d,00
            add         hl,de
            push        hl
            ld          a,10
            sub         b
            ld          d,a
            ld          e,00
            call        setxy
            djnz        173d
            pop         hl
            ld          hl,41c0
            call        gethex
            ld          (61ad),de
            push        de
            pop         hl
            call        unassmbl
            ld          de,0f00
            call        setxy
            rst_chrin
            jr          z,176e
            cp          1b
            ret         z
            cp          20
            jr          z,17ac
            cp          1c
            jr          z,17ac
            cp          1a
            jr          nz,176e
            ld          hl,4040
            call        gethex
            push        de
            pop         hl
            ld          e,00
            dec         hl
            inc         e
            call        unassmbl
            ld         a,(inbuf)
            cp          20
            jr          z,178a
            ld          a,(no_instr)
            cp          e
            jr          nz,178a
            push        hl
            ld          bc,020e
            call        scrdn
            ld          de,0200
            call        setxy
            pop         hl
            jr          17c2
            ld          bc,020e
            call        scrup
            ld          de,0e00
            call        setxy
            ld          hl,(61ad)
            ld         de,(no_instr)
            ld          d,00
            add         hl,de
            call        15ce
            jr          1759

            .text       "use arrows to move,[esc] to exit  \r\000"

            push        bc
            pop         hl
            call        cmdget
            cp          52
            jr          nz,180e
            call        cmdadv
            jr          z,1803
            sub         30
            and         07
            ld          d,08
            ld          e,a
            ld          a,03
            rst_filem
            ld          a,(baudof)
            inc         a
            ld          b,a
            ld          hl,0f69
            jp          0f11
            call        gethex
            ld          (61ad),de
            push        de
            ld          hl,188a
            call        prtstg
            pop         de
            call        pr2hex
            ld          a,02
            rst_chkin
            rst_chrin
            jr          nz,1823
            rst_chrin
            jr          z,1826
            and         7f
            cp          3a
            jr          nz,1826
            ld          a,(video)
            xor         80
            ld          (video),a
            ld          c,00
            call        186c
            ld          b,a
            or          a
            jr          nz,1850
            xor         a
            rst_filem
            ld          hl,189b
            jp          prtstg
            xor         a
            rst_filem
            ld          hl,18ba
            jp          prtstg
            call        186c
            ld          h,a
            call        186c
            ld          l,a
            add         hl,de
            call        186c
            call        186c
            ld          (hl),a
            inc         hl
            djnz        185c
            call        186c
            ld          a,c
            or          a
            jr          nz,1848
            jr          1826
            push        bc
            rst_chrin
            jr          z,186d
            call        0d27
            sla         a
            sla         a
            sla         a
            sla         a
            push        af
            rst_chrin
            jr          z,187c
            call        0d27
            pop         bc
            or          b
            pop         bc
            push        af
            add         a,c
            ld          c,a
            pop         af
            ret

            .text       "target offset" \000"
            .text       "\rdownload complete, no errors\r\000"
            .text       "** download bad **\r\000"

            push        bc
            pop         hl
            call        cmdget
            jr          nz,1913
            ld          e,01
            call        0bac
            jr          nz,18ee
            ld          hl,18f4
            call        prtstg
            ld          de,(6171)
            call        pr2hex
            ld          a,0d
            rst_chrout
            ret

            ld          hl,1905
            jp          prtstg

                     .text      "autoexec set at \000"
                     .text      "no autoexec.\r\000"

            cp          2d
            jr          nz,191e
            ld          b,00
            ld          a,04
            rst_filem
            jr          18d6
            cp          2b
            ld          b,03
            jp          nz,0f0e
            inc         hl
            call        gethex
            ld          b,01
            jr          1919
            push        bc
            pop         hl
            ld          c,03
            call        194e
            pop         de
            ld          a,e
            pop         hl
            pop         de
            or          a
            sbc         hl,de
            ld          b,02
            jp          c,0f0e
            push        hl
            pop         bc
            inc         bc
            push        de
            pop         hl
            ld          e,a
            ld          (hl),e
            inc         hl
            dec         bc
            ld          a,b
            or          c
            jr          nz,1946
            ret

            pop         ix
            ld          b,01
            call        cmdget
            jp          z,0f0e
            call        0d32
            jr          nc,1960
            call        cmdadv
            call        gethex
            push        de
            dec         c
            jr          nz,1952
            jp          (ix)
            push        bc
            pop         hl
            ld          c,02
            call        194e
            ld          (619b),hl
            pop         hl
            pop         de
            ld          (6197),de
            or          a
            sbc         hl,de
            inc         hl
            ld          (6199),hl
            ld          hl,(619b)
            ld          b,01
            call        cmdget
            jp          z,0f0e
            cp          2c
            jr          nz,1994
            call        cmdadv
            jr          1988
            call        0d32
            jp          nc,1a2b
            ld          e,a
            ld          c,00
            ld          (619d),hl
            inc         hl
            ld          a,(hl)
            or          a
            jr          z,19ab
            cp          e
            jr          z,19ab
            inc         c
            jr          19a0
            ld          a,c
            or          a
            ld          b,01
            jp          z,0f0e
            dec         b
            ld          (619b),bc
            ld          hl,(619d)
            inc         hl
            ld          de,611a
            ldir
            ld          hl,(6197)
            ld          de,611a
            ld          bc,(6199)
            ld          a,b
            or          c
            jp          z,19d9
            ld          a,(de)
            cp          (hl)
            dec         bc
            inc         hl
            jr          z,19f9
            ld          a,b
            or          c
            jr          nz,19cf
            ld          hl,19df
            jp          prtstg

                     .text      "\r*** search complete ***\r\000"

            ld          (6197),hl
            ld          (6199),bc
            inc         de
            ld          bc,(619b)
            dec         c
            jr          z,1a10
            ld          a,(de)
            cp          (hl)
            jr          nz,19c0
            inc         hl
            inc         de
            jr          1a05
            ld          hl,1a20
            call        prtstg
            ld          de,(6197)
            dec         de
            call        pr2hex
            jr          19c0

                     .text      "found at \000"

            ld          c,00
            ld          ix,611a
            call        cmdget
            jr          z,1a59
            inc         c
            call        gethex
            ld          a,e
            ld          (ix+00),a
            inc         ix
            ld          a,d
            or          a
            jr          z,1a4a
            ld          (ix+00),a
            inc         ix
            inc         c
            call        cmdget
            jr          z,1a59
            call        0d32
            jr          nc,1a31
            call        cmdadv
            jr          1a31
            ld          b,01
            inc         c
            dec         c
            jp          z,0f0e
            dec         b
            ld          (619b),bc
            jp          19c0

;h -- help/hardcopy
;
help        push        bc          ;1a68
            pop         hl
            call        cmdget        ;move line pointer to the next character
            jp          nz,hardcopy ;if there are arguments, run a printout
h0          ld          hl,helpscr  ;printout the help screen
            call        prtstg
h1          rst_chrin
            jr          z,h1        ;wait for key
            ld          e,a
            ld          hl,helptbl
h4          ld          a,(hl)      ;compare a jump vector to the key pressed
            or          a
            ret         z
            cp          e
            jr          z,h2
            inc         hl
            inc         hl
            inc         hl
            jr          h4
h2          inc         hl
            ld          e,(hl)
            inc         hl
            ld          d,(hl)
            ex          de,hl
            call        nls
            call        prtstg
            ld          hl,keyscr
            call        prtstg
h3          rst_chrin
            jr          z,h3        ;wait for key
            cp          1bh         ;return if escape was pressed
            ret         z
            jr          h0          ;redo the main help menu

helptbl     .db         'e'
            .dw         editscr
            .db         'h'
            .dw         hardscr
            .db         'm'
            .dw         movescr
            .db         'f'
            .dw         fillscr
            .db         's'
            .dw         srchscr
            .db         'r'
            .dw         regrscr
            .db         'u'
            .dw         unasscr
            .db         't'
            .dw         tracscr
            .db         'b'
            .dw         brekscr
            .db         '$'
            .dw         downscr
            .db         '2'
            .dw         r232scr
            .db         '@'
            .dw         autoscr
            .db         'g'
            .dw         gotoscr
            .db         'w'
            .dw         wrtescr
            .db         '!'
            .dw         termscr
            .db         'a'
            .dw         assmscr
            .db         00h

keyscr      .text       "\rpress any key to continue\000"
helpscr     .text       "   edm-80 help utility\r\r"
            .text       "press the key corresponding to  "
            .text       "the command you need help with, "
            .text       "[esc] to exit back to monitor.  \r"
            .text       "(e)dit         (h)ardcopy\r"
            .text       "(m)ove         (f)ill\r"
            .text       "(s)earch       (r)egisters\r"
            .text       "(u)nassemble   (t)race\r"
            .text       "(b)reakpoint   ($)downloading\r"
            .text       "(2)rs232 parms (@)autoexec\r"
            .text       "(g)oto         (w)rite\r"
            .text       "(!)term mode   (a)assemble\r\r"
            .text       "choose?"
            .db         0eh, 00h
editscr     .text       "e - memory edit command\r\r"
            .text       "used with an address to edit or"
            .text       "examine memory. example:\r\r"
            .text       "e 8600.\r\r"
            .text       "edit memory at 8600.  leaving\r
            .text       "out the address will cause the\r"
            .text       "display to begin at the address "
            .text       "in the pc-register.\000"
hardscr     .text       "h - hardcopy memory\r\r"
            .text       "usage:\r\r"
            .text       "h<option><device> (range)\r\r"
            .text       "option=u for unassembled output "
            .text       "device=p=parallel, s=serial\r"
            .text       "range =two memory addresses\r\r"
            .text       "example: dump 8600 to 6610 to\r"
            .text       "parallel printer:\r\r"
            .text       "hp 8600 8610\000"
movescr     .text       "m - move memory contents\r\r"
            .text       "usage:\r\r"
            .text       "m (addr1) (addr2) (addr3)\r\r"
            .text       "moves memory contents in the\r"
            .text       "range (addr1)-(addr2) to a new\r"
            .text       "area starting at (addr3).\r\r"
            .text       "example:\r\r"
            .text       "m 8600 8610 8700\000"
fillscr     .text       "f - fill memory with constant\r\r"
            .text       "usage:\r\r"
            .text       "f (addr1) (addr2) (value)\r\r"
            .text       "loads (value) into all memory\r"
            .text       "locations starting at (addr1)\r"
            .text       "and ending at (addr2).\r\r"
            .text       "example:\r\r"
            .text       "f 8600 8610 00\r\r\000"
srchscr     .text       "s - search memory for pattern\r\r"
            .text       "usage:\r\r"
            .text       "s (range) (pattern)\r\r"
            .text       "searches all addresses in the\r"
            .text       "(range) for any occurances of\r"
            .text       "(pattern).  pattern can be given"
            .text       "in hex or ascii.\r"
            .text       "example:\r\r"
            .text       "s 8600 862f 01 02 03\r"
            .text       "s 8600 862f \"hello\"\000"
regrscr     .text       "r - display z80 registers\r\r"
            .text       "usage:\r\r"
            .text       "r\r\r"
            .text       "use the cursor keys to select\r"
            .text       "the proper register; press [esc]"
            .text       "to terminate the command.\r\r\000"
unasscr     .text       "u - unassemble memory\r\r"
            .text       "usage:\r\r"
            .text       "u (address)\r\r"
            .text       "unassembles memory starting at\r"
            .text       "(address) into standard zilog\r"
            .text       "z80 mnemonics. use arrow keys,\r"
            .text       "or space bar to scroll listing.\r"
            .text       "omitting address will cause the\r"
            .text       "unassembly to begin at the\r"
            .text       "address in the pc-register.\r\r\000"
tracscr     .text       "t - trace program execution\r\r"
            .text       "usage:\r\r"
            .text       "t (address)\r\r"
            .text       "begins tracing program starting\r"
            .text       "at (address). if (address) is\r"
            .text       "omitted, the trace begins at\r"
            .text       "the address in the pc-register.\r\000"
brekscr     .text       "b - breakpoint set/test\r\r"
            .text       "usage:\r\r"
            .text       "b (address)\r\r"
            .text       "sets a breakpoint at (address),\r"
            .text       "if (address) is omitted, the\r"
            .text       "status of the breakpoint is\r"
            .text       "reported. to remove a break-\r"
            .text       "point, use an address of 0.\r\r\000"
downscr     .text       "downloading procedure\r\r"
            .text       "- use $r (rate code) to set the "
            .text       "  rs232 parameters to match the "
            .text       "  host settings.\r\r"
            .text       "- to download, issue:\r\r"
            .text       "$ (offset)\r\r"
            .text       "where (offset) is optional. then"
            .text       "command host to send data.\000"
r232scr     .text       "$r - set/inspect rs232 settings \r"
            .text       "useage:\r\r"
            .text       "$r (rate-code), where\r"
            .text       "rate-code is:\r\r"
            .text       "0 = 0050 bps  1 = 0110 bps\r"
            .text       "2 = 0300 bps  3 = 1200 bps\r"
            .text       "4 = 2400 bps  5 = 4800 bps\r\r"
            .text       "omitting the (rate-code) will\r"
            .text       "cause the current bit-rate to be\r"
            .text       "reported.\000"
autoscr     .text       "@ - set or check autoexec status\r\r"
            .text       "usage:\r\r"
            .text       "@(option) (address)\r\r"
            .text       "option \"+\" sets the autoexec,\r"
            .text       "option \"-\" disables the autoexec.\r"
            .text       "(address) is the point that will\r"
            .text       "get control on next power on\r"
            .text       "cycle. omitting both (address)\r"
            .text       "and (option) will cause the\r"
            .text       "status to be displayed.\000"
gotoscr     .text       "g - goto command\r\r"
            .text       "usage:\r\r"
            .text       "g (address)\r\r"
            .text       "the cpu will jump to (address). "
            .text       "if (address) is omitted, the\r"
            .text       "cpu jumps to the value in the\r"
            .text       "pc-register.\r\r\000"
assmscr     .text       "a - assemble z80 code\r\r"
            .text       "usage:\r\r"
            .text       "a (address)\r\r"
            .text       "if (address) is omitted, the\r"
            .text       "assembly starts at the location\r"
            .text       "pointed to by the pc-register.\r\r\000"
wrtescr     .text       "w - write memory to rs232 using\r"
            .text       "    the intel-hex (tm) protocol\r\r"
            .text       "usage:\r\r"
            .text       "w addr1 addr2\r\r"
            .text       "sends memory from (addr1) to\r"
            .text       "(addr2) inclusive.  set rs232\r"
            .text       "parameters befor transmitting.\000"
termscr     .text       "! - enter the terminal emulator\r\r"
            .text       "- set the rs232 speed first with"
            .text       "  the $r command. 8 data bits\r"
            .text       "always used in this mode.\r\r"
            .text       "- issue the (!) command to enter"
            .text       "  term emulation mode. press the"
            .text       "  [esc] key to exit this mode.\r\r"
            .text       "- press ctrl-d to toggle between"
            .text       "  half and full duplex if needed"
            .text       "  (defaults to full duplex).\r\000"

            cp          50
            ld          e,04
            jr          nz,28d4
            call        cmdadv
            jr          28db

            cp          55
            jr          z,2916
            call        gethex
            push        de
            ld          c,02
            call        194e
            pop         de
            pop         hl
            pop         bc
            ld          a,c
            rst_chkout
            ld          a,l
            and         0f8
            ld          l,a
            push        de
            push        hl
            xor         a
            ld          (asciiflag),a
            call        editline
            ld          a,01
            ld          (asciiflag),a
            ld          a,space
            rst_chrout
            rst_chrout
            pop         hl
            push        hl
            call        11c0
            call        294e
            pop         hl
            ld          de,0008
            add         hl,de
            pop         de
            push        hl
            or          a
            inc         de
            sbc         hl,de
            dec         de
            pop         hl
            jr          c,28ea
            xor         a
            rst_filem
            ret

            call        cmdadv
            cp          50
            ld          e,04
            jr          nz,2924
            call        cmdadv
            jr          2927

            call        gethex
            push        de
            ld          c,02
            call        194e
            pop         de
            pop         hl
            pop         bc
            ld          a,c
            rst_chkout
            push        de
            push        hl
            call        15ce
            call        294e
            ld         de,(no_instr)
            ld          d,00
            pop         hl
            add         hl,de
            pop         de
            push        hl
            or          a
            inc         de
            sbc         hl,de
            dec         de
            pop         hl
            jr          nc,2913
            jr          2932

            ld          a,0d
            rst_chrout
            ld          a,0a
            rst_chrout
            ld          b,05
            xor         a
            rst_chrout
            djnz        2957
            ret

            push        bc
            pop         hl
            ld          c,02
            call        194e
            ld          a,02
            rst_chkout
            pop         hl
            pop         de
            push        hl
            or          a
            sbc         hl,de
            jr          c,29b2
            rst_chrin
            cp          1b
            jr          z,29b2
            inc         hl
            push        hl
            ld          bc,0020
            or          a
            sbc         hl,bc
            pop         hl
            ld          b,l
            jr          c,2980
            ld          b,20
            ld          a,3a
            push        de
            rst_chrout
            pop         de
            ld          a,b
            call        prhex
            add         a,d
            add         a,e
            ld          c,a
            call        pr2hex
            xor         a
            call        prhex
            ld          a,(de)
            inc         de
            call        prhex
            add         a,c
            ld          c,a
            djnz        2993
            ld          a,c
            neg
            call        prhex
            push        de
            call        294e
            pop         de
            pop         hl
            ld          a,(video)
            xor         80
            ld          (video),a
            jr          2967
            ld          a,3a
            rst_chrout
            xor         a
            call        prhex
            ld          e,a
            ld          d,a
            call        pr2hex
            ld          de,videosize
            call        pr2hex
            call        294e
            xor         a
            rst_filem
            pop         hl
            ret

            ld          hl,2a2e
            call        prtstg
            ld          a,0ff
            ld          (6197),a
            call        2a1b
            ld          a,02
            rst_chkin
            rst_chrin
            jr          z,29ed
            and         7f
            call        2a12
            cp          01
            jr          z,29ed
            cp          0f
            jr          z,29ed
            rst_chrout
            xor         a
            rst_filem
            rst_chrin
            or          a
            jr          z,29d9
            cp          1b
            ret         z
            cp          04
            jr          nz,29ff
            call        2a1b
            jr          29d9

            push        af
            ld          a,(6197)
            or          a
            jr          z,2a09
            pop         af
            rst_chrout
            push        af
            ld          a,02
            rst_chkout
            pop         af
            rst_chrout
            xor         a
            rst_filem
            jr          29d9
            cp          61
            ret         c
            cp          7b
            ret         nc
            xor         20
            ret

            ld          a,(6197)
            xor         0ff
            ld          (6197),a
            ld          hl,2a80
            jr          nz,2a2b
            ld          hl,2a90
            jp          prtstg

            .text       "terminal emulation mode.\r\r"
            .text       "press ctrl-d to change\r"
            .text       "duplex. press [esc] to exit.\r\r"
            .db         0eh, 00h
            .text       "[half duplex]\r\000"
            .text       "[full duplex]\r\000"
            .text       "assembler mode: use arrows to   "
            .text       "move cursor, or [esc] to exit\000"

            push        bc
            pop         hl
            call        cmdget
            ld          de,(61ba)
            jr          z,2aed
            call        gethex
            push        de
            ld          hl,2aa0
            call        prtstg
            ld          a,0f
            ld          (619f),a
            ld          de,0f00
            call        setxy
            pop         de
            call        pr2hex
            ld          a,3a
            rst_chrout
            ld          a,(619f)
            ld          d,a
            ld          e,10
            call        setxy
            call        2be2
            cp          1b
            jr          nz,2b23
            xor         a
            rst_filem
            ld          de,0f00
            call        setxy
            ld          a,0d
            rst_chrout
            rst_chrout
            ret

            push        af
            ld          a,(619f)
            call        2c42
            ld          hl,60d4h
            call        gethex
            push        de
            ld          a,(hl)
            or          a
            jr          z,2b4f
            cp          20
            jr          z,2b3c
            inc         hl
            jr          2b31

            inc         hl
            ld          a,(hl)
            or          a
            jr          z,2b4f
            cp          20
            jr          z,2b3c
            push        hl
            pop         ix
            pop         iy
            push        iy
            call        2dc0
            pop         de
            ld          a,(619f)
            push        af
            call        clear_line
            pop         de
            ld          e,00
            call        setxy
            ld          hl,60d4h
            call        gethex
            ex          de,hl
            push        hl
            call        15ce
            pop         hl
            ld          a,(619f)
            cp          0f
            jr          z,2b91
            ld          d,a
            ld          a,0f
            sub         d
            ld          e,00
            ld          b,a
            inc         d
            push        de
            ld          a,d
            call        clear_line
            call        setxy
            ld          a,(no_instr)
            ld          e,a
            ld          d,00
            add         hl,de
            push        hl
            push        bc
            call        15ce
            pop         bc
            pop         hl
            pop         de
            djnz        2b77
            pop         af
            cp          1c
            jr          z,2bc2
            ld          a,(619f)
            cp          0f
            jr          z,2ba4
            inc         a
            ld          (619f),a
            jp          2b06

            ld          bc,030f
            call        scrup
            ld          a,(619f)
            dec         a
            call        2c42
            ld          hl,60d4h
            call        gethex
            ld          a,(no_instr)
            ld          l,a
            ld          h,00
            add         hl,de
            push        hl
            jp          2af4

            ld          a,(619f)
            dec         a
            ld          d,a
            ld          e,00
            call        setxy
            xor         a
            rst_chkin
            rst_chrin
            push        af
            xor         a
            rst_filem
            pop         af
            cp          20
            jp          z,2b06
            ld          a,(619f)
            dec         a
            ld          (619f),a
            jp          2b06

            ld          hl,2c3c
            push        hl
            ld          a,0e
            rst_chrout
            ld       de,(crsr_rate)
            ld          (crsr_count),de
            ld          hl,(crsr_count)
            ld          a,h
            or          l
            dec         hl
            ld          (crsr_count),hl
            jr          nz,2c0f
            ld       hl,(crsr_rate)
            ld          (crsr_count),hl
            ld       a,(cursor_mode)
            or          a
            jr          z,2c0c
            ld          a,0f
            jr          2c0e

            ld          a,0e
            rst_chrout
            rst_chrin
            and         7f
            jr          z,2bf1
            cp          0d
            ret         z
            cp          1c
            ret         z
            cp          1a
            ret         z
            cp          1b
            ret         z
            cp          09
            jr          nz,2c26
            ld          a,19
            cp          08
            jr          z,2c2e
            cp          18
            jr          c,2bf1
            rst_chrout
            ld          a,(619f)
            ld          de,(column)
            ld          d,a
            call        setxy
            jr          2bf1

            push        af
            ld          a,0f
            rst_chrout
            pop         af
            ret

            ld          d,a
            ld          e,00
            call        setxy
            xor         a
            rst_chkin
            ld          b,20
            ld          hl,60d4h
            rst_chrin
            ld          (hl),a
            inc         hl
            djnz        2c4f
            ld          (hl),00
            xor         a
            rst_filem
            ret
            inc         hl
            ld          a,(hl)
            or          a
            ret         z
            cp          2ch
            jp          z,cmdadv
            cp          2eh
            jp          z,cmdadv
            cp          3ah
            jp          z,cmdadv
            cp          3bh
            jp          z,cmdadv
            cp          2fh
            jr          z,cmdadv
            jp          0cd1h

            .db         00h
pwronmsg    .text       "edm-80 - resident monitor v2.3\r\000"

            pop         hl
            ld          a,(hl)
            push        af
            res         7,a
            rst_chrout
            inc         hl
            pop         af
            bit         7,a
            jr          z,2c9c
            push        hl
            ret

            pop         hl
            push        af
            push        de
            ld          d,(hl)
            inc         hl
            ld          e,(hl)
            inc         hl
            call        setxy
            pop         de
            pop         af
            push        hl
            jp          2c9b

            ld          bc,0000
            ld          de,0000
            ld          hl,0000
            ld          a,(ix+00)
            cp          4a
            jp          z,2e1e
            cp          41
            jp          z,2e7d
            cp          4c
            jp          z,2f10
            cp          4e
            jp          z,3083
            cp          4f
            jp          z,3095
            cp          50
            jp          z,3104
            cp          58
            jp          z,3123
            cp          53
            jp          z,313e
            cp          52
            jp          z,31fe
            cp          42
            jp          z,32f0
            cp          45
            jp          z,3308
            cp          43
            jp          z,3464
            cp          49
            jp          z,3377
            cp          44
            jp          z,3342
            cp          48
            jp          z,2e18
            ret

            ld          a,76
            call        34e4
            ret

            ld          a,(ix+01)
            cp          52
            jp          z,2e5a
            call        354b
            cp          28
            jr          z,2e45
            call        370f
            jr          nc,2e52
            call        3654
            push        af
            call        362f
            call        3640
            pop         af
            rlca
            rlca
            rlca
            or          0c2
            jp          36f3

            inc         ix
            ld          a,(ix+00)
            call        34fe
            ld          a,0e9
            jp          36be

            call        3640
            ld          a,0c3
            jp          36f3

            call        354b
            call        370f
            jr          nc,2e75
            call        3654
            push        af
            call        362f
            call        3701
            pop         af
            rlca
            rlca
            rlca
            or          20
            jp          36ea
            call        3701
            ld          a,18
            jp          36ea
            ld          a,(ix+01)
            cp          4e
            jp          z,2ef5
            ld          a,(ix+02)
            cp          43
            jr          z,2ea7
            call        354b
            cp          41
            jr          z,2eda
            call        34fe
            call        362f
            call        34fe
            ld          a,b
            rlca
            rlca
            rlca
            rlca
            or          09
            call        36be
            ret

            call        354b
            cp          41
            jr          z,2ebf
            call        362f
            call        34fe
            ld          a,b
            rlca
            rlca
            rlca
            rlca
            or          4a
            call        36b4
            ret

            call        362f
            call        35a9
            jr          c,2ed1
            call        35e0
            ld          a,88
            or          b
            call        34e4
            ret

            call        3640
            ld          a,0ce
            call        36ea
            ret
            call        362f
            call        35a9
            jr          c,2eec
            call        35e0
            ld          a,80
            add         a,b
            call        34e4
            ret

            call        3640
            ld          a,0c6
            call        36ea
            ret

            call        354b
            call        35a9
            jr          c,2f07
            call        35e0
            ld          a,0a0
            add         a,b
            call        34e4
            ret

            call        3640
            ld          a,0e6
            call        36ea
            ret

            ld          a,(ix+02)
            cp          20
            jp          nz,3073
            call        354b
            cp          28
            jp          z,2f97
            ld          a,(ix+01)
            cp          2c
            jp          z,2fed
            ld          a,(ix+00)
            call        34fe
            ld          c,b
            call        362f
            cp          28
            jr          z,2f50
            call        3728
            jp          nc,2f7f
            call        34fe
            bit         7,e
            jr          z,2f4a
            ld          (iy+00),e
            inc         iy
            ld          e,00
            ld          a,0f9
            call        34e4
            ret

            inc         ix
            ld          a,(ix+00)
            call        3640
            ld          a,c
            cp          02
            jp          z,2f6e
            rlca
            rlca
            rlca
            rlca
            or          4b
            ld          (iy+00),0ed
            inc         iy
            call        36f3
            ret

            bit         7,e
            jr          z,2f77
            ld          (iy+00),e
            inc         iy
            ld          a,2a
            ld          e,00
            call        36f3
            ret

            call        3640
            ld          a,c
            rlca
            rlca
            rlca
            rlca
            inc         a
            bit         7,e
            jr          z,2f93
            ld          (iy+00),e
            inc         iy
            ld          e,00
            call        36f3
            ret

            ld          a,(ix+01)
            cp          49
            jr          z,2fed
            cp          48
            jr          z,2fed
            cp          42
            jr          z,2fe3
            cp          44
            jr          z,2fe8
            inc         ix
            call        3640
            call        362f
            cp          41
            jr          z,2fde
            cp          48
            jr          z,2fd9
            call        34fe
            bit         7,e
            jr          nz,2fd2
            ld          a,b
            rlca
            rlca
            rlca
            rlca
            or          43
            ld          (iy+00),0ed
            inc         iy
            call        36f3
            ret

            ld          (iy+00),e
            inc         iy
            ld          e,00
            ld          a,22
            jp          36f3

            ld          a,32
            jp          36f3

            ld          a,02
            jp          34e4

            ld          a,12
            jp          34e4

            ld          a,(ix+00)
            cp          49
            jp          z,3027
            cp          52
            jp          z,3027
            call        35e0
            ld          c,b
            call        362f
            call        35a9
            jr          c,3066
            cp          49
            jp          z,305a
            cp          52
            jp          z,305a
            cp          28
            jr          nz,3049
            inc         ix
            ld          a,(ix+00)
            call        35a9
            jr          nc,3033
            call        3640
            ld          a,3a
            call        36f3
            ret

            cp          49
            ld          a,47
            jr          z,302f
            add         a,08
            call        36b4
            ret

            ld          a,(ix+01)
            ld          e,0a
            cp          43
            jr          nz,3041
            ld          a,e
            ld          (iy+00),a
            ret

            ld          e,1a
            cp          45
            jr          z,303c
            dec         ix
            ld          a,(ix+00)
            call        35e0
            ld          a,c
            rlca
            rlca
            rlca
            or          40
            or          b
            call        34e4
            ret

            cp          49
            ld          a,57
            jr          z,3062
            add         a,08
            call        36b4
            ret

            call        3640
            ld          a,c
            rlca
            rlca
            rlca
            or          06
            call        36ea
            ret

            inc         ix
            inc         ix
            call        3690
            rlca
            rlca
            rlca
            or          0a0
            call        36b4
            ret

            ld          a,(ix+01)
            cp          4f
            jr          z,3090
            ld          a,44
            call        36b4
            ret

            xor         a
            call        34e4
            ret

            ld          a,(ix+01)
            cp          52
            jr          z,30e9
            cp          54
            jr          z,30d9
            cp          55
            jr          z,30a5
            ret

            ld          a,(ix+03)
            cp          20
            jp          nz,30d9
            call        354b
            ld          a,(ix+01)
            cp          43
            jr          z,30c6
            call        35a9
            ret         nc
            inc         ix
            call        3640
            ld          a,0d3
            call        36ea
            ret

            call        362f
            call        35e0
            rlc         b
            rlc         b
            rlc         b
            ld          a,41
            or          b
            call        36b4
            ret

            inc         ix
            inc         ix
            call        3690
            rlca
            rlca
            rlca
            or          0a3
            call        36b4
            ret

            call        354b
            call        35a9
            jr          c,30fb
            call        35e0
            ld          a,0b0
            add         a,b
            call        34e4
            ret

            call        3640
            ld          a,0f6
            call        36ea
            ret

            ld          a,(ix+01)
            push        af
            call        354b
            call        34fe
            pop         af
            cp          55
            ld          a,0c1
            jr          nz,3117
            add         a,04
            rrc         b
            rrc         b
            rrc         b
            rrc         b
            or          b
            call        36be
            call        354b
            call        35a9
            jr          c,3135
            call        35e0
            ld          a,0a8
            add         a,b
            call        34e4
            ret

            call        3640
            ld          a,0ee
            call        36ea
            ret

            ld          a,(ix+02)
            cp          54
            jp          z,31e6
            cp          41
            jp          z,31c4
            cp          4c
            jp          z,31b7
            cp          42
            jp          z,319c
            cp          43
            jp          z,3165
            cp          46
            jr          z,315f
            ret

            ld          a,37
            call        34e4
            ret

            call        354b
            cp          41
            jr          nz,3187
            call        362f
            call        35a9
            jr          c,317e
            call        35e0
            ld          a,98
            or          b
            call        34e4
            ret

            call        3640
            ld          a,0de
            call        36ea
            ret

            call        362f
            call        34fe
            ld          a,42
            rlc         b
            rlc         b
            rlc         b
            rlc         b
            or          b
            call        36b4
            ret

            call        354b
            call        35a9
            jr          c,31ae
            call        35e0
            ld          a,90
            or          b
            call        34e4
            ret

            call        3640
            ld          a,0d6
            call        36ea
            ret

            call        354b
            call        35e0
            ld          a,38
            add         a,b
            call        36cd
            ret

            ld          a,(ix+01)
            cp          4c
            jp          nz,31d9
            call        354b
            call        35e0
            ld          a,space
            or          b
            call        36cd
            ret

            call        354b
            call        35e0
            ld          a,28
            add         a,b
            call        36cd
            ret

            call        354b
            call        358c
            push        af
            call        362f
            call        35e0
            pop         af
            rlca
            rlca
            rlca
            or          b
            or          0c0
            call        36cd
            ret

            ld          a,(ix+02)
            cp          53
            jp          z,32d8
            cp          43
            jp          z,32a9
            cp          20
            jp          z,3291
            cp          41
            jp          z,3282
            cp          44
            jp          z,3273
            cp          54
            jp          z,3220
            ret

            ld          a,(ix+01)
            cp          53
            jp          z,325a
            ld          a,(ix+03)
            cp          49
            jp          z,3267
            cp          4e
            jp          z,3267
            ld          a,(ix+01)
            cp          45
            jp          z,323e
            ret

            call        354b
            or          a
            jp          nz,324b
            ld          a,0c9
            call        34e4
            ret

            call        3654
            sla         a
            sla         a
            sla         a
            or          0c0
            call        34e4
            ret

            call        354b
            call        3640
            ld          a,0c7
            or          l
            call        34e4
            ret

            cp          49
            ld          a,4d
            jr          z,326f
            sub         08
            call        36b4
            ret

            ld          a,(ix+01)
            cp          4c
            ld          a,67
            jr          nz,327e
            add         a,08
            call        36b4
            ret

            ld          a,(ix+01)
            cp          52
            ld          a,17
            jr          nz,328d
            add         a,08
            call        34e4
            ret

            ld          a,(ix+01)
            push        af
            call        354b
            call        35e0
            pop         af
            cp          52
            ld          a,10
            jr          nz,32a4
            add         a,08
            add         a,b
            call        36cd
            ret

            ld          a,(ix+03)
            cp          41
            jp          z,32c9
            ld          a,(ix+01)
            push        af
            call        354b
            call        35e0
            pop         af
            cp          52
            ld          a,00
            jr          nz,32c4
            add         a,08
            add         a,b
            call        36cd
            ret

            ld          a,(ix+01)
            cp          52
            ld          a,07
            jr          nz,32d4
            add         a,08
            call        34e4
            ret

            call        354b
            call        358c
            push        af
            call        362f
            call        35e0
            pop         af
            rlca
            rlca
            rlca
            or          b
            or          80
            call        36cd
            ret

            call        354b
            call        358c
            push        af
            call        362f
            call        35e0
            pop         af
            rlca
            rlca
            rlca
            or          b
            or          40
            call        36cd
            ret

            ld          a,(ix+01)
            cp          49
            jr          nz,3315
            ld          a,0fb
            call        36be
            ret
            ld          a,(ix+02)
            cp          58
            jr          nz,3320
            ld          a,0d9
            jr          3311

            call        354b
            ld          a,(ix+00)
            cp          41
            jr          nz,332e
            ld          a,08
            jr          3311

            cp          44
            jr          nz,3336
            ld          a,0eb
            jr          3311

            call        362f
            call        34fe
            ld          a,0e3
            call        36be
            ret

            ld          a,(ix+02)
            cp          43
            jp          z,3440
            ld          a,(ix+01)
            cp          41
            jr          nz,3356
            ld          (iy+00),27
            ret

            cp          49
            jr          nz,335f
            ld          (iy+00),0f3
            ret

            call        354b
            call        3640
            ld          (iy+00),10
            inc         iy
            scf
            ccf
            push        iy
            pop         de
            sbc         hl,de
            dec         l
            ld          (iy+00),l
            ret

            ld          a,(ix+02)
            cp          43
            jp          z,341e
            ld          a,(ix+01)
            cp          4d
            jp          z,340b
            ld          a,(ix+02)
            cp          44
            jp          z,33ce
            cp          49
            jp          z,33ef
            call        354b
            call        35e0
            ld          a,07
            cp          b
            jr          z,33b1
            ld          (iy+00),0ed
            inc         iy
            ld          a,b
            rlca
            rlca
            rlca
            or          40
            ld          (iy+00),a
            inc         iy
            ret

            call        362f
            inc         ix
            ld          a,(ix+00)
            call        35a9
            jp          nc,339f
            call        3640
            ld          (iy+00),0db
            inc         iy
            ld          (iy+00),l
            inc         iy
            ret

            ld          a,(ix+03)
            cp          52
            jr          nz,33e2
            ld          (iy+00),0ed
            inc         iy
            ld          (iy+00),0ba
            inc         iy
            ret

            ld          (iy+00),0ed
            inc         iy
            ld          (iy+00),0aa
            inc         iy
            ret

            ld          a,(ix+03)
            cp          52
            ld          (iy+00),0ed
            inc         iy
            jp          nz,3404
            ld          (iy+00),0b2
            inc         iy
            ret

            ld          (iy+00),0a2
            inc         iy
            ret

            call        354b
            call        358c
            or          a
            jr          z,3415
            inc         a
            rlca
            rlca
            rlca
            or          46
            call        36b4
            ret

            call        354b
            call        3526
            jp          c,3437
            call        35e0
            ld          a,04
            rlc         b
            rlc         b
            rlc         b
            or          b
            call        34e4
            ret

            call        34fe
            ld          a,03
            rlc         b
            jr          342c

            call        354b
            call        3526
            jp          c,3459
            call        35e0
            ld          a,05
            rlc         b
            rlc         b
            rlc         b
            or          b
            call        34e4
            ret

            call        34fe
            ld          a,03
            rlc         b
            set         0,b
            jr          344e

            inc         ix
            ld          a,(ix+00)
            cp          41
            jp          z,34bf
            cp          50
            jp          nz,34b8
            inc         ix
            ld          a,(ix+00)
            cp          20
            jp          z,348d
            cp          4c
            jr          z,34b1
            call        3690
            rlca
            rlca
            rlca
            or          0a1
            call        36b4
            ret

            inc         ix
            ld          a,(ix+00)
            cp          20
            jr          z,348d
            call        35a9
            jr          nc,34a4
            call        3640
            ld          a,0fe
            call        36ea
            ret

            ld          a,(ix+00)
            call        35e0
            ld          a,0b8
            or          b
            call        34e4
            ret

            ld          (iy+00),2f
            inc         iy
            ret

            ld          (iy+00),3f
            inc         iy
            ret

            call        354b
            call        35a9
            jr          nc,34d0
            call        3640
            ld          a,0cd
            call        36f3
            ret

            call        3654
            rlca
            rlca
            rlca
            or          0c4
            push        af
            call        362f
            call        3640
            pop         af
            call        36f3
            ret

            bit         7,e
            jr          z,34f8
            ld          (iy+00),e
            inc         iy
            ld          (iy+00),a
            inc         iy
            ld          (iy+00),d
            inc         iy
            ret

            ld          (iy+00),a
            inc         iy
            ret

            ld          a,(ix+00)
            ld          b,03
            cp          53
            ret         z
            cp          41
            ret         z
            dec         b
            cp          48
            ret         z
            dec         b
            cp          44
            ret         z
            dec         b
            cp          42
            ret         z
            ld          a,(ix+01)
            cp          58
            jr          nz,3521
            ld          b,02
            ld          e,0dd
            ret

            ld          b,02
            ld          e,0fd
            ret

            cp          28
            ret         z

            push        af
            ld          a,(ix+01)
            cp          43
            jr          z,3548
            cp          45
            jr          z,3548
            cp          4c
            jr          z,3548
            cp          50
            jr          z,3548
            cp          58
            jr          z,3548
            cp          59
            jr          z,3548
            pop         af
            or          a
            ret

            pop         af
            scf
            ret

            inc         ix
            ld          a,(ix+00)
            cp          00
            jr          z,3565
            cp          20
            jr          nz,354b
            inc         ix
            ld          a,(ix+00)
            cp          00
            jr          z,3565
            cp          20
            jr          z,3558
            ret

            ld          de,0000
            call        35e0
            ld          c,b
            call        35e0
            bit         7,e
            jr          z,3586
            ld          (iy+00),e
            inc         iy
            ld          (iy+00),a
            inc         iy
            ld          (iy+00),d
            inc         iy
            jp          358b

            ld          (iy+00),a
            inc         iy
            ret

            sub         30
            cp          0a
            ret         c
            sub         07
            ret

            cp          30
            jr          c,35a4
            cp          47
            jr          nc,35a4
            cp          41
            jr          nc,35a7
            cp          3a
            jr          c,35a7
            scf
            ccf
            ret

            scf
            ret

            cp          30
            jr          c,35b1
            cp          3a
            jr          c,35b4
            scf
            ccf
            ret

            scf
            ret

            push        af
            inc         ix
            ld          a,(ix+00)
            cp          29
            jr          z,35de
            inc         ix
            ld          a,(ix+00)
            call        358c
            or          d
            ld          d,a
            inc         ix
            ld          a,(ix+00)
            call        3594
            jr          nc,35de
            sla         d
            sla         d
            sla         d
            sla         d
            jr          35c5
            pop         af
            ret

            push        af
            cp          28
            jp          z,3601
            and         0f
            sub         01
            jr          z,35fd
            dec         a
            cp          04
            jr          c,35fa
            add         a,02
            rrca
            cp          04
            jr          z,35fa
            ld          a,05
            ld          b,a
            pop         af
            ret

            ld          a,07
            jr          35fa

            inc         ix
            ld          a,(ix+00)
            cp          48
            jr          nz,3612
            inc         ix
            inc         ix
            ld          a,06
            jr          35fa

            inc         ix
            ld          a,(ix+00)
            cp          58
            jr          nz,3625
            ld          a,06
            ld          e,0dd
            call        35b6
            jp          35fa

            ld          a,06
            ld          e,0fd
            call        35b6
            jp          35fa

            ld          a,(ix+00)
            cp          2c
            jr          z,363a
            inc         ix
            jr          362f

            inc         ix
            ld          a,(ix+00)
            ret

            push        iy
            push        bc
            push        de
            push        ix
            pop         hl
            call        0b53
            push        de
            push        hl
            pop         ix
            pop         hl
            pop         de
            pop         bc
            pop         iy
            ret

            ld          a,(ix+00)
            cp          5a
            jr          nz,365e
            ld          a,01
            ret

            cp          43
            jr          nz,3665
            ld          a,03
            ret

            cp          4d
            jr          nz,366c
            ld          a,07
            ret

            cp          4e
            jr          nz,367c
            ld          a,(ix+01)
            cp          5a
            jr          nz,3679
            xor         a
            ret

            ld          a,02
            ret

            ld          a,(ix+01)
            cp          41
            jr          nc,3686
            ld          a,06
            ret

            cp          45
            jr          nz,368d
            ld          a,05
            ret

            ld          a,04
            ret

            ld          a,(ix+00)
            cp          44
            jr          z,36a5
            inc         ix
            ld          a,(ix+00)
            cp          52
            jr          z,36a2
            xor         a
            ret

            ld          a,02
            ret

            inc         ix
            ld          a,(ix+00)
            cp          52
            jr          z,36b1
            ld          a,01
            ret

            ld          a,03
            ret

            ld          (iy+00),0ed
            inc         iy
            call        34e4
            ret

            bit         7,e
            jr          z,36c7
            ld          (iy+00),e
            inc         iy
            ld          (iy+00),a
            inc         iy
            ret

            bit         7,e
            jp          z,36d7

            ld          (iy+00),e
            inc         iy
            ld          (iy+00),0cb
            inc         iy
            jr          z,36e4
            ld          (iy+00),d
            inc         iy
            ld          (iy+00),a
            inc         iy
            ret

            call        34e4
            ld          (iy+00),l
            inc         iy
            ret

            call        34e4
            ld          (iy+00),l
            inc         iy
            ld          (iy+00),h
            inc         iy
            ret

            push        af
            call        3640
            push        iy
            pop         bc
            xor         a
            inc         bc
            inc         bc
            sbc         hl,bc
            pop         af
            ret

            push        ix
            push        af
            ld          a,(ix+00)
            cp          2c
            jr          z,3723
            or          a
            inc         ix
            jr          nz,3712
            pop         af
            pop         ix
            or          a
            ret

            pop         af
            pop         ix
            scf
            ret

            cp          41
            jr          c,3730
            cp          47
            ccf
            ret

            cp          30
            ret         c
            cp          3a
            ccf
            ret

unassmbl    jp          unassmblv

;addhex -- this routine calculates a two-digit hex value from a-register
;and places it in a buffer.  address 621bh, or bufassptr is the area pointing
;in the buffer which is automaticaly incremented.  no registers affected.
;
addhex      push        af
            push        bc
            push        de
            ld          c,a
            srl         a
            srl         a
            srl         a
            srl         a
            call        hexfix
            call        bufins
            ld          a,c
            and         0f
            call        hexfix
            call        bufins
            pop         de
            pop         bc
            pop         af
            ret

;hexfix -- this subroutine fixes a binary value to convert it to ascii.
;
hexfix      add         a,'0'       ;add the '0' offset
            cp          '9'+1       ;is it still 9 or less?
            ret         m           ;return then, "...it be fixed"
            add         a,07h       ;otherwise, offset it to (a-f).
            ret

;getinfo -- this subroutine loads the values of the instruction to disassemble
;           into the registers.  a-register holds the byte number of the
;           instruction.  the instruction offset pointer is also advanced.
;
getinfo     ld          a,(no_instr)
            inc         a
            ld          (no_instr),a
            push        hl
            ld       hl,(instroffst)
            inc         hl
            ld       (instroffst),hl
            ld          a,(hl)
            pop         hl
            ret

            push        hl
            ld       hl,(instroffst)
            jr          3779

;bufins -- this subroutine places a character in the buffer and increments
;          the bufassptr.  no registers are affected.
;
bufins      push        hl
            ld        hl,(bufassptr);get the current position.
            ld          (hl),a      ;store the character.
            inc         hl          ;advance the pointer.
            ld        (bufassptr),hl;store the pointer for next time.
            pop         hl
            ret

;
;unassmbl -- this subroutine dissasembles one instruction at hl-register to be
;            placed in a buffer at inbuf-1 (6034h).  ix is destroyed.
;
unassmblv   push        af
            push        bc
            push        de
            push        hl
            xor         a
            ld          (621a),a
            ld          (no_instr),a
            ld         (instrptr),hl;instrptr
            dec         hl
            ld       (instroffst),hl;instroffst
            ld          hl,inbuf
            ld        (bufassptr),hl
            ld          bc,buflength
            ld        de,bitnum
            ld          (hl),space
            ldir                    ;clear out the inbuf
            ld          (hl),00     ;terminate it with a zero
            call        getinfo     ;work on the first byte
            cp          0ddh        ;was it the 0ddh instruction prefix?
            ld          e,58
            jp          z,3ed9
            cp          0fdh
            ld          e,59
            jp          z,3ed9
            cp          0cbh
            jp          z,3ea4
            cp          0edh
            jp          z,3e12
            ld          hl,0ffffh
            push        hl
            ld          hl,instrtbl
            ld          bc,0017
            cpir
            jr          nz,3828
            pop         bc
            ld          de,instrtbl
            or          a
            sbc         hl,de
            ld          b,l
            call        3a0c
            ld          a,(621a)
            or          a
            jr          z,37fb
            ld          e,a
            ld          hl,inbuf
            ld          a,(hl)
            or          a
            jr          z,37fb
            cp          3f
            jr          nz,37f8
            ld          (hl),e
            inc         hl
            jr          37ef

            pop         hl
            pop         de
            pop         bc
            pop         af
            ret

            rra
            rra
            rra
            and         07
            ret

            rra
            rra
            rra
            rra
            and         03
            ret

            ld          e,44
            push        de
            ld          e,07
            push        de
            ld          de,0119
            push        de
            call        getinfo
            jp          3d33

            ld          e,49
            push        de
            ld          de,0119
            push        de
            ld          e,07
            jr          3816

            call        377c
            cp          0d3
            jr          z,381d
            cp          0db
            jr          z,380d
            cp          0cd
            jr          nz,3868
            ld          e,40
            push        de
            jp          3923

            ld          e,40
            push        de
            jr          3886

            ld          e,17
            push        de
            call        377c
            call        3800
            add         a,1f
            ld          e,a
            push        de
            jp          3d33

            ld          e,43
            push        de
            call        377c
            call        3800
            sla         a
            sla         a
            sla         a
            ld          d,a
            ld          e,1e
            push        de
            jp          3d33

            and         0c7
            cp          0c7
            jr          z,3852
            cp          0c4
            jr          z,383d
            cp          0c0
            jr          z,3842
            cp          0c2
            jr          c,3893
            cp          0c4
            jr          nc,3893
            ld          e,3d
            push        de
            cp          0c3
            jp          z,3923
            call        377c
            call        3800
            add         a,1f
            ld          e,a
            push        de
            jp          3923

            cp          06
            jr          z,38ac
            cp          04
            jr          c,38c1
            cp          06
            jr          nc,38c1
            add         a,27
            ld          e,a
            push        de
            call        377c
            call        3800
            ld          e,a
            jr          38bd

            ld          e,18
            push        de
            call        377c
            call        3800
            ld          e,a
            push        de
            call        getinfo
            ld          de,011c
            push        de
            jp          3d33

            call        377c
            and         0c0
            cp          40
            jr          nz,38de
            ld          e,18
            push        de
            call        377c
            ld          e,a
            call        3800
            ld          c,a
            push        bc
            ld          a,e
            and         07
            ld          c,a
            push        bc
            jp          3d33

            call        377c
            and         0e7
            cp          22
            jr          nz,390d
            ld          e,18
            push        de
            call        377c
            ld          d,a
            ld          e,07
            bit         4,a
            jr          nz,38f6
            ld          e,0e
            ld          bc,getaddr
            call        getinfo
            call        getinfo
            bit         3,d
            jr          nz,3908
            push        bc
            push        de
            jp          3d33

            push        de
            push        bc
            jp          3d33

            call        377c
            and         0cf
            cp          01
            jr          nz,3930
            ld          e,18
            push        de
            call        377c
            call        3806
            add         a,0c
            ld          e,a
            push        de
            call        getinfo
            call        getinfo
            ld          bc,011b
            push        bc
            jp          3d33

            ld          e,1a
            cp          0c5
            jr          z,393c
            cp          0c1
            jr          nz,3949
            ld          e,1b
            push        de
            call        377c
            call        3806
            add         a,14
            ld          e,a
            jp          38bd

            call        377c
            and         0f8
            cp          0b9
            jr          nc,3972
            cp          80
            jr          c,3972
            call        3800
            call        39f5
            push        de
            cp          04
            jr          nc,3968
            cp          02
            jr          z,3968
            ld          e,07
            push        de
            call        377c
            and         07
            ld          e,a
            push        de
            jp          3d33

            call        377c
            and         0c7
            cp          0c6
            jr          nz,3993
            call        377c
            call        3800
            call        39f5
            push        de
            cp          04
            jr          nc,3990
            cp          02
            jr          z,3990
            ld          e,07
            push        de
            jp          38b7

            call        377c
            and         0cf
            cp          09
            jr          nz,39ae
            ld          e,24
            push        de
            ld          e,0e
            push        de
            call        377c
            call        3806
            add         a,0c
            ld          e,a
            jp          38bd

            cp          03
            ld          e,2b
            jr          z,39b9
            inc         e
            cp          0b
            jr          nz,39c5
            push        de
            call        377c
            call        3806
            add         a,0c
            ld          e,a
            jr          39ab

            call        377c
            cp          18
            ld          e,3e
            jr          z,39d4
            ld          e,3f
            cp          10
            jr          nz,39df
            push        de
            call        getinfo
            ld          de,011a
            push        de
            jp          3d33

            and         0c0
            jr          nz,39f2
            ld          e,3e
            push        de
            call        377c
            call        3800
            add         a,1b
            ld          e,a
            push        de
            jr          39d5

            jp          3d33

            ld          d,00
            ld          e,a
            ld          hl,39fe
            add         hl,de
            ld          e,(hl)
            ret

            inc         h
            dec         h
            ld          h,27
            jr          z,3a2e
            add         hl,hl
            add         hl,de
            ld          a,(hl)
            or          a
            ret         z
            inc         hl
            jr          3a06

            ld          hl,3a6d
            call        3a06
            inc         hl
            djnz        3a0f
            ld          a,(hl)
            or          a
            ret         z
            call        bufins
            inc         hl
            jr          3a15

instrtbl    nop
            ld          a,(bc)
            ld          a,(de)
            ld          (bc),a
            ld          (de),a
            ld          sp,hl
            ex          de,hl
            ex          af,af'
            exx
            ex          (sp),hl
            daa
            cpl
            ccf
            scf
            halt
            di
            ei
            rlca
            rla
            rrca
            rra
            jp          (hl)

            ret

cptbl1      ld          d,a
            ld          e,a
            ld          b,a
            ld          c,a
            and         b
            or          b
            xor         b
            cp          b
            and         c
            or          c
            xor         c
            cp          c
            ld          b,h
            ld          b,(hl)
            ld          d,(hl)
            ld          e,(hl)
            ld          l,a
            ld          h,a
            ld          c,l
            ld          b,l
            and         d
            or          d
            xor         d
            cp          d
            and         e
            or          e
            xor         e
            cp          e
            ld          c,a
            ld          d,b
            ld          d,c
            ld          d,d
            inc         e
            dec         e
            ld          e,1f
            jr          nz,3a7c
            ld          (2d23),hl
            ld          l,2f
            jr          nc,3ab5
            add         hl,sp
            ld          b,c
            ld          b,d
            ld          b,l
            ld          b,(hl)
            ld          b,a
            ld          c,b
            ld          c,e
            ld          c,h
            ld          c,l
            ld          c,(hl)
            .db         00h

            .text       "nop\000"
            .text       "ld   a,(bc)\000"
            .text       "ld   a,(de)\000"
            .text       "ld   (bc),a\000"
            .text       "ld   (de),a\000"
            .text       "ld   sp,hl\000"
            .text       "ex   de,hl\000"
            .text       "ex   af,af\"\000"
            .text       "exx\000"
            .text       "ex   (sp),hl\000"
            .text       "daa\000"
            .text       "cpl\000"
            .text       "ccf\000"
            .text       "scf\000"
            .text       "halt\000"
            .text       "di\000"
            .text       "ei\000"
            .text       "rlca\000"
            .text       "rla\000"
            .text       "rrca\000"
            .text       "rra\000"
            .text       "jp   (hl)\000"
            .text       "ret  \000"
            .text       "ld   \000"
            .text       "cp   \000"
            .text       "push \000"
            .text       "pop  \000"
            .text       "ldi  \000"
            .text       "ldir \000"
            .text       "ld   \000"
            .text       "lddr \000"
            .text       "cpi  \000"
            .text       "cpir \000"
            .text       "cpd  \000"
            .text       "cpdr \000"
            .text       "add  \000"
            .text       "adc  \000"
            .text       "sub  \000"
            .text       "sbc  \000"
            .text       "and  \000"
            .text       "or   \000"
            .text       "xor  \000"
            .text       "inc  \000"
            .text       "dec  \000"
            .text       "neg  \000"
            .text       "im   0\000"
            .text       "im   1\000"
            .text       "im   2\000"
            .text       "rlc  \000"
            .text       "rrc  \000"
            .text       "rl   \000"
            .text       "rr   \000"
            .text       "sla  \000"
            .text       "sra  \000"
            .text       "???  \000"
            .text       "srl  \000"
            .text       "rrd  \000"
            .text       "bit  \000"
            .text       "res  \000"
            .text       "set  \000"
            .text       "jp   \000"
            .text       "jr   \000"
            .text       "djnz \000"
            .text       "call \000"
            .text       "reti \000"
            .text       "retn \000"
            .text       "rst  \000"
            .text       "in   \000"
            .text       "ini  \000"
            .text       "inir \000"
            .text       "ind  \000"
            .text       "indr \000"
            .text       "out  \000"
            .text       "out  (c),\000"
            .text       "outi \000"
            .text       "otir \000"
            .text       "outd \000"
            .text       "outdr \000"
            .text       "ld   a,i\000"
            .text       "ld   a,r\000"
            .text       "ld   i,a\000"
            .text       "ld   r,a\000"
            .text       "rld\000"
            .text       "inc  i?\000"
            .text       "dec  i?\000"
            .text       "jp   (i?)\000"
            .text       "ld   sp,i?\000"
            .text       "push i?\000"
            .text       "pop  i?\000"
            .text       "ex   (sp),i?\000"
            .text       "b\000"
            .text       "c\000"
            .text       "d\000"
            .text       "e\000"
            .text       "h\000"
            .text       "l\000"
            .text       "(hl)\000"
            .text       "a\000"
            .text       "(i?)\000"
            .text       "(i?+\000"
            .text       "(c)\000"
            .text       "(\000"
            .text       "bc\000"
            .text       "de\000"
            .text       "hl\000"
            .text       "sp\000"
            .text       "bc\000"
            .text       "de\000"
            .text       "hl\000"
            .text       "af\000"
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h
            .text       "nz\000"
            .text       "z\000"
            .text       "nc\000"
            .text       "c\000"
            .text       "po\000"
            .text       "pe\000"
            .text       "p\000"
            .text       "m\000"
            .text       "i?\000"

            push        hl
            or          a
            sbc         hl,de
            pop         hl
            ret

            ld          b,00
            ld          de,0ffffh
            pop         hl
            or          a
            sbc         hl,de
            jr          z,3d41
            inc         b
            jr          3d35

            inc         b
            dec         b
            jp          z,37e5
            ld          hl,0fffdh
            add         hl,sp
            ld          ix,0fff4h
            add         ix,sp
            ld          sp,ix
            ld          d,(hl)
            dec         hl
            ld          e,(hl)
            dec         hl
            push        hl
            ld          c,b
            call        3d77
            ld          b,c
            pop         hl
            dec         b
            jp          z,3e07
            ld          d,(hl)
            dec         hl
            ld          e,(hl)
            dec         hl
            push        hl
            push        bc
            call        3d7b
            pop         bc
            pop         hl
            dec         b
            jp          z,3e07
            ld          a,2c
            call        bufins
            jr          3d61

            ld          b,e
            jp          3a0c

            ld          b,e
            ld          a,e
            cp          18
            jr          c,3d85
            cp          1f
            jr          c,3d8d
            ld          hl,3cc7
            inc         b
            call        3a0f
            ld          a,e
            ld          a,e
            cp          1d
            jr          z,single    ;print a single digit less than 8h
            cp          1e
            jr          z,n1byte    ;print two digits without any leading zeroes
            ld          e,d
            ld          d,00
            ld         hl,(instrptr)
            add         hl,de
            cp          09
            jr          z,h2rb      ;print two digits and a ")"
            cp          19
            jr          z,lb2h      ;print a "(" and two digits & chk leading 0
            cp          1a
            jr          z,r2byte    ;print a relative two byte number
            cp          1b
            jr          z,n2byte    ;print a 4 digit high-low byte number
            cp          1c
            jr          z,z1byte    ;print a 2 dig and check for leading zero
            cp          0b
            ret         nz

;        -- place a four digit value followed by "--0xxx)" & chk for a leading
;           zero.  hl points to the value.
;
            inc         hl          ;get the high byte.
            ld          a,(hl)
            call        chkzro      ;check for a leading zero
            call        inshex      ;and place it in the buffer.
            dec         hl
            ld          a,(hl)      ;get the low byte.
twoend      call        inshex      ;place it in the buffer.
            ld          a,')'       ;get the ")" end parenthesis
            jp          bufins      ;and place it.

;        -- place a two digit value ending it with parenthesis "--0xx)".
;           hl points to the number.  leading zero requirement is checked.
;
            ld          a,(hl)      ;get the value
            call        chkzro      ;take care of the leading zero crisis.
            jr          twoend      ;and take care of the end parenthesis above.

;        -- place a single digit value less than seven from d-register "x".
;
single      ld          a,d         ;get the value.
            and         07          ;mask the value under 8.
            add         a,'0'       ;convert the binary to ascii
            jp          bufins      ;place it in the buffer.

;        -- place a single byte value with no leading zero from the d-reg "xx".
;
n1byte      ld          a,d         ;get value to place.
            jp          inshex      ;do it.

;        -- places a two digit value and checks for a leading zero "0xx".
;           hl points to the one byte value.
;
z1byte      ld          a,(hl)      ;get value to place.
            call        chkzro      ;check for a leading zero.
            jp          inshex      ;place it in the buffer.

;        -- places a four digit value with no leading zero checking "xxxx".  hl
;           points to the two byte value.
;
n2byte      inc         hl          ;get the high byte.
            ld          a,(hl)
            call        inshex      ;place it in.
            dec         hl          ;get the low byte.
            ld          a,(hl)
            jp          inshex      ;and place that in too.

;        -- places the "(" in the buffer.
;
lb2h        ld          a,'('
            call        bufins
            jr          3dc6

;        -- places a 4 digit calculated relative value into the buffer.
;           hl points to the two byte value.
;
r2byte      ld          a,(hl)
            ld          e,a
            ld         hl,(instrptr)
            inc         hl
            inc         hl
            ld          d,00
            or          a
            jp          p,3dfe
            dec         d
            add         hl,de
            ld          a,h
            call        inshex
            ld          a,l
            jp          inshex

            ld          ix,000c
            add         ix,sp
            ld          sp,ix
            jp          37e5
            call        getinfo
            ld          hl,cptbl1
            ld          bc,001c
            cpir
            jr          nz,3e3f
            dec         hl
            ld          de,3a35
            or          a
            sbc         hl,de
            ld          de,3a51
            add         hl,de
            ld          l,(hl)
            jp          37e1

            ld          e,44
            push        de
            call        377c
            call        3800
            ld          e,a
            push        de
            ld          e,0a
            push        de
            jp          3d33

            ld          hl,0ffffh
            push        hl
            and         0c7
            cp          40
            jr          z,3e2e
            cp          41
            jr          nz,3e5b
            ld          e,4a
            push        de
            call        377c
            call        3800
            ld          e,a
            push        de
            jp          3d33

            call        377c
            and         0cf
            cp          4b
            jr          z,3e68
            cp          43
            jr          nz,3e7b
            call        377c
            ld          e,18
            push        de
            ld          d,a
            call        3806
            add         a,0c
            ld          e,a
            ld          bc,020b
            jp          38f9
            ld          e,25
            cp          4a
            jr          z,3e88
            ld          e,27
            cp          42
            jp          nz,3d33
            push        de
            ld          e,0e
            push        de
            call        377c
            call        3806
            add         a,0c
            ld          e,a
            push        de
            jp          3d33
;
;chkzro  -- place a leading zero from a-register if necessary.
;
chkzro      cp          0a0h        ;does this need a leading zero?
            ret         c           ;return if ok.
            push        af
            ld          a,'0'       ;place a zero into the buffer.
            call        bufins
            pop         af
            ret

            ld          hl,0ffffh
            push        hl
            call        getinfo
            call        3ed3
            jr          z,3ec7
            add         a,39
            ld          e,a
            push        de
            call        377c
            push        af
            call        3800
            ld          d,a
            ld          e,1d
            pop         af
            push        de
            and         07
            ld          e,a
            push        de
            jp          3d33

            call        377c
            push        af
            call        3800
            add         a,31
            ld          e,a
            jr          3ebe

            rla
            rla
            rla
            and         03
            ret

            ld          a,e
            ld          (621a),a
            ld          hl,0ffffh
            push        hl
            call        getinfo
            ld          hl,hl1tbl
            ld     bc,hl1tble-hl1tbl
            cpir
            jr          nz,3eff
            ld          de,3ea5
            or          a
            sbc         hl,de
            push        hl
            jp          3d33

hl1tbl      inc         hl
            dec         hl
            jp          (hl)
            ld          sp,hl
            push        hl
            pop         hl
            ex          (sp),hl
hl1tble

            ld          hl,hl2tbl
            ld     bc,hl2tble-hl2tbl
            cpir
            jr          nz,3f36
            ld          de,3f09
            or          a
            sbc         hl,de
            ld          a,l
            cp          2d
            jr          nz,3f16
            ld          l,19
            push        hl
            cp          28
            jr          nc,3f22
            cp          26
            jr          z,3f22
            ld          e,07
            push        de
            call        getinfo
            ld          de,0209
            push        de
            jp          3d33

hl2tbl      add         a,(hl)
            adc         a,(hl)
            sub         (hl)
            sbc         a,(hl)
            and         (hl)
            or          (hl)
            xor         (hl)
            inc         (hl)
            dec         (hl)
            cp          (hl)
hl2tble

            cp          21
            jr          nz,3f4b
            ld          e,18
            push        de
            ld          e,12
            push        de
            call        getinfo
            call        getinfo
            ld          de,021b
            jr          3f28

            cp          2a
            jr          z,3f53
            cp          22
            jr          nz,3f5f
            ld          d,a
            ld          e,18
            push        de
            ld          e,12
            ld          bc,020b
            jp          38f9

            cp          36
            jr          nz,3f75
            call        getinfo
            call        getinfo
            ld          e,18
            push        de
            ld          de,0209
            push        de
            ld          de,031c
            jr          3f49

            ld          e,a
            and         0f8
            cp          70
            ld          a,e
            jr          nz,3f8c
            ld          e,18
            push        de
            ld          de,0209
            push        de
            and         07
            ld          e,a
            call        getinfo
            jr          3f49

            ld          e,a
            and         0cf
            cp          09
            ld          a,e
            jr          nz,3fa2
            ld          e,24
            push        de
            ld          e,12
            push        de
            call        3806
            add         a,10
            ld          e,a
            jr          3f49

            cp          0cb
            jr          nz,3fda
            call        getinfo
            call        getinfo
            ld          e,a
            and         07
            cp          06
            ld          a,e
            jp          nz,3d33
            call        3ed3
            jr          z,3fca
            add         a,39
            ld          e,a
            push        de
            call        377c
            call        3800
            ld          d,a
            ld          e,1d
            push        de
            jr          3fd4

            call        377c
            call        3800
            add         a,31
            ld          e,a
            push        de
            ld          de,0209
            jp          3f49

            ld          e,a
            and         0c7
            cp          46
            jp          nz,3d33
            call        getinfo
            ld          a,e
            ld          e,18
            push        de
            call        3800
            ld          e,a
            push        de
            jr          3fd4

            .end
