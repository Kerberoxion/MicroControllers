.include "m168def.inc"

.DSEG
byte: .byte 1 

.CSEG
.org 0x0000
	rjmp RESET


RESET:
	ldi r17, low(RAMEND)
	out SPL, r17
	ldi r17, high(RAMEND)
	out SPH, r17

	; === UART ������������� ===
	ldi r16, 51 ; ��� 9600 ��� ��� 8 ���: UBRR = (F_CPU/16/BAUD) - 1 = 51
	out UBRRL, r16
	ldi r16, (1<<TXEN)
	out UCSRB, r16
	ldi r16, (1<<UCSZ1)|(1<<UCSZ0) ; 8 ��� ������
	out UCSRC, r16

	; === SPI Slave ������������� ===
	ldi r16, (1<<SPE)
	out SPCR, r16

main_loop:
    ; �������� ������ �� SPI
wait_spi:
    in r18, SPSR
    sbrs r18, SPIF
    rjmp wait_spi
    in r19, SPDR
	sts byte, r19     ; ���������� ������

    ; �������� �� UART
    rcall uart_send
    rjmp main_loop

uart_send:
    ; ���, ���� ������� �����
wait_udre:
    in r20, UCSRA
    sbrs r20, UDRE
    rjmp wait_udre

    out UDR, r19
    ret
