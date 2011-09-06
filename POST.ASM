;…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª
;∫                                                                             ∫
;∫ seniorx.asm --Task# 1: Memory and peripheral decoding.                      ∫
;«ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ∂
;∫                                                                             ∫
;»ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº

progstart   .equ        $0
ramtop      .equ        $c000

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

adc         .equ        $01

ppi         .equ        $08 ;8c ;08         ;device used by the video hardware.
ppia        .equ        ppi
ppib        .equ        ppi+1
ppic        .equ        ppi+2
ppicntrl    .equ        ppi+3

rampage     .equ        $00

ctca         .equ        $04 ;04
ctca0        .equ        ctca
ctca1        .equ        ctca+1
ctca2        .equ        ctca+2
ctca3        .equ        ctca+3

ctcb         .equ        $04 ;84
ctcb0        .equ        ctcb
ctcb1        .equ        ctcb+1
ctcb2        .equ        ctcb+2
ctcb3        .equ        ctcb+3

sioa         .equ        $0c
sioaad       .equ        sioa
sioabd       .equ        sioa +1
sioaac       .equ        sioa +2
sioabc       .equ        sioa +3

siob         .equ        $0c ;88
siobad       .equ        siob
siobbd       .equ        siob +1
siobac       .equ        siob +2
siobbc       .equ        siob +3

dma         .equ        $10

;<*** Hardware Screen Attributes ***>
vidram      .equ        $8000; $8000       ;start of video area
vidlen      .equ        $1ff        ;length of text video
grlen       .equ        $17ff       ;length of graphics page
grend       .equ        vidram+grlen;end of graphics page
xlen        .equ        $20         ;maximum x length
ylen        .equ        $18         ;maximum y length

;<*** Graphics Driver Varibles ***>
fontlen     .equ        $08
fontlength  .equ        $100*fontlen
column      .equ        $b0b9
row         .equ        $b0ba
addr        .equ        $b0bb

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
ramstart    .equ        $a000

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
escape      .equ        $1b

;<*** old ROM Interface ***>
#define     CHROUT      rst         10h
#define     CHRIN       rst         18h
chroutvect  .equ        $b004
command     .equ        $bc6
dflti       .equ        $b018
dflto       .equ        $b019
getchar     .equ        $434
getchrvct   .equ        $b007
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
n1int       .org        $6275
n2int       .org        $6278
n3int       .org        $627b
n4int       .org        $627e
n5int       .org        $6281
n6int       .org        $6284
n7int       .org        $6287
n8int       .org        $628a
n9int       .org        $628d


;<*** Include Variables ***>
bit8mask    .equ        111b        ;used for bytewise calculations
neg         .equ        -1
nul         .equ        0
waitdelay   .equ        10000       ;prevent keybouncing


;*******************************************************************************
; Vector Jump routines:
; Registers Used:
; Stack Used:
; These vectors may be used on the modified EDM rom as a quick way to execute
; selected subroutines.
;
;*******************************************************************************
            .org        nzint
            jp          startup
            .org        ncint
            jp          cls
            .org        npint
            jp          ramcheck
            .org        nqint
            jp          exitfont
            .org        nyint
            jp          terminal
            .org        njint
            jp          cominit
            .org        n0int
            jp          wrtest
            .org        n1int
            jp          rdtest
            .org        n2int
            jp          adctest
            .org        n3int
            jp          mousetst
            .org        n4int
            jp          mouseinit
            .org        n5int
            jp          mousedrvr

;******************************************************************************
; bootstrap routine:
; Z80 starts here on initial power up or after active reset.
;
;******************************************************************************
;
bootstrap   .org        $0000
            di                      ;burn some serious time...
            ld          a,a         ;1
            ld          b,b         ;2
            ld          c,c         ;3
            ld          d,d         ;4
            jp          main        ;5,6,7


;******************************************************************************
; RESTART Vecors:
;
;
;******************************************************************************
;
            jp          rst08
            .org        $10
            jp          chrout
            .org        $18
            jp          rst18
            .org        $20
            jp          rst20
            .org        $28
            jp          rst28
            .org        $30
            jp          rst30
            .org        $38
            jp          rst38
            .org        $66
            jp          nmi


;******************************************************************************
; RESTART Subroutines:
;
;
;******************************************************************************
;
rst08
rst10
rst18
rst20
rst28
rst30
rst38
nmi


