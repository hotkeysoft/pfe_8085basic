.module 	exprevaltest
.title 		Tests expreval Module

.include	'expreval.def'
.include	'..\tokenize\tokenize.def'

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

	LXI	H,TESTSTR1
	CALL	TOK_TOKENIZE1
	
	LXI	D,TESTSTR1
	LXI	H,OUTSTR
	CALL	TOK_TOKENIZE2
	
	LXI	H,OUTSTR
	CALL	EXP_EXPREVAL

LOOP:
	JMP	LOOP


TESTSTR1:	.asciz	''

.area	DATA	(REL,CON)
TESTSTR100:	.asciz	''

OUTSTR:		.ds 128

