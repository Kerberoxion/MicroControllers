;
; prac8.asm
;
; Created: 03.04.2025 13:57:05
; Author : User
;

.include "m168def.inc" 

.DSEG
	.def temp = r16
	.equ BUFFER_SIZE = 11

	word: .byte BUFFER_SIZE
	strPtr:	.byte 2 


.CSEG
	.org 0x0000 
		rjmp RESET
	.org 0x0024
		rjmp RX_OK
	.org 0x0026
		rjmp UD_OK
	.org 0x0028
		rjmp TX_OK
RESET:
	cli
	ldi temp, LOW(RAMEND)  
    out SPL, temp
    ldi r16, HIGH(RAMEND)
    out SPH, temp   

	ldi temp,103		
	sts UBRR0L, temp

	ldi temp,(1<<RXEN0)|(1<<TXEN0)|(1<<RXCIE0)|(1<<TXCIE0)	;разрешение приема-передачи
	sts UCSR0B,temp

	ldi temp, (3<<UCSZ00)	;UCSZ0=1, UCSZ1=1, формат 8n1
	sts UCSR0C,temp

	clr temp
	sts strPtr, temp
	sts strPtr+1,temp

	ldi r17, low(word)
	ldi r18, high(word)

	sts strPtr, r17
	sts strPtr+1, r18

	clr r18
	sei
	rjmp start

start:	
	rjmp start

UD_OK:
	push temp              
    in temp, SREG          
    push temp
	push r17

	push ZL	
	push ZH

	lds ZL, strPtr
	lds ZH, strPtr+1

	ld	temp,Z+
	cpi	temp, 0
	breq STOP_RX

	sts	UDR0,temp

	sts	strPtr, ZL	
	sts	strPtr+1, ZH	

RX_EXIT:
	pop	ZH
	pop	ZL
	pop r17
	pop temp               
    out SREG, temp
    pop temp 
	reti

STOP_RX:
	ldi temp,(1<<RXEN0)|(1<<TXEN0)|(1<<RXCIE0)|(1<<TXCIE0)|(0<<UDRIE0)
	sts UCSR0B, temp

	ldi r17, low(word)
	ldi r18, high(word)

	sts strPtr, r17
	sts strPtr+1, r18

	rjmp RX_EXIT

RX_OK:
	push temp              
    in temp, SREG          
    push temp
	push r17

	push ZL	
	push ZH

	lds ZL, strPtr
	lds ZH, strPtr+1 

	lds temp,UDR0
	cpi	temp, 0
	breq STOP_TX

	st Z+, temp
	sts	strPtr, ZL	
	sts	strPtr+1, ZH	

	rjmp RX_EXIT

STOP_TX:
	ldi temp,(1<<RXEN0)|(1<<TXEN0)|(1<<RXCIE0)|(1<<TXCIE0)|(1<<UDRIE0)
	sts UCSR0B, temp

	ldi r17, low(word)
	ldi r18, high(word)

	sts strPtr, r17
	sts strPtr+1, r18

	rjmp RX_EXIT
	
TX_OK:
	reti

	