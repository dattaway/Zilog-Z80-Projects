;G*******************************************************************************
;*LAB5.ASM                                                                     *
;*                          ADC Digital Sampling Scope                         *
;*                                     04                                      *
;*                               Duane P. Attaway                              *
;*                               6DA-EET 484-5/23                              *
;*                                                                             *
;*      This program impliments a simple digital storage oscilliscope          *
;*      through the use of a peripherial ADC.  Sweep time is adjustable        *
;*      through the keyboard menu interface.                                   *
;*                                                                             *
;*                                                                             *
;*                                                                             *
;*                                                                             *
;*******************************************************************************

;<*** Hardware Interface ***>
adc         .equ        $00
dac         .equ        $01

;<*** Graphing Parameters ***>
windowsize  .equ        $05         ;number of text lines in the window.
leftgraph   .equ        $08         ;width in pixels of the ordinate.
lowergraph  .equ        $00         ;offset in pixels of the abcissa.
rightgraph  .equ        $ff         ;maximum horizontal width in pixels.
;*******************************************************************************
;*Hi-Res Character Generator V1.1z                              Duane P. Attaway
;*6502 Version: 12/1984;  Apple ][+e program
;*Z80 Version:  5/1991;   EDM mini program
;*Update 1:     6/9/1991; Scroll and Tab routines added
;*
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
tab         .equ        $c
return      .equ        $0d
left        .equ        $18
right       .equ        $19
up          .equ        $1c
down        .equ        $1a
backspace   .equ        $08
esc         .equ        $1b
space       .equ        $20

;<*** ROM Interface ***>
#define     CHROUT      rst         10h
command     .equ        $bc6
chroutvect  .equ        $6004

;<*** Include Variables ***>
nul         .equ        0
neg         .equ        -1
bit8mask    .equ        111b        ;used for bytewise calculations
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
            jp          main        ;create a command to run this program.
q           .org        nqint
            jp          exitfont
z           .org        nzint
            jp          cls
l           .org        nlint
            jp          hires_drv

;******************************************************************************* jp          waitkeyx
;VARIABLES
;*******************************************************************************
tabdat      .block      1
fontaddr    .block      2
inverse     .block      1
fontreserve .block      2


;*******************************************************************************
;MAIN
;*******************************************************************************
;
calc_addr   jp          calc_addrx
chrout      jp          chroutx
clreol      jp          clreolx
clrwin      jp          clrwinx
cls         jp          clsx
doinverse   jp          doinversex
donormal    jp          donormalx
doreturn    jp          returnln
dotab       jp          dotabx
exitfont    jp          exitfontx
hires_drv   jp          hires_drvx
initppi     jp          initppix
name        jp          namex
pix         jp          pixx
prtstg      jp          prtstgx
settab      jp          settabx
setxy       jp          setxyx
waitkey     jp          waitkeyx
xdec        jp          xdecx
xdecstrc    jp          xdecback
xinc        jp          xincx
ydec        jp          ydecx
yinc        jp          yincx


;*******************************************************************************
;startup Subroutine:
;Registers Used:
;
;*******************************************************************************
;
startup     call       hires_drv
            ld         a,return
            CHROUT
            jp         $0bc6

;*******************************************************************************
;waitkey Subroutine:
;Registers Used:        af.
;Stack Used:            2
;This subroutine simply waits for a key to be pressed.
;*******************************************************************************
;
waitkeyx    call        scan
            jr          nz,waitkeyx
            call        gwaitdelay
waitkeyx2   call        scan
            jr          z,waitkeyx2
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
;Einitppi Subroutine:F
;Registers Used:        a & c.
;stack used:            0
;This subroutine initializes the ppi controller for keyboard input.
;*******************************************************************************
;
initppix    ld          a,ppiomode  ;write in the control word.
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
namex       ld          hl,banner
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
clsx        ld          a,ppigraphic;initialize screen
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
            ld          de,chroutx
            xor         a
            sbc         hl,de
            jr          z,noinit
            ld          hl,(chroutvect)
            ld          (fontreserve),hl
            ld          hl,chroutx  ;initialize vector
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
clrwinx     ld          bc,windowbytes
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
hires_drvx  call        initchr
            ld          hl,font
            ld          (fontaddr),hl
            xor         a
            ld          (inverse),a
            ld          a,ppigraphic
            out         (ppib),a
            ret

;*******************************************************************************
;pix Subroutine:
;Registers Used:        af, bc, de, & hl.
;Stack Used:            8
;This subroutine will plot on an x,y grid with the origin at the lower left hand
;window.  A-register is the x-coordinate, B-register holds the y-coordinate.
;*******************************************************************************
;
pixx        push        af
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
;         --THIS SUBROUTINE CALCULATES THE ADDRESS FOR THE COORDINATES IN THE
;           DEFINED SPACE XYPOS AND XPOS.  THE RESULT IS RETURNED IN ADDR.
;
;*******************************************************************************
;
calc_addrx  PUSH        AF
            PUSH        BC
            PUSH        HL
            LD          A,(row)
            LD          L,A
            LD          H,0
            ADD         HL,HL       ;*2  CALCULATE Y POSITION
            ADD         HL,HL       ;*4
            ADD         HL,HL       ;*8
            ADD         HL,HL       ;*16
            ADD         HL,HL       ;*32
            ADD         HL,HL       ;*2  SKIP 8+4 SCAN LINES
            ADD         HL,HL       ;*4
            ADD         HL,HL       ;*8
            LD          A,(column)
            ADD         A,L
            LD          L,A
            LD          BC,vidram
            ADD         HL,BC
            LD          (addr),HL
            POP         HL
            POP         BC
            POP         AF
            RET

;*******************************************************************************
;setxy Subroutine:
;Registers Used:        de.
;Stack Used:            2
;This subroutine takes the DE-Register pair to set the (x,y) screen character
;coordinates for the chrout driver.
;*******************************************************************************
;
setxyx      ld          (column),de ;store the coordinates.
            call        calc_addrx  ;calculate the screen address and store it.
            ret

;*******************************************************************************
;prtstg Subroutine:
;Registers Used:        af & hl.
;Stack Used:            2
;This subroutine prints out a string of text terminated by a nul character.
;*******************************************************************************
;
prtstgx     call        calc_addr
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
;      --   THIS ROUTINE TAKES THE A-REG CHARACTER AND PLACES IT AT THE CURRENT
;           GRAPHICS POSITION. Cls MUST BE CALLED BEFORE THIS ROUTINE IS USED.
;*******************************************************************************
;
chroutx     push        af
            push        bc
            push        de
            push        hl
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
xdecx       ld          a,(column)  ;advance character left.
            dec         a
            ld          (column),a
            cp          neg
            jr          nz,qdfixexit
eol         ld          a,xlen-1    ;fix character to right on next line:
            ld          (column),a
ydecx       ld          a,(row)     ;advance character up.
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
            jp          z,dotabx
            cp          tab         ;clear screen
            jp          z,clsx
            cp          ctrlc       ;clear window
            jp          z,clrwinx
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
exitfontx   ld          hl,(fontreserve)
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
xincx       ld          a,(column)  ;advance character right.
            inc         a
            ld          (column),a
            cp          xlen
            jr          c,qfixexit
returnln    xor         a           ;fix character to left on next line:
            ld          (column),a
yincx       ld          a,(row)     ;advance character down.
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
doinversex  ld          a,neg
            ld          (inverse),a
            ret

;*******************************************************************************
;donormal Subroutine:
;Registers Used:
;
;*******************************************************************************
;
donormalx   ld          a,nul
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
settabx     ld          a,(column)
            ld          (tabdat),a
            ret

;*******************************************************************************
;dotab Subroutine:
;Registers Used:
;
;*******************************************************************************
;
dotabx      ld          a,(tabdat)
            ld          (column),a
            call        calc_addr
            ret

;*******************************************************************************
;clreol Subroutine:
;Registers Used:
;
;*******************************************************************************
;
clreolx     ld          a,xlen
            ld          hl,column
            sub         (hl)
            jr          z,endclreolx
            ld          b,a
            ld          c,a
            ld          a,space
fillspace   call        chrout
            djnz        fillspace
            ld          b,c
            ld          a,left
backspacef  call        chrout
            djnz        backspacef
endclreolx  ret

;*******************************************************************************
;calc_font Subroutine:
;Registers Used:        af, bc, & hl.
;Stack Used:            none.
;This subroutine calculates the 8x8 font pointed to by a-Register.  Pointer is
;returned in hl_Register.
;*******************************************************************************
;

calc_font   ld          l,a
            LD          H,nul         ;calculate the font address:
            ADD         HL,HL         ;skip over to the font character pointed to
            ADD         HL,HL         ;by A-Register (a font is 8x8, so multiply by 8).
            ADD         HL,HL
            LD          BC,(fontaddr) ;add the offset to get the corrected font address.
            ADD         HL,BC
            ret

;*******************************************************************************
;out_font Subroutine:
;Registers Used:        af, bc, de, & hl.
;Stack Used:            none.
;This subroutine builds a font image pointed to by hl_Register to the graphics
;screen pointed to by de_Register.
;*******************************************************************************
;
out_font    LD          BC,xlen     ;quick adding variable to skip video lines.
            ex          de,hl
            LD          A,(de)      ;fetch a font row.
            LD          (hl),A      ;place it in video memory to build font image.
            add         hl,bc       ;get on down to the next row.
            inc         de          ;get next font image.
            LD          A,(de)      ;Font line# 2
            LD          (hl),A
            add         hl,bc
            inc         de
            LD          A,(de)      ;Font line# 3
            LD          (hl),A
            add         hl,bc
            inc         de
            LD          A,(de)      ;Font line# 4
            LD          (hl),A
            add         hl,bc
            inc         de
            LD          A,(de)      ;Font line# 5
            LD          (hl),A
            add         hl,bc
            inc         de
            LD          A,(de)      ;Font line# 6
            LD          (hl),A
            add         hl,bc
            inc         de
            LD          A,(de)      ;Font line# 7
            LD          (hl),A
            add         hl,bc
            inc         de
            LD          A,(de)      ;Font line# 8
            LD          (hl),A
            ex          de,hl
            RET

;*******************************************************************************
;out_fonti Subroutine:
;Registers Used:        af, bc, de, & hl.
;Stack Used:            none.
;This subroutine builds a inverse font image pointed to by hl_Register to the
;graphics screen pointed to by de_Register.
;*******************************************************************************
;
out_fonti   LD          BC,xlen     ;quick adding variable to skip video lines.
            ex          de,hl
            LD          A,(de)      ;fetch a font row.
            xor         $ff
            LD          (hl),A      ;place it in video memory to build font image.
            add         hl,bc       ;get on down to the next row.
            inc         de          ;get next font image.
            LD          A,(de)      ;Font line# 2
            xor         $ff
            LD          (hl),A
            add         hl,bc
            inc         de
            LD          A,(de)      ;Font line# 3
            xor         $ff
            LD          (hl),A
            add         hl,bc
            inc         de
            LD          A,(de)      ;Font line# 4
            xor         $ff
            LD          (hl),A
            add         hl,bc
            inc         de
            LD          A,(de)      ;Font line# 5
            xor         $ff
            LD          (hl),A
            add         hl,bc
            inc         de
            LD          A,(de)      ;Font line# 6
            xor         $ff
            LD          (hl),A
            add         hl,bc
            inc         de
            LD          A,(de)      ;Font line# 7
            xor         $ff
            LD          (hl),A
            add         hl,bc
            inc         de
            LD          A,(de)      ;Font line# 8
            xor         $ff
            LD          (hl),A
            ex          de,hl
            RET
;
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
;FONT 1 -- 8x8 COMPACT "ZX81" STYLE FONT; FULL ASCII 8-BIT CODE.
            .DB        0F0H,0F0H,0F0H,0F0H,000H,000H,000H,000H  ;0    UL SQUARE
            .DB        00FH,00FH,00FH,00FH,000H,000H,000H,000H  ;1    UR SQUARE
            .DB        0FFH,0FFH,0FFH,0FFH,000H,000H,000H,000H  ;2    U RECTANGLE
            .DB        000H,000H,000H,000H,0F0H,0F0H,0F0H,0F0H  ;3    LL SQUARE
            .DB        0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H  ;4    L RECTANGLE
            .DB        00FH,00FH,00FH,00FH,0F0H,0F0H,0F0H,0F0H  ;5    LL UR SQUARES
            .DB        0FFH,0FFH,0FFH,0FFH,0F0H,0F0H,0F0H,0F0H  ;6    LL UL UR SQR
            .DB        0AAH,055H,0AAH,055H,0AAH,055H,0AAH,055H  ;7    GREY
            .DB        000H,000H,000H,000H,0AAH,055H,0AAH,055H  ;8    L GREY
            .DB        0AAH,055H,0AAH,055H,000H,000H,000H,000H  ;9    U GREY
            .DB        000H,01CH,022H,078H,020H,020H,07EH,000H  ;10   POUND
            .DB        0ffH,0ffH,0ffH,0ffH,0ffH,0ffH,0ffH,0ffH  ;11   white space
            .DB         00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  ;12
            .DB         00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  ;13
            .DB         00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  ;14
            .DB         00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  ;15
            .DB         00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  ;16
            .DB         00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  ;17
            .DB         00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  ;18
            .DB         00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  ;19
            .DB         00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  ;20
            .DB         00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  ;21
            .DB         00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  ;22
            .DB         00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  ;23
            .DB         00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  ;24
            .DB         00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  ;25
            .DB         00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  ;26
            .DB         00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  ;27
            .DB         00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  ;28
            .DB         00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  ;29
            .DB         00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  ;30
            .DB         00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  ;31
            .DB         00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  ;32       SPACE
            .DB        010H,010H,010H,010H,010H,000H,010H,000H  ;33      !
            .DB        000H,024H,024H,000H,000H,000H,000H,000H  ;34      "
            .DB        000H,024H,07EH,024H,024H,07EH,024H,000H  ;35      #
            .DB        000H,008H,03EH,028H,03EH,00AH,03EH,008H  ;36      $
            .DB        000H,062H,064H,008H,010H,026H,046H,000H  ;37      %
            .DB        010H,028H,010H,02AH,024H,02AH,010H,000H  ;38      &
            .DB        000H,008H,008H,010H,000H,000H,000H,000H  ;39      '
            .DB        000H,004H,008H,008H,008H,008H,004H,000H  ;40      (
            .DB        000H,020H,010H,010H,010H,010H,020H,000H  ;41      )
            .DB        000H,000H,014H,008H,03EH,008H,014H,000H  ;42      *
            .DB        000H,000H,008H,008H,03EH,008H,008H,000H  ;43      +
            .DB        000H,000H,000H,000H,000H,008H,008H,010H  ;44      ,
            .DB        000H,000H,000H,000H,03EH,000H,000H,000H  ;45      -
            .DB        000H,000H,000H,000H,000H,018H,018H,000H  ;46      .
            .DB        000H,000H,002H,004H,008H,010H,020H,000H  ;47      /
            .DB        000H,03CH,046H,04AH,052H,062H,03CH,000H  ;48      0
            .DB        000H,018H,028H,008H,008H,008H,03EH,000H  ;49      1
            .DB        000H,03CH,042H,002H,03CH,040H,07EH,000H  ;50      2
            .DB        000H,03CH,042H,00CH,002H,042H,03CH,000H  ;51      3
            .DB        000H,008H,018H,028H,048H,07EH,008H,000H  ;52      4
            .DB        000H,07EH,040H,07CH,002H,042H,03CH,000H  ;53      5
            .DB        000H,03CH,040H,07CH,042H,042H,03CH,000H  ;54      6
            .DB        000H,07EH,002H,004H,008H,010H,010H,000H  ;55      7
            .DB        000H,03CH,042H,03CH,042H,042H,03CH,000H  ;56      8
            .DB        000H,03CH,042H,042H,03EH,002H,03CH,000H  ;57      9
            .DB        000H,000H,000H,010H,000H,000H,010H,000H  ;58      :
            .DB        000H,000H,010H,000H,000H,010H,010H,020H  ;59      ;
            .DB        000H,000H,004H,008H,010H,008H,004H,000H  ;60      <
            .DB        000H,000H,000H,03EH,000H,03EH,000H,000H  ;61      =
            .DB        000H,000H,010H,008H,004H,008H,010H,000H  ;62      >
            .DB        000H,03CH,042H,004H,008H,000H,008H,000H  ;63      ?
            .DB        000H,03CH,002H,03AH,02AH,03AH,042H,03CH  ;64      @
            .DB        000H,03CH,042H,042H,07EH,042H,042H,000H  ;65      A
            .DB        000H,07CH,042H,07CH,042H,042H,07CH,000H  ;66      B
            .DB        000H,03CH,042H,040H,040H,042H,03CH,000H  ;67      C
            .DB        000H,078H,044H,042H,042H,044H,078H,000H  ;68      D
            .DB        000H,07EH,040H,07CH,040H,040H,07EH,000H  ;69      E
            .DB        000H,07EH,040H,07CH,040H,040H,040H,000H  ;70      F
            .DB        000H,03CH,042H,040H,04EH,042H,03CH,000H  ;71      G
            .DB        000H,042H,042H,07EH,042H,042H,042H,000H  ;72      H
            .DB        000H,03EH,008H,008H,008H,008H,03EH,000H  ;73      I
            .DB        000H,002H,002H,002H,042H,042H,03CH,000H  ;74      J
            .DB        000H,044H,048H,070H,048H,044H,042H,000H  ;75      K
            .DB        000H,040H,040H,040H,040H,040H,07EH,000H  ;76      L
            .DB        000H,042H,066H,05AH,042H,042H,042H,000H  ;77      M
            .DB        000H,042H,062H,052H,04AH,046H,042H,000H  ;78      N
            .DB        000H,03CH,042H,042H,042H,042H,03CH,000H  ;79      O
            .DB        000H,07CH,042H,042H,07CH,040H,040H,000H  ;80      P
            .DB        000H,03CH,042H,042H,052H,04AH,03CH,000H  ;81      Q
            .DB        000H,07CH,042H,042H,07CH,044H,042H,000H  ;82      R
            .DB        000H,03CH,040H,03CH,002H,042H,03CH,000H  ;83      S
            .DB        000H,0FEH,010H,010H,010H,010H,010H,000H  ;84      T
            .DB        000H,042H,042H,042H,042H,042H,03CH,000H  ;85      U
            .DB        000H,042H,042H,042H,042H,024H,018H,000H  ;86      V
            .DB        000H,042H,042H,042H,042H,05AH,024H,000H  ;87      W
            .DB        000H,042H,024H,018H,018H,024H,042H,000H  ;88      X
            .DB        000H,082H,044H,028H,010H,010H,010H,000H  ;89      Y
            .DB        000H,07EH,004H,008H,010H,020H,07EH,000H  ;90      Z
            .DB        000H,038H,020H,020H,020H,020H,020H,038H  ;91      [
            .DB        000H,040H,020H,010H,008H,004H,002H,000H  ;92      \
            .DB        000H,038H,008H,008H,008H,008H,008H,038H  ;93      ]
            .DB        000H,010H,028H,044H,000H,000H,000H,000H  ;94      ^
            .DB        000H,000H,000H,000H,000H,000H,000H,0FFH  ;95      _
            .DB        000H,010H,010H,008H,000H,000H,000H,000H  ;96      `
            .DB        000H,000H,03CH,002H,03EH,042H,03EH,000H  ;97      a
            .DB        040H,040H,07CH,042H,042H,042H,07CH,000H  ;98      b
            .DB        000H,000H,03CH,042H,040H,042H,03CH,000H  ;99      c
            .DB        002H,002H,03EH,042H,042H,042H,03EH,000H  ;100     d
            .DB        000H,000H,03CH,042H,07EH,040H,03EH,000H  ;101     e
            .DB        018H,024H,020H,070H,020H,020H,020H,000H  ;102     f
            .DB        000H,000H,03CH,042H,042H,03EH,002H,03CH  ;103     g
            .DB        0C0H,040H,07CH,042H,042H,042H,042H,000H  ;104     h
            .DB        010H,000H,030H,010H,010H,010H,038H,000H  ;105     i
            .DB        010H,000H,030H,010H,010H,010H,050H,020H  ;106     j
            .DB        040H,040H,048H,050H,060H,050H,048H,000H  ;107     k
            .DB        030H,010H,010H,010H,010H,010H,038H,000H  ;108     l
            .DB        000H,000H,036H,049H,049H,049H,049H,000H  ;109     m
            .DB        000H,000H,0BCH,042H,042H,042H,042H,000H  ;110     n
            .DB        000H,000H,03CH,042H,042H,042H,03CH,000H  ;111     o
            .DB        000H,000H,03CH,042H,042H,07CH,040H,040H  ;112     p
            .DB        000H,000H,03CH,042H,042H,03EH,002H,003H  ;113     q
            .DB        000H,000H,05CH,020H,020H,020H,020H,000H  ;114     r
            .DB        000H,000H,03EH,040H,03CH,002H,07CH,000H  ;115     s
            .DB        000H,010H,038H,010H,010H,010H,018H,000H  ;116     t
            .DB        000H,000H,042H,042H,042H,042H,03EH,000H  ;117     u
            .DB        000H,000H,044H,044H,044H,028H,010H,000H  ;118     v
            .DB        000H,000H,044H,044H,054H,054H,028H,000H  ;119     w
            .DB        000H,000H,044H,028H,010H,028H,044H,000H  ;120     x
            .DB        000H,000H,042H,042H,042H,03EH,002H,07CH  ;121     y
            .DB        000H,000H,07EH,004H,018H,020H,07EH,000H  ;122     z
            .DB        000H,008H,010H,010H,020H,010H,010H,008H  ;123     {
            .DB        010H,010H,010H,010H,010H,010H,010H,010H  ;124     |
            .DB        000H,020H,010H,010H,008H,010H,010H,020H  ;125     }
            .DB        000H,000H,020H,054H,008H,000H,000H,000H  ;126     ~
            .db        000h,000h,000h,000h,000h,000h,000h,0ffh  ;127  underline
            .DB        0F0H,0F0H,0F0H,0F0H,000H,000H,000H,000H  ;128  UL SQUARE
            .DB        00FH,00FH,00FH,00FH,000H,000H,000H,000H  ;129  UR SQUARE
            .DB        0FFH,0FFH,0FFH,0FFH,000H,000H,000H,000H  ;130  U RECTANGLE
            .DB        000H,000H,000H,000H,0F0H,0F0H,0F0H,0F0H  ;131  LL SQUARE
            .DB        0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H  ;132  L RECTANGLE
            .DB        00FH,00FH,00FH,00FH,0F0H,0F0H,0F0H,0F0H  ;133  LL UR SQUARES
            .DB        0FFH,0FFH,0FFH,0FFH,0F0H,0F0H,0F0H,0F0H  ;134  LL UL UR SQR
            .DB        0AAH,055H,0AAH,055H,0AAH,055H,0AAH,055H  ;135  GREY
            .DB        000H,000H,000H,000H,0AAH,055H,0AAH,055H  ;136  L GREY
            .DB        0AAH,055H,0AAH,055H,000H,000H,000H,000H  ;137  U GREY
            .DB        000H,01CH,022H,078H,020H,020H,07EH,000H  ;138  POUND
            .DB        0ffH,0ffH,0ffH,0ffH,0ffH,0ffH,0ffH,0ffH  ;139  white space
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
;
;*******************************************************************************
;
;
;*******************************************************************************
;
;<*** Help Screens ***>
;                        01234567890abcdef0123456789abcde
banner      .text       "Hi-Res Character Generator v1.0z"
            .text       "  5/31/91 by Duane P. Attaway   "
            .text       "       EDM mini version\000"
            .text       "Press any key to continue . . .\000"

;<*** Analog/Digital Communications ***>
no_samples  .equ        500       ;<*** Number of Samples ***>
mag         .equ        1           ;initial plot magnification.

;<*** ROM Interface ***>
int         .equ        $6012+1
nmi         .equ        int+3

;*******************************************************************************
;EmainF
;Stack Used:            requires $800 bytes for safe operation (int and nmi).
;This program impliments a simple digital storage oscilliscope
;through the use of a peripherial ADC.  Sweep time is adjustable
;through the keyboard menu interface.
;*******************************************************************************
;
main        call        initppi     ;setup '8255 controller.
            call        hires_drv   ;initialize graphics driver.
            call        cls         ;clear the graphics screen.
            call        setgraph    ;setup grid pattern.
            call        name
            call        initbuffer  ;set initial sampling buffer parameters.
            call        waitkey
            call        initadc     ;set up the adc operation.
            call        clrwin      ;clear graphics window.
            ld          hl,step_j
            call        prtstg
mainloop    call        waitkey
            cp          esc
            jr          z,exitall   ;exit.
            cp          'R'
            jr          z,resample  ;resample input.
            cp          'C'
            call        z,clearplot ;clear graph window.
            cp          'P'
            call        z,plotall   ;plot the graph.
            cp          '9'+1
            call        c,adjust    ;set graphic range.
waitkey1    call        scan        ;make the user let go of the key!
            jr          nz,waitkey1
            call        clrwin      ;clear text window.
            ld          hl,step_j
            call        prtstg      ;print user message.
            call        setgraph    ;set up coordinates.
            jr          mainloop
exitall     jp          command

;*******************************************************************************
;adjust Subroutine:
;Registers Used:        af, bc, de & hl.
;Stack Used:            8
;This subroutine adjusts the plotting range of the graph.  A-Register holds the
;ASCII number (0-9) for the graphing range; 0 covers a small range, 9 covers the
;whole buffer.  The table used for the program defines how many bytes of the
;buffer should be skipped for each sample.
;*******************************************************************************
;
adjust      push        af
            push        bc
            push        de
            push        hl
            sub         '0'         ;convert ASCII to binary for calculation.
            jr          c,exitadjust;invalid numbers should be cause for abortion.
            ld          hl,adjustbl
            add         a,l         ;look up the skip range on the table.
            ld          l,a
            ld          a,0
            adc         a,h
            ld          h,a
            ld          a,(hl)
            ld          (plotrate),a;store the parameter.
exitadjust  pop         hl
            pop         de
            pop         bc
            pop         af
            ret

;*******************************************************************************
;resample routine:
;Registers Used:        none.
;Stack Used:            2
;This routine is called by main to enable a resample by re-enabling the
;interrupts.
;*******************************************************************************
;
resample    call        initadc
            jp          mainloop

;*******************************************************************************
;clearplot Subroutine:
;Registers Used:        none.
;Stack Used:            2
;This subroutine is called by main to clear the graphing area for a new graph.
;*******************************************************************************
;
clearplot   call        cls
            ret

;*******************************************************************************
;plotall Subroutine:
;Registers Used:        af, bc, de, & hl.
;Stack Used:            14
;This subroutine plots contents of the buffer of range plotrate in the graphic
;window.
;*******************************************************************************
;

plotall     push        af
            push        bc
            push        de
            push        hl
            ld          hl,buffer   ;start at the beginning of the buffer.
            ld          d,leftgraph ;
plotfory    ld          a,(plotrate)
            ld          e,a
plotinx     ld          a,(hl)
            srl         a
            ld          b,a
            ld          a,d
            call        pix
            inc         hl
            dec         e
            jr          nz,plotinx
            inc         d
            jr          z,endplot
            push        hl
            push        de
            ld          de,buffend
            xor         a
            sbc         hl,de
            pop         de
            pop         hl
            jr          nz,plotfory
endplot     pop         hl
            pop         de
            pop         bc
            pop         af
            ret

;*******************************************************************************
;initadc Subroutine:
;Registers Used:        af & b.
;This subroutine starts the adc conversion process.
;*******************************************************************************
;
initadc     out         (adc),a        ;get cranking on the adc.
            ld          hl,buffer      ;initialize the buffer start.
            ld          (buffptr),hl
            ld          (nmiptr),hl    ;initialize the nmi stream pointer.
            ld          a,1
            ld          b,nul
waitinit    djnz        waitinit
            out         (adc),a        ;ensure a good start.
            im          1
            ei
            ret

;*******************************************************************************
;initbuffer Subroutine:
;Registers Used:        af, bc, de, & hl.
;Stack Used:            0
;This subroutine sets up the ROM interrupt vectors, plotrate, and the buffer.
;*******************************************************************************
;

initbuffer  ld          hl,nul
            ld          hl,intisr     ;initialize the RAM vector for int.
            ld          (int),hl
            ld          hl,nmiisr     ;initialize the RAM vector for nmi.
            ld          (nmi),hl
            ld          hl,plotrate
            ld          (hl),mag      ;set initial plot magnification.
            ret

;*******************************************************************************
;setgraph Subroutine:
;Registers Used:        af & b.
;Stack Used:            2
;This subroutine plots out the abcissa and the ordinate bars.
;*******************************************************************************
;
setgraph    ld          a,leftgraph
            ld          b,lowergraph;plot the yline.
yline       call        pix
            inc         b
            push        af
            ld          a,b
            cp          uppergraph
            pop         af
            jr          nz,yline
            ld          b,lowergraph;plot the xline.
xline       call        pix
            inc         a
            cp          rightgraph
            jr          nz,xline
            ret


;*******************************************************************************
;intisr Subroutine:
;Registers Used:        af, de, & hl.
;Stack Used:            6
;This is the service routine for /int interrupts used by the ADC to fill the
;buffer area.  The interrupt is disabled when the buffer reaches full capacity.
;*******************************************************************************
;
intisr      out         (adc),a     ;trigger the next conversion process.
            push        af          ;save regs.
            push        hl
            push        de
            in          a,(adc)
            ld          hl,(buffptr)
            ld          (hl),a
            inc         hl
            ld          (buffptr),hl
            xor         a
            ld          de,buffend
            sbc         hl,de
            jr          z,end_adc   ;if all done, bypass reenabling interrupt.
            pop         de
            pop         hl
            pop         af
            ei                      ;reenable that interrupt and get back, jack.
end_isr     reti
end_adc     call        clrwin
            ld          hl,donemsg
            call        prtstg
            ld          hl,buffptr  ;set up the nmi output for usage.
            ld          (nmiptr),hl
            pop         de
            pop         hl
            pop         af
            jr          end_isr     ;leave.

;*******************************************************************************
;nmiisr Subroutine:
;Registers Used:        af, de, & hl.
;Stack Used:            6
;This interrupt servise routine is called by /nmi to redundantly sample the
;buffer area for the devices use.
;*******************************************************************************
;
nmiisr      push        af
            push        de
            push        hl
            ld          hl,(nmiptr) ;check to see if the buffer is beeing overrun.
            ld          de,buffend
            xor         a           ;clear the carry flag for upcoming equality check.
            sbc         hl,de       ;was the buffer finished?
            ld          hl,(nmiptr)
            inc         hl          ;carry flag not affected here.
            ld          (nmiptr),hl
            jr          c,dacout    ;if not, send it out right away.
            ld          hl,buffer   ;fixup buffer if it is being overrun.
            ld          (nmiptr),hl
dacout      ld          hl,(nmiptr)
            ld          a,(hl)      ;get the data before the pointer is destroyed.
            out         (dac),a     ;output to dac.
            pop         hl
            pop         de
            pop         af
            retn

;*******************************************************************************
;DATA AREA
;*******************************************************************************
;
;<*** Buffer ***>
buffptr     .block      2           ;where the intisr routine is placing data.
nmiptr      .block      2           ;where the nmiisr routine is sampling data.

;<*** Plotting Information ***>
plotrate    .block      1           ;how many samples to skip during plots.
                                    ;skip variables.
adjustbl    .db         1, $5, $10, $15, $20, $25, $30, $35, $40, $41
;
;*******************************************************************************
;
;<*** Help Screens ***>
;                        01234567890abcdef0123456789abcde
donemsg     .text       "…DONE -- adc finished cycle,ÕÕÕª"
            .text       "∫Ready for nmi/dac output,     ∫"
            .text       "∫Press a number 0-9 to set plot∫"
            .text       "∫rate and press [P] to plot,  …º"
            .text       "»Press [ESC] or [C]lear-screenº\000"

step_j      .text       "Press [ESC] to exit,\r"
            .text       "Press [R] to re-sample,\r"
            .text       "Press [P] to Plot;\r"
            .text       "[0 - 9] to adjust plot rate,\r"
            .text       "Press [C] to Clear the screen.\000"
buffer      .block      no_samples  ;sample data area.
buffend
endprog
            .end
