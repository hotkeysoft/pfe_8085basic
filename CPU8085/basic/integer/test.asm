.module 	inttest
.title 		Tests Integer Module

.include	'integer.def'

STACK	==	0xFFFF			;SYSTEM STACK

.area	BOOT	(ABS)

.org 	0x0000
	
RST0:
	DI
	LXI	SP,STACK		;INITALIZE STACK
	JMP 	START

.org	0x0038
RST7:	
	HLT
	

;*********************************************************
;* MAIN PROGRAM
;*********************************************************
.area 	_CODE

START:

	LXI	H,INT_ACC0
	MVI	M,0xFF
	INX	H
	MVI	M,0x00

	LXI	H,INT_ACC1
	MVI	M,0x01
	INX	H
	MVI	M,0x00

LOOP:
	LXI	H,INT_ACC1
	CALL	INT_DIV
	
	JMP	LOOP


