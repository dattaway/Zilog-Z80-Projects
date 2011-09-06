;*******************************************************************************
;*			    ADC Digital Sampling Scope			       *
;*				       04				       *
;*				 Duane P. Attaway			       *
;*				 9DA-EET 490				       *
;*	This program impliments a simple digital storage oscilliscope	       *
;*	through the use of a peripherial ADC.  Sweep time is adjustable        *
;*	through the keyboard menu interface.				       *
;*									       *
;*									       *
;*									       *
;*******************************************************************************

;<*** Hardware Interface ***>
page	    .equ	$00
adc	    .equ	$01
ctc	    .equ	$04
ctca	    .equ	ctc
ctcb	    .equ	ctc+1
ctcc	    .equ	ctc+2
ctcd	    .equ	ctc+3
sysram      .equ        $a000
sysramend   .equ        extended
extended    .equ        $c000
extendedln  .equ        $4000
extpages    .equ        $04
page0       .equ        0
rampage     .equ        $00         ;extended memory register port
ppitext     .equ        11111111b
ramtop      .equ        $c000       ;stack reference pointer




;<*** Graphing Parameters ***>
windowsize  .equ	$05	    ;number of text lines in the window.
leftgraph   .equ	$08	    ;width in pixels of the ordinate.
lowergraph  .equ	$00	    ;offset in pixels of the abcissa.
rightgraph  .equ	$ff	    ;maximum horizontal width in pixels.
;*******************************************************************************
;*Hi-Res Character Generator V1.1z				Duane P. Attaway
;*6502 Version: 12/1984;  Apple ][+e program
;*Z80 Version:	5/1991;   EDM mini program
;*Update 1:	6/9/1991; Scroll and Tab routines added
;*
;*
;*
;*******************************************************************************
;
;<*** Hardware Interface ***>
vidppi	    .equ	$08 ;$8c
ppi	    .equ	$08	    ;device used by the keyboardscan routine.
ppia	    .equ	ppi
ppib	    .equ	ppi+1
ppic	    .equ	ppi+2
ppicntrl    .equ	ppi+3

vidppia     .equ	vidppi
vidppib     .equ	vidppi+1
vidppic     .equ	vidppi+2
vidppicntrl .equ	vidppi+3

;<*** Hardware Screen Attributes ***>
vidram	    .equ	$8000 ;$4000	   ;start of video area
vidlen	    .equ	$1ff	    ;length of text video
grlen	    .equ	$17ff	    ;length of graphics page
grend	    .equ	vidram+grlen;end of graphics page
xlen	    .equ	$20	    ;maximum x length
ylen	    .equ	$18	    ;maximum y length

;<*** Graphics Driver Varibles ***>
fontlen     .equ	$08
fontlength  .equ	$100*fontlen

;<*** Graphing Parameters ***>
window	    .equ	grend-(fontlen*xlen*windowsize)
				    ;menu displayed at the bottom of the screen.
windowbytes .equ	windowsize*fontlen*xlen
				    ;size of window for cls.
uppergraph  .equ	fontlen*ylen-windowsize*fontlen
				    ;maximum vertical size in pixels.
winlin1     .equ	(ylen-windowsize)*$100
				    ;(x,y) coordinates in characters of line# 1.
winlin2     .equ	winlin1+$xlen
winlin3     .equ	winlin2+$xlen
winlin4     .equ	winlin3+$xlen
winlin5     .equ	winlin4+$xlen

;<*** Keyboard Control ***>
;8255 CONTROLLER
;   76543210	*** CONTROL WORD ***  --FOR PPICNTRL PORT
;   ≥≥≥≥≥≥≥≥
;   ≥≥≥≥≥≥≥¿ƒƒƒƒPORT C-- 1/INPUT; 0/OUTPUT  (LOWER BITS-PC3-PC0) ø
;   ≥≥≥≥≥≥¿ƒƒƒƒƒPORT B-- 1/INPUT; 0/OUTPUT			 ≥MODE GROUP A
;   ≥≥≥≥≥¿ƒƒƒƒƒƒMODE SELECTION--  0/MODE 0; 1/MODE 1		 Ÿ
;   ≥≥≥≥¿ƒƒƒƒƒƒƒPORT C-- 1/INPUT; 0/OUTPUT  (UPPER BITS-PC7-PC4) ø
;   ≥≥≥¿ƒƒƒƒƒƒƒƒPORT A-- 1/INPUT; 0/OUTPUT			 ≥MODE GROUP B
;   ≥≥¿ƒƒƒƒƒƒƒƒƒ⁄MODE SELECTION-- 00 MODE 0, 01 MODE1,		 ≥
;   ≥¿ƒƒƒƒƒƒƒƒƒƒ¿		  1x MODE 2			 Ÿ
;   ¿ƒƒƒƒƒƒƒƒƒƒƒ 1= I/O MODE;  2= BSR MODE (BIT-SET-RESET)
;
;   76543210
;   ≥≥≥≥≥≥≥≥
;   ≥≥≥≥≥≥≥¿ƒƒƒƒS/R:  1= SET, 0= RESET
;   ≥≥≥≥¿¡¡ƒƒƒƒƒBIT:  000 BIT0, 001 BIT1, 010 BIT2, 011 BIT3, ECT...
;   ≥¿¡¡ƒƒƒƒƒƒƒƒxxx:  NOT USED, SET TO ZERO
;   ¿ƒƒƒƒƒƒƒƒƒƒƒBSR:  0
;
ppiomode    .equ	10001001b   ;initializing register for the EDM.
bppictrl    .equ	10000000b
cppictrl    .equ	00001000b
cppimask    .equ	01000000b
ppigraphic  .equ	11010111b

;<*** ASCII Keyboard Function Codes ***>
ctrla	    .equ	1
ctrlb	    .equ	2
ctrlc	    .equ	3
ctrld	    .equ	4
ctrle	    .equ	5
ctrlf	    .equ	6
ctrlg	    .equ	7
ctrlh	    .equ	8
ctrli	    .equ	9
ctrlj	    .equ	10
ctrlk	    .equ	11
ctrll	    .equ	12
ctrlm	    .equ	13
ctrln	    .equ	14
ctrlo	    .equ	15
ctrlp	    .equ	16
ctrlq	    .equ	17
ctrlr	    .equ	18
ctrls	    .equ	19
ctrlt	    .equ	20
ctrlu	    .equ	21
ctrlv	    .equ	22
ctrlw	    .equ	23
ctrlx	    .equ	24
ctrly	    .equ	25
ctrlz	    .equ	26
tab	    .equ	$c
return	    .equ	$0d
left	    .equ	$18
right	    .equ	$19
up	    .equ	$1c
down	    .equ	$1a
backspace   .equ	$08
esc	    .equ	$1b
space	    .equ	$20

;<*** ROM Interface ***>
#define     CHROUT	rst	    10h

;<*** Include Variables ***>
nul	    .equ	0
neg	    .equ	-1
bit8mask    .equ	111b	    ;used for bytewise calculations
waitdelay   .equ	10000	    ;prevent keybouncing

;*******************************************************************************
;EmainF
;Stack Used:		requires $800 bytes for safe operation (int and nmi).
;This program impliments a simple digital storage oscilliscope
;through the use of a peripherial ADC.	Sweep time is adjustable
;through the keyboard menu interface.
;*******************************************************************************
;
;******************************************************************************
; STACK AREA
;
;******************************************************************************
;
stack	    .equ	$a800
	    .org	$0000
	    DI
	    DI
	    di
	    jp main
	    .org	$10
	    jp		chrout
	    .org	$38
;******************************************************************************
; sample Subroutine:
; Registers Used:	af',bc', de', hl'
; Stack Used: 2
;
;
;******************************************************************************
;
sample	    exx
	    ex		af,af'
	    dec 	bc
	    ld		a,c
	    or		b
	    jr		z,sampleq   ;no more samples and don't ei again

	    in		a,(adc)
	    ld		(hl),a
	    inc 	hl
	    ex		af,af'
	    exx
	    ei
	    reti

sampleq     ex		af,af'
	    exx
	    di
	    reti

;******************************************************************************

	    .org	$100
main	    ld		bc,0
maindelay   djnz	maindelay   ;prevent bouncing resets
	    dec 	c
	    jr		nz,maindelay

;******************************************************************************
; ramcheck Subroutine:
; Registers Used:
; Stack Used:
; This subroutine checks the system RAM area for bit integrety.
;
;******************************************************************************
;
            ld          hl,sysram
ramcheck    ld          a,(hl)                  ;perform flip-bit testing
            cpl
            ld          (hl),a
            cp          (hl)                    ;make sure memory gets changed!
            jr          nz,sysramerr            ;write error, send abort error.
            cpl
            ld          (hl),a                  ;restore value back.
            cp          (hl)
            jr          nz,sysramerr
            inc         hl
            ld          a,h
            cp          (sysramend>>8)
            jr          nz,ramcheck             ;work on next one...



;******************************************************************************
; main -continued-
; Critical system ram has been checked.  Now, other valuable system peripherals
; need to be checked:
;
;******************************************************************************
;
            ld          sp,ramtop

            ld          hl,sysramgood
            call        prtstg
            call        romcheck
            call        vidcheck
            call        extcheck
            call        siocheck
            call        ctccheck
            call        dmacheck
	    call	greetings
	    jp		main2
                
;******************************************************************************
; sysramerr Subroutine:
; Registers Used:
; Stack Used:
; This halting routine displays the diagnostic error message that the system
; memory is defective.
;
;******************************************************************************
;
sysramgood  .text       "System RAM OK!\r\00"
sysrammsg   .text       "System RAM Error!\00"
sysrammsge
sysramerr   ld          hl,sysrammsg
            ld          a,ppitext
            out         (ppib),a
            ld          bc,grlen
            ld          de,vidram
            ld          hl,vidram+1
            ld          (hl),space
            ldir
            ld          hl,sysrammsg
            ld          de,vidram
            ld          bc,sysrammsge-sysrammsg
            ldir
            halt


;******************************************************************************
; romcheck Subroutine:
; Registers Used:
; Stack Used:
; This subroutine checks the value of the preprogrammed checksum in the ROM
; for integrety, and if it is bad, displays such a message and locks the
; system.
;
;******************************************************************************
;
romlength   .equ        $4000
rommsg      .text       "\rROM Checksum: \00"
rom2msg     .text       "INVALID ROM Checksum!\r\00"
romerrorcd  .equ        8
romcheck    ld          hl,rommsg
            call        prtstg
            ld          hl,0
            ld          bc,romlength-2
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
            push        de
            call        pr2hex
            pop         de
            ld          a,return
            CHROUT
            ld          hl,(checkloc)
            xor         a
            sbc         hl,de
            xor         a
            ret         z
            ld          hl,rom2msg
            call        prtstg
            halt
                
;******************************************************************************
; vidcheck Subroutine:
; Registers Used:
; Stack Used:
; This subroutine checks the video memory for bit integrety and will flash the
; screen if there is a ram failure, as well as displaying a message and locking
; the system.
;
;******************************************************************************
;
vidramend   .equ        vidram+vidlen

vidcheck    ld          hl,vidram
vidramcheck ld          a,(hl)                  ;perform flip-bit testing
            cpl
            ld          (hl),a
            cp          (hl)                    ;make sure memory gets changed!
            jr          nz,vidramerr            ;write error, send abort error.
            cpl
            ld          (hl),a                  ;restore value back.
            cp          (hl)
            jr          nz,vidramerr
            inc         hl
            ld          a,h
            cp          (vidramend>>8)
            jr          nz,vidramcheck          ;work on next one...
            ld          hl,vidram2msg
            call        prtstg
            ret

vidramerr   ld          hl,vidrammsg
            call        prtstg

vidbad	    halt

vidrammsg   .text       "Video Memory Corrupt!\00"
vidram2msg  .text       "Video Memory OK!\r\00"


;******************************************************************************
; extcheck Subroutine:
; Registers Used:
; Stack Used:
; This subroutine checks the extended memory pages for overlapping and bit
; integrety.  A message is displayed if there is a failure and the system will
; lock in such an event.
;
;******************************************************************************
;

extcheck    ld          d,page0                 ;page ram checking
pageramnext ld          a,d
            ld          hl,extended             ;hl holds starting address.
            ld          bc,extendedln/extpages  ;bc/4 holds the length.
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
            ld          hl,extramgood
            call        prtstg
            ret                                 ;ram all ok, go to next phase

pageramerr  ld          hl,extrammsg
            call        prtstg
            ld          a,d
            call        prhex
            halt

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


;******************************************************************************
; siocheck Subroutine:
; Registers Used:
; Stack Used:
; This subroutine checks the SIO Serial Input/Output device for proper
; interrupt operation.  If a MicroSoft Mouse is present, it will be initialized
; and its presence will be prompted to the screen.
;
;******************************************************************************
;
siookmsg    .text       "SIO OK!\r\00"
siomousemsg .text       "MicroSoft Mouse Enabled\r\00"
siobadmsg   .text       "SIO Failure!\r\00"

siocheck    ld          hl,siookmsg
            call        prtstg
            ret


;******************************************************************************
; ctccheck Subroutine:
; Registers Used:
; Stack Used:
; This subroutine checks the CTC Clock/Timer/Counter device for proper
; interrupt operation.  If all four channels do not work, then the device is
; declared bad, and is publicly scolded on the video screen for its sins.
;
;******************************************************************************
;
ctcokmsg    .text       "CTC OK!\r\00"
ctcbadmsg   .text       "CTC Failure!\r\00"

ctccheck    ld          hl,siookmsg
            call        prtstg
            ret


;******************************************************************************
; dmacheck Subroutine:
; Registers Used:
; Stack Used:
; This subroutine checks the DMA Direct Memory Accessor device for proper
; operation.  If memory does not move, then the device is probably castrated and
; not worth anything to society anyway.
;
;******************************************************************************
;
dmaokmsg    .text       "DMA OK!\r\00"
dmabadmsg   .text       "DMA Failure!\r\00"

dmacheck    ld          hl,dmaokmsg
            call        prtstg
            ret



;******************************************************************************
; greetings Subroutine:
; Registers Used:
; Stack Used:
; This subroutine introduces the user to the current state of the system.
; Whatever messages or pretty pictures need to be displayed, this is the time
; to show 'em.
;
;******************************************************************************
;
greetmsg    .text       "System Fully Operational!\r\"
            .text       "System Halted - no main\r\00"
greetings   ld          hl,greetmsg
            call        prtstg
            jp          ramcheck
            halt
            ret


main2
	    xor 	a
	    out 	(page),a
	    call	initppi     ;setup '8255 controller.
	    call	hires_drv   ;initialize graphics driver.
	    call	cls	    ;clear the graphics screen.
	    call	setgraph    ;setup grid pattern.
	    call	name
	    call	initbuffer  ;set initial sampling buffer parameters.
	    call	initadc     ;set up the adc operation.
	    call	initdivider ;initialize sampling varables

mainloop    call	clrwin	    ;clear graphics window.
	    call	setgraph    ;set up coordinates.
	    ld		hl,mainmsg
	    call	prtstg
	    call	displayst
	    call	waitkey
	    call	gotofn
	    jr		mainloop


gotofn	    ld		hl,jmpbar
	    ld		de,jmpaddr
nextfn	    cp		(hl)
	    jr		nz,nojump
	    ex		de,hl
	    ld		e,(hl)
	    inc 	hl
	    ld		d,(hl)
	    push	de
	    ret 		    ;exit to function - job all done.

nojump	    inc 	de
	    inc 	de
	    inc 	hl
	    ld		b,a
	    ld		a,(hl)
	    or		a
	    ret 	z
	    ld		a,b
	    jr		nextfn


jmpbar	    .db 	esc	    ;1
	    .db 	'R'         ;2
	    .db 	'C'         ;3
	    .db 	'P'         ;4
	    .db 	'U'         ;5
	    .db 	'D'         ;6
	    .db 	'-'         ;7
	    .db 	'+'         ;8
	    .db 	0	    ;9

jmpaddr     .dw 	exitall     ;1
	    .dw 	resample    ;2
	    .dw 	clearplot   ;3
	    .dw 	plotall     ;4
	    .dw 	timedown    ;5
	    .dw 	timeup	    ;6
	    .dw 	voltdown    ;7
	    .dw 	voltup	    ;8


exitall     jp		$0000

;*******************************************************************************
; timedown Subroutine:
; Registers Used: af,bc,de, & hl.
; Stack Used: 2
; This subroutine adjusts the time scale.
;*******************************************************************************
;
timedown    push	af
	    push	bc
	    push	de
	    push	hl
	    ld		a,(time)    ;don't overrange
	    or		a
	    jr		z,timedowne

	    dec 	a	    ;store new time sweep time
	    ld		(time),a

	    ld		hl,plotlist ;store selected samples per x plot slice
	    ld		e,a
	    ld		d,0
	    add 	hl,de
	    ld		a,(hl)
	    ld		(plotrate),a

	    ld		hl,timemaglist ;store selected display value for time
	    add 	hl,de
	    ld		a,(hl)
	    ld		(timemag),a

				    ;store selected display time unit
	    ld		hl,timelist
	    add 	hl,de
	    ld		a,(hl)
	    ld		(timediv),a
			   
timedowne   pop 	hl
	    pop 	de
	    pop 	bc
	    pop 	af
	    ret


;*******************************************************************************
; timeup Subroutine:
; Registers Used: af,bc,de, & hl.
; Stack Used: 2
; This subroutine adjusts the time scale.
;*******************************************************************************
;
;plotrate
;adc4
;from timediv
maxtimedivs .equ	5-1
plotlist    .db 	1, 10,30,100,255
timelist    .db 	1, 5, 10, 15, 20
timemaglist .db 	2, 2,  1,  0,  0

timeup	    push	af
	    push	bc
	    push	de
	    push	hl
	    ld		a,(time)    ;don't overrange
	    cp		maxtimedivs
	    jr		z,timeupex

	    inc 	a	    ;store new time sweep time
	    ld		(time),a

	    ld		hl,plotlist ;store selected samples per x plot slice
	    ld		e,a
	    ld		d,0
	    add 	hl,de
	    ld		a,(hl)
	    ld		(plotrate),a

	    ld		hl,timemaglist ;store selected display value for time
	    add 	hl,de
	    ld		a,(hl)
	    ld		(timemag),a

				    ;store selected display time unit
	    ld		hl,timelist
	    add 	hl,de
	    ld		a,(hl)
	    ld		(timediv),a
			   
timeupex    pop 	hl
	    pop 	de
	    pop 	bc
	    pop 	af
	    ret

;*******************************************************************************
;waitkey Subroutine:
;Registers Used:	af.
;Stack Used:		2
;This subroutine simply waits for a key to be pressed.
;*******************************************************************************
;
waitkey     call	scan
	    jr		z,waitkey

	    push	af
waitkey2    call	scan
	    jr		nz,waitkey2

	    pop 	af
	    ret

;*******************************************************************************
;Einitppi Subroutine:F
;Registers Used:	a & c.
;stack used:		0
;This subroutine initializes the ppi controller for keyboard input.
;*******************************************************************************
;
initppi     ld		a,ppiomode  ;write in the control word.
	    out 	(ppicntrl),a
	    out 	(vidppicntrl),a
	    ld		a,bppictrl
	    out 	(vidppib),a
	    ld		c,vidppib   ;initialize input/output status.
	    in		a,(c)	    ;important!
	    or		cppimask
	    out 	(c),a
	    ret

;*******************************************************************************
;name Subroutine:
;Registers Used:	af, de, & hl.
;Stack Used:		2
;This subroutine prints my name and other credits in the text window.
;*******************************************************************************
;
name	    ld		hl,banner
	    ld		de,winlin1
	    call	setxy
	    call	prtstg
	    ld		a,return
	    call	chrout
	    ret

;*******************************************************************************
;cls Subroutine:
;Registers Used:	af, bc, de, & hl.
;Stack Used:		none.
;This subroutine clears out the graphics area, like totally blank.
;Initialization of the driver also occurs here.
;*******************************************************************************
;
cls	    ld		a,ppigraphic;initialize screen
	    out 	(vidppib),a
	    call	initchr
	    ld		bc,grlen    ;clear screen
	    ld		de,vidram+1
	    ld		hl,vidram
	    ld		a,nul
	    ld		(hl),a
	    ldir
	    ld		de,nul	    ;set screen position
	    call	setxy
	    ret


;*******************************************************************************
;initchr Subroutine:
;Registers Used:
;
;*******************************************************************************
;
initchr
noinit	    ret

;*******************************************************************************
;clrwin Subroutine:
;Registers Used:	af, bc, de, & hl.
;Stack Used:		2
;This subroutine clears out the lower text window and repositions the cursor
;at the top of that text window.
;*******************************************************************************
;
clrwin	    push	af
	    push	bc
	    push	de
	    push	hl
	    ld		bc,windowbytes
	    ld		de,window+1
	    ld		hl,window
	    ld		a,nul
	    ld		(hl),a
	    ldir
	    ld		de,winlin1
	    call	setxy
	    pop 	hl
	    pop 	de
	    pop 	bc
	    pop 	af
	    ret

;*******************************************************************************
;hires_drv Subroutine:
;Registers Used:	hl.
;Stack Used:		0
;This subroutine initializes the character generator for proper operation.
;*******************************************************************************
;
hires_drv   call	initchr
	    ld		hl,font
	    ld		(fontaddr),hl
	    xor 	a
	    ld		(inverse),a
	    ld		a,ppigraphic
	    out 	(vidppib),a
	    ret

;*******************************************************************************
;pix Subroutine:
;Registers Used:	af, bc, de, & hl.
;Stack Used:		8
;This subroutine will plot on an x,y grid with the origin at the lower left hand
;window.  A-register is the x-coordinate, B-register holds the y-coordinate.
;*******************************************************************************
;
pix	    push	af
	    push	bc
	    push	de
	    push	hl
	    inc 	b
	    ld		c,a	    ;save the x-coordinate.
	    srl 	a	    ;divide by 8 -- pixel to bit conversion.
	    srl 	a
	    srl 	a
	    ld		hl,window+1 ;reference one line below lower left corner.
	    add 	a,l	    ;locate pointer address to x coordinate.
	    ld		l,a
	    ld		a,nul
	    adc 	a,h
	    ld		h,a	    ;x-coordinate now calculated for row-0.
	    ld		de,xlen     ;now calculate y-coordinate.
	    xor 	a
	    ld		a,b
xloop	    sbc hl,de		    ;recursively calculate y-offset.
	    djnz	xloop
	    ld		a,c	    ;now mask in the pixel.
	    and 	bit8mask
	    ld		b,a
	    xor 	a
	    scf
	    inc 	b
yloop	    rra 		    ;recursively find the pixel bit.
	    djnz	yloop
	    ld		b,(hl)	    ;filter in the previous pixels and save.
	    or		b
	    ld		(hl),a
	    pop 	hl
	    pop 	de
	    pop 	bc
	    pop 	af
	    ret

;*******************************************************************************
;calc_addr Subroutine:
;Registers Used:	af, bc, & hl.
;Stack Used:		6
;	  --THIS SUBROUTINE CALCULATES THE ADDRESS FOR THE COORDINATES IN THE
;	    DEFINED SPACE XYPOS AND XPOS.  THE RESULT IS RETURNED IN ADDR.
;
;*******************************************************************************
;
calc_addr   PUSH	AF
	    PUSH	BC
	    PUSH	HL
	    LD		A,(row)
	    LD		L,A
	    LD		H,0
	    ADD 	HL,HL	    ;*2  CALCULATE Y POSITION
	    ADD 	HL,HL	    ;*4
	    ADD 	HL,HL	    ;*8
	    ADD 	HL,HL	    ;*16
	    ADD 	HL,HL	    ;*32
	    ADD 	HL,HL	    ;*2  SKIP 8+4 SCAN LINES
	    ADD 	HL,HL	    ;*4
	    ADD 	HL,HL	    ;*8
	    LD		A,(column)
	    ADD 	A,L
	    LD		L,A
	    LD		BC,vidram
	    ADD 	HL,BC
	    LD		(addr),HL
	    POP 	HL
	    POP 	BC
	    POP 	AF
	    RET

;*******************************************************************************
;setxy Subroutine:
;Registers Used:	de.
;Stack Used:		2
;This subroutine takes the DE-Register pair to set the (x,y) screen character
;coordinates for the chrout driver.
;*******************************************************************************
;
setxy	    ld		(column),de ;store the coordinates.
	    call	calc_addr   ;calculate the screen address and store it.
	    ret

;*******************************************************************************
;prtstg Subroutine:
;Registers Used:	af & hl.
;Stack Used:		2
;This subroutine prints out a string of text terminated by a nul character.
;*******************************************************************************
;
prtstg	    call	calc_addr
nextstr     ld		a,(hl)
	    or		a
	    ret 	z
	    CHROUT
	    inc 	hl
	    jr		nextstr

;*******************************************************************************
;chrout Subroutine:
;Registers Used:	af, bc, de, & hl.
;Stack Used:		10
;      --   THIS ROUTINE TAKES THE A-REG CHARACTER AND PLACES IT AT THE CURRENT
;	    GRAPHICS POSITION. Cls MUST BE CALLED BEFORE THIS ROUTINE IS USED.
;*******************************************************************************
;
chrout	    push	af
	    push	bc
	    push	de
	    push	hl
	    cp		space	    ;check if it is a control character.
	    jr		c,grcontrol
	    call	calc_font
	    ld		de,(addr)   ;get the current graphic video address.
	    ld		c,a
	    ld		a,(inverse)
	    or		a
	    ld		a,c
	    jr		nz,out2
	    call	out_font    ;draw the font image to the graphic screen.
	    jr		nextout
out2	    call	out_fonti   ;draw the font image in inverse.
nextout     call	xinc
	    pop 	hl
	    pop 	de
	    pop 	bc
	    pop 	af
	    ret
grcontrol   call	controlmv   ;do the control function.
	    pop 	hl
	    pop 	de
	    pop 	bc
	    pop 	af
	    ret

;*******************************************************************************
;xdec Subroutine:
;Registers Used:	af & hl.
;Stack Used:		2
;This subroutine handles the character when it is moved to the left.  This
;soubroutine will fixup the position if it travels beyond screen boundries to
;"wrap" around the edges.
;*******************************************************************************
;
xdecback    call	xdec
	    ld		a,space
	    call	chrout
xdec	    ld		a,(column)  ;advance character left.
	    dec 	a
	    ld		(column),a
	    cp		neg
	    jr		nz,qdfixexit
eol	    ld		a,xlen-1    ;fix character to right on next line:
	    ld		(column),a
ydec	    ld		a,(row)     ;advance character up.
	    dec 	a
	    ld		(row),a
	    cp		neg
	    jr		nz,dfixexit
	    ld		a,ylen+neg  ;fix character to bottom of the screen.
	    ld		(row),a
dfixexit    call	calc_addr
	    ret
qdfixexit   ld		hl,addr
	    dec 	(hl)
	    ret


;*******************************************************************************
;controlmv Subroutine:
;Registers Used:	af.
;Stack Used:		2
;This subroutine dispatches any A-Register control characters if any are
;encountered.
;*******************************************************************************
;
controlmv   cp		return	    ;carriage return
	    jp		z,returnln
	    cp		left	    ;left arrow
	    jp		z,xdec
	    cp		backspace   ;backspace
	    jp		z,xdecback
	    cp		up	    ;up arrow
	    jp		z,ydec
	    cp		down	    ;down arrow
	    jp		z,yinc
	    cp		right	    ;right arrow
	    jp		z,xinc
	    cp		ctrlb	    ;set tabs
	    jp		z,settab
	    cp		ctrla	    ;tab
	    jp		z,dotab
	    cp		tab	    ;clear screen
	    jp		z,cls
	    cp		ctrlc	    ;clear window
	    jp		z,clrwin
	    cp		ctrlz	    ;clear to end of line
	    jp		z,clreol
	    cp		ctrli	    ;inverse
	    jp		z,doinverse
	    cp		ctrln	    ;normal
	    jp		z,donormal
	    cp		ctrlw
	    jp		z,doupfont
	    cp		ctrlq
	    jp		z,dodnfont
	    cp		ctrle
	    jp		z,exitfont
exit	    ret

;*******************************************************************************
;exitfont Subroutine:
;Registers Used:
;
;*******************************************************************************
;
exitfont

	    call	initppi
	    ld		de,nul
	    call	setxy
	    ld		hl,vidram
	    ld		bc,vidlen
	    ld		de,vidram+1
	    ld		(hl),space
	    ldir
	    ld		a,2
	    CHROUT
	    ret

;*******************************************************************************
;xinc Subroutine:
;Registers Used:	af & hl.
;Stack Used:		2
;This subroutine manages the character position and address on the graphics
;screen.  This subroutine is called after a character is placed on the screen to
;manage the next character's destiny.  An attempt to place the character one
;space to the right is made if possible.  If it spills over into the next line,
;corrections have to be made.  If controlling characters are entered, action
;will be performed on the coordinates.
;*******************************************************************************
;
xinc	    ld		a,(column)  ;advance character right.
	    inc 	a
	    ld		(column),a
	    cp		xlen
	    jr		c,qfixexit
returnln    xor 	a	    ;fix character to left on next line:
	    ld		(column),a
yinc	    ld		a,(row)     ;advance character down.
	    inc 	a
	    ld		(row),a
	    cp		ylen
	    jr		c,fixexit
	    dec 	a	    ;fix character at bottom of the screen.
	    ld		(row),a
	    call	scrollup
	    ld		a,(inverse)
	    or		a
	    jr		z,doblank
	    ld		a,neg
doblank     ld		hl,grend-(8*xlen)-1
	    ld		b,nul
blankbottom ld		(hl),a
	    inc 	hl
	    djnz	blankbottom
fixexit     call	calc_addr
	    ret
qfixexit    ld		hl,addr
	    inc 	(hl)
	    ret

;*******************************************************************************
;doupfont Subroutine:
;Registers Used:
;
;*******************************************************************************
;
doupfont    ld		hl,(fontaddr)
	    ld		de,fontlength
	    add 	hl,de
	    ld		(fontaddr),hl
	    ret

;*******************************************************************************
;dodnfont Subroutine:
;Registers Used:
;
;*******************************************************************************
;
dodnfont    ld		hl,(fontaddr)
	    ld		de,fontlength
	    xor 	a
	    sbc 	hl,de
	    ld		(fontaddr),hl
	    ret

;*******************************************************************************
;doinverse Subroutine:
;Registers Used:
;
;*******************************************************************************
;
doinverse   ld		a,neg
	    ld		(inverse),a
	    ret

;*******************************************************************************
;donormal Subroutine:
;Registers Used:
;
;*******************************************************************************
;
donormal    ld		a,nul
	    ld		(inverse),a
	    ret

;*******************************************************************************
;scrollup Subroutine:
;Registers Used:
;
;*******************************************************************************
;
scrollup    ld		hl,vidram+(xlen*8)
	    ld		de,vidram
	    ld		bc,xlen*8
nextscrl    push	bc	    ;move line
	    ldir
	    pop 	bc
	    push	hl	    ;check end
	    push	bc
	    ld		bc,grend
	    xor 	a
	    dec 	hl
	    sbc 	hl,bc
	    pop 	bc
	    pop 	hl
	    jr		nz,nextscrl
	    ret

;*******************************************************************************
;settab Subroutine:
;Registers Used:
;
;*******************************************************************************
;
settab	    ld		a,(column)
	    ld		(tabdat),a
	    ret

;*******************************************************************************
;dotab Subroutine:
;Registers Used:
;
;*******************************************************************************
;
dotab	    ld		a,(tabdat)
	    ld		(column),a
	    call	calc_addr
	    ret

;*******************************************************************************
;clreol Subroutine:
;Registers Used:
;
;*******************************************************************************
;
clreol	    ld		a,xlen
	    ld		hl,column
	    sub 	(hl)
	    jr		z,endclreol
	    ld		b,a
	    ld		c,a
	    ld		a,space
fillspace   call	chrout
	    djnz	fillspace
	    ld		b,c
	    ld		a,left
backspacef  call	chrout
	    djnz	backspacef
endclreol   ret

;*******************************************************************************
;calc_font Subroutine:
;Registers Used:	af, bc, & hl.
;Stack Used:		none.
;This subroutine calculates the 8x8 font pointed to by a-Register.  Pointer is
;returned in hl_Register.
;*******************************************************************************
;

calc_font   ld		l,a
	    LD		H,nul	      ;calculate the font address:
	    ADD 	HL,HL	      ;skip over to the font character pointed to
	    ADD 	HL,HL	      ;by A-Register (a font is 8x8, so multiply by 8).
	    ADD 	HL,HL
	    LD		BC,(fontaddr) ;add the offset to get the corrected font address.
	    ADD 	HL,BC
	    ret

;*******************************************************************************
;out_font Subroutine:
;Registers Used:	af, bc, de, & hl.
;Stack Used:		none.
;This subroutine builds a font image pointed to by hl_Register to the graphics
;screen pointed to by de_Register.
;*******************************************************************************
;
out_font    LD		BC,xlen     ;quick adding variable to skip video lines.
	    ex		de,hl
	    LD		A,(de)	    ;fetch a font row.
	    LD		(hl),A	    ;place it in video memory to build font image.
	    add 	hl,bc	    ;get on down to the next row.
	    inc 	de	    ;get next font image.
	    LD		A,(de)	    ;Font line# 2
	    LD		(hl),A
	    add 	hl,bc
	    inc 	de
	    LD		A,(de)	    ;Font line# 3
	    LD		(hl),A
	    add 	hl,bc
	    inc 	de
	    LD		A,(de)	    ;Font line# 4
	    LD		(hl),A
	    add 	hl,bc
	    inc 	de
	    LD		A,(de)	    ;Font line# 5
	    LD		(hl),A
	    add 	hl,bc
	    inc 	de
	    LD		A,(de)	    ;Font line# 6
	    LD		(hl),A
	    add 	hl,bc
	    inc 	de
	    LD		A,(de)	    ;Font line# 7
	    LD		(hl),A
	    add 	hl,bc
	    inc 	de
	    LD		A,(de)	    ;Font line# 8
	    LD		(hl),A
	    ex		de,hl
	    RET

;*******************************************************************************
;out_fonti Subroutine:
;Registers Used:	af, bc, de, & hl.
;Stack Used:		none.
;This subroutine builds a inverse font image pointed to by hl_Register to the
;graphics screen pointed to by de_Register.
;*******************************************************************************
;
out_fonti   LD		BC,xlen     ;quick adding variable to skip video lines.
	    ex		de,hl
	    LD		A,(de)	    ;fetch a font row.
	    xor 	$ff
	    LD		(hl),A	    ;place it in video memory to build font image.
	    add 	hl,bc	    ;get on down to the next row.
	    inc 	de	    ;get next font image.
	    LD		A,(de)	    ;Font line# 2
	    xor 	$ff
	    LD		(hl),A
	    add 	hl,bc
	    inc 	de
	    LD		A,(de)	    ;Font line# 3
	    xor 	$ff
	    LD		(hl),A
	    add 	hl,bc
	    inc 	de
	    LD		A,(de)	    ;Font line# 4
	    xor 	$ff
	    LD		(hl),A
	    add 	hl,bc
	    inc 	de
	    LD		A,(de)	    ;Font line# 5
	    xor 	$ff
	    LD		(hl),A
	    add 	hl,bc
	    inc 	de
	    LD		A,(de)	    ;Font line# 6
	    xor 	$ff
	    LD		(hl),A
	    add 	hl,bc
	    inc 	de
	    LD		A,(de)	    ;Font line# 7
	    xor 	$ff
	    LD		(hl),A
	    add 	hl,bc
	    inc 	de
	    LD		A,(de)	    ;Font line# 8
	    xor 	$ff
	    LD		(hl),A
	    ex		de,hl
	    RET

;******************************************************************************
; initdivider Subroutine:
; Registers Used: af,bc,de, & hl.
; Stack Used: 2
; This subroutine is to initialize the voltage divider for the ADC to a known
; state upon power up.
;
;******************************************************************************
;

initdivider push	af
	    xor 	a
	    ld		(time),a    ;time control for sampling
	    out 	(ppia),a
	    ld		(timemag),a ;calculated - initialize display variables
	    inc 	a
	    ld		(timediv),a		;calculated - initialy 1 ms/div
	    ld		(voltlevel),a		;ms/div
	    pop 	af
	    ret

;*******************************************************************************
; pr2hex Subroutine:
; Registers Used: af,bc,de, & hl.
; Stack Used: 2
;
;
;*******************************************************************************
;
pr2hex	    push	af
	    push	de
	    ld		a,d
	    call	prhex
	    ld		a,e
	    call	prhex
	    pop 	de
	    pop 	af
	    ret

;*******************************************************************************
; prhex Subroutine:
; Registers Used: af,bc,de, & hl.
; Stack Used: 2
;
;
;
;*******************************************************************************
;
prhex	    push	af
	    push	bc
	    push	de
	    ld		c,a
	    srl 	a
	    srl 	a
	    srl 	a
	    srl 	a
	    call	prfixup
	    CHROUT
	    ld		a,c
	    and 	$f
	    call	prfixup
	    CHROUT
	    pop 	de
	    pop 	bc
	    pop 	af
	    ret

;*******************************************************************************
; prfixup Subroutine:
; Registers Used: af,bc,de, & hl.
; Stack Used: 2
;
;*******************************************************************************
;
prfixup     add 	a,'0'
	    cp		'9'+1
	    ret 	m
	    add 	a,'a'-'9'-1
	    ret

;*******************************************************************************
; bin2bin Subroutine:
; Registers Used: af,bc,de, & hl.
; Stack Used: 2
; This subroutine prints out a binary number to the screen as 0s and 1s.
;
;*******************************************************************************
;
bin2bin     push	af
	    push	bc
	    ld		b,7
	    sla 	a
nextbin     sla 	a
	    push	af
	    call	displaybin
	    pop 	af
	    djnz	nextbin
	    ld		a,return
	    CHROUT
	    pop 	bc
	    pop 	af
	    ret

;*******************************************************************************
; displaybin Subroutine:
; Registers Used: af,bc,de, & hl.
; Stack Used: 2
;
;
;
;*******************************************************************************
;
displaybin  jr		c,disone
	    ld		a,'0'
	    CHROUT
	    ret
disone	    ld		a,'1'
	    CHROUT
	    ret

;******************************************************************************
; voltup  Subroutine:
; Registers Used: af,bc,de, & hl.
; Stack Used: 2
; This subroutine increases the voltage range by changing the relay divider.
;
;******************************************************************************
;

voltup	    push	af
	    push	hl
	    ld		a,(voltlevel)
	    cp		relaydataen-relaydata-1
	    jr		nc,voltupexit
	    inc 	a
voltupexit2 ld		(voltlevel),a
	    call	relayadj
	    pop 	hl
	    pop 	af
	    ret

voltupexit  ld		a,relaydataen-relaydata
	    jr		voltupexit2

relaydata   .db 	110b,101b,011b
relaydataen

;*******************************************************************************
; relayadj Subroutine:
; Registers Used: af,bc,de, & hl.
; Stack Used: 2
; This subroutine adjusts the relay voltage divider according to the level of
; the A-Register.
;
;*******************************************************************************
;
relayadj    push	af
	    push	de
	    push	hl
	    ld		hl,relaydata
	    ld		e,a
	    ld		d,0
	    add 	hl,de
	    ld		a,(hl)
	    out 	(ppia),a
	    pop 	hl
	    pop 	de
	    pop 	af
	    ret

;******************************************************************************
;voltdown Subroutine:
; Registers Used: af,bc,de, & hl.
; Stack Used: 2
; This subroutine decreases the voltage range by changing the relay divider.
;
;******************************************************************************
;
voltdown    push	af
	    push	hl
	    ld		a,(voltlevel)
	    cp		1
	    jr		c,voltdowne
	    dec 	a
voltdowne2  ld		(voltlevel),a
	    call	relayadj
	    pop 	hl
	    pop 	af
	    ret
voltdowne   xor 	a
	    jr		voltdowne2

;
;******************************************************************************
;bin2asc -- this subroutine converts an unsigned int type in hl into decimal
;ascii that is stored in a buffer pointed by de.  it is used internally by
;p_int and has potential use where formatted integer output is required.
;
;call must load hl with the value and point de to a suitable buffer area.
;the buffer must be at least 6 characters in length, as bin2asc will fill it
;with up to a 5 digit number, and a zero terminator byte.  bin2asc performs
;leading zero suppression (leading zeroes are converted to 20h space codes).
;on return, hl and de will have their original values.
;******************************************************************************
;
bin2asc     push	af
	    push	bc
	    push	de
	    push	hl
	    push	ix
	    push	de
	    push	de
	    ld		b,05
	    ld		a,'0'
bin2asc1    ld		(de),a
	    inc 	de
	    djnz	bin2asc1
	    xor 	a
	    ld		(de),a
	    pop 	ix
	    ld		bc,bintbl
bin2asc5    ld		a,(bc)
	    ld		e,a
	    inc 	bc
	    ld		a,(bc)
	    ld		d,a
	    inc 	bc
	    or		e
	    jr		z,bin2asc2
bin2asc4    or		a
	    sbc 	hl,de
	    jr		c,bin2asc3
	    inc 	(ix+00)
	    jr		bin2asc4
bin2asc3    add 	hl,de
	    inc 	ix
	    jr		bin2asc5
bin2asc2    pop 	hl
	    ld		b,04
bin2asc8    ld		a,(hl)
	    or		a
	    jr		z,bin2asc7
	    cp		'0'
	    jr		nz,bin2asc7
	    ld		(hl),space
	    inc 	hl
	    djnz	bin2asc8
bin2asc7    pop 	ix
	    pop 	hl
	    pop 	de
	    pop 	bc
	    pop 	af
	    ret

bintbl	    .db 	10h, 27h,0e8h, 03h, 64h, 00h, 0ah
	    .db 	00h, 01h, 00h, 00h, 00h

;*******************************************************************************
;p_int -- prints the contents of the hl register pair as an unsigned decimal
;integer.  leading zero suppression is automatic, and no spaces are printed on
;either side of the number.  output goes to the current output device, normally
;the screen.  load hl with the value to print and call p_int.  10 bytes of stack
;are required.
;*******************************************************************************
;
p_int	    push	hl
	    push	de
	    push	af
	    ex		de,hl
	    ld		hl,0fff8h
	    add 	hl,sp
	    ld		sp,hl
	    ex		de,hl
	    call	bin2asc
p_inta	    ld		a,(de)
	    cp		20
	    jr		nz,p_int1
	    inc 	de
	    jr		p_inta
p_int1	    ex		de,hl
	    call	prtstg
	    ld		hl,0008h
	    add 	hl,sp
	    ld		sp,hl
	    pop 	af
	    pop 	de
	    pop 	hl
	    ret

;*******************************************************************************
; pradec Subroutine:
; Registers Used: af,bc,de, & hl.
; Stack Used: 2
; This subroutine prints out the A-Register as a decimal number to the screen.
;
;
;*******************************************************************************
;
pradec	    push	af
	    push	hl
	    ld		l,a
	    ld		h,0
	    call	p_int
	    pop 	hl
	    pop 	af
	    ret

;******************************************************************************
; displayst Subroutine:
; Registers Used: af,bc,de, & hl.
; Stack Used: 2
; This subroutine displays the status of the 1) voltage range, 2) time division
; and 3) adc state.
;
;******************************************************************************
;


