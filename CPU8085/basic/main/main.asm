.module 	main
.title 		Main Module

.include	'..\error\error.def'
.include	'..\expreval\expreval.def'
.include	'..\integer\integer.def'
.include	'..\io\io.def'
.include	'..\program\program.def'
.include	'..\strings\strings.def'
.include	'..\tokenize\tokenize.def'
.include	'..\variables\variable.def'

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

	; IO INIT
	CALL	IO_INIT
	CALL	INT_INIT
	CALL	EXP_INIT

	LXI	H,0
	SHLD	PRG_CURRLINE

	; TEST PROGRAM
	LXI	H,0x9000		; PROGRAM MEMORY
	SHLD	PRG_LOPTR
	SHLD	PRG_HIPTR
	SHLD	VAR_LOPTR
	SHLD	VAR_HIPTR
	
	CALL	PRG_INIT

	; SET STR PTRS
	LXI	H,STACK-1024
	SHLD	STR_LOPTR
	SHLD	STR_HIPTR

	LXI	H,LOOP
	SHLD	ERR_RESTARTPTR

LOOP:
	LXI	H,READYSTR			; PRINT 'READY'
	CALL	IO_PUTS
	CALL	IO_PUTCR
	
	LXI	H,INSTR				; PTR TO INPUT STR IN HL
	
LL:
	CALL	IO_GETCHAR			; READ CHARACTER FROM INBUFFER
	ORA	A				; NOCHAR
	JZ	LL
	CPI	13				; CHECK FOR (CR)
	JZ	DONE
	
	MOV	M,A				; COPY CHAR TO BUFFER
	INX	H				; PTR++
	
	JMP	LL				; LOOP
	
DONE:
	MVI	M,0				; NULL-TERMINATE STR
	
	LXI	H,INSTR				; PTR TO INPUT STR IN HL
	CALL	EXECUTE
	
	JMP	LOOP


EXECUTE:
	PUSH	H
	CALL	TOK_TOKENIZE1
	POP	H
	XCHG
	LXI	H,OUTSTR
	CALL	TOK_TOKENIZE2
	LXI	H,OUTSTR
	MVI	B,FALSE				; INIF = FALSE
	MVI	C,TRUE				; EXECUTE = TRUE
	CALL	EXP_EXPREVAL
	RET	


READYSTR:	.asciz	'Ready.'

.area	DATA	(REL,CON)

INSTR::		.ds 256
OUTSTR::	.ds 256
	