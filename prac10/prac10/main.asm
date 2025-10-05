;
; prac10.asm
;
; Created: 23.04.2025 12:48:07
; Author : User
;
.include "m168def.inc" 

.DSEG
	.def temp = r16
	byte: .byte 1

.CSEG
	.org 0x0000 
		rjmp RESET
RESET:
	cli

	ldi temp, LOW(RAMEND)  
    out SPL, temp
    ldi r16, HIGH(RAMEND)
    out SPH, temp 

	clr temp
	sts byte, temp
	sts byte+1,temp

	ldi temp, (1<<REFS1)|(1<<REFS0) 
	sts ADMUX, temp

	ldi temp, (1<<ADEN) | (1<<ADPS2) | (1<<ADPS1) | (1<<ADPS0)  
	sts ADCSRA, temp

	rcall delay

	ldi temp, (1<<ADSC)|(1<<ADEN) | (1<<ADPS2) | (1<<ADPS1) | (1<<ADPS0)
	sts ADCSRA, temp
	sei

wait_adc:
	lds temp, ADCSRA
	sbrs temp, ADIF         ; ∆дать окончани€
	rjmp wait_adc

	ldi temp, (1<<ADIF)
	sts ADCSRA, temp      

	lds r17, ADCL
	lds r17, ADCH

	sts byte, r17

start:
    rjmp start

delay:
	ldi r18, 100
loop1:
	ldi r19, 255
loop2:
	dec r19
	brne loop2
	dec r18
	brne loop1
	ret