;******************************************************************************
; main routine:
; The POST (Power On Self Test) is performed here.  During this test, critical
; system variables and hardware are set for proper operation.
;
; These areas are checked:
;
;           RAM - system area checked
;                 Stack is set
;           ROM - Checksum verified
;           RAM - Video area is checked
;           Video Generator is checked for existance
;           RAM - Extended area checked
;           DMA - checked for existance
;           CTC - all channels are checked
;           ADC - value simply displayed to screen
;           SIO - mouse pointing device checked for existance
;
; Then the user is asked to continue . . .
;
;
;******************************************************************************
;
vid111      .text       "Video Memory OK.\r\000"
sio111      .text       "SIO Peripheral OK.\r\000"
dev8255     .text       "8255 Peripheral OK\r\000"
main        ;<*** clear screen and initialize video for any error codes ***>
            ld          hl,vidram2
            ld          de,vidram2+1
            ld          bc,grlen
            ld          (hl),nul
            ldir                    ;clear the screen

            ;<*** setup video for graphics mode ***>
            ld          c,ppicntrl
            ld          a,10000000b
            out         (c),a       ;initialize all outputs
            ld          a,graphicmode
            out         (ppix),a
            ld          sp,$7f00
            call        startup
            call        cls
            call        ramcheck
            halt

            ;<*** RAM - system area checked ***>
            ld          hl,sysram
sysramchk   ld          a,(hl)                  ;perform flip-bit testing
            cpl
            ld          (hl),a
            cp          (hl)                    ;make sure memory gets changed!
            jp          nz,sysramerr            ;write error, send abort error.
            cpl
            ld          (hl),a                  ;restore value back.
            inc         hl
            ld          a,h
            cp          sysramend
            jr          nz,sysramchk            ;work on next one...

            ld          sp,ramtop

romlength   .equ        $3fff
rommsg      .text       "\rROM Checksum: \000"
rom2msg     .text       "INVALID ROM Checksum!\r\000"
romerrorcd  .equ        8
romcheck    ld          hl,rommsg
            call        prtstg
            ld          hl,0
            ld          bc,romlength
            ld          de,0
nextrom     ld          a,(hl)
            add         a,e
            ld          e,a
            ld          a,0
            adc         a,d
            ld          d,a
            dec         bc
            inc         hl
            ld          a,c
            or          b
            jr          nz,nextrom
            call        pr2hex
            ld          a,return
            CHROUT
            ld          hl,(checkloc)
            sbc         hl,de
            ret         z
            ld          hl,rom2msg
            call        prtstg
            ld          e,romerrorcd
            jp          flash

            ld          hl,vidram2              ;video ram checking
vidramchk   ld          a,(hl)                  ;perform flip-bit testing
            cpl
            ld          (hl),a
            cp          (hl)                    ;make sure memory gets changed!
            jp          nz,vidramerr            ;write error, send abort error.
            cpl
            ld          (hl),a                  ;restore value back.
            inc         hl
            ld          a,h
            cp          vidram2end
            jr          nz,vidramchk            ;work on next one...



;*******************************************************************************
; mousedrvr Subroutine:
; Registers Used:
; Stack Used:
; This subroutine checks if a mouse is present by dropping the RTS line on the
; comm port.  If a 'MM' or 'M' is returned, the mouse has just been inialized
; or reinitialized, respectively.  If nothing is returned, no mouse is present.
; If some other code is returned, another type of mouse is assumed.
;*******************************************************************************
;
maxx        .equ        xlen*8      ;maximum horizontal pixel length on video
maxy        .equ        ylen*8      ;

xcenter     .equ        maxx/2      ;used for centering the mouse curser
ycenter     .equ        maxy/2

;

mousedrvr   call        mouseinit   ;set the baud rate and initialize communications.
            xor         a
            ld          (minst),a   ;reset the mouse_isr task number.

            ld          (ml),a      ;clear the mouse buttons
            ld          (mr),a
            ld          a,xcenter
            ld          (mx),a      ;center the mouse X coordinate pointer.
            ld          (mx2),a     ;center the mouse X coordinate buffer.
            ld          a,ycenter
            ld          (my),a      ;center the mouse Y coordinate pointer.
            ld          (my2),a     ;center the mouse Y corrdinate buffer.

            ld          a,isr_table
            ld          i,a
            ei
            ret

;*******************************************************************************
; mouseinit Subroutine:
; Registers Used:
; Stack Used:
; This subroutine initializes the mouse baud rate at 1200,n,7,1.  Interrupts
; are set using the mouse_isr to accomadate the fast cursor position conversion.
;
;*******************************************************************************
;
wr0         .equ        0           ;write register 0 for the SIO
wr1         .equ        1           ;write register 1 for the SIO
wr2         .equ        2           ;write register 2 for the SIO
wr3         .equ        3           ;write register 3 for the SIO
wr4         .equ        4           ;write register 4 for the SIO
wr5         .equ        5           ;write register 5 for the SIO
wr6         .equ        6           ;write register 6 for the SIO
wr7         .equ        7           ;write register 7 for the SIO

isr_sio_low .equ        mouse_isr<<8

mouseinit   ld          c,sioaac
            xor         a           ;make sure WR0 will get written
            out         (c),a
            ld          a,00010000b ;reset SIO chip with software reset
            out         (c),a
            ld          a,(de)      ;waste a many clock cycles
            ld          a,(de)      ;waste a many clock cycles
            xor         a           ;make sure WR0 will get written again
            out         (c),a
            ld          a,wr2       ;set the interrupt vector low byte
            out         (c),a
            ret

