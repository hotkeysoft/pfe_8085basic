.module 	exprevaltest
.title 		Tests expreval Module

.include	'expreval.def'

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

	MVI	A,8			;SET INTERRUPT MASK
	SIM
	EI				;ENABLE INTERRUPTS


LOOP:
	JMP	LOOP


TESTSTR1:	.asciz	''

.area	DATA	(REL,CON)
TESTSTR100:	.asciz	''

OUTSTR:		.ds 128

