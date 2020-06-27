.module 	testrom
.title 		Test ROM

BANKR = 0xA0			;BANK REGISTER PORT BASE

STACK	= 0x60FF

.area	BOOT	(ABS)

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

.area	_DATA	(REL,CON)

.area PAGE4 (REL,CON)
PAGE4B:		.ds	1

.area PAGE5 (REL,CON)
PAGE5B:		.ds	1

.area BANK0 (REL,CON)
PAGE6B:		.ds	1

.area BANK1 (REL,CON)
PAGE7B:		.ds	1

