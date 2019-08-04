.module 	testrom
.title 		Test ROM

STACK		=	0xFFFF		;SYSTEM STACK

TIMER	=	0x40			;TIMER PORT BASE
UART	=	0x60			;UART PORT BASE
SOUND	= 0x80			;SOUND PORT BASE
BANKR = 0xA0			;BANK REGISTER PORT BASE

.area	BOOT	(ABS)

.org 	0x0000

RST0:
	DI
	LXI	SP,STACK	;INITALIZE STACK
	JMP START
	
;*********************************************************
;* MAIN PROGRAM
;*********************************************************
.area 	_CODE

START:

LOOP:
	OUT UART
	
	OUT TIMER	
	
	OUT SOUND
	
	OUT BANKR
	
	JMP LOOP


;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

