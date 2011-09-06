#include grout.exp


;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณCompiled for Zilog Z80-C using standard Zilog peripherals.                   ณ
;ณAll values are in HEX unless otherwise noted.                                ณ
;ณRequires include file "grout.exp" screen driver.                             ณ
;ณ                                                                             ณ
;ณ                                                                             ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;

;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณmain                                                                         ณ
;ณRegisters Used:                                                              ณ
;ณStack Used:                                                                  ณ
;ณThis program provides support for a Microsoft Serial Mouse through a serial  ณ
;ณport.                                                                        ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;


;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณmousetest Subroutine:                                                        ณ
;ณRegisters Used:                                                              ณ
;ณStack Used:                                                                  ณ
;ณThis subroutine provides a diagnostic procedure to determine reliable        ณ
;ณmouse operation.                                                             ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;
mousetest
            ret


;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณmouseset Subroutine:                                                         ณ
;ณRegisters Used:                                                              ณ
;ณStack Used:                                                                  ณ
;ณThis subroutine changes the mouse speed parameters with the value determined ณ
;ณin Register-A.  Register-A determines speed: 0-Slowest, FF-Fastest           ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;
mouseset
            ret

;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณmousesetg Subroutine:                                                        ณ
;ณRegisters Used:                                                              ณ
;ณStack Used:                                                                  ณ
;ณThis subroutine graphically adjusts the mouse speed through a temporary      ณ
;ณwindow.                                                                      ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;


;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณpushwin Subroutine:                                                          ณ
;ณRegisters Used:                                                              ณ
;ณStack Used:                                                                  ณ
;ณ                                                                             ณ
;ณ                                                                             ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;
;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณmouseinit                                                                    ณ
;ณRegisters Used:                                                              ณ
;ณStack Used:                                                                  ณ
;ณThis subroutine initializes this mouse driver and the serial port for        ณ
;ณ1200 baud necessary for its proper communication.                            ณ
;ิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
;
;                        12345678901234567890123456789012
mousebanner .text       "Microsoft Mouse Driver Installed\r\000"
mouseerr    .text       "Please plug in Microsoft mouse\r\r\000"

mouseinit
            ld          hl,mousebanner
            call        prtstg
            ret

            .end
