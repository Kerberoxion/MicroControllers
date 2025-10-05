;
; prac9.asm
;
; Created: 16.04.2025 23:12:10
; Author : User
;


.include "m168def.inc" 

.DSEG
	.def temp = r16
	.equ BUFFER_SIZE = 4

	word: .byte BUFFER_SIZE
	strPtr:	.byte 2 
	txPtr:	.byte 2 
	registers:  .byte 16
	cmd_ready:  .byte 1
	tx_buffer:  .byte 4
	index:		.byte 1
	r_name:		.byte 1


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

	sts txPtr, temp
	sts txPtr+1,temp

	sts cmd_ready, temp
	sts index, temp

	ldi r17, low(word)
	ldi r18, high(word)

	sts strPtr, r17
	sts strPtr+1, r18

	clr r18
	sei
	rjmp start

start:
    lds   temp, cmd_ready
    cpi   temp, 1
    brne  start
	ldi ZL, low(word)
	ldi ZH, high(word)		 
	
	ld r21, Z+ 
    ld r22, Z+ 
    ld r23, Z+  
    ld r24, Z 

	clr temp
    sts cmd_ready, temp

	cpi r22, 'R'
    brne check_write

	ldi ZL, low(tx_buffer)
    ldi ZH, high(tx_buffer)
	
	st Z+, r21
	st Z+, r23

	ldi XL, low(registers)
	ldi XH, high(registers)
	subi r23, '0'
	add XL, r23
	ld r24, X

	st Z+, r24
	clr temp
	st Z, temp

	ldi ZL, low(tx_buffer)
    ldi ZH, high(tx_buffer)

	sts	txPtr, ZL	
	sts	txPtr+1, ZH	

	ldi temp,(1<<RXEN0)|(1<<TXEN0)|(1<<RXCIE0)|(1<<TXCIE0)|(1<<UDRIE0)
	sts UCSR0B, temp
	 	
	rjmp start

check_write:


	cpi r22, 'W'
	brne start
	ldi ZL, low(registers)
	ldi ZH, high(registers)
	subi r23, '0'
	add ZL, r23
	st Z, r24

	rjmp start

UD_OK:
	push temp              
    in temp, SREG          
    push temp
	push r17

	push ZL	
	push ZH

	lds ZL, txPtr
	lds ZH, txPtr+1
	
	lds r17, index
	inc r17
	sts index, r17  

	ld	temp,Z+

	sts	UDR0,temp

	sts	txPtr, ZL	
	sts	txPtr+1, ZH
	
	cpi	r17, BUFFER_SIZE-1
	breq STOP_RX	

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

	clr r17
	sts index, r17

	rjmp RX_EXIT

RX_OK:
	push temp              
    in temp, SREG          
    push temp
	push r17

	push ZL	
	push ZH

	lds r17, index
	inc r17
	sts index, r17 

	lds ZL, strPtr
	lds ZH, strPtr+1 

	lds temp,UDR0

	st Z+, temp
	sts	strPtr, ZL	
	sts	strPtr+1, ZH
	
	cpi	r17, BUFFER_SIZE
	breq STOP_TX	

	rjmp RX_EXIT

STOP_TX:

	ldi r17, low(word)
	ldi r18, high(word)

	sts strPtr, r17
	sts strPtr+1, r18

	clr r17
	sts index, r17

	ldi temp, 1
	sts cmd_ready, temp


	rjmp RX_EXIT
	
TX_OK:
	reti