disp1	    .text	"Time slice:\000"
disp1x	    .db 	'm','u','n','p'
disp2x	    .dw 	1,100,1
disp2	    .text	"Voltage:   \000"
disp3	    .text	"ADC            \000"
disprdy     .text	"rdy\000"
dispbsy     .text	"bsy\000"

displayst   push	af
	    push	de
	    push	hl

	    ld		d,1	    ;set status line position
	    ld		e,0
	    call	setxy
	    ld		a,return
	    CHROUT

	    ld		hl,disp1    ;print time division
	    call	prtstg
	    ld		a,(timediv)
	    call	pradec

	    ld		a,(timemag) ;print time magnification factor
	    ld		hl,disp1x
	    ld		e,a
	    ld		d,0
	    add 	hl,de
	    ld		a,(hl)
	    CHROUT
	    ld		a,'S'
	    CHROUT
	    ld		a,return
	    CHROUT

	    ld		hl,disp2    ;print voltage division
	    call	prtstg
	    ld		a,(voltlevel)
	    sla 	a
	    ld		hl,disp2x
	    ld		e,a
	    ld		d,0
	    add 	hl,de
	    ld		e,(hl)
	    inc 	hl
	    ld		d,(hl)
	    ex		de,hl
	    call	p_int

	    ld	       a,(voltlevel);don't print 'm' prefix
	    cp		2
	    jr		z,nomv
	    ld		a,'m'
	    CHROUT