;*******************************************************************************
; mousecall Subroutine:
; Registers Used:
; Stack Used:
; This subroutine may be used as a software interrupt function handler.
; A-Register contains the function to be performed as follows:
;
;           00 - No Operation
;           01 - Center Cursor in screen
;           02 - Initialize mouse driver (also paints mouse cursor)
;           03 - Enables mouse driver (Enable without reseting last coordinates)
;           04 - Disables mouse driver (also erases mouse cursor)
;           05 - Enable mouse cursor  (show)
;           06 - Disable mouse cursor (hide)
;           07 - Perform a mouse test to the text screen
;           08 - Check left mouse button
;           09 - Check right mouse button
;           0A - Move cursor to specified position
;
;
;*******************************************************************************
;
mousecall   push        hl          ;save HL-Register
            ld          hl,mousejp  ;get jump pointer
            sla         a
            add         l,a         ;add function call offset
            ex          (sp),hl     ;restore HL-Register and setup jump
            ret         z           ;jump to function subroutine
            inc         h           ;in case of miscalculation, don't dare crash
            ret

;*******************************************************************************
; nop Subroutine:
; 00 - mousejp software interrupt
; Registers Used:
; Stack Used:
; This subroutine does nothing.
;
;
;*******************************************************************************
;
nop         ret

;*******************************************************************************
; centercurs Subroutine:
; 01 - mousejp software interrupt
; Registers Used:
; Stack Used:
; This subroutine centers and repaints the mouse cursor in the center of the
; screen.
;
;
;*******************************************************************************
;
centercurs  push        de
            ld          d,xcenter
            ld          e,ycenter
            call        mcurmove
            pop         de
            ret

;*******************************************************************************
; mdrvi Subroutine:
; 02 - mousejp software interrupt
; Registers Used:
; Stack Used:
; This subroutine initializes the mouse driver.
;
;
;*******************************************************************************
;
mdrvi

;*******************************************************************************
; mousejp Interrupt Table:
; These interrupt vectors are used by the software subroutine 'mousecall'.
; Each vector corresponds to a particular function.
;
;*******************************************************************************
;
mousejp     .dw         nop         ;00 - No operation
            .dw         centercurs  ;01 - center the mouse cursor
            .dw         mdrvi       ;02 - mouse driver enable/initialize
            .dw         0           ;03 - Not Used
            .dw         mdrvd       ;04 - mouse driver disable
            .dw         mcure       ;05 - enable mouse cursor
            .dw         mcurd       ;06 - disable mouse cursor
            .dw         mousetest   ;07 - Perform a mouse test to the text screen
            .dw         mlbutton    ;08 - Check left mouse button
            .dw         mrbutton    ;09 - Check right mouse button
            .dw         mcurmove    ;0A - Move cursor to specified position
            .dw         erase       ;0B - Erase cursor at DE
            .dw         draw        ;0C - Draw cursor at DE
            .dw         0           ;0D -
            .dw         0           ;0E -
            .dw         0           ;0F -
            .dw         0           ;10 -
            .dw         0           ;11 -
            .dw         0           ;12 -
            .dw         0           ;13 -
            .dw         0           ;14 -
            .dw         0           ;15 -
            .dw         0           ;16 -
            .dw         0           ;17 -


;*******************************************************************************
; mouse_isr Subroutine:
; Registers Used:
; Stack Used:
; The MicroSoft mouse sends out a three byte package whenever it moves or a
; button is pushed.  These bytes are 7 bits wide, with the MSB used as a sync
; bit.  The first of three bytes containing of the package is identified with
; the sync bit as a 1.  The following two bytes of the package are identified
; with the MSB sync bit of a 0.  The mouse will send this 3 byte package as fast
; as possible.
;
; To identify if a button is pushed, bits 4 and 5 of the first byte identify
; the right and left button, respectively.
;
; The X and Y coordinates are extracted from all three bytes as described in the
; following table:
;
;       …ÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª
;       ∫byte  ≥sync                        ∫  For example, the eight bits
;       «ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ∂  of X represent one whole byte
;       ∫ 0    ≥ 1   L   R   Y7  Y6  X7  X6 ∫  for how many pixels the mouse
;       ∫ 1    ≥ 0   X5  X4  X3  X2  X1  X0 ∫  has moved since the last communication.
;       ∫ 2    ≥ 0   Y5  Y4  Y3  Y2  Y1  Y0 ∫  A negative number means the left
;       »ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº  hand direction.  (The byte is signed.)
;
; This service routine uses a task variable to identify which byte of the
; package it will work on when each interrupt is issued, as the 3 bytes of the
; package do not get sent at once.  If there is a descrepency with the sync
; bit and the sync variable, the mouse variables will reset in attempt to
; realign later.
;
;*******************************************************************************
;
mouse_isr   push        af
            push        bc
            ld          a,(minst)   ;see which part of the three byte conversion.
            or          a
            jr          nz,mousechk1
