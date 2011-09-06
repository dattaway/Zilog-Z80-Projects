;*******************************************************************************
;*Hi-Res Character Generator V1.2z                              Duane P. Attaway
;*6502 Version: 12/1984;   Apple ][+e program
;*Z80 Version:  5/1991;    EDM mini program
;*Update 1:     6/9/1991;  Scroll and Tab routines added
;*Update 2:     6/13/1991; Graphics character cursor added
; <*** Revision: Sun  08-04-1991  at 10:46:30 ***>   ;Mouse support added
;*
;*
;*******************************************************************************
;
;<*** Hardware Interface ***>
ppi         .equ        $8c         ;device used by the keyboard scan routine.
ppia        .equ        ppi
ppib        .equ        ppi+1
ppic        .equ        ppi+2
ppicntrl    .equ        ppi+3

;<*** Hardware Screen Attributes ***>
vidram      .equ        $4000       ;start of video area
vidlen      .equ        $1ff        ;length of text video
grlen       .equ        $17ff       ;length of graphics page
grend       .equ        vidram+grlen;end of graphics page
xlen        .equ        $20         ;maximum x length
ylen        .equ        $18         ;maximum y length

;<*** Graphics Driver Varibles ***>
fontlen     .equ        $08
fontlength  .equ        $100*fontlen
column      .equ        $60b9
row         .equ        $60ba
addr        .equ        $60bb

;<*** Graphing Parameters ***>
windowsize  .equ        5
window      .equ        grend-fontlen*xlen*windowsize
                                    ;menu displayed at the bottom of the screen.
windowbytes .equ        windowsize*fontlen*xlen
                                    ;size of window for cls.
uppergraph  .equ        fontlen*ylen-windowsize*fontlen
                                    ;maximum vertical size in pixels.
winlin1     .equ        (ylen-windowsize)*$100
                                    ;(x,y) coordinates in characters of line# 1.
winlin2     .equ        winlin1+$xlen
winlin3     .equ        winlin2+$xlen
winlin4     .equ        winlin3+$xlen
winlin5     .equ        winlin4+$xlen

;<*** Keyboard Control ***>
repeat      .equ        1000

;8255 CONTROLLER
;   76543210    *** CONTROL WORD ***  --FOR PPICNTRL PORT
;   ≥≥≥≥≥≥≥≥
;   ≥≥≥≥≥≥≥¿ƒƒƒƒPORT C-- 1/INPUT; 0/OUTPUT  (LOWER BITS-PC3-PC0) ø
;   ≥≥≥≥≥≥¿ƒƒƒƒƒPORT B-- 1/INPUT; 0/OUTPUT                       ≥MODE GROUP A
;   ≥≥≥≥≥¿ƒƒƒƒƒƒMODE SELECTION--  0/MODE 0; 1/MODE 1             Ÿ
;   ≥≥≥≥¿ƒƒƒƒƒƒƒPORT C-- 1/INPUT; 0/OUTPUT  (UPPER BITS-PC7-PC4) ø
;   ≥≥≥¿ƒƒƒƒƒƒƒƒPORT A-- 1/INPUT; 0/OUTPUT                       ≥MODE GROUP B
;   ≥≥¿ƒƒƒƒƒƒƒƒƒ⁄MODE SELECTION-- 00 MODE 0, 01 MODE1,           ≥
;   ≥¿ƒƒƒƒƒƒƒƒƒƒ¿                 1x MODE 2                      Ÿ
;   ¿ƒƒƒƒƒƒƒƒƒƒƒ 1= I/O MODE;  2= BSR MODE (BIT-SET-RESET)
;
;   76543210
;   ≥≥≥≥≥≥≥≥
;   ≥≥≥≥≥≥≥¿ƒƒƒƒS/R:  1= SET, 0= RESET
;   ≥≥≥≥¿¡¡ƒƒƒƒƒBIT:  000 BIT0, 001 BIT1, 010 BIT2, 011 BIT3, ECT...
;   ≥¿¡¡ƒƒƒƒƒƒƒƒxxx:  NOT USED, SET TO ZERO
;   ¿ƒƒƒƒƒƒƒƒƒƒƒBSR:  0
;
ppiomode    .equ        10011000b   ;initializing register for the EDM.
bppictrl    .equ        10000000b
cppictrl    .equ        00001000b
keyrows     .equ        00001000b
cppimask    .equ        01000000b
ppigraphic  .equ        11010111b

;<*** ASCII Keyboard Function Codes ***>
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

;<*** ROM Interface ***>
#define     CHROUT      rst         10h
chroutvect  .equ        $6004
command     .equ        $bc6
dflti       .equ        $6018
dflto       .equ        $6019
getchar     .equ        $434
getchrvct   .equ        $6007
par_prn     .equ        $a83
prtc        .equ        $54d
rx          .equ        $9c8
tx          .equ        $9de

;<*** Include Variables ***>
bit8mask    .equ        111b        ;used for bytewise calculations
neg         .equ        -1
nul         .equ        0
waitdelay   .equ        10000       ;prevent keybouncing

;<*** Keyword Jump Vectors ***>
inttable    .equ        $6251
ncint       .equ        inttable
njint       .equ        $ncint+3
nkint       .equ        $njint+3
nlint       .equ        $nkint+3
nnint       .equ        $nlint+3
npint       .equ        $nnint+3
nqint       .equ        $npint+3
nvint       .equ        $nqint+3
nxint       .equ        $nvint+3
nyint       .equ        $nxint+3
nzint       .equ        $nyint+3
n0int       .equ        $nzint+3
n1int       .equ        $n0int+3
n2int       .equ        $n1int+3
n3int       .equ        $n2int+3
n4int       .equ        $n3int+3
n5int       .equ        $n4int+3
n6int       .equ        $n5int+3
n7int       .equ        $n6int+3
n8int       .equ        $n7int+3
n9int       .equ        $n8int+3


;*******************************************************************************
;c_key_vector
;Registers Used:
;This section creates a new command "C" by placing a jump instruction in RAM
;that intercepts a modified jump table.
;*******************************************************************************
;
c           .org        ncint       ;"C" command key intercepting vector.
;           jp          main        ;create a command to run this program.
q           .org        nqint
            jp          exitfont
z           .org        nzint
            jp          cls
l           .org        nlint
            jp          hires_drv

;*******************************************************************************
;EVARIABLESF
;*******************************************************************************
            .org        $6290
fontaddr    .ds         2
fontreserve .dw         font
inverse     .ds         1
rptcnt      .ds         2
rptflag     .ds         1
scanjump    .db         $c3
scantemp    .dw         $a52
tabdat      .ds         1


;*******************************************************************************
;EMAINF
;*******************************************************************************
;
            .org        $6300

;*******************************************************************************
;Estartup Subroutine:F
;Registers Used:
;
;*******************************************************************************
;
startup     call        hires_drv
            call        scanset
            ld          a,return
            CHROUT
            jp          $0bc6

;*******************************************************************************
;Ewaitkey Subroutine:F
;Registers Used:        af.
;Stack Used:            2
;This subroutine simply waits for a key to be pressed.
;*******************************************************************************
;
waitkey     call        scan
            jr          nz,waitkey
            call        gwaitdelay
waitkey2    call        scan
            jr          z,waitkey2
            call        gwaitdelay
            ret

;*******************************************************************************
;waitdelay Subroutine:
;Registers Used:        f & bc.
;Stack Used:            0
;This subroutine produces a small time delay for keyboard debouncing.
;*******************************************************************************
;
gwaitdelay  ld          bc,waitdelay
delaykey    djnz        delaykey
            dec         c
            jr          nz,delaykey
            ret

;*******************************************************************************
;scanset Subroutine:
;Registers Used:
;
;*******************************************************************************
;
scanset     ld          hl,(getchrvct)
            ld          de,getchr
            xor         a
            sbc         hl,de
            jr          z,exitset
            ld          hl,(getchrvct)
            ld          (scantemp),hl
            ld          hl,getchr
            ld          (getchrvct),hl
exitset     ret

;*******************************************************************************
;scandel Subroutine:
;Registers Used:
;
;*******************************************************************************
;
scandel     ld          hl,(scantemp)
            ld          (getchrvct),hl
            ret

;*******************************************************************************
;getchr Subroutine:
;Registers Used:
;
;*******************************************************************************
;
getchr      ld          a,(dflti)
            or          a
            jp          z,getchar
            dec         a
            jp          z,scana
            dec         a
            jp          z,rx
            scf
            ret
scana       push        hl
            ld          hl,repeat
            ld          (rptcnt),hl
            call        togglecurs
            xor         a
            ld          (rptflag),a
getloop     ld          hl,(rptcnt)
            dec         hl
            ld          (rptcnt),hl
            ld          a,h
            or          l
            jr          nz,nextget
            ld          hl,repeat
            ld          (rptcnt),hl
            ld          a,(rptflag)
            or          a
            jr          z,cursoron
cursoroff   xor         a
            ld          (rptflag),a
            call        togglecurs
            jr          nextget
cursoron    ld          a,1
            ld          (rptflag),a
            call        togglecurs
nextget     call        scanjump
            jr          z,getloop
            push        af
            ld          a,(rptflag)
            or          a
            call        z,togglecurs
            pop         af
            pop         hl
            ret

;*******************************************************************************
;togglecurs Subroutine:
;Registers Used:
;
;*******************************************************************************
;
togglecurs  push        hl
            push        bc
            ld          hl,(addr)
            ld          bc,xlen*8
            ld          a,(row)
            cp          ylen-1
            jr          nz,normal
            ld          bc,xlen*6
normal      add         hl,bc
            ld          a,(hl)
            xor         -1
            ld          (hl),a
            pop         bc
            pop         hl
            ret

;*******************************************************************************
;Einitppi Subroutine:F
;Registers Used:        a & c.
;stack used:            0
;This subroutine initializes the ppi controller for keyboard input.
;*******************************************************************************
;
initppi     ld          a,ppiomode  ;write in the control word.
            out         (ppicntrl),a
            ld          a,bppictrl
            out         (ppib),a
            ld          a,cppictrl
            out         (ppic),a
            ld          c,ppib      ;initialize input/output status.
            in          a,(c)       ;important!
            or          cppimask
            out         (c),a
            ret

;*******************************************************************************
;name Subroutine:
;Registers Used:        af, de, & hl.
;Stack Used:            2
;This subroutine prints my name and other credits in the text window.
;*******************************************************************************
;
name        ld          hl,banner
            ld          de,winlin1
            call        setxy
            call        prtstg
            ld          a,return
            call        chrout
            ret

;*******************************************************************************
;cls Subroutine:
;Registers Used:        af, bc, de, & hl.
;Stack Used:            none.
;This subroutine clears out the graphics area, like totally blank.
;Initialization of the driver also occurs here.
;*******************************************************************************
;
cls         ld          a,ppigraphic;initialize screen
            out         (ppib),a
            call        initchr
            ld          bc,grlen    ;clear screen
            ld          de,vidram+1
            ld          hl,vidram
            ld          a,nul
            ld          (hl),a
            ldir
            ld          de,nul      ;set screen position
            call        setxy
            ret


;*******************************************************************************
;initchr Subroutine:
;Registers Used:
;
;*******************************************************************************
;
initchr     ld          hl,(chroutvect)
            ld          de,chrout
            xor         a
            sbc         hl,de
            jr          z,noinit
            ld          hl,(chroutvect)
            ld          (fontreserve),hl
            ld          hl,chrout   ;initialize vector
            ld          (chroutvect),hl
noinit      ld          a,4         ;set autoexec
            ld          b,1
            ld          de,startup
            rst         08h
            ret

;*******************************************************************************
;clrwin Subroutine:
;Registers Used:        af, bc, de, & hl.
;Stack Used:            2
;This subroutine clears out the lower text window and repositions the cursor
;at the top of that text window.
;*******************************************************************************
;
clrwin      ld          bc,windowbytes
            ld          de,window+1
            ld          hl,window
            ld          a,nul
            ld          (hl),a
            ldir
            ld          de,winlin1
            call        setxy
            ret

;*******************************************************************************
;hires_drv Subroutine:
;Registers Used:        hl.
;Stack Used:            0
;This subroutine initializes the character generator for proper operation.
;*******************************************************************************
;
hires_drv   call        initchr
            ld          hl,font
            ld          (fontaddr),hl
            xor         a
            ld          (inverse),a
            ld          a,ppigraphic
            out         (ppib),a
            call        scanset
            ret

;*******************************************************************************
;pix Subroutine:
;Registers Used:        af, bc, de, & hl.
;Stack Used:            8
;This subroutine will plot on an x,y grid with the origin at the lower left hand
;window.  A-register is the x-coordinate, B-register holds the y-coordinate.
;*******************************************************************************
;
pix         push        af
            push        bc
            push        de
            push        hl
            inc         b
            ld          c,a         ;save the x-coordinate.
            srl         a           ;divide by 8 -- pixel to bit conversion.
            srl         a
            srl         a
            ld          hl,window+1 ;reference one line below lower left corner.
            add         a,l         ;locate pointer address to x coordinate.
            ld          l,a
            ld          a,nul
            adc         a,h
            ld          h,a         ;x-coordinate now calculated for row-0.
            ld          de,xlen     ;now calculate y-coordinate.
            xor         a
            ld          a,b
xloop       sbc hl,de               ;recursively calculate y-offset.
            djnz        xloop
            ld          a,c         ;now mask in the pixel.
            and         bit8mask
            ld          b,a
            xor         a
            scf
            inc         b
yloop       rra                     ;recursively find the pixel bit.
            djnz        yloop
            ld          b,(hl)      ;filter in the previous pixels and save.
            or          b
            ld          (hl),a
            pop         hl
            pop         de
            pop         bc
            pop         af
            ret

;*******************************************************************************
;calc_addr Subroutine:
;Registers Used:        af, bc, & hl.
;Stack Used:            6
;         --this subroutine calculates the address for the coordinates in the
;           defined space xypos and xpos.  the result is returned in addr.
;
;*******************************************************************************
;
calc_addr   push        af
            push        bc
            push        hl
            ld          a,(row)
            ld          l,a
            ld          h,0
            add         hl,hl       ;*2  calculate y position
            add         hl,hl       ;*4
            add         hl,hl       ;*8
            add         hl,hl       ;*16
            add         hl,hl       ;*32
            add         hl,hl       ;*2  skip 8+4 scan lines
            add         hl,hl       ;*4
            add         hl,hl       ;*8
            ld          a,(column)
            add         a,l
            ld          l,a
            ld          bc,vidram
            add         hl,bc
            ld          (addr),hl
            pop         hl
            pop         bc
            pop         af
            ret

;*******************************************************************************
;setxy Subroutine:
;Registers Used:        de.
;Stack Used:            2
;This subroutine takes the DE-Register pair to set the (x,y) screen character
;coordinates for the chrout driver.
;*******************************************************************************
;
setxy       ld          (column),de ;store the coordinates.
            call        calc_addr   ;calculate the screen address and store it.
            ret

;*******************************************************************************
;prtstg Subroutine:
;Registers Used:        af & hl.
;Stack Used:            2
;This subroutine prints out a string of text terminated by a nul character.
;*******************************************************************************
;
prtstg      call        calc_addr
nextstr     ld          a,(hl)
            or          a
            ret         z
            CHROUT
            inc         hl
            jr          nextstr

;*******************************************************************************
;chrout Subroutine:
;Registers Used:        af, bc, de, & hl.
;Stack Used:            10
;      --   this routine takes the a-reg character and places it at the current
;           graphics position. cls must be called before this routine is used.
;*******************************************************************************
;
chrout      push        af
            ld          a,(dflto)
            or          a
            jr          z,prtcg
            cp          $2
            jp          z,tx
            cp          $4
            jp          z,par_prn
            pop         af
            scf
            ret
prtcg       pop         af
            push        af
            push        bc
            push        de
            push        hl
            call        calc_addr
            cp          space       ;check if it is a control character.
            jr          c,grcontrol
            call        calc_font
            ld          de,(addr)   ;get the current graphic video address.
            ld          c,a
            ld          a,(inverse)
            or          a
            ld          a,c
            jr          nz,out2
            call        out_font    ;draw the font image to the graphic screen.
            jr          nextout
out2        call        out_fonti   ;draw the font image in inverse.
nextout     call        xinc
            pop         hl
            pop         de
            pop         bc
            pop         af
            ret
grcontrol   call        controlmv   ;do the control function.
            pop         hl
            pop         de
            pop         bc
            pop         af
            ret

;*******************************************************************************
;xdec Subroutine:
;Registers Used:        af & hl.
;Stack Used:            2
;This subroutine handles the character when it is moved to the left.  This
;soubroutine will fixup the position if it travels beyond screen boundries to
;"wrap" around the edges.
;*******************************************************************************
;
xdecback    call        xdec
            ld          a,space
            call        chrout
xdec        ld          a,(column)  ;advance character left.
            dec         a
            ld          (column),a
            cp          neg
            jr          nz,qdfixexit
eol         ld          a,xlen-1    ;fix character to right on next line:
            ld          (column),a
ydec        ld          a,(row)     ;advance character up.
            dec         a
            ld          (row),a
            cp          neg
            jr          nz,dfixexit
            ld          a,ylen+neg  ;fix character to bottom of the screen.
            ld          (row),a
dfixexit    call        calc_addr
            ret
qdfixexit   ld          hl,addr
            dec         (hl)
            ret


;*******************************************************************************
;controlmv Subroutine:
;Registers Used:        af.
;Stack Used:            2
;This subroutine dispatches any A-Register control characters if any are
;encountered.
;*******************************************************************************
;
controlmv   cp          return      ;carriage return
            jp          z,returnln
            cp          left        ;left arrow
            jp          z,xdec
            cp          backspace   ;backspace
            jp          z,xdecback
            cp          up          ;up arrow
            jp          z,ydec
            cp          down        ;down arrow
            jp          z,yinc
            cp          right       ;right arrow
            jp          z,xinc
            cp          ctrlb       ;set tabs
            jp          z,settab
            cp          ctrla       ;tab
            jp          z,dotab
            cp          tab         ;clear screen
            jp          z,cls
            cp          ctrlc       ;clear window
            jp          z,clrwin
            cp          ctrlz       ;clear to end of line
            jp          z,clreol
            cp          ctrli       ;inverse
            jp          z,doinverse
            cp          ctrln       ;normal
            jp          z,donormal
            cp          ctrlw
            jp          z,doupfont
            cp          ctrlq
            jp          z,dodnfont
            cp          ctrle
            jp          z,exitfont
exit        ret

;*******************************************************************************
;exitfont Subroutine:
;Registers Used:
;
;*******************************************************************************
;
exitfont    ld          hl,(fontreserve)
            ld          (chroutvect),hl
            call        initppi
            ld          de,nul
            call        setxy
            ld          hl,vidram
            ld          bc,vidlen
            ld          de,vidram+1
            ld          (hl),space
            ldir
            ld          a,2
            CHROUT
            call        scandel
            ret

;*******************************************************************************
;xinc Subroutine:
;Registers Used:        af & hl.
;Stack Used:            2
;This subroutine manages the character position and address on the graphics
;screen.  This subroutine is called after a character is placed on the screen to
;manage the next character's destiny.  An attempt to place the character one
;space to the right is made if possible.  If it spills over into the next line,
;corrections have to be made.  If controlling characters are entered, action
;will be performed on the coordinates.
;*******************************************************************************
;
xinc        ld          a,(column)  ;advance character right.
            inc         a
            ld          (column),a
            cp          xlen
            jr          c,qfixexit
returnln    xor         a           ;fix character to left on next line:
            ld          (column),a
yinc        ld          a,(row)     ;advance character down.
            inc         a
            ld          (row),a
            cp          ylen
            jr          c,fixexit
            dec         a           ;fix character at bottom of the screen.
            ld          (row),a
            call        scrollup
            ld          a,(inverse)
            or          a
            jr          z,doblank
            ld          a,neg
doblank     ld          hl,grend-(8*xlen)-1
            ld          b,nul
blankbottom ld          (hl),a
            inc         hl
            djnz        blankbottom
fixexit     call        calc_addr
            ret
qfixexit    ld          hl,addr
            inc         (hl)
            ret

;*******************************************************************************
;doupfont Subroutine:
;Registers Used:
;
;*******************************************************************************
;
doupfont    ld          hl,(fontaddr)
            ld          de,fontlength
            add         hl,de
            ld          (fontaddr),hl
            ret

;*******************************************************************************
;dodnfont Subroutine:
;Registers Used:
;
;*******************************************************************************
;
dodnfont    ld          hl,(fontaddr)
            ld          de,fontlength
            xor         a
            sbc         hl,de
            ld          (fontaddr),hl
            ret

;*******************************************************************************
;doinverse Subroutine:
;Registers Used:
;
;*******************************************************************************
;
doinverse   ld          a,neg
            ld          (inverse),a
            ret

;*******************************************************************************
;donormal Subroutine:
;Registers Used:
;
;*******************************************************************************
;
donormal    ld          a,nul
            ld          (inverse),a
            ret

;*******************************************************************************
;scrollup Subroutine:
;Registers Used:
;
;*******************************************************************************
;
scrollup    ld          hl,vidram+(xlen*8)
            ld          de,vidram
            ld          bc,xlen*8
nextscrl    push        bc          ;move line
            ldir
            pop         bc
            push        hl          ;check end
            push        bc
            ld          bc,grend
            xor         a
            dec         hl
            sbc         hl,bc
            pop         bc
            pop         hl
            jr          nz,nextscrl
            ret
 
;*******************************************************************************
;settab Subroutine:
;Registers Used:
;
;*******************************************************************************
;
settab      ld          a,(column)
            ld          (tabdat),a
            ret

;*******************************************************************************
;dotab Subroutine:
;Registers Used:
;
;*******************************************************************************
;
dotab       ld          a,(tabdat)
            ld          (column),a
            call        calc_addr
            ret

;*******************************************************************************
;clreol Subroutine:
;Registers Used:
;
;*******************************************************************************
;
clreol      ld          a,xlen
            ld          hl,column
            sub         (hl)
            jr          z,endclreol
            ld          b,a
            ld          c,a
            ld          a,space
fillspace   call        chrout
            djnz        fillspace
            ld          b,c
            ld          a,left
backspacef  call        chrout
            djnz        backspacef
endclreol   ret

;*******************************************************************************
;calc_font Subroutine:
;Registers Used:        af, bc, & hl.
;Stack Used:            none.
;This subroutine calculates the 8x8 font pointed to by a-Register.  Pointer is
;returned in hl_Register.
;*******************************************************************************
;

calc_font   ld          l,a
            ld          h,nul         ;calculate the font address:
            add         hl,hl         ;skip over to the font character pointed to
            add         hl,hl         ;by a-register (a font is 8x8, so multiply by 8).
            add         hl,hl
            ld          bc,(fontaddr) ;add the offset to get the corrected font address.
            add         hl,bc
            ret

;*******************************************************************************
;out_font Subroutine:
;Registers Used:        af, bc, de, & hl.
;Stack Used:            none.
;This subroutine builds a font image pointed to by hl_Register to the graphics
;screen pointed to by de_Register.
;*******************************************************************************
;
out_font    ld          bc,xlen     ;quick adding variable to skip video lines.
            ex          de,hl
            ld          a,(de)      ;fetch a font row.
            ld          (hl),a      ;place it in video memory to build font image.
            add         hl,bc       ;get on down to the next row.
            inc         de          ;get next font image.
            ld          a,(de)      ;font line# 2
            ld          (hl),a
            add         hl,bc
            inc         de
            ld          a,(de)      ;font line# 3
            ld          (hl),a
            add         hl,bc
            inc         de
            ld          a,(de)      ;font line# 4
            ld          (hl),a
            add         hl,bc
            inc         de
            ld          a,(de)      ;font line# 5
            ld          (hl),a
            add         hl,bc
            inc         de
            ld          a,(de)      ;font line# 6
            ld          (hl),a
            add         hl,bc
            inc         de
            ld          a,(de)      ;font line# 7
            ld          (hl),a
            add         hl,bc
            inc         de
            ld          a,(de)      ;font line# 8
            ld          (hl),a
            ex          de,hl
            ret

;*******************************************************************************
;out_fonti Subroutine:
;Registers Used:        af, bc, de, & hl.
;Stack Used:            none.
;This subroutine builds a inverse font image pointed to by hl_Register to the
;graphics screen pointed to by de_Register.
;*******************************************************************************
;
out_fonti   ld          bc,xlen     ;quick adding variable to skip video lines.
            ex          de,hl
            ld          a,(de)      ;fetch a font row.
            xor         $ff
            ld          (hl),a      ;place it in video memory to build font image.
            add         hl,bc       ;get on down to the next row.
            inc         de          ;get next font image.
            ld          a,(de)      ;font line# 2
            xor         $ff
            ld          (hl),a
            add         hl,bc
            inc         de
            ld          a,(de)      ;font line# 3
            xor         $ff
            ld          (hl),a
            add         hl,bc
            inc         de
            ld          a,(de)      ;font line# 4
            xor         $ff
            ld          (hl),a
            add         hl,bc
            inc         de
            ld          a,(de)      ;font line# 5
            xor         $ff
            ld          (hl),a
            add         hl,bc
            inc         de
            ld          a,(de)      ;font line# 6
            xor         $ff
            ld          (hl),a
            add         hl,bc
            inc         de
            ld          a,(de)      ;font line# 7
            xor         $ff
            ld          (hl),a
            add         hl,bc
            inc         de
            ld          a,(de)      ;font line# 8
            xor         $ff
            ld          (hl),a
            ex          de,hl
            ret

;*******************************************************************************
;Escan Subroutine:F
;Registers Used:        af, bc, & d.
;Stack Used:            6
;This subroutine polls the keyboard and if any keys are pressed, an appropriate
;ASCII code is returned.  A nul character is returned if no keys are pressed.
;*******************************************************************************
;
scan        push        bc
            ld          c,ppic
            ld          b,keyrows   ;Initialize the ROW number.
sloop       dec         b
            out         (c),b       ;Turn on the ROW.
            in          a,(ppia)
            cp          neg         ;See if no keys were pressed.
            jr          nz,encode   ;Found one, see what i'is.
            dec         b           ;keep on searching all of the rows.
            inc         b
            jr          nz,sloop
            pop         bc          ;leave if nothing was found.
            xor         a
            ret
encode      push        bc          ;B and C cannot be messed up; we'll save 'em.
            ld          c,nul        ;B carries the row, A carries the column,
nextcolumn  rrca                    ;and C holds the key entry table number.
            jr          nc,found_col
            inc         c
            jr          nextcolumn
found_col   ld          a,c
next_row    inc         b           ;Search for additional keys
            push        de
            ld          d,a
            ld          a,b
            cp          keyrows
            ld          a,d
            pop         de
            jr          z,got_it
            add         a,keyrows
            jr          next_row
got_it      ld          bc,asciit   ;get the ASCII character number from the table.
            add         a,c
            ld          c,a
            ld          a,nul
            adc         a,b
            ld          b,a
            ld          a,(bc)
            pop         bc
            pop         bc
            ret

;*******************************************************************************
;DATA AREA
;*******************************************************************************
;

;<*** Keyboard ASCII Locations ***>
asciit      .db            32H, 51H, 20H, 20H     ;2  Q
            .db            03H, 00H, 0CH, 31H     ;.  .  .  1
            .db            34H, 45H, 53H, 5AH     ;4  E  S  Z
            .db            00H, 41H, 57H, 33H     ;.  A  W  3
            .db            36H, 54H, 46H, 43H     ;6  T  F  C
            .db            58H, 44H, 52H, 35H     ;X  D  R  5
            .db            38H, 55H, 48H, 42H     ;8  U  H  B
            .db            56H, 47H, 59H, 37H     ;V  G  Y  7
            .db            30H, 4FH, 4BH, 4DH     ;0  O  K  M
            .db            4EH, 4AH, 49H, 39H     ;N  J  I  9
            .db            1CH, 2DH, 3AH, 2EH     ;.  -  :  .
            .db            2CH, 4CH, 50H, 1AH     ;,  L  P  .
            .db            09H, 2BH, 3DH, 1BH     ;.  +  =  .
            .db            2FH, 3BH, 2AH, 18H     ;/  ;  *  .
            .db            00H, 00H, 00H, 00H     ;.  .  .  .
            .db            40H, 5CH, 0DH, 08H     ;@  \  .  .
            
font
;font 1 -- 8x8 compact "zx81" style font; full ascii 8-bit code.
            .db        0f0h,0f0h,0f0h,0f0h,000h,000h,000h,000h  ;0    ul square
            .db        00fh,00fh,00fh,00fh,000h,000h,000h,000h  ;1    ur square
            .db        0ffh,0ffh,0ffh,0ffh,000h,000h,000h,000h  ;2    u rectangle
            .db        000h,000h,000h,000h,0f0h,0f0h,0f0h,0f0h  ;3    ll square
            .db        0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h  ;4    l rectangle
            .db        00fh,00fh,00fh,00fh,0f0h,0f0h,0f0h,0f0h  ;5    ll ur squares
            .db        0ffh,0ffh,0ffh,0ffh,0f0h,0f0h,0f0h,0f0h  ;6    ll ul ur sqr
            .db        0aah,055h,0aah,055h,0aah,055h,0aah,055h  ;7    grey
            .db        000h,000h,000h,000h,0aah,055h,0aah,055h  ;8    l grey
            .db        0aah,055h,0aah,055h,000h,000h,000h,000h  ;9    u grey
            .db        000h,01ch,022h,078h,020h,020h,07eh,000h  ;10   pound
            .db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh  ;11   white space
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  ;12
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  ;13
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  ;14
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  ;15
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  ;16
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  ;17
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  ;18
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  ;19
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  ;20
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  ;21
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  ;22
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  ;23
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  ;24
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  ;25
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  ;26
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  ;27
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  ;28
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  ;29
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  ;30
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  ;31
            .db         00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h  ;32       space
            .db        010h,010h,010h,010h,010h,000h,010h,000h  ;33      !
            .db        000h,024h,024h,000h,000h,000h,000h,000h  ;34      "
            .db        000h,024h,07eh,024h,024h,07eh,024h,000h  ;35      #
            .db        000h,008h,03eh,028h,03eh,00ah,03eh,008h  ;36      $
            .db        000h,062h,064h,008h,010h,026h,046h,000h  ;37      %
            .db        010h,028h,010h,02ah,024h,02ah,010h,000h  ;38      &
            .db        000h,008h,008h,010h,000h,000h,000h,000h  ;39      '
            .db        000h,004h,008h,008h,008h,008h,004h,000h  ;40      (
            .db        000h,020h,010h,010h,010h,010h,020h,000h  ;41      )
            .db        000h,000h,014h,008h,03eh,008h,014h,000h  ;42      *
            .db        000h,000h,008h,008h,03eh,008h,008h,000h  ;43      +
            .db        000h,000h,000h,000h,000h,008h,008h,010h  ;44      ,
            .db        000h,000h,000h,000h,03eh,000h,000h,000h  ;45      -
            .db        000h,000h,000h,000h,000h,018h,018h,000h  ;46      .
            .db        000h,000h,002h,004h,008h,010h,020h,000h  ;47      /
            .db        000h,03ch,046h,04ah,052h,062h,03ch,000h  ;48      0
            .db        000h,018h,028h,008h,008h,008h,03eh,000h  ;49      1
            .db        000h,03ch,042h,002h,03ch,040h,07eh,000h  ;50      2
            .db        000h,03ch,042h,00ch,002h,042h,03ch,000h  ;51      3
            .db        000h,008h,018h,028h,048h,07eh,008h,000h  ;52      4
            .db        000h,07eh,040h,07ch,002h,042h,03ch,000h  ;53      5
            .db        000h,03ch,040h,07ch,042h,042h,03ch,000h  ;54      6
            .db        000h,07eh,002h,004h,008h,010h,010h,000h  ;55      7
            .db        000h,03ch,042h,03ch,042h,042h,03ch,000h  ;56      8
            .db        000h,03ch,042h,042h,03eh,002h,03ch,000h  ;57      9
            .db        000h,000h,000h,010h,000h,000h,010h,000h  ;58      :
            .db        000h,000h,010h,000h,000h,010h,010h,020h  ;59      ;
            .db        000h,000h,004h,008h,010h,008h,004h,000h  ;60      <
            .db        000h,000h,000h,03eh,000h,03eh,000h,000h  ;61      =
            .db        000h,000h,010h,008h,004h,008h,010h,000h  ;62      >
            .db        000h,03ch,042h,004h,008h,000h,008h,000h  ;63      ?
            .db        000h,03ch,002h,03ah,02ah,03ah,042h,03ch  ;64      @
            .db        000h,03ch,042h,042h,07eh,042h,042h,000h  ;65      a
            .db        000h,07ch,042h,07ch,042h,042h,07ch,000h  ;66      b
            .db        000h,03ch,042h,040h,040h,042h,03ch,000h  ;67      c
            .db        000h,078h,044h,042h,042h,044h,078h,000h  ;68      d
            .db        000h,07eh,040h,07ch,040h,040h,07eh,000h  ;69      e
            .db        000h,07eh,040h,07ch,040h,040h,040h,000h  ;70      f
            .db        000h,03ch,042h,040h,04eh,042h,03ch,000h  ;71      g
            .db        000h,042h,042h,07eh,042h,042h,042h,000h  ;72      h
            .db        000h,03eh,008h,008h,008h,008h,03eh,000h  ;73      i
            .db        000h,002h,002h,002h,042h,042h,03ch,000h  ;74      j
            .db        000h,044h,048h,070h,048h,044h,042h,000h  ;75      k
            .db        000h,040h,040h,040h,040h,040h,07eh,000h  ;76      l
            .db        000h,042h,066h,05ah,042h,042h,042h,000h  ;77      m
            .db        000h,042h,062h,052h,04ah,046h,042h,000h  ;78      n
            .db        000h,03ch,042h,042h,042h,042h,03ch,000h  ;79      o
            .db        000h,07ch,042h,042h,07ch,040h,040h,000h  ;80      p
            .db        000h,03ch,042h,042h,052h,04ah,03ch,000h  ;81      q
            .db        000h,07ch,042h,042h,07ch,044h,042h,000h  ;82      r
            .db        000h,03ch,040h,03ch,002h,042h,03ch,000h  ;83      s
            .db        000h,0feh,010h,010h,010h,010h,010h,000h  ;84      t
            .db        000h,042h,042h,042h,042h,042h,03ch,000h  ;85      u
            .db        000h,042h,042h,042h,042h,024h,018h,000h  ;86      v
            .db        000h,042h,042h,042h,042h,05ah,024h,000h  ;87      w
            .db        000h,042h,024h,018h,018h,024h,042h,000h  ;88      x
            .db        000h,082h,044h,028h,010h,010h,010h,000h  ;89      y
            .db        000h,07eh,004h,008h,010h,020h,07eh,000h  ;90      z
            .db        000h,038h,020h,020h,020h,020h,020h,038h  ;91      [
            .db        000h,040h,020h,010h,008h,004h,002h,000h  ;92      \
            .db        000h,038h,008h,008h,008h,008h,008h,038h  ;93      ]
            .db        000h,010h,028h,044h,000h,000h,000h,000h  ;94      ^
            .db        000h,000h,000h,000h,000h,000h,000h,0ffh  ;95      _
            .db        000h,010h,010h,008h,000h,000h,000h,000h  ;96      `
            .db        000h,000h,03ch,002h,03eh,042h,03eh,000h  ;97      a
            .db        040h,040h,07ch,042h,042h,042h,07ch,000h  ;98      b
            .db        000h,000h,03ch,042h,040h,042h,03ch,000h  ;99      c
            .db        002h,002h,03eh,042h,042h,042h,03eh,000h  ;100     d
            .db        000h,000h,03ch,042h,07eh,040h,03eh,000h  ;101     e
            .db        018h,024h,020h,070h,020h,020h,020h,000h  ;102     f
            .db        000h,000h,03ch,042h,042h,03eh,002h,03ch  ;103     g
            .db        0c0h,040h,07ch,042h,042h,042h,042h,000h  ;104     h
            .db        010h,000h,030h,010h,010h,010h,038h,000h  ;105     i
            .db        010h,000h,030h,010h,010h,010h,050h,020h  ;106     j
            .db        040h,040h,048h,050h,060h,050h,048h,000h  ;107     k
            .db        030h,010h,010h,010h,010h,010h,038h,000h  ;108     l
            .db        000h,000h,036h,049h,049h,049h,049h,000h  ;109     m
            .db        000h,000h,0bch,042h,042h,042h,042h,000h  ;110     n
            .db        000h,000h,03ch,042h,042h,042h,03ch,000h  ;111     o
            .db        000h,000h,03ch,042h,042h,07ch,040h,040h  ;112     p
            .db        000h,000h,03ch,042h,042h,03eh,002h,003h  ;113     q
            .db        000h,000h,05ch,020h,020h,020h,020h,000h  ;114     r
            .db        000h,000h,03eh,040h,03ch,002h,07ch,000h  ;115     s
            .db        000h,010h,038h,010h,010h,010h,018h,000h  ;116     t
            .db        000h,000h,042h,042h,042h,042h,03eh,000h  ;117     u
            .db        000h,000h,044h,044h,044h,028h,010h,000h  ;118     v
            .db        000h,000h,044h,044h,054h,054h,028h,000h  ;119     w
            .db        000h,000h,044h,028h,010h,028h,044h,000h  ;120     x
            .db        000h,000h,042h,042h,042h,03eh,002h,07ch  ;121     y
            .db        000h,000h,07eh,004h,018h,020h,07eh,000h  ;122     z
            .db        000h,008h,010h,010h,020h,010h,010h,008h  ;123     {
            .db        010h,010h,010h,010h,010h,010h,010h,010h  ;124     |
            .db        000h,020h,010h,010h,008h,010h,010h,020h  ;125     }
            .db        000h,000h,020h,054h,008h,000h,000h,000h  ;126     ~
            .db        000h,000h,000h,000h,000h,000h,000h,0ffh  ;127  underline
            .db        0f0h,0f0h,0f0h,0f0h,000h,000h,000h,000h  ;128  ul square
            .db        00fh,00fh,00fh,00fh,000h,000h,000h,000h  ;129  ur square
            .db        0ffh,0ffh,0ffh,0ffh,000h,000h,000h,000h  ;130  u rectangle
            .db        000h,000h,000h,000h,0f0h,0f0h,0f0h,0f0h  ;131  ll square
            .db        0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h  ;132  l rectangle
            .db        00fh,00fh,00fh,00fh,0f0h,0f0h,0f0h,0f0h  ;133  ll ur squares
            .db        0ffh,0ffh,0ffh,0ffh,0f0h,0f0h,0f0h,0f0h  ;134  ll ul ur sqr
            .db        0aah,055h,0aah,055h,0aah,055h,0aah,055h  ;135  grey
            .db        000h,000h,000h,000h,0aah,055h,0aah,055h  ;136  l grey
            .db        0aah,055h,0aah,055h,000h,000h,000h,000h  ;137  u grey
            .db        000h,01ch,022h,078h,020h,020h,07eh,000h  ;138  pound
            .db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh  ;139  white space
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;140   å
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;141   ç
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;142   é
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;143   è
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;144   ê
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;145   ë
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;146   í
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;147   ì
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;148   î
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;149   ï
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;150   ñ
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;151   ó
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;152   ò
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;153   ô
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;154   ö
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;155   õ
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;156   ú
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;157   ù
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;158   û
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;159   ü
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;160   †
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;161   °
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;162   ¢
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;163   £
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;164   §
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;165   •
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;166   ¶
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;167   ß
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;168   ®
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;169   ©
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;170   ™
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;171   ´
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;172   ¨
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;173   ≠
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;174   Æ
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;175   Ø
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;176   ∞
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;177   ±
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;178   ≤
            .db         $10, $10, $10, $10, $10, $10, $10, $10  ;179   ≥
            .db         $10, $10, $10, $30, $10, $10, $10, $10  ;180   ¥
            .db         $10, $10, $f0, $10, $f0, $10, $10, $10  ;181   µ
            .db         $28, $28, $28, $e8, $28, $28, $28, $28  ;182   ∂
            .db         $00, $00, $00, $f8, $28, $28, $28, $28  ;183   ∑
            .db         $00, $00, $f0, $10, $f0, $10, $10, $10  ;184   ∏
            .db         $28, $28, $e8, $08, $e8, $28, $28, $28  ;185   π
            .db         $28, $28, $28, $28, $28, $28, $28, $28  ;186   ∫
            .db         $00, $00, $f8, $08, $e8, $28, $28, $28  ;187   ª
            .db         $28, $28, $e8, $08, $f8, $00, $00, $00  ;188   º
            .db         $28, $28, $28, $f8, $00, $00, $00, $00  ;189   Ω
            .db         $10, $10, $f0, $10, $f0, $00, $00, $00  ;190   æ
            .db         $00, $00, $00, $f0, $10, $10, $10, $10  ;191   ø
            .db         $10, $10, $10, $1f, $00, $00, $00, $00  ;192   ¿
            .db         $10, $10, $10, $ff, $00, $00, $00, $00  ;193   ¡
            .db         $00, $00, $00, $ff, $10, $10, $10, $10  ;194   ¬
            .db         $10, $10, $10, $1f, $10, $10, $10, $10  ;195   √
            .db         $00, $00, $00, $ff, $00, $00, $00, $00  ;196   ƒ
            .db         $10, $10, $10, $ff, $10, $10, $10, $10  ;197   ≈
            .db         $10, $10, $1f, $10, $1f, $10, $10, $10  ;198   ∆
            .db         $28, $28, $28, $2f, $28, $28, $28, $28  ;199   «
            .db         $28, $28, $2f, $20, $3f, $00, $00, $00  ;200   »
            .db         $00, $00, $3f, $20, $2f, $28, $28, $28  ;201   …
            .db         $28, $28, $ef, $00, $ff, $00, $00, $00  ;202    
            .db         $00, $00, $ff, $00, $ef, $28, $28, $28  ;203   À
            .db         $28, $28, $2f, $20, $2f, $28, $28, $28  ;204   Ã
            .db         $00, $00, $ff, $00, $ff, $00, $00, $00  ;205   Õ
            .db         $28, $28, $ef, $00, $ef, $28, $28, $28  ;206   Œ
            .db         $10, $10, $ff, $00, $ff, $00, $00, $00  ;207   œ
            .db         $28, $28, $ff, $00, $00, $00, $00, $00  ;208   –
            .db         $00, $00, $ff, $00, $ff, $28, $28, $28  ;209   —
            .db         $00, $00, $ff, $28, $28, $28, $28, $28  ;210   “
            .db         $28, $28, $28, $28, $3f, $00, $00, $00  ;211   ”
            .db         $10, $10, $1f, $10, $1f, $00, $00, $00  ;212   ‘
            .db         $00, $00, $1f, $10, $1f, $10, $10, $10  ;213   ’
            .db         $00, $00, $3f, $28, $28, $28, $28, $28  ;214   ÷
            .db         $28, $28, $ff, $28, $28, $28, $28, $28  ;215   ◊
            .db         $10, $10, $ff, $10, $ff, $10, $10, $10  ;216   ÿ
            .db         $10, $10, $10, $f0, $00, $00, $00, $00  ;217   Ÿ
            .db         $00, $00, $00, $1f, $10, $10, $10, $10  ;218   ⁄
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;219   €
            .db         $00, $00, $00, $00, $ff, $ff, $ff, $ff  ;210   ‹
            .db         $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0  ;221   ›
            .db         $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f  ;222   ﬁ
            .db         $ff, $ff, $ff, $ff, $00, $00, $00, $00  ;223   ﬂ
            .db         $00, $00, $00, $00, $00, $00, $00, $00  ;224
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;225   ·
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;226   ‚
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;227   „
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;228   ‰
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;229   Â
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;230   Ê
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;231   Á
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;232   Ë
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;233   È
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;234   Í
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;235   Î
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;236   Ï
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;237   Ì
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;238   Ó
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;239   Ô
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;240   
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;241   Ò
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;242   Ú
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;243   Û
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;244   Ù
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;245   ı
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;246   ˆ
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;247   ˜
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;248   ¯
            .db         $00, $00, $28, $28, $00, $00, $00, $00  ;249   ˘
            .db         $00, $00, $00, $10, $00, $00, $00, $00  ;250   ˙
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;251   ˚
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;252   ¸
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;253   ˝
            .db         $00, $7e, $7e, $7e, $7e, $7e, $7e, $00  ;254   ˛
            .db         $00, $00, $00, $00, $00, $00, $00, $00  ;255

;*******************************************************************************
;
;<*** Help Screens ***>
;                        01234567890abcdef0123456789abcde
banner      .text       "Hi-Res Character Generator v1.0z"
            .text       "  5/31/91 by Duane P. Attaway   "
            .text       "       EDM mini version\000"
            .text       "Press any key to continue . . .\000"

            .export     calc_addr
            .export     chrout
            .export     clreol
            .export     clrwin
            .export     cls
            .export     doinverse
            .export     donormal
            .export     dotab
            .export     exitfont
            .export     getchr
            .export     hires_drv
            .export     initppi
            .export     name
            .export     pix
            .export     prtstg
            .export     returnln
            .export     scan
            .export     scandel
            .export     scanset
            .export     settab
            .export     setxy
            .export     togglecurs
            .export     waitkey
            .export     xdec
            .export     xdecback
            .export     xinc
            .export     ydec
            .export     yinc

            .end