nomv	    ld		a,'V'       ;print 'V' suffix
	    CHROUT
	    ld		a,' '
	    CHROUT		    ;print a space to finish off old line
	    ld		a,return
	    CHROUT

endispst    pop 	hl
	    pop 	de
	    pop 	af
	    ret





;
;*******************************************************************************
;Escan Subroutine:F
;Registers Used:	af, bc, & d.
;Stack Used:		4
;This subroutine polls the keyboard and if any keys are pressed, an appropriate
;ASCII code is returned.  A nul character is returned if no keys are pressed.
;*******************************************************************************
;
scan	    in		a,(ppic)
	    xor 	11111111b   ;convert from active low
	    ret 	z

	    push	bc
	    push	hl

	    ld		b,nul
debounce    in		a,(ppic)
	    xor 	11111111b
	    jr		z,scanexit
	    djnz	debounce

	    ld		c,a	    ;find character code for corresponding key
	    ld		b,keytablen-keytable
	    ld		a,10000000b
	    ld		hl,keytable-1
findkey     rlc 	a
	    inc 	hl
	    cp		c
	    jr		z,foundkey
	    djnz	findkey
	    ld		a,c	    ;return at least something if more than one
				    ;key has been pressed.
	    jr		scanexit

keytable    .db 	'-','+','U','D','P','C','R',esc
keytablen

