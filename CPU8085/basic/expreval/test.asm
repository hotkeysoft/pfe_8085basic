.module 	exprevaltest
.title 		Tests expreval Module

.include	'expreval.def'
.include	'..\integer\integer.def'
.include	'..\tokenize\tokenize.def'

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

	CALL	INT_INIT
	CALL	EXP_INIT

;	JMP	TEST_BINCALC
;	JMP	TEST_BINREL
;	JMP	TEST_BINLOG
;	JMP	TEST_NEG
;	JMP	TEST_NOT
;	JMP	TEST_ABS
;	JMP	TEST_SGN
;	JMP	TEST_PEEK
	JMP	TEST_RND
	
TEST_BINCALC:	; TEST OF ARITHMETIC OPERATORS
	LXI	H,TESTSTR001	; 4+4
	CALL 	EVAL		; RESULT: 8
	LXI	H,TESTSTR002	; 4-4
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR003	; 4*4
	CALL 	EVAL		; RESULT: 16
	LXI	H,TESTSTR004	; 4/4
	CALL 	EVAL		; RESULT: 1


TEST_BINREL:	; TEST OF BINARY RELATIONS
	LXI	H,TESTSTR101	; 4=4
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTR102	; 4<>4
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTR103	; 4<4
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTR104	; 4>4
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTR105	; 4<=4
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTR106	; 4>=4
	CALL 	EVAL		; RESULT: TRUE

	LXI	H,TESTSTR111	; 1=10
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTR112	; 1<>10
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTR113	; 1<10
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTR114	; 1>10
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTR115	; 1<=10
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTR116	; 1>=10
	CALL 	EVAL		; RESULT: FALSE

	LXI	H,TESTSTR121	; 10=1
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTR122	; 10<>1
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTR123	; 10<1
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTR124	; 10>1
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTR125	; 10<=1
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTR126	; 10>=1
	CALL 	EVAL		; RESULT: TRUE

TEST_BINLOG:	; TESTS OF LOGICAL OPERATORS (AND OR XOR)
	LXI	H,TESTSTR201	; 0 AND 0
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR202	; 0 AND 255
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR203	; 255 AND 0
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR204	; 255 AND 255
	CALL 	EVAL		; RESULT: 255

	LXI	H,TESTSTR211	; 0 OR 0
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR212	; 0 OR 255
	CALL 	EVAL		; RESULT: 255
	LXI	H,TESTSTR213	; 255 OR 0
	CALL 	EVAL		; RESULT: 255
	LXI	H,TESTSTR214	; 255 OR 255
	CALL 	EVAL		; RESULT: 255

	LXI	H,TESTSTR221	; 0 XOR 0
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR222	; 0 XOR 255
	CALL 	EVAL		; RESULT: 255
	LXI	H,TESTSTR223	; 255 XOR 0
	CALL 	EVAL		; RESULT: 255
	LXI	H,TESTSTR224	; 255 XOR 255
	CALL 	EVAL		; RESULT: 0

TEST_NEG:	;	TESTS OF NEGATION
	LXI	H,TESTSTR301	; -10
	CALL 	EVAL		; RESULT: -10
	LXI	H,TESTSTR302	; --10
	CALL 	EVAL		; RESULT: +10
	LXI	H,TESTSTR303	; -(2+2)
	CALL 	EVAL		; RESULT: -4
	LXI	H,TESTSTR304	; -(-5--1)
	CALL 	EVAL		; RESULT: +4

TEST_NOT:	;	TESTS OF NOT
	LXI	H,TESTSTR401	; NOT 0
	CALL 	EVAL		; RESULT: -1
	LXI	H,TESTSTR402	; NOT NOT 0
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR403	; NOT -1
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR404	; NOT --1
	CALL 	EVAL		; RESULT: -2

TEST_ABS:	;	TESTS OF ABS
	LXI	H,TESTSTR501	; ABS ( 0  ) 
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR502	; ABS ( 1  ) 
	CALL 	EVAL		; RESULT: 1
	LXI	H,TESTSTR503	; ABS ( -1 )
	CALL 	EVAL		; RESULT: 1
	LXI	H,TESTSTR504	; ABS ( - ABS ( -10 ) )
	CALL 	EVAL		; RESULT: 10

TEST_SGN:	;	TESTS OF SGN
	LXI	H,TESTSTR601	; SGN ( 0  )
	CALL 	EVAL		; RESULT:  0
	LXI	H,TESTSTR602	; SGN ( 1  )
	CALL 	EVAL		; RESULT: 1
	LXI	H,TESTSTR603	; SGN ( -1 )
	CALL 	EVAL		; RESULT: -1
	LXI	H,TESTSTR604	; SGN ( -32768 )
	CALL 	EVAL		; RESULT: -1
	LXI	H,TESTSTR605	; SGN ( 32767 )
	CALL 	EVAL		; RESULT: 1

TEST_PEEK:	;	TESTS OF PEEK
	LXI	H,TESTSTR701	; PEEK ( 0  )
	CALL 	EVAL		; 
	LXI	H,TESTSTR702	; PEEK ( 32767  )
	CALL 	EVAL		; 
	LXI	H,TESTSTR703	; PEEK ( -1 )
	CALL 	EVAL		; 

