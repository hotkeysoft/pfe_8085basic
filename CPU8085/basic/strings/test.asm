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
	JMP	TEST_FREE

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

LOOP:
	JMP	LOOP


;TESTSTR1:	.asciz	''

;.area	DATA	(REL,CON)

;OUTSTR:	.ds 128

