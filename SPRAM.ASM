variables   .org        $6250
last	    .ds 	1	    ;variable:	last value read
value	    .ds 	10	    ;variable:	current weight
dectext     .ds 	10	    ;buffer:	decimal text
xpos	    .ds 	1
scale	    .equ	$8	    ;port:	pulse port
digitalker  .equ        $18         ;port:      digitalker
lcd         .equ        $00         ;port:      lcd
waitime     .equ        $29         ;variable:  time delay
space       .equ        $20         ;variable:  ascii space
nul         .equ        0           ;variable:  zero
chk_wrt     .equ        $00
wrt_dat     .equ        $01
lcd_str     .equ        $01
chk_rd      .equ        $02
set_ent     .equ        $06
dat_len     .equ        $0f
get_wrd     .equ        $0f
lcd_set     .equ        $38
dis_2       .equ        $c0


;*******************************************************************************
main        .org        $6300
;*******************************************************************************
;
	    jp		start

start	    call	lcd_init
	    call	namedisp    ;initially displays my name on the lcd

                                    ;test talking scale
main1       call        clearscale  ;scale is reset at start of this only.

main2       call        read
	    call	waitnext    ;wait for weight to change

	    call	cls
	    call	readoff     ;do one reading
	    jr		main2	    ;loop again


;******************************************************************************
;waitnext Subroutine
;Registers Used:
;This subroutine waits until the weight has settled to read off the weight
;
;******************************************************************************
;
waitlast    .ds 	1	    ;last holding weight
holdtime    .equ	12
holdweight  .equ	5

waitnext    push	af
	    push	bc
	    push	de
	    push	hl
	    ld		hl,waitlast

waitnexta   call	read
	    ld		a,(value)
	    ld		b,(hl)
	    cp		b
	    jr		z,waitnexta

waitnext2   call	read	    ;loop nothing until weight > 5lbs
	    ld		a,(value)
	    ld		(hl),a
	    cp		holdweight  ;don't do readout under minimum weight
	    jr		c,waitnext2
	    cp		0-holdweight
	    jr		nc,waitnext2;don't do readout if out of range
	    ld		(hl),a	    ;load holding weight

	    ld		b,0	    ;reset holding timer


waitnext3   inc 	b	    ;increment speak-nothing timer
	    call	miniwait
	    ld		a,b
	    cp		holdtime
	    jr		z,waitnexte ;weight is holding, leave wait
	    call	read
	    ld		a,(value)
	    cp		(hl)
	    jr		z,waitnext3 ;loop hold end
	    jr		waitnext2   ;weight changed, start holding over

waitnexte   pop 	hl
	    pop 	de
	    pop 	bc
	    pop 	af
	    ret

;******************************************************************************
;miniwait Subroutine
;Registers Used:
;This subroutine produces a small delay
;
;******************************************************************************
;
miniwait    push	af
	    push	bc
	    ld		b,0
miniwait1   call	read
	    djnz	miniwait1
	    pop 	bc
	    pop 	af
	    ret

;*******************************************************************************
;name display Subroutine
;Registers used:
;This subroutine displays my name to the lcd upon power-up
;
;*******************************************************************************
;
namedisp    call	cls
            call        name
            ret

;******************************************************************************
;lcd_init Subroutine
;Registers Used:
;This subroutine initializes the lcd display
;
;******************************************************************************
;
;chk_wrt     .equ	 $00	    ;read port
;wrt_dat     .equ	 $01	    ;write port
;lcd_str     .equ	 $01	    ;00000001	display clear
;chk_rd      .equ	 $02	    ;00000010	display cursor home
;set_ent     .equ	 $06	    ;00000110	entry mode set
;dat_len     .equ	 $0f	    ;00001111
;get_wrd     .equ	 $0f	    ;00001111	display/cursor on/on
;lcd_set     .equ	 $38	    ;00111000	function set
;dis_2	     .equ	 $c0	    ;11000000	right half display
lcd_init    push	af
	    ld		a,lcd_set   ;function set
            out         (chk_wrt),a
            call        bus_sig
	    ld		a,get_wrd   ;display/cursor on/on
            out         (chk_wrt),a
            call        bus_sig
	    ld		a,lcd_str   ;diplay clear
            out         (chk_wrt),a
            call        bus_sig
	    ld		a,set_ent   ;entry mode set
            out         (chk_wrt),a
	    xor 	a
	    ld		(xpos),a    ;reset x-position to 0 on lcd
	    pop 	af
            ret