TEST_RND:	;	TESTS OF RND
	LXI	H,TESTSTRRND	; RND(0)
	CALL 	EVAL		; 
	LXI	H,TESTSTRRND	; RND(0)
	CALL 	EVAL		; 
	LXI	H,TESTSTRRND	; RND(0)
	CALL 	EVAL		; 
	LXI	H,TESTSTRRND	; RND(0)
	CALL 	EVAL		; 



LOOP:
	JMP	LOOP

	
EVAL:	
	PUSH	H
	CALL	TOK_TOKENIZE1
	POP	H
	XCHG
	LXI	H,OUTSTR
	CALL	TOK_TOKENIZE2
	LXI	H,OUTSTR
	CALL	EXP_EXPREVAL
	RET	



.area	DATA	(REL,CON)


;	TESTS OF BINARY ARITHMETIC OPERATIONS
TESTSTR001:	.asciz	'4+4'			; 8
TESTSTR002:	.asciz	'4-4'			; 0
TESTSTR003:	.asciz	'4*4'			; 16
TESTSTR004:	.asciz	'4/4'			; 1


;	TESTS OF BINARY RELATIONS

TESTSTR101:	.asciz	'4=4'			; TRUE
TESTSTR102:	.asciz	'4<>4'			; FALSE
TESTSTR103:	.asciz	'4<4'			; FALSE
TESTSTR104:	.asciz	'4>4'			; FALSE
TESTSTR105:	.asciz	'4<=4'			; TRUE
TESTSTR106:	.asciz	'4>=4'			; TRUE

TESTSTR111:	.asciz	'1=10'			; FALSE
TESTSTR112:	.asciz	'1<>10'			; TRUE
TESTSTR113:	.asciz	'1<10'			; TRUE
TESTSTR114:	.asciz	'1>10'			; FALSE
TESTSTR115:	.asciz	'1<=10'			; TRUE
TESTSTR116:	.asciz	'1>=10'			; FALSE

TESTSTR121:	.asciz	'10=1'			; FALSE
TESTSTR122:	.asciz	'10<>1'			; TRUE
TESTSTR123:	.asciz	'10<1'			; FALSE
TESTSTR124:	.asciz	'10>1'			; TRUE
TESTSTR125:	.asciz	'10<=1'			; FALSE
TESTSTR126:	.asciz	'10>=1'			; TRUE

;	TESTS OF LOGICAL OPERATORS (AND OR XOR)

TESTSTR201:	.asciz	'0 AND 0'		; 0
TESTSTR202:	.asciz	'0 AND 255'		; 0
TESTSTR203:	.asciz	'255 AND 0'		; 0
TESTSTR204:	.asciz	'255 AND 255'		; 255

TESTSTR211:	.asciz	'0 OR 0'		; 0
TESTSTR212:	.asciz	'0 OR 255'		; 255
TESTSTR213:	.asciz	'255 OR 0'		; 255
TESTSTR214:	.asciz	'255 OR 255'		; 255

TESTSTR221:	.asciz	'0 XOR 0'		; 0
TESTSTR222:	.asciz	'0 XOR 255'		; 255
TESTSTR223:	.asciz	'255 XOR 0'		; 255
TESTSTR224:	.asciz	'255 XOR 255'		; 0

;	TESTS OF NEGATION
TESTSTR301:	.asciz	'-10'			; -10
TESTSTR302:	.asciz	'--10'			; +10
TESTSTR303:	.asciz	'-(2+2)'		; -4
TESTSTR304:	.asciz	'-(-5--1)'		; +4

;	TESTS OF NOT
TESTSTR401:	.asciz	'NOT 0'			; -1
TESTSTR402:	.asciz	'NOT NOT 0'		; 0
TESTSTR403:	.asciz	'NOT -1'		; 0
TESTSTR404:	.asciz	'NOT --1'		; -2

;	TESTS OF ABS
TESTSTR501:	.asciz	'ABS ( 0  ) '		; 0
TESTSTR502:	.asciz	'ABS ( 1  ) '		; 1
TESTSTR503:	.asciz	'ABS ( -1 )'		; 1
TESTSTR504:	.asciz	'ABS ( - ABS ( -10 ) )'	; 

;	TESTS OF SGN
TESTSTR601:	.asciz	'SGN ( 0  ) '		; 0
TESTSTR602:	.asciz	'SGN ( 1  ) '		; 1
TESTSTR603:	.asciz	'SGN ( -1 )'		; -1
TESTSTR604:	.asciz	'SGN ( -32768 )'	; -1
TESTSTR605:	.asciz	'SGN ( 32767 )'		; 1

;	TESTS OF PEEK
TESTSTR701:	.asciz	'PEEK ( 0  ) '		; 
TESTSTR702:	.asciz	'PEEK ( 32767  ) '	; 
TESTSTR703:	.asciz	'PEEK ( -1 )'		; 1

;	TESTS OF RND
TESTSTRRND:	.asciz	'RND(0)'		; 



OUTSTR:		.ds 128

