.module 	commontest
.title 		Tests Common Module

.include	'common.def'

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

	JMP	TEST_TAG2NAME


;*********************************************************
;* TEST C_ISDIGIT FUNCTION
TEST_ISDIGIT:
	MVI	A,'0		; CF = 1
	CALL	C_ISDIGIT
	
	MVI	A,'9		; CF = 1
	CALL	C_ISDIGIT
	
	MVI	A,'0 - 1	; CF = 0
	CALL	C_ISDIGIT
	
	MVI	A,'9 + 1	; CF = 0
	CALL 	C_ISDIGIT

;*********************************************************
;* TEST C_ISALPHA FUNCTION
TEST_ISALPHA:
	MVI	A,'A
	CALL	C_ISALPHA		; CF = 1
	
	MVI	A,'Z
	CALL	C_ISALPHA		; CF = 1
	
	MVI	A,'a
	CALL	C_ISALPHA		; CF = 1
	
	MVI	A,'z
	CALL 	C_ISALPHA		; CF = 1

	MVI	A,'A - 1
	CALL	C_ISALPHA		; CF = 0
	
	MVI	A,'Z + 1
	CALL	C_ISALPHA		; CF = 0
	
	MVI	A,'a - 1
	CALL	C_ISALPHA		; CF = 0
	
	MVI	A,'z + 1
	CALL 	C_ISALPHA		; CF = 0

;*********************************************************
;* TEST C_TAG2NAME FUNCTION
TEST_TAG2NAME:
	LXI	H,TEMPSTR		; OUTPUT TO TEMPSTR
	MVI	B,'A + 128		; A (STRING) +
	MVI	C,'B			; B
	CALL	C_TAG2NAME		; RESULT: AB$

	LXI	H,TEMPSTR		; OUTPUT TO TEMPSTR
	MVI	B,'F  + 128		; F (STRING) 
	MVI	C,0			; 
	CALL	C_TAG2NAME		; RESULT: F$


	LXI	H,TEMPSTR		; OUTPUT TO TEMPSTR
	MVI	B,'Z 			; Z 
	MVI	C,0			; B
	CALL	C_TAG2NAME		; RESULT: Z


LOOP:
	JMP	LOOP


TESTSTR1:	.asciz	'test'


;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

TEMPSTR:	.ds	32			;TEMP STRING