mousechk0   in          a,(sioaad)  ;fetch character off comm port.
            bit         6,a         ;check sync bit...
            jr          z,mouserror ;the sync bit must be a one!
            ld          b,a
            sla         a           ;get the 2 MSB's of the Y-coordinate
            sla         a
            sla         a
            sla         a
            ld          c,a
            and         11000000b
            ld          (my),a
            ld          a,c
            sla         a           ;get the 2 MSB's of the X-coordinate
            sla         a
            ld          (mx),a
            ld          a,b         ;left mouse button
            and         00100000b
            ld          (ml),a
            ld          a,b         ;right mouse button
            and         00010000b
            ld          (mr),a
            ld          a,mousechk1no
            ld          (minst),a   ;set second stage conversion for next time.
            jr          endmouse_isr

mousechk1   dec         a
            jr          nz,mousechk2
            in          a,(sioaad)
            bit         6,a         ;the sync bit must be a zero in this stage.
            jr          nz,mouserror
            and         00111111b   ;recover the 6 LSB's of the X-coordinate.
            ld          b,a
            ld          a,(mx)
            add         a,b
            ld          (mx),a
            ld          a,mousechk2no
            ld          (minst),a   ;set the third stage conversion for next time.
            jr          endmouse_isr
                                    
mousechk2   dec         a
            jr          nz,mouserror
            in          a,(sioaad)
            bit         6,a         ;the sync bit must be a zero in this stage.
            jr          nz,mouserror
            and         00111111b   ;recover the 6 LSB's of the Y-coordinate.
            ld          b,a
            add         a,(my)
            add         a,b
            ld          (my),a
            ld          a,mousechk0no
            ld          (minst),a   ;reset for the first conversion next time.
            call        move_mouse
            jr          endmouse_isr

mousechk0no .equ        0
mousechk1no .equ        1
mousechk2no .equ        2

mouserror   xor         a
            ld          (minst),a
            ld          (mx),a
            ld          (my),a
            ld          (ml),a
            ld          (mr),a
            jr          endmouse_isr

endmouse_isr
            pop         bc
            pop         af
            ei
            ret

;*******************************************************************************
; move_move Subroutine:
; Registers Used:
; Stack Used:
;
;
;
;*******************************************************************************
;
move_mouse  ld          de,(mx)
            call        pr2hex
            ret



;*******************************************************************************
; dma_isr Subroutine:
; Registers Used:
; Stack Used:
;
;
;
;*******************************************************************************
;
dma_isr

;*******************************************************************************
; mousetst Subroutine:
; Registers Used:
; Stack Used:
; This subroutine reads and displays mouse communication in binary to the
; video screen.
;
;*******************************************************************************
;
mousetst    call        cominit
            ld          de,$0703
            ld          a,e
            ld          (baudset),a
            ld          a,d
            ld          (bitset),a
            call        set_rate
nxtrcve     CHRIN
            cp          escape
            jp          z,command
            call        rx
            jr          z,nxtrcve
            call        bin2bin
            jr          nxtrcve

;*******************************************************************************
; cursor Subroutine:
; Registers Used:
; Stack Used:
; Register DE contains the new cursor XY location.
;
;
;*******************************************************************************
;

cursor      push        de
            ld          de,(cursory)
            call        ulcarrow    ;get the old cursor address and restore.
            call        restorearr
            pop         de
            call        ulcarrow    ;get new cursor address and...
            call        drawarrow   ;draw new arrow and save address for the
                                    ;next restore.
            ret

;*******************************************************************************
; restorearr Subroutine:
; Registers Used:
; Stack Used:
; This subroutine restores the mouse cursor arrow at the DE-Address
; with the data located in cursorblk.
; THIS SUBROUTINE IS OPTIMIZED FOR MAXIMUM SPEED EFFICIENCY!
;          (Please pardon the strange code flow)
;
;*******************************************************************************
;
restorearr  ld          c,cursorsize;number of iterations
            ld          hl,cursorblk
            and         00000111b
            ld          b,a
            ex          af,af'
shiftl      dec         b
            jr          c,noshiftl
            srl         a
            jr          shiftl
noshiftl    ex          af,af'
            cpl
            ld          b,a
            ex          af,af'
shiftr      inc         b


shiftdata   .db         11111111b   ;X-Coordinate shift table
            .db         01111111b
            .db         00111111b
            .db         00011111b
            .db         00001111b
            .db         00000111b
            .db         00000011b
            .db         00000001b
            .db         00000000b

