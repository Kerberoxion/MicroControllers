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

EEWrite:
	sbic EECR,EEPE		; ���� ���������� ������ � ������. �������� � �����
	rjmp EEWrite 		
 
	out EEARL, r18		; ��������� ����� ������ ������
	out EEARH, r19  		
	out EEDR, r17 		; � ���� ������, ������� ��� ����� ���������
 
	sbi EECR,EEMPE		; ������� ��������������
	sbi EECR,EEPE		; ���������� ����
 
	ret
 
 
EERead:		
	sbic EECR,EEPE		; ���� ���� ����� ��������� ������� ������.
	rjmp EERead	
			
	out EEARL, r18		; ��������� ����� ������ ������
	out EEARH, r19	
		
	sbi EECR,EERE 		; ���������� ��� ������
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

