.include "m168def.inc"

.DEF    TEMP = R16 
.DSEG
overflow_count: .BYTE 2  
.CSEG
	.ORG $000
	rjmp reset
	.ORG $01C
	reti
	.ORG $01E
	reti
	.ORG $020			;Timer/Counter0 Overflow
	rjmp overflow

overflow:
	
	reti	
Reset:  LDI TEMP,Low(RAMEND)	
		OUT SPL,R16		
 
		LDI TEMP,High(RAMEND)	
		OUT SPH,TEMP
		rcall timer0_init
		SEI			
		reti
TIMER0_INIT:
    ; ��������� ������ Normal (�� ���������)
    CLR     TEMP
    OUT     TCCR0A, TEMP        ; WGM00=0, WGM01=0
    
    ; ����� �������� 
    LDI     TEMP, (1<<CS02) ; CS02=1
    OUT     TCCR0B, TEMP
    
    ; ���������� ���������� �� ������������
    LDI     TEMP, (1<<TOIE0)
    STS     TIMSK0, TEMP        ; ��� ATmega168 ����� TIMSK0 = 0x6E
    RET
overflow:
    PUSH    TEMP                ; ��������� ��������
    IN      TEMP, SREG
    PUSH    TEMP
    PUSH    R0
    PUSH    R1
    
    ; ��������� 16-������� ��������
    LDS     R0, overflow_count
    LDS     R1, overflow_count+1
    SUBI    R0, 0xFF            ; ��������� �������� �����
    SBCI    R1, 0xFF            ; ��������� �������� ����� � ���������
    STS     overflow_count, R0
    STS     overflow_count+1, R1
    
    POP     R1                  ; ��������������� ��������
    POP     R0
    POP     TEMP
    OUT     SREG, TEMP
    POP     TEMP
    RETI

	main:
		CLR r17
	loop:
		LDS     TEMP, overflow_count+1 ; �������� �������� �����
		CPI     TEMP, HIGH(976)      ; ��������� � ������� (������ ��� 1 ���)
		BRLO    loop                ; ���� ������ - ���������� �����
    
		; ����� ��������
		CLR     TEMP
		STS     overflow_count, TEMP
		STS     overflow_count+1, TEMP
		INC		r17    
		RJMP    loop