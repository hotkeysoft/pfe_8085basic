.module 	tokenizetest
.title 		Tests tokenize Module

.include	'tokenize.def'
.include	'..\common\common.def'
.include	'..\error\error.def'
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
	SHLD	PRG_CURRLINE

	JMP	TEST_FINDTOKENID
;	JMP	TEST_FINDTOKENSTR
;	JMP	TEST_TOKENIZE


;TEST_FINDTOKENID:
	LXI	H,TESTSTR1
	CALL	TOK_FINDTOKENID		;TOK = K_POWER, LEN = 1
	LDA	TOK_CURRTOKEN
	CALL	IO_PUTCH

	LXI	H,TESTSTR2
	CALL	TOK_FINDTOKENID		;TOK = K_ADD, LEN = 1
	LDA	TOK_CURRTOKEN
	CALL	IO_PUTCH

	LXI	H,TESTSTR3
	CALL	TOK_FINDTOKENID		;TOK = K_NOTEQUAL, LEN = 2
	LDA	TOK_CURRTOKEN
	CALL	IO_PUTCH

	LXI	H,TESTSTR4
	CALL	TOK_FINDTOKENID		;TOK = K_ABS, LEN = 3
	LDA	TOK_CURRTOKEN
	CALL	IO_PUTCH

	LXI	H,TESTSTR5
	CALL	TOK_FINDTOKENID		;TOK = K_RIGHT, LEN = 6
	LDA	TOK_CURRTOKEN
	CALL	IO_PUTCH

	LXI	H,TESTSTR6
	CALL	TOK_FINDTOKENID		;TOK = K_PRINT, LEN = 1
	LDA	TOK_CURRTOKEN
	CALL	IO_PUTCH

	LXI	H,TESTSTR7
	CALL	TOK_FINDTOKENID		;TOK = K_NONE (0), LEN = ?
	LDA	TOK_CURRTOKEN
	CALL	IO_PUTCH

	LXI	H,TESTSTR8
	CALL	TOK_FINDTOKENID		;TOK = K_NONE (0), LEN = ?
	LDA	TOK_CURRTOKEN
	CALL	IO_PUTCH

	LXI	H,TESTSTR9
	CALL	TOK_FINDTOKENID		;TOK = K_TO, LEN = 2
	LDA	TOK_CURRTOKEN
	CALL	IO_PUTCH
TEST_FINDTOKENID:
.if DEBUG
	LXI	H,TESTSTR10
	CALL	TOK_FINDTOKENID		;TOK = K_DUMPVAR, LEN = 7
	LDA	TOK_CURRTOKEN
	CALL	IO_PUTCH

	LXI	H,TESTSTR11
	CALL	TOK_FINDTOKENID		;TOK = K_DUMPSTK, LEN = 7
	LDA	TOK_CURRTOKEN
	CALL	IO_PUTCH

	LXI	H,TESTSTR12
	CALL	TOK_FINDTOKENID		;TOK = K_DUMPSTR, LEN = 7
	LDA	TOK_CURRTOKEN
	CALL	IO_PUTCH
.endif
	HLT

TEST_FINDTOKENSTR:

	MVI	A, K_POWER
	CALL	TOK_FINDTOKENSTR	;[HL] = "^"

	MVI	A, K_PRINT
	CALL	TOK_FINDTOKENSTR	;[HL] = "PRINT"

	MVI	A, 0xFF
	CALL	TOK_FINDTOKENSTR	;HL = 0

;TEST_TOKENIZE:

; TOKENIZE1
	LXI	H,TESTSTR100
	CALL	TOK_TOKENIZE1
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTR101
	CALL	TOK_TOKENIZE1
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,CONTINUE1			; SET RESTART POS
	SHLD	ERR_RESTARTPTR

	LXI	H,TESTSTR102
	CALL	TOK_TOKENIZE1

CONTINUE1:
	LXI	H,TESTSTR103
	CALL	TOK_TOKENIZE1
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTR104
	CALL	TOK_TOKENIZE1
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTR105
	CALL	TOK_TOKENIZE1
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTR106
	CALL	TOK_TOKENIZE1
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTR107
	CALL	TOK_TOKENIZE1
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTR108
	CALL	TOK_TOKENIZE1
	CALL	IO_PUTS
	CALL	IO_PUTCR