;******************************************************************************
;bus_sig Subroutine
;Registers Used:
;This subroutine checks the busy status of the lcd display
;
;******************************************************************************
;
bus_sig     push	af
bus_sig1    in		a,(chk_rd)
            bit         7,a
	    jr		nz,bus_sig1
	    pop 	af
            ret

;******************************************************************************
;cls Subroutine
;Registers Used:
;This subroutine clears the lcd display
;
;******************************************************************************
;
cls	    push	af
	    push	bc
	    push	de
	    push	hl
	    call	lcd_init
	    pop 	hl
	    pop 	de
	    pop 	bc
	    pop 	af
	    ret

;******************************************************************************
;name Subroutine
;Registers Used:
;This subroutine prints out my name.
;
;******************************************************************************
;
name	    ld		hl,word3
	    call	prtstg
            ret

word3	    .text	" JAMES O. SIME"
	    .db 	0


;*******************************************************************************
;prtstg Subroutine
;Registers Used:
;This subroutine outputs a string pointed to by the HL-reg, terminated with nul.
;
;*******************************************************************************
;
prtstg	    ld		a,(hl)	    ;fetch character to be printed
	    or		a	    ;check for terminating null character
            ret         z
	    call	chrout	    ;print it
	    inc 	hl	    ;move to next character in the string
	    jr		prtstg	    ;re-run the loop


;*******************************************************************************
;chrout Subroutine
;Registers Used:        af
;This subroutine outputs a A-reg character to the LCD screen.
;
;*******************************************************************************
;
clrscrctrl  .equ        $01
rightctrl   .equ        $06
leftctrl    .equ        $07
delctrl     .equ        $08

chrout      push        af
            push        bc
            push        de
            push        hl
	    cp		$20	    ;check for control characters
	    jr		c,control   ;if they are not printable, control...
	    call	outlcd	    ;output to the lcd
	    call	nextchr     ;move character to the next location
	    jr		chroute

control     push        af
            cp          clrscrctrl
            jr          nz,right

clrscr	    call	cls
            jr          controle

right       cp          rightctrl   ;backspace one character
            jr          nz,left
            ld          a,00010100b
            call        outlcd
	    call	nextchr
            jr          controle

left        cp          leftctrl
            jr          nz,del
            ld          a,00010101b
            call        outlcd
            jr          controle

del         cp          delctrl
            jr          nz,controle
            ld          a,00010100b
            call        outlcd
            jr          controle

controle    pop         af
            jr          chroute

chroute     pop         hl
            pop         de
            pop         bc
            pop         af
            ret


;******************************************************************************
;diplayrt Subroutine
;Registers Used:
;This subroutine shifts the cursor address to the right half of the display.
;
;******************************************************************************
;
displayrt   push	af
	    ld		a,dis_2
	    out 	(chk_wrt),a
	    call	bus_sig
	    ld		a,$c0
	    out 	(chk_wrt),a
	    call	bus_sig
	    pop 	af
	    ret

;*******************************************************************************
; nextchr Subroutine
;Registers Used:
;This subroutine advances the lcd character position one space
;
;*******************************************************************************
;
nextchr     push	af
	    ld		a,(xpos)
	    inc 	a
	    ld		(xpos),a
	    cp		8
	    jr		nz,nextchre

	    call	displayrt
nextchre    pop 	af
	    ret 		    ;not needed in this application


;*******************************************************************************
;outlcd Subroutine
;Registers Used:        af
;This subroutine outputs a character directly to the LCD port.
;
;*******************************************************************************
;
outlcd      push        af
	    call	bus_sig     ;the LCD might be a little slow today
	    out 	($01),a
            pop         af
            ret

;*******************************************************************************
;clearscale Subroutine
;Register Notes:        none
;This subroutine clears the weight variable.
;
;*******************************************************************************
;
clearscale  push        af
            push        hl
            call        reset
            ld          hl,0
            ld          (value),hl
            pop         hl
            pop         af
            ret

;*******************************************************************************
;scaletest Subroutine
;Register Notes:        none
;This subroutine tests the scale pulse decoder through the buffer subroutine.
;
;*******************************************************************************
;
scaletest   call        clearscale
            ld          hl,0
            call        reset       ;initialize the weight variable

