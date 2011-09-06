;lab3

data        .org        $6300
acc1        .ds         4
acc2        .ds         4

start       ld          ix,acc1     ;set the index for the source
            ld          iy,acc2     ;set the second index for the destination

            ld          a,(ix+03)   ;get the lsb of the source
            add         a,(iy+03)   ;add the two together
            ld          (ix+03),a   ;save the result

            ld          a,(ix+02)   ;get the next digit
            adc         a,(iy+02)   ;add with the previous carry
            ld          (ix+02),a   ;save the result in the next place

            ld          a,(ix+01)   ;get the next digit
            adc         a,(iy+01)   ;add with the previous carry
            ld          (ix+01),a   ;save the result in the next place

            ld          a,(ix+00)   ;get the next digit
            adc         a,(iy+00)   ;add with the previous carry
            ld          (ix+00),a   ;save the result in the next place

            halt

            .end
