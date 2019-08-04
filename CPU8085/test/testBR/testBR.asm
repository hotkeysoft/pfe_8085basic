.module 	testrom
.title 		Test ROM

STACK		=	0xFFFF		;SYSTEM STACK

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
	MVI A,0	
LOOP:
	OUT BANKR
	INR	A
	JMP LOOP

;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

