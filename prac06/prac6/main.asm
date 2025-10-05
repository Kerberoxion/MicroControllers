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

	ldi temp,(1<<RXEN0)|(1<<TXEN0)	;���������� ������-��������
	sts UCSR0B,temp

	ldi temp, (3<<UCSZ00)	;UCSZ0=1, UCSZ1=1, ������ 8n1
	sts UCSR0C,temp
	clr temp
	sts UCSR0A, temp
	ldi r17, 1
	rjmp start

recv:							;����� ����� � temp � ��������� ����������
	lds  temp, UCSR0A              ; ��������� UCSR0A � ����� �������
    sbrs temp, RXC0 
	rjmp recv
	lds r17,UDR0				;���������� ����� �����
	ret							;������� �� ��������� In_com
send:						;������� ����� �� temp � ��������� ����������
	lds  temp, UCSR0A              ; ��������� UCSR0A � ����� �������
    sbrs temp, UDRE0  		
	rjmp send
	sts UDR0,r17				;���������� ������� �����
	ret							;������� �� ��������� Out_com

start:	
	rcall recv;
	rcall send;
   ; rcall send
	;rcall recv
	rjmp start
