#include "i2c.h"

void i2c_init(void) {
	TWSR = 0x00;
	TWBR = 72;          // (16 000 000 / 100 000 ? 16) / 2 = 72
	TWCR = (1 << TWEN);
}


uint8_t i2c_start(uint8_t address_with_rw) {
	// 1) �������� TWINT � ��������� ��� START � TWEN
	TWCR = (1<<TWINT)|(1<<TWSTA)|(1<<TWEN);
	while (!(TWCR & (1<<TWINT))); // ��� ���������

	// ���������: TWSR & 0xF8 == 0x08 (START �������)
	if ((TWSR & 0xF8) != 0x08) return 1;

	// 2) ������� ����� + R/W
	TWDR = address_with_rw;
	TWCR = (1<<TWINT) | (1<<TWEN);
	while (!(TWCR & (1<<TWINT))); // ��� ���������


	uint8_t status = TWSR & 0xF8;
	if (((address_with_rw & 1) == 0 && status != 0x18) ||
	((address_with_rw & 1) == 1 && status != 0x40)) {
		return 2;
	}
	return 0;
}


uint8_t i2c_write(uint8_t data) {
	TWDR = data;
	TWCR = (1<<TWINT) | (1<<TWEN);
	while (!(TWCR & (1<<TWINT)));
	// ��������� ������: 0x28 = Data transmitted, ACK received
	if ((TWSR & 0xF8) != 0x28) return 1;
	return 0;
}


uint8_t i2c_read_nack(uint8_t *out) {
	TWCR = (1<<TWINT) | (1<<TWEN); // ��� TWEA � NACK
	while (!(TWCR & (1<<TWINT)));
	*out = TWDR;
	// ��������� ������: 0x58 = Data received, NACK transmitted
	if ((TWSR & 0xF8) != 0x58) return 1;
	return 0;
}

// ������������ �������� (STOP)
void i2c_stop(void) {
	TWCR = (1<<TWINT) | (1<<TWEN) | (1<<TWSTO);

	_delay_us(10);
}