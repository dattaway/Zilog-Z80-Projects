;*******************************************************************************
; Duane P. Attaway
; 8DA-EET463-12/20
; UART Transmitt and Receive Service Subroutines for Z80 Controllers
;
; Software Description:
;
;           This module consists of two subroutines, which are transmitt 'TX_',
;           and receive 'RX_'.  The data byte is passed through Register-A, with
;           no other registers used.  The receive subroutine is of the polling
;           type, which will not exit until a character is detected.
;
; Hardware Description:
;
;           The hardware utilizes two or three addresses within the I/O mapped
;           plane of the Z80; the two in/out equates for this address may be
;           equal to eachother if the hardware is set up in this read/write
;           fashion.
;           The UART control register to determine if the transmitt or
;           receive buffers are empty must contain a bit mask defined as an
;           equate.
;
;
;*******************************************************************************
;*******************************************************************************
;
; Hardware Ports and Bit Masks:
;
uartin      .equ        $00
uartout     .equ        $00
uartctrl    .equ        $01
readmask    .equ        00010000b   ;fourth bit is DAV (data available).
writemask   .equ        00000001b   ;zero bit is TBMT (transmitter buffer empty).
;
;*******************************************************************************


;*******************************************************************************
; TX_ Subroutine:
; Registers Used:       AF
; Registers Altered     none
; Stack Used:           0
; Subroutines Called:   none
;
; This subroutine sends Register-A to the UART transmitt buffer.  If the UART
; transmitt buffer is full, this subroutine will wait until the UART can accept
; the byte.  This subroutine may hang if the UART transmitt buffer never clears.
;
;*******************************************************************************
;
TX_         push        af
txloop      in          a,(uartctrl)
            or          writemask   ;seperate the transmitter empty flag.
            jr          nz,txloop   ;keep polling if the UART is full.
            pop         af
            out         (uartout),a
            ret

;*******************************************************************************
; RX_ Subroutine:
; Registers Used:       AF
; Registers Altered:    A
; Stack Used:           0
; Subroutines Called:   none
;
; This polling subroutine returns in Register-A with a character received in
; the UART buffer.  As this is a polling subroutine, it will hang if no
; characters are received by the UART.
;
;*******************************************************************************
;
RX_
rxloop      in          a,(uartctrl)
            or          readmask    ;seperate the receive available flag.
            jr          z,rxloop    ;keep polling if the UART is empty.
            in          a,(uartin)
            ret

            .end