;*******************************************************************************
; draw Subroutine:
; Registers Used:       de
; Stack Used:
; This subroutine draws the mouse arrow to the video screen.  The previous
; contents under the mouse arrow are saved into a 8x8 bit buffer array for
; restoration of the origional screen.  DE-register points to the XY location
; for the drawing.  The 'addrgr' memory register points to this screen address
; for quick restoration as needed by the 'erase' subroutine.
;
; The 8x8 bit array stores the previous display segment as appeared on the
; screen in a shifted manner, so the complete 8 horizontal bits will sqeeze
; into one byte (not two).
;
;*******************************************************************************
;
cursorsize  .equ        8           ;block size of the mouse cursor.

draw        ;store contents of screen to buffer
            call        ulcarrow
            ld          (addrgr),hl
            ld          a,d
            and         00000111b   ;get the 8-bit offset
            ld          c,a

nextbytes   ld          a,(hl)      ;next byte save
            jr          z,noxoffset
            ld          b,a         ;left justify offset count
ljusts      sla         a           ;"left justify save"
            djnz        ljusts

            inc         hl          ;cursor-next-byte-spillover
            ld          a,c
            neg
            and         00000111b   ;
            ld          a,(hl)





cursoror    .db         01000000b   ;OR mask to "paint" the cursor
            .db         01100000b
            .db         01111000b
            .db         01110100b
            .db         01111110b
            .db         01011000b
            .db         00001100b
            .db         00000110b

cursorand   .db         01111111b   ;AND mask to "shaddow" the cursor
            .db         01111111b
            .db         01111111b
            .db         01111111b
            .db         01111111b
            .db         01011111b
            .db         10001111b
            .db         11110111b


;*******************************************************************************
; ulcarrow Subroutine:
; Registers Used:
; Stack Used:
; This subroutine finds the Upper Left Arrow byte address of the mouse arrow.
; DE-Register holds the coordinates, address is returned in HL.
;
;*******************************************************************************
;
ulcarrow    push        af
            push        bc
            ld          l,e         ;x position
            ld          h,0
            srl         l           ;clip off the 8 bits in each cursor cell.
            srl         l
            srl         l
            add         hl,hl       ;*2  calculate y position.
            add         hl,hl       ;*4  this multiplication should correspond
            add         hl,hl       ;*8   to the cursorsize variable.
            add         hl,hl       ;*16
            add         hl,hl       ;*32
            ld          a,d
            add         a,l
            ld          l,a
            ld          bc,vidram
            add         hl,bc
            pop         bc
            pop         af
            ret


;*******************************************************************************
; dmatest Subroutine:
; Registers Used:
; Stack Used:
;
;
;*******************************************************************************
;
dmatest
            ret

;*******************************************************************************
; dmainit Subroutine:
; Registers Used:
; Stack Used:
;
;
;*******************************************************************************
;
dmainit
            ret

;*******************************************************************************
; adctest Subroutine:
; Registers Used:
; Stack Used:
;
;
;*******************************************************************************
;
adctest     call        adcctc
            ret

;*******************************************************************************
; adcctc Subroutine:
; Registers Used:
; Stack Used:
;
;
;*******************************************************************************
;
adcctc      ld          a,00100101b
            out         (ctca2),a
            ld          a,$ff
            out         (ctca2),a
            ret

;*******************************************************************************
; rdtest Subroutine:
; Registers Used:
; Stack Used:
;
;
;
;*******************************************************************************
;
rdtest      call        rx
            or          a
            jr          z,rdtest
            CHROUT
            jr          rdtest




;*******************************************************************************
; wrtest Subroutine:
; Registers Used:
; Stack Used:
;
;
;
;*******************************************************************************
;
wrtest      call        cominit
prewrt      ld          a,$20
nxtwr       push        af
            call        tx
            pop         af
            inc         a
            call        wait1
            cp          $7f
            jr          nz,nxtwr
            jr          prewrt

;*******************************************************************************
; wait1 Subroutine:
; Registers Used:
; Stack Used:
; This is a general purpose wait subroutine.
;
;*******************************************************************************
;
wait1       push        af
            push        bc
            ld          b,0
wait1nx     dec         b
            jr          nz,wait1nx
            pop         bc
            pop         af
            ret

;*******************************************************************************
; cominit Subroutine:
; Registers Used:
; Stack Used:
; This subroutine initializes and tests the SIO peripheral for proper operation.
; If an error is encountered, the program will exit with an error message to the
; video device and a set carry flag.
;
;
;*******************************************************************************
;
nintysix    .equ        5
eight       .equ        8
cominit     ld          e,nintysix
            ld          a,e
            ld          (baudset),a
            ld          d,eight
            ld          a,d
            ld          (bitset),a
            call        set_rate
            ret

;*******************************************************************************
; terminal Subroutine:
; Registers Used:
; Stack Used:
; This subroutine allows the video screen and keyboard to act as a dummy
; terminal for testing of serial peripheral equipment.
;
;*******************************************************************************
;
;                        123456789012334567890123456789012
termsg      .text       "Terminal Emulation Mode\r\r"
            .text       " ...to adjust settings, type\r"
            .text       "        >CTRL-R< and..."
