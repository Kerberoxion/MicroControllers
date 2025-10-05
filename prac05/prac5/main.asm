;
; prac5.asm
;
; Created: 11.03.2025 9:11:12
; Author : User
;
.include "m168def.inc"

.DSEG
.def remainder = r15
.def dividend = r16
.def divisor = r17
.def cnt = r18
.CSEG

; Replace with your application code
start:
	clr remainder
	ldi cnt, 9
	ldi dividend, 127
	ldi divisor, 10
	clc

cycle:
	rol dividend 
	dec cnt
	breq exit

	rol remainder
	sub remainder, divisor	
	brmi func
	sec
	rjmp cycle

func:
	add remainder, divisor
	clc
	rjmp cycle
exit:
	rjmp exit