scanexit    pop 	hl
	    pop 	bc
	    ret

foundkey    ld		a,(hl)
	    or		a
	    jr		scanexit


;<*** Analog/Digital Communications ***>
no_samples  .equ	$4000	    ;<*** Number of Samples ***>

;<*** ROM Interface ***>




;*******************************************************************************
;resample routine:
;Registers Used:	none.
;Stack Used:		2
;This routine is called by main to enable a resample by re-enabling the
;interrupts.
;*******************************************************************************
;
resample    push	af
	    call	initadc
	    pop 	af
	    ret

;*******************************************************************************
;clearplot Subroutine:
;Registers Used:	none.
;Stack Used:		2
;This subroutine is called by main to clear the graphing area for a new graph.
;*******************************************************************************
;
clearplot   call	cls
	    ret

;*******************************************************************************
;plotall Subroutine:
;Registers Used:	af, bc, de, & hl.
;Stack Used:		14
;This subroutine plots contents of the buffer of range plotrate in the graphic
;window.
;*******************************************************************************
;

plotall     push	af
	    push	bc
	    push	de
	    push	hl
	    ld		hl,buffer   ;start at the beginning of the buffer.
	    ld		d,leftgraph ;
plotfory    ld		a,(plotrate)
	    ld		e,a

plotin	    ld		a,(hl)
	    srl 	a
	    ld		b,a
	    ld		a,d
	    call	pix
	    inc 	hl

	    dec 	e
	    jr		nz,plotin

	    inc 	d
	    jr		z,endplot

	    push	hl
	    push	de
	    ld		de,buffend
	    xor 	a
	    sbc 	hl,de
	    pop 	de
	    pop 	hl
	    jr		c,plotfory

