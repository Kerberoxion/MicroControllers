#ifndef LCD_H
#define LCD_H

#define LCD_Dir  DDRD
#define LCD_Port PORTD
#define RS PD0
#define EN PD1

#include <avr/io.h>
#include <util/delay.h>

void LCD_Command( unsigned char cmnd );
void LCD_Char( unsigned char data );
void LCD_Init (void);
void LCD_String (char *str);
void LCD_String_xy (char row, char pos, char *str);
void LCD_Clear();

#endif