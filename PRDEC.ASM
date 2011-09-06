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
; Registers Used:
; Stack Used:
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