demo2       call        read
            ld          a,$d
	    call	chrout
            ld          hl,(value)
            call        $f8
            jr          demo2

;*******************************************************************************
;scaletest2 Subroutine
;Register Notes:        none
;This subroutine tests the scale pulse decoder directly.
;
;*******************************************************************************
;
scaletest2  call        clearscale
            ld          hl,0
            call        reset       ;initialize the weight variable

demoa       in          a,(scale)
            push        af
            ld          a,$d
	    call	chrout
            pop         af
            ld          l,a
            ld          h,0
            call        $f8
            jr          demoa

;*******************************************************************************
; reset Subroutine:
; Register Notes:       af
; This subroutine resets the 'weight' variable and enables the read subroutine.
;
;*******************************************************************************
;
reset       xor         a
            ld          (value),a   ;reset weight variable
            ld          (last),a    ;store initial vector
            call        inscale
            ld          (last),a    ;store initial vector
            ret

;*******************************************************************************
; read Subroutine:
; Register Notes:       af, bc.
; This subroutine updates the 'weight' variable.
;
;*******************************************************************************
;0230230230230230230230230230230230230230230230230230230230230230230230230230230
;
read        push        bc
            ld          a,(last)
            ld          c,a
            call        inscale     ;get the pulse value
            ld          b,a         ;b=current, c=previous

            or          a
            jr          nz,cond1
                                    ;0
cond0       ld          a,c
            cp          3           ;3i
            jr          z,ince
            cp          2           ;2d
            jr          z,dece
            jr          end

cond1       ld          a,b
            cp          2
            jr          nz,cond2
                                    ;2
            ld          a,c
            or          a           ;0i
            jr          z,ince
            cp          3           ;3d
            jr          z,dece
            jr          end

cond2       ld          a,b
            cp          3
            jp          nz,$bc6
                                    ;3
            ld          a,c
            cp          2           ;2i
            jr          z,ince
            or          a           ;0d
            jr          z,dece
            jr          end

ince        call        incbuf
            jr          end

dece        call        decbuf
            jr          end

end         pop         bc
            ret

;*******************************************************************************
;incbuf Subroutine
;Register Notes:        none
;This subroutine increments the weight value.
;
;*******************************************************************************
;
incbuf      push        af
            ld          a,b
            ld          (last),a
            ld          a,(value)
            inc         a
            ld          (value),a
            pop         af
            ret

;*******************************************************************************
;decbuf Subroutine
;Register Notes:        none
;This subroutine decrements the weight value.
;
;*******************************************************************************
;
decbuf      push        af
            ld          a,b
            ld          (last),a
            ld          a,(value)
            dec         a
            ld          (value),a
            pop         af
            ret

;*******************************************************************************
;inscale Subroutine
;Register Notes:        af
;This subroutine reads the value of the port and returns a valid value.
;
;*******************************************************************************
;
inscale     in          a,(scale)
            and         11b
            cp          1           ;eliminate invalid error readings
            jr          nz,inscalee
            ld          a,(last)
inscalee    ret

;*******************************************************************************
;wait Subroutine
;Register Notes:        none
;This subroutine causes a wait and reads the scale during the intermission.
;
;*******************************************************************************
;
wait        push        af
            push        bc
	    push	de
	    push	hl

            ld          bc,waitime  ;set delay
wait2       call        read        ;adjust scale weight
            djnz        wait2
            dec         c
            ld          a,b
            or          c
            jr          nz,wait2    ;burn off calories

	    pop 	hl
	    pop 	de
            pop         bc
            pop         af
            ret

;*******************************************************************************
;readoff Subroutine
;Register Notes:        none
;This subroutine reads off the weight through the digitalker.
;
;*******************************************************************************
;
weightloc   .ds 	1	    ;temporary scratchpad

readoff     push        af
            push        bc
            push        de
            push        hl

	    ld		a,(value)
	    ld		(weightloc),a

	    push	af			;speak "weight is"
            ld          a,10001111b ;"weight"
            call        readout
            ld          a,01100000b ;"is"
            call        readout
            pop         af

	    push	af
	    call	weightout   ;call out the weight
	    pop 	af

	    cp		20	    ;
            jr          nc,continue
            cp          10
            jr          c,continue
	    call	readout     ;read em out load
            jr          readoffe

;speak out from millions ... to tens to ones:

