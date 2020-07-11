.module 	errortest
.title 		Tests errorModule

.include	'error.def'
.include	'..\io\io.def'
.include	'..\program\program.def'


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


	CALL	IO_INIT
	
	LXI	H,0
	SHLD	PRG_CURRLINE		; CURRENT LINE = 0
	
	LXI	H,RESTART1
	SHLD	ERR_RESTARTPTR		; RESTART POSITION
	
	JMP	ERR_SYNTAX		; SYNTAX ERROR
	
RESTART1:
	LXI	H,123
	SHLD	PRG_CURRLINE		; CURRENT LINE = 123
	
	LXI	H,RESTART2
	SHLD	ERR_RESTARTPTR		; RESTART POSITION
	
	JMP	ERR_NOENDSTR		; UNTERMINATED STR CONST

RESTART2:
	LXI	H,10
	SHLD	PRG_CURRLINE		; CURRENT LINE = 10
	
	LXI	H,RESTART3
	SHLD	ERR_RESTARTPTR		; RESTART POSITION
	
	JMP	ERR_UNKNOWN		; UNKNOWN ERROR

RESTART3:
	
LOOP:
	JMP	LOOP



.area	DATA	(REL,CON)
