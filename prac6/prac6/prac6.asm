;
; prac6.asm
;
; Created: 13.03.2025 13:24:07
; Author : User
;
.include "m168def.inc" 

.DSEG
	.def temp = r16

.CSEG

.org 0x0000 rjmp init

init:
	cli

	ldi temp,103		
	sts UBRR0L, temp

	ldi temp,(1<<RXEN0)|(1<<TXEN0)	;разрешение приема-передачи
	sts UCSR0B,temp

	ldi temp, (3<<UCSZ00)	;UCSZ0=1, UCSZ1=1, формат 8n1
	sts UCSR0C,temp
	clr temp
	sts UCSR0A, temp
	ldi r17, 1
	rjmp start

recv:							;прием байта в temp с ожиданием готовности
	lds  temp, UCSR0A              ; Загружаем UCSR0A в общий регистр
    sbrs temp, RXC0 
	rjmp recv
	lds r17,UDR0				;собственно прием байта
	ret							;возврат из процедуры In_com
send:						;посылка байта из temp с ожиданием готовности
	lds  temp, UCSR0A              ; Загружаем UCSR0A в общий регистр
    sbrs temp, UDRE0  		
	rjmp send
	sts UDR0,r17				;собственно посылка байта
	ret							;возврат из процедуры Out_com

start:	
	rcall recv
	lds  temp, UCSR0A              ; Загружаем UCSR0A в общий регистр
    sbrs temp, UDRE0  		
	rjmp start
	inc r17
	sts UDR0,r17
   ; rcall send
	;rcall recv
	rjmp start
