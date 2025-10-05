;
; prac7.asm
;
; Created: 03.04.2025 12:41:06
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
	lds  temp, UCSR0A              ; «агружаем UCSR0A в общий регистр
    sbrs temp, RXC0 
	rjmp recv
	lds r17,UDR0				;собственно прием байта
	ret							;возврат из процедуры In_com
send:						;посылка байта из temp с ожиданием готовности
	lds  temp, UCSR0A              ; «агружаем UCSR0A в общий регистр
    sbrs temp, UDRE0  		
	rjmp send
	sts UDR0,r17				;собственно посылка байта
	ret							;возврат из процедуры Out_com

EEWrite:
	sbic EECR,EEPE		; ∆дем готовности пам€ти к записи.  рутимс€ в цикле
	rjmp EEWrite 		
 
	out EEARL, r18		; «агружаем адрес нужной €чейки
	out EEARH, r19  		
	out EEDR, r17 		; и сами данные, которые нам нужно загрузить
 
	sbi EECR,EEMPE		; взводим предохранитель
	sbi EECR,EEPE		; записываем байт
 
	ret
 
 
EERead:		
	sbic EECR,EEPE		; ∆дем пока будет завершена прошла€ запись.
	rjmp EERead	
			
	out EEARL, r18		; загружаем адрес нужной €чейки
	out EEARH, r19	
		
	sbi EECR,EERE 		; ¬ыставл€ем бит чтени€
	in r17, EEDR 		
	ret

start:	
	clr r18
	clr r19	
	rcall recv
	rcall EEWrite
	rcall EERead
	inc r17
	rcall send

	rjmp start

