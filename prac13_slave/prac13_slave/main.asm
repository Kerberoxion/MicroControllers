;
; prac13_slave.asm
;
; Created: 15.05.2025 14:09:58
; Author : User
;


.include "m168def.inc"
.DSEG

byte: .byte 1 

.CSEG
.org 0x0000
	rjmp RESET

RESET:
	ldi r17, low(RAMEND)
	out SPL, r17
	ldi r17, high(RAMEND)
	out SPH, r17


	ldi r16, 51 ; 
	sts UBRR0L, r16
	ldi r16, (1<<TXEN0)
	sts UCSR0B, r16
	ldi r16, (1<<UCSZ01)|(1<<UCSZ00) 
	sts UCSR0C, r16


	ldi r16, (1<<SPE)|(1<<SPR0)
	out SPCR, r16

main_loop:
    ; ќжидание данных по SPI
    in r18, SPSR
    sbrs r18, SPIF
    rjmp main_loop
    in r19, SPDR   
	sts byte, r19

    ; ќтправка по UART
    rcall uart_send
	rcall delay_500ms
	clr r18
    rjmp main_loop

uart_send:

wait_udre:
    lds r20, UCSR0A
    sbrs r20, UDRE0
    rjmp wait_udre

    sts UDR0, r19
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