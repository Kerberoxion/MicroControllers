;
; prac11.asm
;

.include "m168def.inc"

.DSEG

 ticks: .byte 1     ; счётчик тиков по ?10 ms
.def tmp = r16

 phase: .byte 1   ; 0=ON, 1=OFF

.CSEG
    .org 0x0000
		rjmp RESET
    .org 0x001C      ; вектор Timer0 COMPA
		rjmp TIMER_ISR

RESET:

	cli
    ; стек
    ldi   tmp, low(RAMEND)
    out   SPL, tmp
    ldi   tmp, high(RAMEND)
    out   SPH, tmp

    ; PB4 ? выход
    sbi   DDRB,4
    ; Инициализация переменных и LED
    clr   r17       ; обнуляем счётчик
	sts ticks, r17
    sts phase, r17       ; первая фаза = ON
    cbi   PORTB,4     ; зажигаем LED сразу

    ; Timer0 CTC, prescaler=1024
    ldi   tmp, (1<<WGM01)
    out   TCCR0A, tmp
    ldi   tmp, (1<<CS02)|(1<<CS00)
    out   TCCR0B, tmp

    ; OCR0A = 156 ? прерывание ?10 ms
    ldi   tmp, 156
    out   OCR0A, tmp
    ; включаем прерывание COMPA
    ldi   tmp, (1<<OCIE0A)
    sts   TIMSK0, tmp

    sei  
	rjmp start             ; глобальные прерывания

start:
    rjmp start

TIMER_ISR:
    push  tmp
    push  r17
    push  r18
	
	lds r17, ticks
	inc   r17
	sts ticks, r17
	
	lds r18, phase
    cpi r18, 1
    breq check_OFF

    ; --- ON-фаза (phase=0): ждём 100 тиков (~1 s) ---
    cpi   r17, 100
    brlt  end_ISR
    ; переключаем в OFF
    ldi   r18, 1
	sts phase, r18

    sbi   PORTB,4     ; LED OFF
    clr   r17
	sts ticks, r17
    rjmp  end_ISR

check_OFF:
    ; --- OFF-фаза (phase=1): ждём 200 тиков (~2 s) ---

    cpi   r17, 200
    brne  end_ISR

    cbi   PORTB,4     ; LED ON
    clr   r17
	sts ticks, r17
	sts phase, r17

end_ISR:
    pop   r18
    pop   r17
    pop   tmp
    reti
