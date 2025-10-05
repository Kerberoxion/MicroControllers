;
; prac13.asm
;
; Created: 14.05.2025 22:43:18
; Author : User
;


.include "m168def.inc"
.DSEG

byte: .byte 1

.CSEG
.org 0x0000
    rjmp RESET

RESET:
	ldi r16, 0x55 
	ldi r17, low(RAMEND)
	out SPL, r17
	ldi r17, high(RAMEND)
	out SPH, r17

	ldi r17,(1<<DDB3)|(1<<DDB5)
	out DDRB,r17


	ldi r17, (1<<SPE)|(1<<MSTR)|(1<<SPR0) 
	out SPCR, r17


main_loop:
    rcall spi_transmit
    rcall delay_500ms
    rjmp main_loop


spi_transmit:
    out SPDR, r16
wait_spi:
    in r18, SPSR
    sbrs r18, SPIF
    rjmp wait_spi
	sts byte, r16
	dec r16
    ret



delay_500ms:
    ldi r21, 50      
delay_10ms:
    ldi r22, 200
loop2:
    ldi r23, 250
loop1:
    dec r23
    brne loop1
    dec r22
    brne loop2
    dec r21
    brne delay_10ms
    ret

