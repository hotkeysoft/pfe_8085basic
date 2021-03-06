.module 	stringstest
.title 		Tests strings Module

.include	'strings.def'
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
	MVI	A,8			;SET INTERRUPT MASK
	SIM
	EI				;ENABLE INTERRUPTS

	; SET STR PTRS
	LXI	H,0xA000
	SHLD	STR_LOPTR
	SHLD	STR_HIPTR

;	JMP	TEST_ALLOCATE
;	JMP	TEST_FREE
	JMP	TEST_COPY
;	JMP	TEST_CMP
;	JMP	TEST_DUMP

TEST_ALLOCATE:
	MVI	A,10			; ALLOCATE STRING LEN=10
	LXI	B,0x1234		; 'PARENT' = 0x1234
	CALL	STR_ALLOCATE
	
	MVI	A,20			; ALLOCATE STRING LEN=20
	LXI	B,0x4567		; 'PARENT' = 0x4567
	CALL	STR_ALLOCATE
	
TEST_FREE:	
	MVI	A,10			; ALLOCATE STRING LEN=10
	LXI	B,0x6666		; 'PARENT' = 0x6666
	CALL	STR_ALLOCATE		; STR PTR IN HL
	
	CALL	STR_FREE		; FREE STR	

	; SHOULD NOT BE DELETED
	LXI	H,0
	CALL	STR_FREE		; ADDRESS = 0 -> DON'T TOUCH
	
	LHLD	STR_LOPTR		; ADDRESS = STR_LOPTR
	CALL	STR_FREE


TEST_COPY:
	MVI	A,10			; ALLOCATE STRING LEN=10
	LXI	B,0x1234		; 'PARENT' = 0x1234
	CALL	STR_ALLOCATE		; RETURNS ADDRESS IN HL

	LXI	D,TESTSTR01		; SOURCE STRING
	MVI	B,9			; STRING LENGTH
	CALL	STR_COPY

TEST_CMP:
	LXI	B,0x0000
	LXI	D,TESTSTR1A		; ''
	LXI	H,TESTSTR1B		; ''
	CALL	STR_CMP			; RESULT: 0

	LXI	B,0x0100
	LXI	D,TESTSTR2A		; 'A'
	LXI	H,TESTSTR2B		; ''
	CALL	STR_CMP			; RESULT: +1

	LXI	B,0x0001
	LXI	D,TESTSTR3A		; ''
	LXI	H,TESTSTR3B		; 'A'
	CALL	STR_CMP			; RESULT: -1

	LXI	B,0x0101
	LXI	D,TESTSTR4A		; 'A'
	LXI	H,TESTSTR4B		; 'A'
	CALL	STR_CMP			; RESULT: 0

	LXI	B,0x0101
	LXI	D,TESTSTR5A		; 'A'
	LXI	H,TESTSTR5B		; 'B'
	CALL	STR_CMP			; RESULT: -1

	LXI	B,0x0101
	LXI	D,TESTSTR6A		; 'B'
	LXI	H,TESTSTR6B		; 'A'
	CALL	STR_CMP			; RESULT: +1

	LXI	B,0x0304
	LXI	D,TESTSTR7A		; 'ABA'
	LXI	H,TESTSTR7B		; 'ABAB'
	CALL	STR_CMP			; RESULT: -1

	LXI	B,0x0403
	LXI	D,TESTSTR8A		; 'ABAB'
	LXI	H,TESTSTR8B		; 'ABA'
	CALL	STR_CMP			; RESULT: +1

TEST_DUMP:
	CALL	STR_DUMPSTRINGS

LOOP:
	JMP	LOOP


TESTSTR01:	.asciz	'123456789'

	; STRINGS FOR STR_CMP
TESTSTR1A:	.asciz	''		; SIZE 0
TESTSTR1B:	.asciz	''		; SIZE 0

TESTSTR2A:	.asciz	'A'		; SIZE 1
TESTSTR2B:	.asciz	''		; SIZE 0

TESTSTR3A:	.asciz	''		; SIZE 0
TESTSTR3B:	.asciz	'A'		; SIZE 1

TESTSTR4A:	.asciz	'A'		; SIZE 1
TESTSTR4B:	.asciz	'A'		; SIZE 1

TESTSTR5A:	.asciz	'A'		; SIZE 1
TESTSTR5B:	.asciz	'B'		; SIZE 1

TESTSTR6A:	.asciz	'B'		; SIZE 1
TESTSTR6B:	.asciz	'A'		; SIZE 1

TESTSTR7A:	.asciz	'ABA'		; SIZE 3
TESTSTR7B:	.asciz	'ABAB'		; SIZE 4

TESTSTR8A:	.asciz	'ABAB'		; SIZE 4
TESTSTR8B:	.asciz	'ABA'		; SIZE 3



;.area	DATA	(REL,CON)

;OUTSTR:	.ds 128