endplot     pop 	hl
	    pop 	de
	    pop 	bc
	    pop 	af
	    ret

;*******************************************************************************
;initadc Subroutine:
;Registers Used:	af & b.
;This subroutine starts the adc conversion process.
;*******************************************************************************
;
intvect     .equ	$a013

initadc
	    push	af
	    push	bc
	    push	hl

	    di			    ;*** change sampling mode to 'on' ***
	    exx
	    ld		hl,buffer
	    ld		bc,buffend-buffer
	    exx

	    ld		b,nul
waitinit    djnz	waitinit

	    di
	    im		1
	    ld		c,ctca
	    ld		a,$85
	    out 	(c),a
	    ld		a,$1
	    out 	(c),a

	    pop 	hl
	    pop 	bc
	    pop 	af
	    ei
	    ret

;*******************************************************************************
;initbuffer Subroutine:
;Registers Used:	af, bc, de, & hl.
;Stack Used:		0
;This subroutine sets up the ROM interrupt vectors, plotrate, and the buffer.
;*******************************************************************************
;

initbuffer  ld		hl,nul
	    ld		hl,plotrate
	    ld		a,1
	    ld		(plotrate),a
	    ret

;*******************************************************************************
;setgraph Subroutine:
;Registers Used:	af & b.
;Stack Used:		2
;This subroutine plots out the abcissa and the ordinate bars.
;*******************************************************************************
;
setgraph    push	af
	    push	bc
	    push	de
	    push	hl
	    ld		a,leftgraph
	    ld		b,lowergraph;plot the yline.
