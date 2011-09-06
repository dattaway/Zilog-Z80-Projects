;*******************************************************************************
;main -- This program will disassemble one instruction pointed to by the
;HL-Register pair.  The output will be written to a buffer pointed to by DE.
;HL will return the next instruction to fetch.
;*******************************************************************************
;
main

;*******************************************************************************
;Data Area
;*******************************************************************************
;
r           .db 'B'+$80
            .db 'C'+$80
            .db 'D'+$80
            .db 'E'+$80
            .db 'H'+$80
            .db 'L'+$80
            .db 'X'+$80
            .db 'A'+$80

s           .text       "B"\ .db 'C'+$80
            .text       "D"\ .db 'E'+$80
            .db 'Y'+$80
            .text       "S"\ .db 'P'+$80

q           .text       "B"\ .db 'C'+$80
            .text       "D"\ .db 'E'+$80
            .db 'Y'+$80
            .text       "A"\ .db 'F'+$80

n           .db '0'+$80
            .db '1'+$80
            .db '2'+$80
            .db '3'+$80
            .db '4'+$80
            .db '5'+$80
            .db '6'+$80
            .db '7'+$80

c           .text       "N"\ .db 'Z'+$80
            .db 'Z'+$80
            .text       "N"\ .db 'C'+$80
            .db 'C'+$80
            .text       "P"\ .db 'O'+$80
            .text       "P"\ .db 'E'+$80
            .db 'P'+$80
            .db 'M'+$80

x           .text       "


            .end
