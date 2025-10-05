.include "m168def.inc" 

.org 0x00
    rjmp RESET            ; ������ ������
.org 0x0020
    rjmp TIMER0_OVF_ISR   ; ������ ���������� ������������ ������� 0

RESET:
    ; ��������� �����
    ldi r16, LOW(RAMEND)  
    out SPL, r16
    ldi r16, HIGH(RAMEND)
    out SPH, r16         

	ldi r18, (1<<CS02)    ; ��������� ��������
    out TCCR0B, r18
	
	clr r18
	out tcnt0, r18
	out TCCR0A, r18

    ldi r16, (1<<TOIE0)   ; ���������� ���������� �� ������������
    sts TIMSK0, r16       
	sei                   ; ���������� ���������� ����������

MAIN:
    rjmp MAIN         

TIMER0_OVF_ISR:
	; ���������� 
    push r16              
    in r16, SREG          
    push r16

	inc r17

	; ��������������
    pop r16               
    out SREG, r16
    pop r16 
    reti  
