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


;*********************************************************
;* TEST C_ISDIGIT FUNCTION
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



LOOP:
	JMP	LOOP
