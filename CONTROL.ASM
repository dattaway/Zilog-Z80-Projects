;*******************************************************************************
;control Subroutine
;Registers Used:        af
;This subroutine accepts control chacters and performs ansii functions.
;
;*******************************************************************************
;
clrscrctrl  .equ        $01
rightctrl   .equ        $06
leftctrl    .equ        $07
delctrl     .equ        $08


control     push        af
            cp          clrscrctrl
            jr          nz,right

clrscr      ld          a,$38       ;initialize and clear lcd screen
            call        outlcd
            ld          a,$38
            call        outlcd
            ld          a,$38
            call        outlcd
            ld          a,$0f
            call        outlcd
            ld          a,$01
            call        outlcd
            ld          a,$06
            call        outlcd
            jr          controle

right       cp          rightctrl   ;backspace one character
            jr          nz,left
            ld          a,00010100b
            call        outlcd
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

