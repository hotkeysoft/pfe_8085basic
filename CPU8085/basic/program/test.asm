.module 	programtest
.title 		Tests program Module

.include	'program.def'
.include	'..\common\common.def'
.include	'..\io\io.def'
.include	'..\error\error.def'

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


	LXI	H,TESTPRG1		; PROGRAM MEMORY
	SHLD	PRG_LOPTR
	
	LXI	H,TESTPRG4END
	SHLD	PRG_HIPTR
	
	CALL	PRG_INIT

	CALL	PRG_LIST

LOOP:
	JMP	LOOP



.area	DATA	(REL,CON)

TESTPRG1:	
	.db	TESTPRG1END-TESTPRG1	; SIZE
	.dw	10			; LINE NO
	.db	K_PRINT,32,SID_CINT .dw 1234 .db 0
TESTPRG1END:
TESTPRG2:	
	.db	TESTPRG2END-TESTPRG2	; SIZE
	.dw	20			; LINE NO
	.db	K_LET,32,SID_VAR,'A,'B,32,K_EQUAL,32,SID_CINT .dw -6666 .db 0
TESTPRG2END:
TESTPRG3:	
	.db	TESTPRG3END-TESTPRG3	; SIZE
	.dw	30			; LINE NO
	.db	K_PRINT,32,SID_VAR,'A,'B,32,', ,SID_CSTR,4 .ascii "ABCD" .db 0
TESTPRG3END:
TESTPRG4:	
	.db	TESTPRG4END-TESTPRG4	; SIZE
	.dw	40			; LINE NO
	.db	K_GOTO,32,SID_CINT .dw 10 .db 0
TESTPRG4END:


;OUTSTR:	.ds 128

