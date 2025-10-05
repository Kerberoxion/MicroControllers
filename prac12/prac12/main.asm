;
; prac12.asm
;
; Created: 09.05.2025 14:18:58
; Author : User
;


.include "m168def.inc"

.def temp = r16
.def row  = r17
.def col  = r18
.def key  = r19
.def num = r20

.org 0x0000
    rjmp RESET

RESET:
    ldi temp, low(RAMEND)
    out SPL, temp
    ldi temp, high(RAMEND)
    out SPH, temp

    ; PB2ЦPB4 как входы с подт€жкой (столбцы)
    ldi temp, 0
    out DDRB, temp
    ldi temp, (1<<PB2)|(1<<PB3)|(1<<PB4)
    out PORTB, temp

    ; PC2ЦPC5 как выходы (строки), все неактивны (pull-up)
    ldi temp, (1<<PC2)|(1<<PC3)|(1<<PC4)|(1<<PC5)
    out DDRC, temp
    out PORTC, temp   

    ; PD0ЦPD6 как выходы
    ldi temp, (1<<PD0)|(1<<PD1)|(1<<PD2)|(1<<PD3)|(1<<PD4)|(1<<PD5)|(1<<PD6)|(1<<PD7)
    out DDRD, temp

    ; ќчистить дисплей
    ldi temp, 0xFF
    out PORTD, temp

main_loop:
	ldi temp, 0x00   
	;out DDRD, temp
	;out PORTD, temp

    ldi row, (1<<PC2)

scan_rows:

    ldi temp, 0x3C
    out PORTC, temp

    ; јктивировать одну строку (0)
    com row           ; инвертируем, активный 0
    andi row, 0x3C    ; маска только PC2ЦPC5
    out PORTC, row
    com row 
	andi row, 0x3C          ; восстановить оригинал

    ; «адержка
    nop
    nop

    ; —читываем столбцы
    in col, PINB
	com col
    andi col, (1<<PB2)|(1<<PB3)|(1<<PB4)
    breq next_row     ; если нет нажатий Ч следующа€ строка

    ; ќпредел€ем колонку
    ldi key, 0xFF
    cpi col, (1<<PB2)
    breq col0
    cpi col, (1<<PB3)
    breq col1
    cpi col, (1<<PB4)
    breq col2
    rjmp next_row

col2:
    cpi row, (1<<PC5)
    breq set_key_1
    cpi row, (1<<PC4)
    breq set_key_4
    cpi row, (1<<PC3)
    breq set_key_7
    cpi row, (1<<PC2)
    breq set_key_star
    rjmp next_row

col1:
    cpi row, (1<<PC5)
    breq set_key_2
    cpi row, (1<<PC4)
    breq set_key_5
    cpi row, (1<<PC3)
    breq set_key_8
    cpi row, (1<<PC2)
    breq set_key_0
    rjmp next_row

col0:
    cpi row, (1<<PC5)
    breq set_key_3
    cpi row, (1<<PC4)
    breq set_key_6
    cpi row, (1<<PC3)
    breq set_key_9
    cpi row, (1<<PC2)
    breq set_key_sharp
    rjmp next_row

next_row:
    lsl row
    cpi row, (1<<PC6)
    brlt scan_rows
    rjmp main_loop

; ќбработка кнопок
set_key_0:
   ldi key, 0
   ldi num, 0b11000000  
   rjmp show_key
set_key_1:
   ldi key, 1 
   ldi num, 0b11001111
   rjmp show_key
set_key_2:
   ldi key, 2   
   ldi num, 0b10010010
   rjmp show_key
set_key_3:
   ldi key, 3  
   ldi num, 0b10000110 
   rjmp show_key
set_key_4:
   ldi key, 4  
   ldi num, 0b10001101
    rjmp show_key
set_key_5:
   ldi key, 5  
   ldi num, 0b10100100
    rjmp show_key
set_key_6:
   ldi key, 6  
   ldi num, 0b10100000
    rjmp show_key
set_key_7:
   ldi key, 7  
   ldi num, 0b11001110
    rjmp show_key
set_key_8:
   ldi key, 8 
   ldi num, 0b10000000
    rjmp show_key
set_key_9:
   ldi key, 9   
   ldi num, 0b10000100
   rjmp show_key
set_key_star:
   ldi key, 10 
   ldi num, 0b01111111
    rjmp show_key
set_key_sharp:
  ldi key, 11  
  rjmp show_key

show_key:
    cpi key, 11
    brsh clear_display

	com num
    out PORTD, num
    rjmp wait_loop

clear_display:
    ldi temp, 0xFF
    out PORTD, temp
    rjmp wait_loop

wait_loop:
    ; ∆дЄм отпускани€ кнопки
    in col, PINB
	com col
    andi col, (1<<PB2)|(1<<PB3)|(1<<PB4)
    brne wait_loop
    rjmp main_loop



