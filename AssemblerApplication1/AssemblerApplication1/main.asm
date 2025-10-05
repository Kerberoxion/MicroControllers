;
; AssemblerApplication1.asm
;
; Created: 13.02.2025 14:07:29
; Author : User
;
.include "m168def.inc"

.DSEG

array: .BYTE 10;

.CSEG
.def cnt = r17
ldi r16, 0
ldi cnt, 0

ldi zl, low(array)
ldi zh, high(array)

; Replace with your application code
start:
	st z+, r16
	inc r16
	cpi r16, 10
	breq main
	rjmp start

main:
	ldi zl, low(array)
	ldi zh, high(array)
	rjmp cycle

cycle:
	ld r16, z+
	inc cnt
	cpi r16, 7
	breq end
	cpi cnt, 10
	breq end2
	rjmp cycle
end:
	subi r16, 6
	st -z, r16

	rjmp end2

end2:
	rjmp end2