continue    ld		de,dectext		;get weight
	    ld		a,(weightloc)		;buffer area
            ld          h,0
            ld          l,a
            push        de
            push        hl
            call        bin2asc
            pop         hl
            pop         de

            ex          de,hl
            dec         hl
	    ld		b,5+1	    ;number of locations to read

;B-reg:     exponent value
;A-reg:     mantissa
;HL-regs:   pointer

readoff2    dec         b
            inc         hl
            jr          z,readoffe  ;end of readoff

            ld          a,(hl)      ;fetch current digit
            cp          space
            jr          z,readoff2  ;ignore leading spaces
            cp          nul
            jr          z,readoffe  ;done
            sub         '0'         ;convert to binary
            call        convert     ;convert digit into proper weighted word
            call        readout     ;read it out loud
            jr          readoff2    ;continue loop until all words are spoken

readoffe    push        af
            ld          a,01111011b ;"pound"
            call        readout
            ld          a,10000001b ;"'s"
            call        readout
            pop         af

            pop         hl
            pop         de
            pop         bc
            pop         af
            ret

;*******************************************************************************
;weightout Subroutine
;Registers Used:
;This subroutine prints out the weight on the lcd.
;
;*******************************************************************************
;
weight1     .text	"Weight is: \000"

weightout   push        af
            push        bc
            push        de
            push        hl
            ld          hl,weight1
            call        prtstg
	    ld		a,(weightloc)
	    call	dec2lcd
            pop         hl
            pop         de
            pop         bc
            pop         af
            ret


;*******************************************************************************
;convert Subroutine
;Register Notes:        af, b.
;This subroutine converts the current digital into the proper word(s) to say
;A-reg is the mantissa, B-reg is the exponent.
;*******************************************************************************
;
convert     push        bc

            ld          c,a
            ld          a,b         ;check exponent
            cp          1
            jr          nz,convert2
            ld          a,c
            jr          converte    ;ones, no exponent

convert2    cp          2
            jr          nz,convert3 ;9x,8x,7x,6x,5x,4x,3x,2x.
            ld          a,c
            or          a
            jr          z,convertz
            cp          1
            jr          z,convertt
            add         a,10100b-2d
            jr          converte

convert3    ld          a,c         ;x00,x000,x0000...
            call        readout     ;speak value
            ld          a,b
            add         a,11100b-3d ;speak exponent
                                                   
converte    pop         bc
            ret

convertz    call        readout
            jr          converte

convertt    dec         b
            inc         hl
            ld          a,(hl)
            sub         '0'
            add         a,10
            pop         hl
            ret

;*******************************************************************************
;asc2bin Subroutine
;Register Notes:        none
;This subroutine converts ascii text into digitalker numbers.
;
;*******************************************************************************
;
asc2bin     push        af
            push        bc
            push        de
            push        hl
            ld          hl,asctable
            push        hl
            pop         de
            inc         de
asc2binl    ld          b,(hl)      ;fetch one off the tree
            cp          b
            jr          z,asc2bin2  ;is it the word of the day?

            ld          c,a         ;check for end of table
            ld          a,(hl)
            or          a
            ld          a,c
            jr          z,asc2bine

            inc         hl          ;increment table loop
            inc         hl
            inc         de
            inc         de
            jr          asc2binl

asc2bin2    ld          a,(de)
            call        readout

asc2bine    pop         hl
            pop         de
            pop         bc
            pop         af
            ret

;*******************************************************************************
;readout Subroutine
;Register Notes:        af
;This subroutine articulates one word of the A-reg through the digitalker.
;
;*******************************************************************************
;
readout     or          a           ;say nothing if no word to be spoken
            ret         z
            out         (digitalker),a
            call        wait
            ret

;*******************************************************************************
; dec2lcd Subroutine:
; Registers Used:
; Stack Used:
; This subroutine prints out the A-Register as a decimal number to the screen.
;
;
;*******************************************************************************
;
dec2lcd     push	af
	    push	hl
	    ld		l,a
	    ld		h,0
	    call	p_int
	    pop 	hl
	    pop 	af
	    ret

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

asctable    .db         '0',        00011111b
            .db         '1',        1
            .db         '2',        2
            .db         '3',        3
            .db         '4',        4
            .db         '5',        5
            .db         '6',        6
            .db         '7',        7
            .db         '8',        8
            .db         '9',        9
            .db         0,0


progend     .end
