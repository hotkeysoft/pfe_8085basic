.module 	iotest
.title 		Tests IO Module

.include	'io.def'

STACK	==	0xFFFF			;SYSTEM STACK

.area	BOOT	(ABS)

.org 	0x0000
	
RST0:
	DI
	LXI	SP,STACK		;INITALIZE STACK
	JMP 	START


;*********************************************************
;* MAIN PROGRAM
;*********************************************************
.area 	_CODE

START:
	CALL	IO_INIT

	MVI	A,8			;SET INTERRUPT MASK
	SIM
	EI				;ENABLE INTERRUPTS

	CALL	IO_BEEP			;MAKE SOME NOISE!

	MVI	A,10		
	CALL 	IO_DELAY		;WAIT 5 * 100 MS

LOOP:
	CALL	IO_GETCHAR
	ORA	A
	JZ	LOOP

	CALL	IO_PUTC

	JMP	LOOP

NUMBERS:	.asciz		'0123456789ABCDEF'