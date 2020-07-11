.module 	variabletest
.title 		Tests variable Module

.include	'variable.def'
.include	'..\io\io.def'
.include	'..\common\common.def'
.include	'..\program\program.def'
.include	'..\strings\strings.def'

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

	LXI	H,0x9000		; SET PRG AREA
	SHLD	PRG_LOPTR
	SHLD	PRG_HIPTR
	SHLD	VAR_LOPTR		; SET VAR PTRS
	SHLD	VAR_HIPTR

	CALL	PRG_INIT

	LXI	H,0xE000
	SHLD	STR_LOPTR
	SHLD	STR_HIPTR

;	JMP	TEST_INTNEWFIND
;	JMP	TEST_GET
	JMP	TEST_SET
	JMP	TEST_SETSTR

TEST_INTNEWFIND:	; TEST INTERNAL NEW AND INTERNAL FIND
	; TRY FIND WITH EMPTY VAR AREA
	MVI	B,'A			; CHECK FOR 'A'
	MVI	C,0
	CALL	VAR_INTERNALGET		; RESULT: HL = 0

	; CREATE NEW
	CALL	VAR_INTERNALNEW
	
	; TRY FIND AGAIN
	MVI	B,'A			; CHECK FOR 'A'
	MVI	C,0
	CALL	VAR_INTERNALGET		; RESULT: HL = VAR_LOPTR

	; TRY FIND NON EXISTING
	MVI	B,'B			; CHECK FOR 'B'
	MVI	C,0
	CALL	VAR_INTERNALGET		; RESULT: HL = 0

	; CREATE NEW VARIABLE
	MVI	B,'A			; CREATE 'AB'
	MVI	C,'B
	CALL	VAR_INTERNALNEW		

	; FIND IT
	MVI	B,'A			; CHECK FOR 'AB'
	MVI	C,'B
	CALL	VAR_INTERNALGET		; RESULT: ADDRESS OF 'AB'

	; FIND UNKNOWN
	MVI	B,'A			; CHECK FOR 'AC'
	MVI	C,'C
	CALL	VAR_INTERNALGET		; RESULT: HL = 0
	

TEST_GET:
	; NEW VARIABLE 'T0'
	MVI	B,'T			; CHECK FOR 'T0'
	MVI	C,'0
	LXI	H,VAR_TEMP1		; DESTINATION
	CALL	VAR_GET

TEST_SET:
	; NEW VARIABLE 'T0'
	MVI	A,SID_CINT
	STA	VAR_TEMP1
	LXI	H,0x1234
	SHLD	VAR_TEMP1+1	
	
	MVI	B,'T			; SET 'T0'
	MVI	C,'0
	LXI	H,VAR_TEMP1		; DESTINATION
	CALL	VAR_SET

	; NEW VARIABLE 'T1'
	MVI	A,SID_CINT
	STA	VAR_TEMP1
	LXI	H,0x4567
	SHLD	VAR_TEMP1+1	
	
	MVI	B,'T			; SET 'T1'
	MVI	C,'1
	LXI	H,VAR_TEMP1		; DESTINATION
	CALL	VAR_SET

	; VARIABLE 'T1' (EXISTING VARIABLE)
	MVI	A,SID_CINT
	STA	VAR_TEMP1
	LXI	H,0x6666
	SHLD	VAR_TEMP1+1	
	
	MVI	B,'T			; SET 'T1'
	MVI	C,'1
	LXI	H,VAR_TEMP1		; DESTINATION
	CALL	VAR_SET

TEST_SETSTR:
	; NEW VARIABLE 'A$'
	MVI	A,SID_CSTR
	STA	VAR_TEMP1
	MVI	A,TESTSTRV1END-TESTSTRV1
	STA	VAR_TEMP1+1
	LXI	H,TESTSTRV1
	SHLD	VAR_TEMP1+2	
	
	MVI	B,'A+128		; SET 'A$'
	MVI	C,'0
	LXI	H,VAR_TEMP1		; DESTINATION
	CALL	VAR_SET

	; NEW VARIABLE 'Z$'
	MVI	A,SID_CSTR
	STA	VAR_TEMP1
	MVI	A,TESTSTR1END-TESTSTR1
	STA	VAR_TEMP1+1
	LXI	H,TESTSTR1
	SHLD	VAR_TEMP1+2	
	
	MVI	B,'Z+128		; SET 'Z$'
	MVI	C,'0
	LXI	H,VAR_TEMP1		; DESTINATION
	CALL	VAR_SET

	; REPLACE VARIABLE 'Z$'
	MVI	A,SID_CSTR
	STA	VAR_TEMP1
	MVI	A,TESTSTR2END-TESTSTR2
	STA	VAR_TEMP1+1
	LXI	H,TESTSTR1
	SHLD	VAR_TEMP1+2	
	
	MVI	B,'Z+128		; SET 'Z$'
	MVI	C,'0
	LXI	H,VAR_TEMP1		; DESTINATION
	CALL	VAR_SET

	; REPLACE VARIABLE 'A$'
	MVI	A,SID_CSTR
	STA	VAR_TEMP1
	MVI	A,TESTSTRV2END-TESTSTRV2
	STA	VAR_TEMP1+1
	LXI	H,TESTSTRV1
	SHLD	VAR_TEMP1+2	
	
	MVI	B,'A+128		; SET 'A$'
	MVI	C,'0
	LXI	H,VAR_TEMP1		; DESTINATION
	CALL	VAR_SET

LOOP:
	JMP	LOOP


;TESTSTR1:	.asciz	''

.area	DATA	(REL,CON)

TESTSTR1:	.ascii	'1234567890'
TESTSTR1END:
TESTSTR2:	.ascii	'ABCDEFGHIJKLMNOP'
TESTSTR2END:

.area	VAR	(ABS)

.org 	0xA000

TESTSTRV1:	.ascii	'1234567890'
TESTSTRV1END:
TESTSTRV2:	.ascii	'ABCDEFGHIJKLMNOP'
TESTSTRV2END:

