.include "m168def.inc" 

.org 0x00
    rjmp RESET            ; Вектор сброса
.org 0x0020
    rjmp TIMER0_OVF_ISR   ; Вектор прерывания переполнения таймера 0

RESET:
    ; Настройка стека
    ldi r16, LOW(RAMEND)  
    out SPL, r16
    ldi r16, HIGH(RAMEND)
    out SPH, r16         

	ldi r18, (1<<CS02)    ; Установка делителя
    out TCCR0B, r18
	
	clr r18
	out tcnt0, r18
	out TCCR0A, r18

    ldi r16, (1<<TOIE0)   ; Разрешение прерывания по переполнению
    sts TIMSK0, r16       
	sei                   ; Разрешение глобальных прерываний

MAIN:
    rjmp MAIN         

TIMER0_OVF_ISR:
	; Сохранение 
    push r16              
    in r16, SREG          
    push r16

	inc r17

	; Восстановление
    pop r16               
    out SREG, r16
    pop r16 
    reti  
