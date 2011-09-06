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



;*******************************************************************************
; capacitance Subroutine:
; Registers Used:
; Stack Used:
;
;
;
;*******************************************************************************
;
capacitance


;*******************************************************************************
; frequency Subroutine:
; Registers Used:
; Stack Used:
;
;
;
;*******************************************************************************
;
frequency

;*******************************************************************************
; capisr Subroutine:
; Registers Used:
; Stack Used:
;
;
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
; freisr Subroutine:
; Registers Used:
; Stack Used:
;
;
;
;*******************************************************************************
;
frecounter  .ds         2

freisr      push        af
            push        hl
            ld          hl,(frecounter)
            inc         hl
            ld          (frecounter),hl
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
            ld          hl,(freqcounter)
            call        p_int
            pop         af
            ret





;*******************************************************************************
; vectint Subroutine:
; Registers Used:
; Stack Used:
;
;
;
;*******************************************************************************
;
vectable    .equ        $7d
vectint     di
            ld          a,vectint
            ld          i,a
            ld          h,vectable
            ld          l,capisrlo
            ld          hl,(capisr)
            ld          l,freisrlo
            ld          hl,(freisr)
            im          2
            ei
            ret

; ษออออออออออออออออออออออออออออออออออป
; บ    ISR Mode 2 Interrupt Table    บ
; ฬอออออออัออออออออออออออออออออออออออน
; บ       ณcapisr  freisr  ctcisr    บ
; บ       รฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ
; บ$7d00  ณ 7d00    7d02    7d04     บ
; บ       ณ                          บ
; บ       ณ                          บ
; ศอออออออฯออออออออออออออออออออออออออผ


;*******************************************************************************
; Subroutine:
; Registers Used:
; Stack Used:
;
;
;
;*******************************************************************************
;