adjmsg      .text       "\r *Baud Rate Adjustment:\r"
            .text       "  1 - 100 buad\r"
            .text       "  2 - 200 buad\r"
            .text       "  3 - 600 buad\r"
            .text       "  4 - 2400 buad\r"
            .text       "  5 - 4800 buad\r"
            .text       "  6 - 9600 buad\r"
            .text       " *Bits/Character Adjustment:\r"
            .text       "  7 - 7 bits/character\r"
            .text       "  8 - 8 bits/character\r\r\000"
escmsg      .text       "or press any other key to cancel\r\r\000"

terminal    ld          a,return    ;setup header
            CHROUT
            CHROUT
            ld          hl,termsg
            call        prtstg
            call        cominit
;
;The terminal reading loop (pc recycles here when there's nothing to do):
;
readin      call        rx          ;attempt to fetch a comm character.
            or          a
            jr          z,noprint   ;if there's a character, print it.
            CHROUT
noprint     CHRIN                   ;attempt to fetch a keyboard key..
            cp          escape
            jr          z,exiterm
            cp          ctrlr
            call        z,changerate
            jr          z,readin
            call        tx
            jr          readin

exiterm     ret


;*******************************************************************************
; changerate Subroutine:
; Registers Used:
; Stack Used:
;
;
;
;*******************************************************************************
;
changerate  push        af
            ld          hl,adjmsg   ;reprint help message.
            call        prtstg

getkey      CHRIN                   ;fetch a user command.
            or          a
            jr          z,getkey

            sub         '0'         ;ascii > binary
            jr          c,nochange  ;if it was invalid, ignore...
            jr          z,nochange
            cp          7
            jr          nc,dobit    ;check to see if it was to change the rate.

            dec         a
            ld          (baudset),a
            ld          e,a
            ld          a,(bitset)
            ld          d,a
            call        set_rate
            jr          nochange

dobit       cp          9
            jr          nc,nochange
            ld          (bitset),a
            ld          d,a
            ld          a,(baudset)
            ld          e,a
            call        set_rate
            jr          nochange

nochange    pop         af
            ret



;*******************************************************************************
; rx Subroutine:
; Registers Used:
; Stack Used:
; This subroutine reads one byte from the comm port or returns with the zero
; flag set if there was no data available.
;
;
;*******************************************************************************
;
rx          xor         a           ;read "read register 0"
            out         (sioaac),a
            in          a,(sioaac)
            and         00000001b   ;check for read character available.
            ret         z
            in          a,(sioaad)   ;fetch byte from comm port.
            push        de
            ld          e,a
            inc         e
            cp          e           ;return with no zero flag set.
            pop         de
            or          a
            ret

;*******************************************************************************
; tx Subroutine:
; Registers Used:
; Stack Used:
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
;*******************************************************************************
;

tx          push        af
tx1         xor         a           ;read "read register 0"
            out         (sioaac),a
            in          a,(sioaac)
            bit         2,a         ;check for an empty transmitter buffer.
            jr          z,tx1      ;if empty, keep trying until ready.
            pop         af
            out         (sioaad),a   ;send out data to comm port.
            ret

baud1t      .db         11h, 12h, 12h, 07h, 01h, 2fh, 01h, 0ch, 01h
            .db         06h, 01h, 03h
baud2t      .db         8ah, 01h, 81h,0cah, 41h,0aah,0c1h,0eah

;
;*******************************************************************************
; Subroutine:
; Registers Used:
; Stack Used:
;set the rs-232 parameters.  e=value for data rate, as follows:
;
; 00 = 50 bps   01 = 110 bps  02 = 300 bps    03 = 1200 bps  04 = 2400 bps
; 05 = 4800 bps 06 = 9600 bps 07 = ff invalid
;
; d=number of bits per character, normally 5 to 8. not range checked.
;
;exit: de,bc,hl destroyed.
;
;*******************************************************************************
;

set_rate    push        de
            push        hl
            push        de
            ld          hl,baud1t   ;<*** Set CTC Timer Rate ***>
            ld          a,e
            ld          (baudof),a
            ld          a,d
            ld          (bitnum),a
            sla         e
            ld          d,00
            add         hl,de
            ld          a,00000101b ;control word and time constant follows.
            out         (ctca0),a
            ld          a,(hl)
            out         (ctca0),a    ;set time constant for clock# 0.
            inc         hl
            ld          a,01000101b ;counter mode and constant follows.
            out         (ctca1),a
            ld          a,(hl)
            out         (ctca1),a    ;set counter constant for clock# 1.
            xor         a           ;<*** Set SIO Read & Write parameters ***>
            out         (sioaac),a   ;make sure selected is write register# 0
            ld          a,00000100b ;Select write register# 4
            out         (sioaac),a
            ld          a,01000100b ;x16 clock mode, 1 stop bit per character.
            out         (sioaac),a
            ld          a,1
            out         (sioaac),a   ;select write register# 1
            xor         a
            out         (sioaac),a   ;Disable Rx and Tx interrupts,
            pop         af
            sub         05h
            sla         a
            ld          e,a
            ld          d,00
            ld          hl,baud2t   ;9f9
            add         hl,de
            ld          a,00000011b ;Set write register# 3.
            out         (sioaac),a
            ld          a,(hl)
            inc         hl
            out         (sioaac),a   ;
            ld          a,00000101b ;Set write register# 5.
            out         (sioaac),a
            ld          a,(hl)
            out         (sioaac),a
            pop         hl
            pop         de
            ret





;*******************************************************************************
; pr2hex Subroutine:
; Registers Used:
; Stack Used:
;
;
;*******************************************************************************
;
pr2hex      push        af
            push        de
            ld          a,d
            call        prhex
            ld          a,e
            call        prhex
            pop         de
            pop         af
            ret

;*******************************************************************************
; prhex Subroutine:
; Registers Used:
; Stack Used:
;
;
;
;*******************************************************************************
;
prhex       push        af
            push        bc
            push        de
            ld          c,a
            srl         a
            srl         a
            srl         a
            srl         a
            call        prfixup
            CHROUT
            ld          a,c
            and         $f
            call        prfixup
            CHROUT
            pop         de
            pop         bc
            pop         af
            ret

;*******************************************************************************
; prfixup Subroutine:
; Registers Used:
; Stack Used:
;
;*******************************************************************************
;
prfixup     add         a,'0'
            cp          '9'+1
            ret         m
            add         a,'a'-'9'
            ret

;*******************************************************************************
; bin2bin Subroutine:
; Registers Used:
; Stack Used:
; This subroutine prints out a binary number to the screen as 0s and 1s.
;
;*******************************************************************************
;
bin2bin     push        af
            push        bc
            ld          b,7
            sla         a
nextbin     sla         a
            push        af
            call        displaybin
            pop         af
            djnz        nextbin
            ld          a,return
            CHROUT
            pop         bc
            pop         af
            ret

;*******************************************************************************
; displaybin Subroutine:
; Registers Used:
; Stack Used:
;
;
;
;*******************************************************************************
;
displaybin  jr          c,disone
            ld          a,'0'
            CHROUT
            ret
disone      ld          a,'1'
            CHROUT
            ret


;*******************************************************************************
; ramcheck Subroutine:
; Registers Used:
; Stack Used:
; Performs a complete memory check of system, video, and extended RAM memory.
; Exits to pwr_ok or pwr_error with an error code in E depending on memory
; status.  Extended memory is also checked for overlapping areas.
;*******************************************************************************
;
vidram2     .equ        $8000
vidram2end  .equ        $a0
sysram      .equ        $a000
sysramend   .equ        $c0
extended    .equ        $c000
extendedln  .equ        $3fff
vidcode     .equ        1
syscode     .equ        2
page0code   .equ        3
page0       .equ        0


ramcheck    ld          hl,sysram               ;system ram checking
pageramchk  ld          d,page0                 ;page ram checking
            ld          e,10101010b
pageramnext ld          a,d
            ld          hl,extended             ;hl holds starting address.
            ld          bc,extendedln/4         ;bc/4 holds the length.
            out         (rampage),a             ;set the ram page to test.
            call        bitchart                ;initialize a bit pattern.
            inc         d
            ld          a,d
            cp          page0+3
            jr          nz,pageramnext

            ld          d,page0                 ;now check the key patterns.
pageramtest ld          a,d
            ld          hl,extended
            ld          bc,extendedln/4
            out         (rampage),a             ;set the ram page.
            call        bitcheck
            jr          c,pageramerr            ;abort if there was an error.
            inc         d
            ld          a,d
            cp          page0+3
            jr          nz,pageramtest
            jp          pwr_ok                  ;ram all ok, go to next phase

pageramerr  ld          a,d                     ;calculate page error code
            add         a,page0code
            ld          e,a
            jp          pwr_error               ;perform error sequence.

;*******************************************************************************
; pwr_error Subroutine:
; Registers Used:
; Stack Used:
; This routine handles memory errors with the error code in register E.
; An attempt to place the code to the video screen is made here.
; Normally on a power on self test, the error code would be flashed to a port.
;*******************************************************************************
;
pwr_msg     .text       "\rMemory Error code: \000"

pwr_error   push        af
            ld          hl,pwr_msg              ;print the error string.
            call        prtstg
            pop         af
            push        af
            ld          a,e                     ;print the error code.
            add         a,'0'
            CHROUT
            pop         af
            jr          flash

;*******************************************************************************
; flash Subroutine:
; Registers Used:
; Stack Used:
;
;
;*******************************************************************************
;
flash       exx
            ld          a,e
            exx
            ld          b,a
fl1         ld          hl,0
            ld          a,$01
fl1b        out         (adc),a
fl1a        dec         l
            jr          nz,fl1a
            dec         h
            jr          nz,fl1a
            xor         $01
            jp          m,fl2
            jr          fl1b
fl2         djnz        fl1
            ld          b,5
fl3         dec         hl
            ld          a,h
            or          l
            jr          nz,fl3
            djnz        fl3
            jr          flash

;*******************************************************************************
; pwr_ok Subroutine:
; Registers Used:
; Stack Used:
;
;
;
;*******************************************************************************
;
pwr_okmsg   .text       "\rMemory all ok.\r\000"

pwr_ok      ld          hl,pwr_okmsg            ;print the 'ok' message.
            call        prtstg
            ret




;*******************************************************************************
; bitchart Subroutine:
; Registers Used:
; Stack Used:
; This subroutine initializes a memory addressing test with the memory address
; starting at hl and ending at bc*4.  DE is a
; unique key pattern that will be embedded into the test area.
;*******************************************************************************
;
bitchart    ld          (hl),l
            inc         hl
            ld          (hl),h
            inc         hl
            ld          (hl),e
            inc         hl
            ld          (hl),d
            inc         hl
            dec         bc
            ld          a,b
            or          c
            jr          nz,bitchart
            ret

;*******************************************************************************
; bitcheck Subroutine:
; Registers Used:
; Stack Used:
; This subroutine tests an intialized memory addressing test area with the
; address area starting at hl and ending at bc*4.
; DE is a unique key pattern that must match with memory area.  Carry flag
; is set if there is an error.
;*******************************************************************************
;
bitcheck    ld          a,(hl)
            cp          l
            jr          nz,bitcherr
            inc         hl
            ld          a,(hl)
            cp          h
            jr          nz,bitcherr
            inc         hl
            ld          a,(hl)
            cp          e
            jr          nz,bitcherr
            inc         hl
            ld          a,(hl)
            cp          d
            jr          nz,bitcherr
            inc         hl
            dec         bc
            ld          a,b
            or          c
            jr          nz,bitcheck
            ret
bitcherr    scf
            ret




;*******************************************************************************
;nextck Subroutine:
;Registers Used:
;Stack Used:
;This subroutine checks RAM memory and returns a zero flag upon sucess.
;*******************************************************************************
;
nextck	    ld		a,(hl)
            xor         $ff
            ld          (hl),a
            cp          (hl)
	    ret 	nz
            xor         $ff
            ld          (hl),a
            inc         hl
            dec         bc
            ld          a,c
            or          b
	    jr		nz,nextck
	    ret

;*******************************************************************************
;Estartup Subroutine:F
;Registers Used:
;
;*******************************************************************************
;
startup     call        hires_drv
            ld          a,return
            CHROUT
            ret

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
            call        initppi
            ld          hl,font
            ld          (fontaddr),hl
            xor         a
            ld          (inverse),a
            ld          a,ppigraphic
            out         (ppib),a
            ld          hl,chrout
            ld          ($b004),hl
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
doblank     ld          hl,grend-(8*xlen)+1
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
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;145   '
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;146   '
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;147   "
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;148   "
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;149   o
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;150   -
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;151   -
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;152   ò
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;153   ô
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;154   ö
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;155   õ
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;156   ú
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;157   ù
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;158   û
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;159   ü
            .db         $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ;160    
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

;*******************************************************************************
;*******************************************************************************
; RAM AREA:
;*******************************************************************************
;*******************************************************************************
;
.org        ramstart


;*******************************************************************************
; Software Variables:
;
;*******************************************************************************
;                   
baudset     .ds         1
bitset      .ds         1

minst       .ds         1           ;scratch calaculation step buffer

mx          .ds         1           ;last calculated mouse coordinates
my          .ds         1

ml          .ds         1           ;last calculated left mouse button  0=off
mr          .ds         1           ;last calculated right mouse button 0=off

mx2         .ds         1           ;mouse pointer buffer used by the mouse
my2         .ds         1           ;driver for calculating the x,y coordinates
checkloc    .ds         2
cursory     .ds         1           ;location of Y coordinate (0-255)
cursorx     .ds         1           ;location of X coordinate (0-192)
cursorblk   .ds         cursorsize  ;temporary cursor swap block
addrgr      .ds         2           ;quick access address

;*******************************************************************************
; isr_table:
; Registers Used:
; Stack Used:
;
;
;
;*******************************************************************************
;
isr_table   .org        (($ + $ff) & $ff00)
            .dw         mouse_isr
            .dw         dma_isr
;*******************************************************************************
;EVARIABLESF
;*******************************************************************************
fontaddr    .ds         2
fontreserve .dw         font
inverse     .ds         1
rptcnt      .ds         2
rptflag     .ds         1
scanjump    .db         $c3
scantemp    .dw         $a52
tabdat      .ds         1
baudof      .ds         2
bitnum      .ds         2



            .end
