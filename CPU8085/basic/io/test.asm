.module 	iotest
.title 		Tests IO Module

.include	'io.def'
.include	'..\common\common.def'

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

	MVI	A,12
	CALL	IO_SETCOLOR

	CALL	IO_CLS

	MVI	H,0
	MVI	L,1
	CALL	IO_GOTOXY
	
	LXI	H,STR
	CALL	IO_PUTS

	MVI	H,79
	MVI	L,24
	CALL	IO_GOTOXY

	MVI	A,14
	CALL	IO_SETCOLOR
	
	MVI	A,#'Z
	CALL	IO_PUTC

LOOP:
	CALL	IO_GETCHAR
	ORA	A
	JZ	LOOP

	CALL	IO_PUTC

	JMP	LOOP

STR:	.asciz	'0123456789012346578901234567980'