.include "m168def.inc"

.org 0x0000
	rjmp RESET

RESET:
	ldi r17, low(RAMEND)
	out SPL, r17
	ldi r17, high(RAMEND)
	out SPH, r17

	; === UART инициализация ===
	ldi r16, 51 ; для 9600 бод при 8 МГц: UBRR = (F_CPU/16/BAUD) - 1 = 51
	sts UBRR0L, r16
	ldi r16, (1<<TXEN0)
	sts UCSR0B, r16
	ldi r16, (1<<UCSZ01)|(1<<UCSZ00) ; 8 бит данных
	sts UCSR0C, r16

	; === SPI Slave инициализация ===
	ldi r16, (1<<SPE)
	out SPCR, r16

main_loop:
    ; Ожидание данных по SPI
wait_spi:
    in r18, SPSR
    sbrs r18, SPIF
    rjmp wait_spi
    in r19, SPDR     ; Полученные данные

    ; Отправка по UART
    rcall uart_send
    rjmp main_loop

uart_send:
    ; Ждём, пока регистр готов
wait_udre:
    lds r20, UCSR0A
    sbrs r20, UDRE0
    rjmp wait_udre

    sts UDR0, r19
    ret
