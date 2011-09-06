;*******************************************************************************
; Name:   Thomas G. Harr
; Date:   Fri  09-27-1991
; Lab# 3: Frequency and Capacitance Computer
;
; This little program computes the frequency of an incoming wave-form and
; also can check capacitances.
;*******************************************************************************
;




;*******************************************************************************
; cls Subroutine:
; Registers Used:       everything destroyed.
; Stack Used:
;
;
;
;*******************************************************************************
;
vidstart    .equ        $4000
vidlength   .equ        $1ff
space       .equ        $20
setxy       .equ        $ce         ;set screen x & y coordinates with reg-DE.
                                    ;D=ROW, E=COLUMN

cls         ld          hl,vidstart
            ld          de,vidstart+1
            ld          bc,vidlength
            ld          a,space
            ld          (hl),a
            ldir
            ld          de,0
            call        setxy
            ret

;*******************************************************************************
; name Subroutine:
; Registers Used:
; Stack Used:
;
;
;
;*******************************************************************************
;
;                        12345678901234567890123456789012
namestr     .text       "   CAPACITANCE AND FREQUENCY\R"
            .text       "             COMPUTER\R\R"
            .text       "          THOMAS G. HARR\R\R"
            .text       "    1 - TO MEASURE CAPACITANCE\R"
            .TEXT       "    2 - TO DETERMINE FREQUENCY\R"
            .TEXT       "    3 - \R"
            .text       "  [esc] TO EXIT...\R\000"

name        ld          hl,namestr
            call        prtstg
            ret

;*******************************************************************************
; prtstg Subroutine:
; Registers Used:
; Stack Used:
; This subroutine will print the string pointed to by HL-REGISTER terminated
; by a null (00h) character.
;
;
;*******************************************************************************
;
prtstg      ld          a,(hl)
            or          a
            ret         z
            rst         10h
            inc         hl
            jr          prtstg


;*******************************************************************************
; main Routine:
; Capacitance and Frequency Checker:
;
;
;*******************************************************************************
;
escape      .equ        $1b
monitor     .equ        $0bc6


main        call        cls
            call        name
            call        vectint
keyf        rst         18h         ;fetch a key from the keyboard.
            jr          z,keyf      ;keep searching for a key to be pressed.
            cp          escape
            jp          z,exitall   ;is the user exiting?
            cp          '1'
            call        z,capacitance
            cp          '2'
            call        z,frequency
            cp          '3'
            call        z,option
            jr          keyf        ;must be some invalid key; ignore...

exitall     jp          monitor

;*******************************************************************************
; option Subroutine:
; Registers Used:
; Stack Used:
;
;
;
;*******************************************************************************
;
option      ret


;*******************************************************************************
; capacitance Subroutine:
; Registers Used:
; Stack Used:
;
;
;
;*******************************************************************************
;
capacitance push        af
            ld          hl,0
            ld          (capcounter),hl
            xor         a                       ;set the mode for capacitance.
            ld          (progmode),a
            pop         af
            ret


;*******************************************************************************
; frequency Subroutine:
; Registers Used:
; Stack Used:
;
;
;
;*******************************************************************************
;
frequency   push        af
            ld          hl,0
            ld          (capcounter),hl
            ld          a,1
            ld          (progmode),a            ;set the mode for frequency.
            pop         af
            ret

;*******************************************************************************
; capisr Subroutine:
; Registers Used:
; Stack Used:
;
; This subroutine increases the counter used to calculate the frequency or
; capacitance.
;
;*******************************************************************************
;
capcounter  .ds         2

capisr      push        af
            push        hl
            ld          hl,(capcounter)
            inc         hl
            ld          (capcounter),hl
            pop         hl
            pop         af
            ei
            reti

;*******************************************************************************
; ctcisr Subroutine:
; Registers Used:
; Stack Used:
;
;
;
;*******************************************************************************
;
progmode    .ds         1
ctcmsgloc   .equ        $0d00

ctcisr      push        af
            push        bc
            push        de
            push        hl
            ld          de,ctcmsgloc
            call        setxy
            ld          a,(progmode)            ;find out what is supposed to
                                                ;be done when the time is up.
            or          a
            call        z,calcap                ;split up the unique tasks up.
            call        nz,calfreq              ;these subroutines must save af.
            pop         hl
            pop         de
            pop         bc
            pop         af
            ei
            reti


;*******************************************************************************
; calcap Subroutine:
; Registers Used:
; Stack Used:
;
;
;
;*******************************************************************************
;
capmsg      .text       "Capacitance: \000"
calcap      push        af

            pop         af
            ret

;*******************************************************************************
; calfreq Subroutine:
; Registers Used:
; Stack Used:
;
;
;
;*******************************************************************************
;
p_int       .equ        $f8

freqmsg     .text       "Frequency:   \000"

calfreq     push        af
            ld          hl,freqmsg
            call        prtstg
            ld          hl,(capcounter)
            call        p_int

            pop         af
            ret





;*******************************************************************************
; vectint Subroutine:
; Registers Used:
; Stack Used:
;
; This subroutine initializes the isr table.
;
; The interrupt program structure in this program work as follows:
;
;   When the 555 generates a pulse, the handshaking lines on the PIO
;   will generate an interrupt to increment a counter.  When the CTC
;   decides that it is time to stop incrementing the counter, everything
;   will then be calculated in the ctcisr.
;
;*******************************************************************************
;
vectable    .equ        $7d
pio         .equ        $80
pioda       .equ        pio
pioca       .equ        pio+1
ctc         .equ        $84
ctc2        .equ        $84+2
ctc3        .equ        $84+3
ctcr1       .equ        $ff
ctcr2       .equ        55

vectint     di
            ld          a,vectint
            ld          i,a
            ld          h,vectable
            ld          l,0
            ld          (hl),capisr ;capacitor/frequency isr
            inc         hl
            inc         hl
            ld          (hl),ctcisr ;ctc isr

            ld          a,00001111b ;select mode 0
            out         (pioca),a
            ld          a,0
            out         (pioca),a   ;first entry in the isr table
            ld          a,10000011b ;enable interrupts
            out         (pioca),a

            ld          a,00100101b ;control word and time constant follows
            out         (ctc2),a
            ld          a,ctcr1
            out         (ctc2),a
            ld          a,01100101b ;counter mode and time constant follows
            out         (ctc3),a
            ld          a,ctcr2

            im          2
            ei
            ret

; ษออออออออออออออออออออออออออออออออออป
; บ    ISR Mode 2 Interrupt Table    บ
; ฬอออออออัออออออออออออออออออออออออออน
; บ       ณcapisr          ctcisr    บ
; บ       รฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ
; บ$7d00  ณ 7d00            7d02     บ
; บ       ณ                          บ
; บ       ณ                          บ
; ศอออออออฯออออออออออออออออออออออออออผ


            .end
