/*
 * DigitTerm.c
 *
 * Created: 06.06.2025 6:35:54
 * Author : User
 */ 

#define F_CPU 16000000UL
#include <util/twi.h>
#include <stdio.h>
#include <stdlib.h>
#include <util/delay.h>
#include "lcd.h"
#include "i2c.h"

#define DS1621_ADDR_WRITE 0x90
#define DS1621_ADDR_READ 0x91



void ds1621_start_conversion(void) {
	if (i2c_start(DS1621_ADDR_WRITE)) return;
	i2c_write(0xEE);
	// 3) STOP
	i2c_stop();
	// Ждём ~200 мс, чтобы датчик сделал первое измерение
	_delay_ms(200);
}

// Чтение температуры (целочисленная часть, знак в int8_t)
int8_t ds1621_read_temp(void) {
	uint8_t raw;
	// 1) START + адрес (запись)
	if (i2c_start(DS1621_ADDR_WRITE)) return 0;
	i2c_write(0xAA);

	if (i2c_start(DS1621_ADDR_READ)) return 0;
	// 4) Считываем один байт (без ACK)
	i2c_read_nack(&raw);
	i2c_stop();
	return (int8_t)raw;
}

int main()
{

	LCD_Init();
	i2c_init();
	PORTC = 0xFF;
	
	char buf[16];
	
	while(1){
		ds1621_start_conversion();
		int8_t temp = ds1621_read_temp();
		itoa(temp, buf, 10);
	
		LCD_String("T:");	/* Write string on 1st line of LCD*/
		LCD_String(buf);	/* Write string on 1st line of LCD*/
		LCD_String("°C");
		_delay_ms(1000);
		LCD_Clear();
	}
	while(1);
}