yline	    call	pix
	    inc 	b
	    push	af
	    ld		a,b
	    cp		uppergraph
	    pop 	af
	    jr		nz,yline
	    ld		b,lowergraph;plot the xline.
xline	    call	pix
	    inc 	a
	    cp		rightgraph
	    jr		nz,xline
				    ;draw the divisions

ygrid	    ld		b,lowergraph;origon
	    ld		c,12	    ;number of y-divisions
nygridr     ld		a,leftgraph-3
nygrid	    call	pix
	    inc 	a
	    cp		leftgraph
	    jr		nz,nygrid
	    push	af
	    ld		a,b
	    add 	a,10
	    ld		b,a
	    pop 	af
	    dec 	c
	    jr		nz,nygridr

	    pop 	hl
	    pop 	de
	    pop 	bc
	    pop 	af
	    ret


;*******************************************************************************
;DATA AREA
;*******************************************************************************
;

font
;FONT 1 -- 8x8 COMPACT "ZX81" STYLE FONT; FULL ASCII 8-BIT CODE.
	    .DB        0F0H,0F0H,0F0H,0F0H,000H,000H,000H,000H	;0    UL SQUARE
	    .DB        00FH,00FH,00FH,00FH,000H,000H,000H,000H	;1    UR SQUARE
	    .DB        0FFH,0FFH,0FFH,0FFH,000H,000H,000H,000H	;2    U RECTANGLE
	    .DB        000H,000H,000H,000H,0F0H,0F0H,0F0H,0F0H	;3    LL SQUARE
	    .DB        0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H	;4    L RECTANGLE
	    .DB        00FH,00FH,00FH,00FH,0F0H,0F0H,0F0H,0F0H	;5    LL UR SQUARES
	    .DB        0FFH,0FFH,0FFH,0FFH,0F0H,0F0H,0F0H,0F0H	;6    LL UL UR SQR
	    .DB        0AAH,055H,0AAH,055H,0AAH,055H,0AAH,055H	;7    GREY
	    .DB        000H,000H,000H,000H,0AAH,055H,0AAH,055H	;8    L GREY
	    .DB        0AAH,055H,0AAH,055H,000H,000H,000H,000H	;9    U GREY
	    .DB        000H,01CH,022H,078H,020H,020H,07EH,000H	;10   POUND
	    .DB        0ffH,0ffH,0ffH,0ffH,0ffH,0ffH,0ffH,0ffH	;11   white space
	    .DB 	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	;12
	    .DB 	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	;13
	    .DB 	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	;14
	    .DB 	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	;15
	    .DB 	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	;16
	    .DB 	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	;17
	    .DB 	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	;18
	    .DB 	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	;19
	    .DB 	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	;20
	    .DB 	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	;21
	    .DB 	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	;22
	    .DB 	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	;23
	    .DB 	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	;24
	    .DB 	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	;25
	    .DB 	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	;26
	    .DB 	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	;27
	    .DB 	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	;28
	    .DB 	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	;29
	    .DB 	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	;30
	    .DB 	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	;31
	    .DB 	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	;32	  SPACE
	    .DB        010H,010H,010H,010H,010H,000H,010H,000H	;33	 !
	    .DB        000H,024H,024H,000H,000H,000H,000H,000H	;34	 "
	    .DB        000H,024H,07EH,024H,024H,07EH,024H,000H	;35	 #
	    .DB        000H,008H,03EH,028H,03EH,00AH,03EH,008H	;36	 $
	    .DB        000H,062H,064H,008H,010H,026H,046H,000H	;37	 %
	    .DB        010H,028H,010H,02AH,024H,02AH,010H,000H	;38	 &
	    .DB        000H,008H,008H,010H,000H,000H,000H,000H	;39	 '
	    .DB        000H,004H,008H,008H,008H,008H,004H,000H	;40	 (
	    .DB        000H,020H,010H,010H,010H,010H,020H,000H	;41	 )
	    .DB        000H,000H,014H,008H,03EH,008H,014H,000H	;42	 *
	    .DB        000H,000H,008H,008H,03EH,008H,008H,000H	;43	 +
	    .DB        000H,000H,000H,000H,000H,008H,008H,010H	;44	 ,
	    .DB        000H,000H,000H,000H,03EH,000H,000H,000H	;45	 -
	    .DB        000H,000H,000H,000H,000H,018H,018H,000H	;46	 .
	    .DB        000H,000H,002H,004H,008H,010H,020H,000H	;47	 /
	    .DB        000H,03CH,046H,04AH,052H,062H,03CH,000H	;48	 0
	    .DB        000H,018H,028H,008H,008H,008H,03EH,000H	;49	 1
	    .DB        000H,03CH,042H,002H,03CH,040H,07EH,000H	;50	 2
	    .DB        000H,03CH,042H,00CH,002H,042H,03CH,000H	;51	 3
	    .DB        000H,008H,018H,028H,048H,07EH,008H,000H	;52	 4
	    .DB        000H,07EH,040H,07CH,002H,042H,03CH,000H	;53	 5
	    .DB        000H,03CH,040H,07CH,042H,042H,03CH,000H	;54	 6
	    .DB        000H,07EH,002H,004H,008H,010H,010H,000H	;55	 7
	    .DB        000H,03CH,042H,03CH,042H,042H,03CH,000H	;56	 8
	    .DB        000H,03CH,042H,042H,03EH,002H,03CH,000H	;57	 9
	    .DB        000H,000H,000H,010H,000H,000H,010H,000H	;58	 :
	    .DB        000H,000H,010H,000H,000H,010H,010H,020H	;59	 ;
	    .DB        000H,000H,004H,008H,010H,008H,004H,000H	;60	 <
	    .DB        000H,000H,000H,03EH,000H,03EH,000H,000H	;61	 =
	    .DB        000H,000H,010H,008H,004H,008H,010H,000H	;62	 >
	    .DB        000H,03CH,042H,004H,008H,000H,008H,000H	;63	 ?
	    .DB        000H,03CH,002H,03AH,02AH,03AH,042H,03CH	;64	 @
	    .DB        000H,03CH,042H,042H,07EH,042H,042H,000H	;65	 A
	    .DB        000H,07CH,042H,07CH,042H,042H,07CH,000H	;66	 B
	    .DB        000H,03CH,042H,040H,040H,042H,03CH,000H	;67	 C
	    .DB        000H,078H,044H,042H,042H,044H,078H,000H	;68	 D
	    .DB        000H,07EH,040H,07CH,040H,040H,07EH,000H	;69	 E
	    .DB        000H,07EH,040H,07CH,040H,040H,040H,000H	;70	 F
	    .DB        000H,03CH,042H,040H,04EH,042H,03CH,000H	;71	 G
	    .DB        000H,042H,042H,07EH,042H,042H,042H,000H	;72	 H
	    .DB        000H,03EH,008H,008H,008H,008H,03EH,000H	;73	 I
	    .DB        000H,002H,002H,002H,042H,042H,03CH,000H	;74	 J
	    .DB        000H,044H,048H,070H,048H,044H,042H,000H	;75	 K
	    .DB        000H,040H,040H,040H,040H,040H,07EH,000H	;76	 L
	    .DB        000H,042H,066H,05AH,042H,042H,042H,000H	;77	 M
	    .DB        000H,042H,062H,052H,04AH,046H,042H,000H	;78	 N
	    .DB        000H,03CH,042H,042H,042H,042H,03CH,000H	;79	 O
	    .DB        000H,07CH,042H,042H,07CH,040H,040H,000H	;80	 P
	    .DB        000H,03CH,042H,042H,052H,04AH,03CH,000H	;81	 Q
	    .DB        000H,07CH,042H,042H,07CH,044H,042H,000H	;82	 R
	    .DB        000H,03CH,040H,03CH,002H,042H,03CH,000H	;83	 S
	    .DB        000H,0FEH,010H,010H,010H,010H,010H,000H	;84	 T
	    .DB        000H,042H,042H,042H,042H,042H,03CH,000H	;85	 U
	    .DB        000H,042H,042H,042H,042H,024H,018H,000H	;86	 V
	    .DB        000H,042H,042H,042H,042H,05AH,024H,000H	;87	 W
	    .DB        000H,042H,024H,018H,018H,024H,042H,000H	;88	 X
	    .DB        000H,082H,044H,028H,010H,010H,010H,000H	;89	 Y
	    .DB        000H,07EH,004H,008H,010H,020H,07EH,000H	;90	 Z
	    .DB        000H,038H,020H,020H,020H,020H,020H,038H	;91	 [
	    .DB        000H,040H,020H,010H,008H,004H,002H,000H	;92	 \
	    .DB        000H,038H,008H,008H,008H,008H,008H,038H	;93	 ]
	    .DB        000H,010H,028H,044H,000H,000H,000H,000H	;94	 ^
	    .DB        000H,000H,000H,000H,000H,000H,000H,0FFH	;95	 _
	    .DB        000H,010H,010H,008H,000H,000H,000H,000H	;96	 `
	    .DB        000H,000H,03CH,002H,03EH,042H,03EH,000H	;97	 a
	    .DB        040H,040H,07CH,042H,042H,042H,07CH,000H	;98	 b
	    .DB        000H,000H,03CH,042H,040H,042H,03CH,000H	;99	 c
	    .DB        002H,002H,03EH,042H,042H,042H,03EH,000H	;100	 d
	    .DB        000H,000H,03CH,042H,07EH,040H,03EH,000H	;101	 e
	    .DB        018H,024H,020H,070H,020H,020H,020H,000H	;102	 f
	    .DB        000H,000H,03CH,042H,042H,03EH,002H,03CH	;103	 g
	    .DB        0C0H,040H,07CH,042H,042H,042H,042H,000H	;104	 h
	    .DB        010H,000H,030H,010H,010H,010H,038H,000H	;105	 i
	    .DB        010H,000H,030H,010H,010H,010H,050H,020H	;106	 j
	    .DB        040H,040H,048H,050H,060H,050H,048H,000H	;107	 k
	    .DB        030H,010H,010H,010H,010H,010H,038H,000H	;108	 l
	    .DB        000H,000H,036H,049H,049H,049H,049H,000H	;109	 m
	    .DB        000H,000H,0BCH,042H,042H,042H,042H,000H	;110	 n
	    .DB        000H,000H,03CH,042H,042H,042H,03CH,000H	;111	 o
	    .DB        000H,000H,03CH,042H,042H,07CH,040H,040H	;112	 p
	    .DB        000H,000H,03CH,042H,042H,03EH,002H,003H	;113	 q
	    .DB        000H,000H,05CH,020H,020H,020H,020H,000H	;114	 r
	    .DB        000H,000H,03EH,040H,03CH,002H,07CH,000H	;115	 s
	    .DB        000H,010H,038H,010H,010H,010H,018H,000H	;116	 t
	    .DB        000H,000H,042H,042H,042H,042H,03EH,000H	;117	 u
	    .DB        000H,000H,044H,044H,044H,028H,010H,000H	;118	 v
	    .DB        000H,000H,044H,044H,054H,054H,028H,000H	;119	 w
	    .DB        000H,000H,044H,028H,010H,028H,044H,000H	;120	 x
	    .DB        000H,000H,042H,042H,042H,03EH,002H,07CH	;121	 y
	    .DB        000H,000H,07EH,004H,018H,020H,07EH,000H	;122	 z
	    .DB        000H,008H,010H,010H,020H,010H,010H,008H	;123	 {
	    .DB        010H,010H,010H,010H,010H,010H,010H,010H	;124	 |
	    .DB        000H,020H,010H,010H,008H,010H,010H,020H	;125	 }
	    .DB        000H,000H,020H,054H,008H,000H,000H,000H	;126	 ~
	    .db        000h,000h,000h,000h,000h,000h,000h,0ffh	;127  underline
	    .DB        0F0H,0F0H,0F0H,0F0H,000H,000H,000H,000H	;128  UL SQUARE
	    .DB        00FH,00FH,00FH,00FH,000H,000H,000H,000H	;129  UR SQUARE
	    .DB        0FFH,0FFH,0FFH,0FFH,000H,000H,000H,000H	;130  U RECTANGLE
	    .DB        000H,000H,000H,000H,0F0H,0F0H,0F0H,0F0H	;131  LL SQUARE
	    .DB        0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H	;132  L RECTANGLE
	    .DB        00FH,00FH,00FH,00FH,0F0H,0F0H,0F0H,0F0H	;133  LL UR SQUARES
	    .DB        0FFH,0FFH,0FFH,0FFH,0F0H,0F0H,0F0H,0F0H	;134  LL UL UR SQR
	    .DB        0AAH,055H,0AAH,055H,0AAH,055H,0AAH,055H	;135  GREY
	    .DB        000H,000H,000H,000H,0AAH,055H,0AAH,055H	;136  L GREY
	    .DB        0AAH,055H,0AAH,055H,000H,000H,000H,000H	;137  U GREY
	    .DB        000H,01CH,022H,078H,020H,020H,07EH,000H	;138  POUND
	    .DB        0ffH,0ffH,0ffH,0ffH,0ffH,0ffH,0ffH,0ffH	;139  white space
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;140   å
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;141   ç
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;142   é
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;143   è
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;144   ê
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;145   ë
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;146   í
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;147   ì
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;148   î
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;149   ï
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;150   ñ
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;151   ó
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;152   ò
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;153   ô
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;154   ö
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;155   õ
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;156   ú
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;157   ù
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;158   û
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;159   ü
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;160   †
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;161   °
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;162   ¢
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;163   £
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;164   §
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;165   •
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;166   ¶
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;167   ß
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;168   ®
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;169   ©
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;170   ™
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;171   ´
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;172   ¨
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;173   ≠
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;174   Æ
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;175   Ø
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;176   ∞
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;177   ±
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;178   ≤
	    .db 	$10, $10, $10, $10, $10, $10, $10, $10	;179   ≥
	    .db 	$10, $10, $10, $30, $10, $10, $10, $10	;180   ¥
	    .db 	$10, $10, $f0, $10, $f0, $10, $10, $10	;181   µ
	    .db 	$28, $28, $28, $e8, $28, $28, $28, $28	;182   ∂
	    .db 	$00, $00, $00, $f8, $28, $28, $28, $28	;183   ∑
	    .db 	$00, $00, $f0, $10, $f0, $10, $10, $10	;184   ∏
	    .db 	$28, $28, $e8, $08, $e8, $28, $28, $28	;185   π
	    .db 	$28, $28, $28, $28, $28, $28, $28, $28	;186   ∫
	    .db 	$00, $00, $f8, $08, $e8, $28, $28, $28	;187   ª
	    .db 	$28, $28, $e8, $08, $f8, $00, $00, $00	;188   º
	    .db 	$28, $28, $28, $f8, $00, $00, $00, $00	;189   Ω
	    .db 	$10, $10, $f0, $10, $f0, $00, $00, $00	;190   æ
	    .db 	$00, $00, $00, $f0, $10, $10, $10, $10	;191   ø
	    .db 	$10, $10, $10, $1f, $00, $00, $00, $00	;192   ¿
	    .db 	$10, $10, $10, $ff, $00, $00, $00, $00	;193   ¡
	    .db 	$00, $00, $00, $ff, $10, $10, $10, $10	;194   ¬
	    .db 	$10, $10, $10, $1f, $10, $10, $10, $10	;195   √
	    .db 	$00, $00, $00, $ff, $00, $00, $00, $00	;196   ƒ
	    .db 	$10, $10, $10, $ff, $10, $10, $10, $10	;197   ≈
	    .db 	$10, $10, $1f, $10, $1f, $10, $10, $10	;198   ∆
	    .db 	$28, $28, $28, $2f, $28, $28, $28, $28	;199   «
	    .db 	$28, $28, $2f, $20, $3f, $00, $00, $00	;200   »
	    .db 	$00, $00, $3f, $20, $2f, $28, $28, $28	;201   …
	    .db 	$28, $28, $ef, $00, $ff, $00, $00, $00	;202    
	    .db 	$00, $00, $ff, $00, $ef, $28, $28, $28	;203   À
	    .db 	$28, $28, $2f, $20, $2f, $28, $28, $28	;204   Ã
	    .db 	$00, $00, $ff, $00, $ff, $00, $00, $00	;205   Õ
	    .db 	$28, $28, $ef, $00, $ef, $28, $28, $28	;206   Œ
	    .db 	$10, $10, $ff, $00, $ff, $00, $00, $00	;207   œ
	    .db 	$28, $28, $ff, $00, $00, $00, $00, $00	;208   –
	    .db 	$00, $00, $ff, $00, $ff, $28, $28, $28	;209   —
	    .db 	$00, $00, $ff, $28, $28, $28, $28, $28	;210   “
	    .db 	$28, $28, $28, $28, $3f, $00, $00, $00	;211   ”
	    .db 	$10, $10, $1f, $10, $1f, $00, $00, $00	;212   ‘
	    .db 	$00, $00, $1f, $10, $1f, $10, $10, $10	;213   ’
	    .db 	$00, $00, $3f, $28, $28, $28, $28, $28	;214   ÷
	    .db 	$28, $28, $ff, $28, $28, $28, $28, $28	;215   ◊
	    .db 	$10, $10, $ff, $10, $ff, $10, $10, $10	;216   ÿ
	    .db 	$10, $10, $10, $f0, $00, $00, $00, $00	;217   Ÿ
	    .db 	$00, $00, $00, $1f, $10, $10, $10, $10	;218   ⁄
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;219   €
	    .db 	$00, $00, $00, $00, $ff, $ff, $ff, $ff	;210   ‹
	    .db 	$f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0	;221   ›
	    .db 	$0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f	;222   ﬁ
	    .db 	$ff, $ff, $ff, $ff, $00, $00, $00, $00	;223   ﬂ
	    .db 	$00, $00, $00, $00, $00, $00, $00, $00	;224
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;225   ·
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;226   ‚
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;227   „
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;228   ‰
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;229   Â
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;230   Ê
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;231   Á
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;232   Ë
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;233   È
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;234   Í
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;235   Î
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;236   Ï
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;237   Ì
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;238   Ó
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;239   Ô
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;240   
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;241   Ò
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;242   Ú
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;243   Û
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;244   Ù
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;245   ı
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;246   ˆ
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;247   ˜
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;248   ¯
	    .db 	$00, $00, $28, $28, $00, $00, $00, $00	;249   ˘
	    .db 	$00, $00, $00, $10, $00, $00, $00, $00	;250   ˙
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;251   ˚
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;252   ¸
	    .db 	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff	;253   ˝
	    .db 	$00, $7e, $7e, $7e, $7e, $7e, $7e, $00	;254   ˛
	    .db 	$00, $00, $00, $00, $00, $00, $00, $00	;255
;
;*******************************************************************************
;
;
;*******************************************************************************
;
;<*** Help Screens ***>
;			 01234567890abcdef0123456789abcde
banner	    .text	"Hi-Res Character Generator v1.1z"
	    .text	"  5/31/91 by Duane P. Attaway   "
	    .text	"       EDM mini version\0000"
	    .text	"Press any key to continue . . .\000"

adjustbl    .db 	1, $5, $10, $15, $20, $25, $30, $35, $40, $41
mainmsg     .text	" VoltageƒTime¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒø    "
	    .text	" ≥ inc ≥ inc ≥ Clear≥ Help ≥    "
	    .text	" ≥ dec ≥ dec ≥ Plot ≥Sample≥    "
	    .text	" ¿ƒƒƒƒƒ¡ƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒŸ  \000"
extrammsg   .text       "Extended memory failure #\00"
extramgood  .text       "Extended memory OK!\r\00"
	    .org	 $8000-2
checkloc    .dw         $c410       ;strategic ROM checksum location

	    .org	$a000
time	    .ds 	1
tabdat	    .ds 	1
fontaddr    .ds 	2
inverse     .ds 	1
fontreserve .ds 	2
;<*** Buffer ***>
buffptr     .ds 	2	    ;where the intisr routine is placing data.
nmiptr	    .ds 	2	    ;where the nmiisr routine is sampling data.

;<*** Plotting Information ***>
plotrate    .ds 	1	    ;how many samples to skip during plots.
				    ;skip variables.

timediv     .ds 	1
timemag     .ds 	1
voltlevel   .ds 	1
column	    .ds 	1
row	    .ds 	1
addr	    .ds 	2
	    .org	$a800
buffer	    .ds 	no_samples  ;sample data area.
buffend

endprog
	    .end
