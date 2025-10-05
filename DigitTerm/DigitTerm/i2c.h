#ifndef I2C_H
#define I2C_H

#define F_CPU 16000000UL
#include <util/twi.h>
#include <stdio.h>
#include <stdlib.h>
#include <util/delay.h>

void i2c_init(void);
uint8_t i2c_start(uint8_t address_with_rw);
uint8_t i2c_write(uint8_t data);
uint8_t i2c_read_nack(uint8_t *out);
void i2c_stop(void);

#endif