TEST_TOKENIZE:
	LXI	H,TESTSTR109
	CALL	TOK_TOKENIZE1
	CALL	IO_PUTS
	CALL	IO_PUTCR

	CALL	IO_CLS

TEST_TOKENIZE2:
; TOKENIZE2 + UNTOKENIZE
	LXI	D,TESTSTR100
	LXI	H,OUTSTR
	CALL	TOK_TOKENIZE2
	CALL	IO_PUTS
	CALL	IO_PUTCR
	CALL	TOK_UNTOKENIZE
	CALL	IO_PUTCR
	CALL	IO_PUTCR

	LXI	D,TESTSTR101
	LXI	H,OUTSTR	
	CALL	TOK_TOKENIZE2
	CALL	IO_PUTS
	CALL	IO_PUTCR
	CALL	TOK_UNTOKENIZE
	CALL	IO_PUTCR
	CALL	IO_PUTCR

	LXI	D,TESTSTR103
	LXI	H,OUTSTR	
	CALL	TOK_TOKENIZE2
	CALL	IO_PUTS
	CALL	IO_PUTCR
	CALL	TOK_UNTOKENIZE
	CALL	IO_PUTCR
	CALL	IO_PUTCR

	LXI	D,TESTSTR104
	LXI	H,OUTSTR	
	CALL	TOK_TOKENIZE2
	CALL	IO_PUTS
	CALL	IO_PUTCR
	CALL	TOK_UNTOKENIZE
	CALL	IO_PUTCR
	CALL	IO_PUTCR	

	LXI	D,TESTSTR105
	LXI	H,OUTSTR	
	CALL	TOK_TOKENIZE2
	CALL	IO_PUTS
	CALL	IO_PUTCR
	CALL	TOK_UNTOKENIZE
	CALL	IO_PUTCR
	CALL	IO_PUTCR		

	LXI	D,TESTSTR106
	LXI	H,OUTSTR	
	CALL	TOK_TOKENIZE2
	CALL	IO_PUTS
	CALL	IO_PUTCR
	CALL	TOK_UNTOKENIZE
	CALL	IO_PUTCR	
	CALL	IO_PUTCR

	LXI	D,TESTSTR107
	LXI	H,OUTSTR	
	CALL	TOK_TOKENIZE2
	CALL	IO_PUTS
	CALL	IO_PUTCR
	CALL	TOK_UNTOKENIZE
	CALL	IO_PUTCR
	CALL	IO_PUTCR	

	LXI	H,CONTINUE2			; SET RESTART POS
	SHLD	ERR_RESTARTPTR

	LXI	D,TESTSTR108
	LXI	H,OUTSTR	
	CALL	TOK_TOKENIZE2

CONTINUE2:

	LXI	D,TESTSTR109
	LXI	H,OUTSTR	
	CALL	TOK_TOKENIZE2
	CALL	IO_PUTS
	CALL	IO_PUTCR
	CALL	TOK_UNTOKENIZE
	CALL	IO_PUTCR	
	CALL	IO_PUTCR


LOOP:
	JMP	LOOP


TESTSTR1:	.asciz	'^'
TESTSTR2:	.asciz	'+'
TESTSTR3:	.asciz	'<>'

TESTSTR4:	.asciz	'ABS'
TESTSTR5:	.asciz	'RIGHT$'
TESTSTR6:	.asciz	'?'

TESTSTR7:	.asciz	'!'
TESTSTR8:	.asciz	'IN'

TESTSTR9:	.asciz	'TO'

TESTSTR10:	.asciz	'DUMPVAR'
TESTSTR11:	.asciz	'DUMPSTK'
TESTSTR12:	.asciz	'DUMPSTR'

.area	DATA	(REL,CON)
TESTSTR100:	.asciz	'X=ABS(-10)'
TESTSTR101:	.asciz	'PRINT "PRINTS A STRING", A$'

TESTSTR102:	.asciz	'?"NOEND'

TESTSTR103:	.asciz	'X=128: REM COMMENT'

TESTSTR104:	.asciz	'X=-1'
TESTSTR105:	.asciz	'? A,-X*2'
TESTSTR106:	.asciz	'? 20-9'

TESTSTR107:	.asciz	'VARIABLE$ = "TEST" + STR$(NUM01)'

TESTSTR108:	.asciz	'TOTO = 2 + @#$: REM INVALID CHARS'

TESTSTR109:	.asciz	'DUMPSTR'

OUTSTR:		.ds 128

