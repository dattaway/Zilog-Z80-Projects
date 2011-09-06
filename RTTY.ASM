;
;rtty reception program for edm-80
;
;(c) 1990, tom a. wheeler. all rights reserved.
;
;

ltr_flag        equ     624fh           ;flag for baudot/ascii (ram)


prtstg          equ     00d1h           ;kernal routine: print_string


figs            equ     11011b
ltrs            equ     11111b


                org     8000h           ;rom socket

;
;*** print opening screen ***
;

start:          ld      hl,msg1         ;offset of string to print
                call    prtstg          ;kernal print_string routine

;
;set rs-232 parameters
;

                ld      de,0500h        ;5 bits/char, 45.5 bps
                ld      a,3             ;command: rs232 parameters
                rst     08h             ;set parms

                jr      clear_flg       ;clear flag then go to loop

;
;now that everything is set up, go into terminal program loop.
;
;algorithm: if a character is received on the rs232 received data line,
;           convert it to ascii and print it on the video display.
;
;           if a key is pressed, interpret & process command.
;
;
;

loop:           ld      a,2             ;device #2-rs232
                rst     28h             ;chkin--set input channel = rs-232
lp1:            rst     18h             ;getin--get or check character
                jr      z,no_232        ;no rs232 input data?

                call    b2asc           ;conv rtty to ascii

                cp      15              ;oh no, not the dreaded cursor-off!
                jr      z,no_232        ;if so, don't allow it!
                cp      01
                jr      z,no_232        ;no graphics mode
                rst     10h             ;output character to video display

;
;reset input channel back to keyboard for key check
;

no_232:         xor     a               ;kernal command 00=clrchn clear chan.
                rst     08h             ;do the kernal command


;
;scan keyboard for local key--if detected, transmit it.
;

key_loop:       rst     18h             ;getin--check current input channel
                or      a               ;key detected?
                jr      z,loop          ;no key found, back to top again

;
;local key detected--process it
;

key_det:        cp      27              ;escape?
                jr      z,exit_term     ;if [esc], exit terminal mode!
                cp      13              ;[return] (clear to ltrs mode)?
                jr      z,clear_flg     ;clear flag?

                push    af              ;save character a sec.
                ld      a,2             ;device 2=rs232
                rst     30h             ;chkout--direct output to rs-232
                pop     af              ;restore character to send
                rst     10h             ;send over current output channel
                xor     a               ;command 00, clrchn, etc.
                rst     08h             ;clear to default output chan.
                jr      loop            ;then go back to check it all again!


;
;clear flag to letters
;

clear_flg:      xor     a
                ld      (ltr_flag),a
                jr      loop

;
;print goodbye message & exit terminal program
;

exit_term:      ld      hl,msg2a        ;offset of "goodbye" message
                call    prtstg          ;tell kernal to print it
                rst     20h             ;software break point for re-entry




;
;convert character in .a into upper-case.
;

ulc:            cp      'a'
                ret     c               ;<'a' not lc
                cp      'z'+1
                ret     nc
                xor     20h
                ret

;
;string constants
;


msg1:           db      12,'rtty receiver v 1.00    ',13,13
                db      'press [return] key if you',13
                db      'need to reset the receiver to',13
                db      'letters mode.',13,13
                db      'rtty ttl input is pin 12 of u16',13
                db      '(remove u16 first!)',13,13
                db      'current parameters: 45.5 bps',13,13
                db      'press [esc] to exit.',13,13,14,0
msg2a:          db      13,'back to the monitor!',13,13,0




;
;convert baudot into ascii.
;


b2asc:          and     1fh     ;mask d5-d7
                push    de
                push    hl

                push    af      ;test if (ltrs or figs)
                and     figs
                cp      figs
                jr      z,let_fig
                pop     af

                and     31      ;get into valid range (00-1f)

                add     a,a     ;2*rcvd value
                ld      e,a
                ld      a,(ltr_flag)
                or      e       ;2*rcvd value + flag value
                ld      e,a
                ld      d,0
                ld      hl,table
                add     hl,de
                ld      a,(hl)
                pop     hl
                pop     de
                ret


let_fig:        ld      e,0
                pop     af
                cp      ltrs
                jr      z,let_fig2
                inc     e       ;was figs

let_fig2:       ld      a,e
                ld      (ltr_flag),a
                pop     hl
                pop     de
                ret




;
;
;lookup table for baudot - to - ascii
;
;even entries in table are for letters mode; odd entries are for
;figures mode.
;
;


table:          db      0,0     ;null
                db      'e','3'
                db      0,0     ;do nothing on (lf,lf)
                db      'a','-'
                db      20h,20h ;space
                db      's',27h ; s '
                db      'i','8'
                db      'u','7'
                db      13,13
                db      'd',05
                db      'r','4'
                db      'j',27h
                db      'n',','
                db      'f','!'
                db      'c',':'
                db      'k','('
                db      't','5'
                db      'z',34
                db      'l',')'
                db      'w','2'
                db      'h','#'
                db      'y','6'
                db      'p','0'
                db      'q','1'
                db      'o','9'
                db      'b','?'
                db      'g','&'
                db      figs,figs
                db      'm','.'
                db      'x','/'
                db      'v',';'
                db      ltrs,ltrs



                end

