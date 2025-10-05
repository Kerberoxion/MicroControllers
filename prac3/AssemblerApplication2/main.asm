.include "m168def.inc" 

.org 0x00					
    rjmp RESET			

RESET:
	cli
    ldi r16, LOW(RAMEND)  
    out SPL, r16
    ldi r16, HIGH(RAMEND)
    out SPH, r16         



	ldi r18, (1<<PORTD6)
	out PORTD, r18

	ldi r18, (1<<DDD6)
	out DDRD, r18

	clr r18
	out tcnt0, r18
	ldi r18, (1<<WGM00)| (1<<WGM01)|(0<<COM0A0)|(1<<COM0A1)|(0<<COM0B0)|(0<<COM0B1)
	out TCCR0A, r18

    ldi r18, 200
    out OCR0A, r18

	ldi r18, (1<<CS01)    
    out TCCR0B, r18

    ldi r16, (0<<TOIE0)			
    sts TIMSK0, r16


MAIN:
    rjmp MAIN         


