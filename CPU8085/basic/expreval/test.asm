.module 	exprevaltest
.title 		Tests expreval Module

.include	'expreval.def'
.include	'..\integer\integer.def'
.include	'..\tokenize\tokenize.def'
.include	'..\strings\strings.def'
.include	'..\io\io.def'
.include	'..\error\error.def'
.include	'..\variables\variable.def'
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

	; IO INIT
	CALL	IO_INIT
	LXI	H,0
	SHLD	PRG_CURRLINE

	CALL	INT_INIT
	CALL	EXP_INIT

	; TEST PROGRAM
	LXI	H,TESTPRG1		; PROGRAM MEMORY
	SHLD	PRG_LOPTR
	
	LXI	H,TESTPRG4END
	SHLD	PRG_HIPTR
	SHLD	VAR_LOPTR
	SHLD	VAR_HIPTR
	
	CALL	PRG_INIT

	; SET STR PTRS
	LXI	H,0xA000
	SHLD	STR_LOPTR
	SHLD	STR_HIPTR

	; SET ZZ = 70
	MVI	B,'Z
	MVI	C,'Z
	MVI	A,SID_CINT
	STA	VAR_TEMP1
	LXI	H,70
	SHLD	VAR_TEMP1+1
	LXI	H,VAR_TEMP1
	CALL	VAR_SET

	LXI	H,LOOP
	SHLD	ERR_RESTARTPTR

;	JMP	TEST_BINCALC
;	JMP	TEST_BINREL
;	JMP	TEST_BINLOG
;	JMP	TEST_NEG
;	JMP	TEST_NOT
;	JMP	TEST_ABS
;	JMP	TEST_SGN
;	JMP	TEST_PEEK
;	JMP	TEST_RND
;	JMP	TEST_SQR
;	JMP	TEST_LEN
;	JMP	TEST_ASC
;	JMP	TEST_VAL
;	JMP	TEST_CHR
;	JMP	TEST_ADDSTR
;	JMP	TEST_BINRELSTR
;	JMP	TEST_STR
;	JMP	TEST_LEFT
;	JMP	TEST_RIGHT
;	JMP	TEST_MID
;	JMP	TEST_ERROR
;	JMP	TEST_LIST
;	JMP	TEST_END
;	JMP	TEST_NEW
;	JMP	TEST_PRINT
;	JMP	TEST_LET
;	JMP	TEST_CLR
;	JMP	TEST_REM
;	JMP	TEST_IF

	LXI	H,TEST_INTERACTIVE
	SHLD	ERR_RESTARTPTR

	CALL	TEST_INTERACTIVE
	
TEST_BINCALC:	; TEST OF ARITHMETIC OPERATORS
	LXI	H,TESTSTR0
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTR001	; 4+4
	CALL 	EVAL		; RESULT: 8
	LXI	H,TESTSTR002	; 4-4
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR003	; 4*4
	CALL 	EVAL		; RESULT: 16
	LXI	H,TESTSTR004	; 4/4
	CALL 	EVAL		; RESULT: 1

	LXI	H,TESTSTR005	; A+50
	CALL 	EVAL		; RESULT: 50
	LXI	H,TESTSTR006	; 50+ZZ
	CALL 	EVAL		; RESULT: 50

	CALL	EXP_DUMPSTACK	; PRINT RESULTS
	CALL	EXP_CLEARSTACK

	HLT

TEST_BINREL:	; TEST OF BINARY RELATIONS
	LXI	H,TESTSTR1
	CALL	IO_PUTS
	CALL	IO_PUTCR

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

	CALL	EXP_DUMPSTACK	; PRINT RESULTS
	CALL	EXP_CLEARSTACK

	LXI	H,TESTSTR131	; ZZ=ZZ+1
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTR132	; ZZ<>ZZ+1
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTR133	; ZZ<ZZ/2
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTR134	; ZZ>ZZ/10
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTR135	; ZZ<=ZZ-1
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTR136	; ZZ>=ZZ-ZZ
	CALL 	EVAL		; RESULT: TRUE

	CALL	EXP_DUMPSTACK	; PRINT RESULTS
	CALL	EXP_CLEARSTACK



TEST_BINLOG:	; TESTS OF LOGICAL OPERATORS (AND OR XOR)
	LXI	H,TESTSTR2
	CALL	IO_PUTS
	CALL	IO_PUTCR

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

	CALL	EXP_DUMPSTACK	; PRINT RESULTS
	CALL	EXP_CLEARSTACK

TEST_NEG:	;	TESTS OF NEGATION
	LXI	H,TESTSTR3
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTR301	; -10
	CALL 	EVAL		; RESULT: -10
	LXI	H,TESTSTR302	; --10
	CALL 	EVAL		; RESULT: +10
	LXI	H,TESTSTR303	; -(2+2)
	CALL 	EVAL		; RESULT: -4
	LXI	H,TESTSTR304	; -(-5--1)
	CALL 	EVAL		; RESULT: +4

	CALL	EXP_DUMPSTACK	; PRINT RESULTS
	CALL	EXP_CLEARSTACK

TEST_NOT:	;	TESTS OF NOT
	LXI	H,TESTSTR4
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTR401	; NOT 0
	CALL 	EVAL		; RESULT: -1
	LXI	H,TESTSTR402	; NOT NOT 0
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR403	; NOT -1
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR404	; NOT --1
	CALL 	EVAL		; RESULT: -2

	CALL	EXP_DUMPSTACK	; PRINT RESULTS
	CALL	EXP_CLEARSTACK

TEST_ABS:	;	TESTS OF ABS
	LXI	H,TESTSTR5
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTR501	; ABS ( 0  ) 
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR502	; ABS ( 1  ) 
	CALL 	EVAL		; RESULT: 1
	LXI	H,TESTSTR503	; ABS ( -1 )
	CALL 	EVAL		; RESULT: 1
	LXI	H,TESTSTR504	; ABS ( - ABS ( -10 ) )
	CALL 	EVAL		; RESULT: 10

	CALL	EXP_DUMPSTACK	; PRINT RESULTS
	CALL	EXP_CLEARSTACK

TEST_SGN:	;	TESTS OF SGN
	LXI	H,TESTSTR6
	CALL	IO_PUTS
	CALL	IO_PUTCR

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

	CALL	EXP_DUMPSTACK	; PRINT RESULTS
	CALL	EXP_CLEARSTACK

TEST_PEEK:	;	TESTS OF PEEK
	LXI	H,TESTSTR7
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTR701	; PEEK ( 0  )
	CALL 	EVAL		; 
	LXI	H,TESTSTR702	; PEEK ( 32767  )
	CALL 	EVAL		; 
	LXI	H,TESTSTR703	; PEEK ( -1 )
	CALL 	EVAL		; 

	CALL	EXP_DUMPSTACK	; PRINT RESULTS
	CALL	EXP_CLEARSTACK

TEST_RND:	;	TESTS OF RND
	LXI	H,TESTSTRR0
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTRRND	; RND(0)
	CALL 	EVAL		; 
	LXI	H,TESTSTRRND	; RND(0)
	CALL 	EVAL		; 
	LXI	H,TESTSTRRND	; RND(0)
	CALL 	EVAL		; 
	LXI	H,TESTSTRRND	; RND(0)
	CALL 	EVAL		; 

	CALL	EXP_DUMPSTACK	; PRINT RESULTS
	CALL	EXP_CLEARSTACK

TEST_SQR:	;	TESTS OF SQR
	LXI	H,TESTSTR8
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTR801	; SQR(10)
	CALL 	EVAL		; RESULT: 3
	LXI	H,TESTSTR802	; SQR(100)
	CALL 	EVAL		; RESULT: 10
	LXI	H,TESTSTR803	; SQR(1000)
	CALL 	EVAL		; RESULT: 31
	LXI	H,TESTSTR804	; SQR(10000)
	CALL 	EVAL		; RESULT: 100

	CALL	EXP_DUMPSTACK	; PRINT RESULTS
	CALL	EXP_CLEARSTACK

TEST_LEN:	;	TESTS OF LEN
	LXI	H,TESTSTR9
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTR901	; LEN("")
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR902	; SQR("A")
	CALL 	EVAL		; RESULT: 1
	LXI	H,TESTSTR903	; SQR("12345")
	CALL 	EVAL		; RESULT: 5

	CALL	EXP_DUMPSTACK	; PRINT RESULTS
	CALL	EXP_CLEARSTACK

TEST_ASC:	;	TESTS OF ASC
	LXI	H,TESTSTRA
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTRA01	; ASC("1234")
	CALL 	EVAL		; RESULT: '1'
	LXI	H,TESTSTRA02	; ASC(" ")
	CALL 	EVAL		; RESULT: 32

	CALL	EXP_DUMPSTACK	; PRINT RESULTS
	CALL	EXP_CLEARSTACK

TEST_VAL:	;	TESTS OF VAL
	LXI	H,TESTSTRB
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTRB01	; VAL("1234")
	CALL 	EVAL		; RESULT: 1234
	LXI	H,TESTSTRB02	; VAL("-666")
	CALL 	EVAL		; RESULT: -666

	CALL	EXP_DUMPSTACK	; PRINT RESULTS
	CALL	EXP_CLEARSTACK

TEST_CHR:	;	TESTS OF CHR$
	LXI	H,TESTSTRC
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTRC01	; CHR$(65)
	CALL 	EVAL		; RESULT: "A"
	LXI	H,TESTSTRC02	; CHR$(48)
	CALL 	EVAL		; RESULT: "0"

	CALL	EXP_DUMPSTACK	; PRINT RESULTS
	CALL	EXP_CLEARSTACK

TEST_ADDSTR:	;	TESTS OF ADD (STR)
	LXI	H,TESTSTRD
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTRD01	; "1234"+"66"
	CALL 	EVAL		; RESULT: "123466"
	LXI	H,TESTSTRD02	; "6666"+""
	CALL 	EVAL		; RESULT: "6666"

	CALL	EXP_DUMPSTACK	; PRINT RESULTS
	CALL	EXP_CLEARSTACK

TEST_BINRELSTR:	;	TESTS OF BINARY RELATIONS
	LXI	H,TESTSTRE
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTRE01	; "A"="A"
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTRE02	; "B"<>"B"
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTRE03	; "C"<"C"
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTRE04	; "C">"C"
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTRE05	; "D"<="D"
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTRE06	; "E">="E"
	CALL 	EVAL		; RESULT: TRUE

	LXI	H,TESTSTRE11	; "A"="B"
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTRE12	; "A"<>"B"
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTRE13	; "A"<"B"
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTRE14	; "A">"B"
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTRE15	; "A"<="B"
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTRE16	; "A">="B"
	CALL 	EVAL		; RESULT: FALSE

	LXI	H,TESTSTRE21	; "B"="A"
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTRE22	; "B"<>"A"
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTRE23	; "B"<"A"
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTRE24	; "B">"A"
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTRE25	; "B"<="A"
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTRE26	; "B">="A"
	CALL 	EVAL		; RESULT: TRUE

	CALL	EXP_DUMPSTACK	; PRINT RESULTS
	CALL	EXP_CLEARSTACK

TEST_STR:	;	TESTS OF STR$
	LXI	H,TESTSTRF
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTRF01	; STR$(0)
	CALL 	EVAL		; RESULT: " 0"
	LXI	H,TESTSTRF02	; STR$(-1)
	CALL 	EVAL		; RESULT: "-1"
	LXI	H,TESTSTRF03	; STR$(1234)
	CALL 	EVAL		; RESULT: "1234"
	LXI	H,TESTSTRF04	; STR$(10+10)
	CALL 	EVAL		; RESULT: "20"
	LXI	H,TESTSTRF05	; STR$(10*10)
	CALL 	EVAL		; RESULT: "100"

	CALL	EXP_DUMPSTACK	; PRINT RESULTS
	CALL	EXP_CLEARSTACK

TEST_LEFT:	;	TESTS OF LEFT$
	LXI	H,TESTSTRG
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTRG01	; LEFT$("ABCD",2)
	CALL 	EVAL		; RESULT: "AB"
	LXI	H,TESTSTRG02	; LEFT$("ABCD",4)
	CALL 	EVAL		; RESULT: "ABCD"
	LXI	H,TESTSTRG03	; LEFT$("ABCD",66)
	CALL 	EVAL		; RESULT: "ABCD"
	LXI	H,TESTSTRG04	; LEFT$("",0)
	CALL 	EVAL		; RESULT: ""
	LXI	H,TESTSTRG05	; LEFT$("",5)
	CALL 	EVAL		; RESULT: ""

	CALL	EXP_DUMPSTACK	; PRINT RESULTS
	CALL	EXP_CLEARSTACK

TEST_RIGHT:	;	TESTS OF RIGHT$
	LXI	H,TESTSTRH
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTRH01	; RIGHT$("ABCD",2)
	CALL 	EVAL		; RESULT: "CD"
	LXI	H,TESTSTRH02	; RIGHT$("ABCD",4)
	CALL 	EVAL		; RESULT: "ABCD"
	LXI	H,TESTSTRH03	; RIGHT$("ABCD",66)
	CALL 	EVAL		; RESULT: "ABCD"
	LXI	H,TESTSTRH04	; RIGHT$("",0)
	CALL 	EVAL		; RESULT: ""
	LXI	H,TESTSTRH05	; RIGHT$("",5)
	CALL 	EVAL		; RESULT: ""

	CALL	EXP_DUMPSTACK	; PRINT RESULTS
	CALL	EXP_CLEARSTACK

TEST_MID:	;	TESTS OF MID$
	LXI	H,TESTSTRI
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTRI01	; MID$("ABCD",66,66)
	CALL 	EVAL		; RESULT: ""
	LXI	H,TESTSTRI02	; MID$("ABCD",2,0)
	CALL 	EVAL		; RESULT: ""
	LXI	H,TESTSTRI03	; MID$("ABCD",1,1)
	CALL 	EVAL		; RESULT: "A"
	LXI	H,TESTSTRI04	; MID$("ABCD",2,2)
	CALL 	EVAL		; RESULT: "BC"
	LXI	H,TESTSTRI05	; MID$("ABCD",3,66)
	CALL 	EVAL		; RESULT: "CD"
	LXI	H,TESTSTRI06	; MID$("ABCD",4,1)
	CALL 	EVAL		; RESULT: "D"
	LXI	H,TESTSTRI07	; MID$("ABCD",3,255)
	CALL 	EVAL		; RESULT: "CD"


	CALL	EXP_DUMPSTACK	; PRINT RESULTS
	CALL	EXP_CLEARSTACK

TEST_ERROR:	;	TESTS OF ERROR HANDLING
	LXI	H,TESTSTRX
	CALL	IO_PUTS
	CALL	IO_PUTCR
	
	LXI	H,X01
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX01	; 2 + "2"
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X01:
	LXI	H,X02
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX02	; 2 AND "2"
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X02:	
	LXI	H,X03
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX03	; "THIS" = 3
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X03:
	LXI	H,X04
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX04	; "THIS" / "THAT"
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X04:

	LXI	H,X05
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX05	; "THIS" AND "THAT"
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X05:
	LXI	H,X06
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX06	; -"THIS"
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X06:
	LXI	H,X07
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX07	; NOT "THIS"
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X07:
	LXI	H,X08
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX08	; ABS("THIS")
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X08:
	LXI	H,X09
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX09	; SGN("THIS")
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X09:
	LXI	H,X0A
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX0A	; PEEK("THIS")
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X0A:
	LXI	H,X0B
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX0B	; RND("THIS")
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X0B:
	LXI	H,X0C
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX0C	; SQR("THIS")
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X0C:
	LXI	H,X0D
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX0D	; LEN(1234)
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X0D:
	LXI	H,X0E
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX0E	; ASC(1234)
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X0E:
	LXI	H,X0F
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX0F	; VAL(1234)
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X0F:
	LXI	H,X0G
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX0G	; CHR$("THIS")
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X0G:
	LXI	H,X0H
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX0H	; STR$("THIS")
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X0H:
	LXI	H,X0I
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX0I	; LEFT$("THIS", "THAT")
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X0I:
	LXI	H,X0J
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX0J	; LEFT$(3, 4)
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X0J:
	LXI	H,X0K
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX0K	; RIGHT$("THIS", "THAT")
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X0K:
	LXI	H,X0L
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX0L	; RIGHT$(3, 4)
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X0L:
	LXI	H,X0M
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX0M	; MID$(3, 2, 1)
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X0M:
	LXI	H,X0N
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX0N	; MID$("A", "B", 1)
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X0N:
	LXI	H,X0O
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX0O	; MID$("A", 3, "C")
	CALL 	EVAL		; RESULT: TYPE MISMATCH
X0O:
	LXI	H,X11
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX11	; ASC("")
	CALL 	EVAL		; RESULT: ILLEGAL ARGUMENT
X11:
	LXI	H,X12
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX12	; VAL("")
	CALL 	EVAL		; RESULT: ILLEGAL ARGUMENT
X12:
	LXI	H,X13
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX13	; CHR$(666)
	CALL 	EVAL		; RESULT: ILLEGAL ARGUMENT
X13:
	LXI	H,X14
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX14	; LEFT$("THIS",666)
	CALL 	EVAL		; RESULT: ILLEGAL ARGUMENT
X14:
	LXI	H,X15
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX15	; RIGHT$("THIS",666)
	CALL 	EVAL		; RESULT: ILLEGAL ARGUMENT
X15:
	LXI	H,X16
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX16	; MID$("THIS",0,1)
	CALL 	EVAL		; RESULT: ILLEGAL ARGUMENT
X16:
	LXI	H,X17
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX17	; MID$("THIS",666,1)
	CALL 	EVAL		; RESULT: ILLEGAL ARGUMENT
X17:
	LXI	H,X21
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX18	; MID$("THIS",1,666)
	CALL 	EVAL		; RESULT: ILLEGAL ARGUMENT

X21:
	LXI	H,X22
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX21	; 32760+10
	CALL 	EVAL		; RESULT: OVERFLOW
X22:	
	LXI	H,X23
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX22	; 3280*10
	CALL 	EVAL		; RESULT: OVERFLOW
X23:	
	LXI	H,X24
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX23	; -32767-100
	CALL 	EVAL		; RESULT: OVERFLOW
X24:
	LXI	H,X31
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX24	; 1000/0
	CALL 	EVAL		; RESULT: DIVISION BY ZERO

X31:
	LXI	H,X32
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX31	; 2*(2+2
	CALL 	EVAL		; RESULT: SYNTAX ERROR
X32:
	LXI	H,X33
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX32	; ABS(123
	CALL 	EVAL		; RESULT: SYNTAX ERROR
X33:
	LXI	H,X34
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX33	; LEFT$("THIS")
	CALL 	EVAL		; RESULT: SYNTAX ERROR
X34:
	LXI	H,X35
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX34	; RIGHT$("THAT")
	CALL 	EVAL		; RESULT: SYNTAX ERROR
X35:
	LXI	H,X36
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX35	; MID$("THAT")
	CALL 	EVAL		; RESULT: SYNTAX ERROR
X36:
	LXI	H,X37
	SHLD	ERR_RESTARTPTR
	LXI	H,TESTSTRX36	; MID$("THAT",2)
	CALL 	EVAL		; RESULT: SYNTAX ERROR

X37:

	LXI	H,LOOP
	SHLD	ERR_RESTARTPTR

TEST_LIST:
	LXI	H,TESTSTRLIST
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTRLIST01	; LIST
	CALL 	EXECUTE		; RESULT: LISTS PROGRAM
	CALL	IO_PUTCR

	LXI	H,TESTSTRLIST02	; LIST
	CALL 	EXECUTE		; RESULT: LISTS PROGRAM
	CALL	IO_PUTCR

TEST_END:
	LXI	H,TESTSTREND
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTREND01	; LIST : END : LIST
	CALL 	EXECUTE		; RESULT: LIST (ONCE)
	CALL	IO_PUTCR

TEST_NEW:
	LXI	H,TESTSTRNEW
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTRNEW01	; LIST : NEW : LIST
	CALL 	EXECUTE		; RESULT: LIST (ONCE)
	CALL	IO_PUTCR

	; "RESTORE" PROGRAM
	LXI	H,TESTPRG1		; PROGRAM MEMORY
	SHLD	PRG_LOPTR
	
	LXI	H,TESTPRG4END
	SHLD	PRG_HIPTR
	SHLD	VAR_LOPTR
	SHLD	VAR_HIPTR

TEST_PRINT:
	LXI	H,TESTSTRPRINT
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTRPRINT01	; PRINT 1234
	CALL 	EXECUTE			; RESULT: 1234

	LXI	H,TESTSTRPRINT02	; PRINT 1234 + 5678
	CALL 	EXECUTE			; RESULT: 6912

	LXI	H,TESTSTRPRINT03	; PRINT 1234 , 5678
	CALL 	EXECUTE			; RESULT: 1234	5678

	LXI	H,TESTSTRPRINT04	; PRINT 1234 : ? 6666
	CALL 	EXECUTE			; RESULT: 1234 (CR) 6666

	LXI	H,TESTSTRPRINT05	; PRINT 1234 ; : ? 5678
	CALL 	EXECUTE			; RESULT: 1234	5678

	LXI	H,TESTSTRPRINT06	; PRINT ZZ,ZZ*10,ZZ*100
	CALL 	EXECUTE			; RESULT: 70	700	7000

	LXI	H,TESTSTRPRINT07	; PRINT 1234 , : ? 5678
	CALL 	EXECUTE			; RESULT: 1234	5678

	LXI	H,TESTSTRPRINT11	; PRINT "THIS"
	CALL 	EXECUTE			; RESULT: THIS

	LXI	H,TESTSTRPRINT12	; PRINT "","Z","X",123
	CALL 	EXECUTE			; RESULT:  	Z	X	123
	
	LXI	H,TESTSTRPRINT13	; PRINT STR$(66*66),666
	CALL 	EXECUTE			; RESULT: 4356	666

TEST_LET:
	LXI	H,TESTSTRLET
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTRLET01		; ?V0,: LETV0=123 : ?V0
	CALL 	EXECUTE			; RESULT: 0	123

	LXI	H,TESTSTRLET02		; V0=V0*V0 :?"V0=";V0
	CALL 	EXECUTE			; RESULT: V0=15129

	LXI	H,TESTSTRLET03		; A$=CHR$(65):?"A$=";A$
	CALL 	EXECUTE			; RESULT: A$=A

	LXI	H,TESTSTRLET04		; A$=A$+"123":?"A$=";A$
	CALL 	EXECUTE			; RESULT: A$=A123
	
	LXI	H,TESTSTRLET05		; Z$=LEFT$(A$,2):?"Z$=";Z$
	CALL 	EXECUTE			; RESULT: Z$=A1

	LXI	H,TESTSTRLET06		; ZZ$=A$+A$+Z$+Z$
	CALL 	EXECUTE			; RESULT: ZZ$=A123A123A1A1

TEST_CLR:
	LXI	H,TESTSTRCLR
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTRCLR01		; A=123:?"A=";A,:CLR:?"A=";A
	CALL 	EXECUTE			; RESULT: A=123	A=0

	LXI	H,TESTSTRCLR02		; A$="ZXC":?A$,:CLR:?"A$=";A$
	CALL 	EXECUTE			; RESULT: ZXC	A$=

TEST_REM:
	LXI	H,TESTSTRREM
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTRREM01		; ?"REMTEST";:REM TEST:?TEST
	CALL 	EXECUTE			; RESULT: REMTEST

TEST_IF:
	LXI	H,TESTSTRIF
	CALL	IO_PUTS
	CALL	IO_PUTCR

	LXI	H,TESTSTRIF01		; IF 1 = 0 THEN ?1:?2:?3
	CALL 	EXECUTE			; RESULT: ""
	LXI	H,TESTSTRIF02		; IF 1 = 1 THEN ?1:?2:?3
	CALL 	EXECUTE			; RESULT: 123
	LXI	H,TESTSTRIF03		; IF 1=0 THEN?"1=0"ELSE?"1<>0"
	CALL 	EXECUTE			; RESULT: 1<>0
	LXI	H,TESTSTRIF04		; IF 1=1 THEN?"1=1"ELSE?"1<>1"
	CALL 	EXECUTE			; RESULT: 1=1
	
	
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
	CALL	EXP_L0
	RET	

EXECUTE::
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



TEST_INTERACTIVE:
	LXI	H,READYSTR
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
	
	JMP	TEST_INTERACTIVE

READYSTR:	.asciz	'Ready.'

.area	DATA	(REL,CON)


TESTSTR0:	.asciz	'TESTS OF BINARY ARITHMETIC OPERATIONS'
TESTSTR001:	.asciz	'4+4'			; 8
TESTSTR002:	.asciz	'4-4'			; 0
TESTSTR003:	.asciz	'4*4'			; 16
TESTSTR004:	.asciz	'4/4'			; 1
TESTSTR005:	.asciz	'A+50'			; 50
TESTSTR006:	.asciz	'50+ZZ'			; 50

TESTSTR1:	.asciz	'TESTS OF BINARY RELATIONS'
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

TESTSTR131:	.asciz	'ZZ=ZZ+1'			; FALSE
TESTSTR132:	.asciz	'ZZ<>ZZ+1'			; TRUE
TESTSTR133:	.asciz	'ZZ<ZZ/2'			; FALSE
TESTSTR134:	.asciz	'ZZ>ZZ/10'			; TRUE
TESTSTR135:	.asciz	'ZZ<=ZZ-1'			; FALSE
TESTSTR136:	.asciz	'ZZ>=ZZ-ZZ'			; TRUE

TESTSTR2:	.asciz	'TESTS OF LOGICAL OPERATORS (AND OR XOR)'
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

TESTSTR3:	.asciz	'TESTS OF NEGATION'
TESTSTR301:	.asciz	'-10'			; -10
TESTSTR302:	.asciz	'--10'			; +10
TESTSTR303:	.asciz	'-(2+2)'		; -4
TESTSTR304:	.asciz	'-(-5--1)'		; +4

TESTSTR4:	.asciz	'TESTS OF NOT'
TESTSTR401:	.asciz	'NOT 0'			; -1
TESTSTR402:	.asciz	'NOT NOT 0'		; 0
TESTSTR403:	.asciz	'NOT -1'		; 0
TESTSTR404:	.asciz	'NOT --1'		; -2

TESTSTR5:	.asciz	'TESTS OF ABS'
TESTSTR501:	.asciz	'ABS ( 0  ) '		; 0
TESTSTR502:	.asciz	'ABS ( 1  ) '		; 1
TESTSTR503:	.asciz	'ABS ( -1 )'		; 1
TESTSTR504:	.asciz	'ABS ( - ABS ( -10 ) )'	; 10

TESTSTR6:	.asciz	'TESTS OF SGN'
TESTSTR601:	.asciz	'SGN ( 0  ) '		; 0
TESTSTR602:	.asciz	'SGN ( 1  ) '		; 1
TESTSTR603:	.asciz	'SGN ( -1 )'		; -1
TESTSTR604:	.asciz	'SGN ( -32768 )'	; -1
TESTSTR605:	.asciz	'SGN ( 32767 )'		; 1

TESTSTR7:	.asciz	'TESTS OF PEEK'
TESTSTR701:	.asciz	'PEEK ( 0  ) '		; 
TESTSTR702:	.asciz	'PEEK ( 32767  ) '	; 
TESTSTR703:	.asciz	'PEEK ( -1 )'		; 1

TESTSTRR0:	.asciz	'TESTS OF RND'
TESTSTRRND:	.asciz	'RND(0)'		; 

TESTSTR8:	.asciz	'TESTS OF SQR'
TESTSTR801:	.asciz	'SQR(10)'		; 3
TESTSTR802:	.asciz	'SQR(100)'		; 10
TESTSTR803:	.asciz	'SQR(1000)'		; 31
TESTSTR804:	.asciz	'SQR(10000)'		; 100

TESTSTR9:	.asciz	'TESTS OF LEN'
TESTSTR901:	.asciz	'LEN("")'		; 0
TESTSTR902:	.asciz	'LEN("A")'		; 1
TESTSTR903:	.asciz	'LEN("12345")'		; 5

TESTSTRA:	.asciz	'TESTS OF ASC'
TESTSTRA01:	.asciz	'ASC("1234")'		; '1'
TESTSTRA02:	.asciz	'ASC(" ")'		; 32

TESTSTRB:	.asciz	'TESTS OF VAL'
TESTSTRB01:	.asciz	'VAL("1234")'		; 1234
TESTSTRB02:	.asciz	'VAL("-666")'		; -666

TESTSTRC:	.asciz	'TESTS OF CHR$'
TESTSTRC01:	.asciz	'CHR$(65)'		; "A"
TESTSTRC02:	.asciz	'CHR$(48)'		; "0"

TESTSTRD:	.asciz	'TESTS OF ADD (STR)'
TESTSTRD01:	.asciz	'"1234"+"66"'		; "123466"
TESTSTRD02:	.asciz	'"6666"+""'		; "6666"

TESTSTRE:	.asciz	'TESTS OF BINARY RELATIONS'
TESTSTRE01:	.asciz	'"A"="A"'		; TRUE
TESTSTRE02:	.asciz	'"B"<>"B"'		; FALSE
TESTSTRE03:	.asciz	'"C"<"C"'		; FALSE
TESTSTRE04:	.asciz	'"C">"C"'		; FALSE
TESTSTRE05:	.asciz	'"D"<="D"'		; TRUE
TESTSTRE06:	.asciz	'"E">="E"'		; TRUE

TESTSTRE11:	.asciz	'"A"="B"'		; FALSE
TESTSTRE12:	.asciz	'"A"<>"B"'		; TRUE
TESTSTRE13:	.asciz	'"A"<"B"'		; TRUE
TESTSTRE14:	.asciz	'"A">"B"'		; FALSE
TESTSTRE15:	.asciz	'"A"<="B"'		; TRUE
TESTSTRE16:	.asciz	'"A">="B"'		; FALSE

TESTSTRE21:	.asciz	'"B"="A"'		; FALSE
TESTSTRE22:	.asciz	'"B"<>"A"'		; TRUE
TESTSTRE23:	.asciz	'"B"<"A"'		; FALSE
TESTSTRE24:	.asciz	'"B">"A"'		; TRUE
TESTSTRE25:	.asciz	'"B"<="A"'		; FALSE
TESTSTRE26:	.asciz	'"B">="A"'		; TRUE

TESTSTRF:	.asciz	'TESTS OF STR$'
TESTSTRF01:	.asciz	'STR$(0)'		; " 0"
TESTSTRF02:	.asciz	'STR$(-1)'		; "-1"
TESTSTRF03:	.asciz	'STR$(1234)'		; "1234"
TESTSTRF04:	.asciz	'STR$(10+10)'		; "20"
TESTSTRF05:	.asciz	'STR$(10*10)'		; "100"

TESTSTRG:	.asciz	'TESTS OF LEFT$'
TESTSTRG01:	.asciz	'LEFT$("ABCD",2)'	; "AB"
TESTSTRG02:	.asciz	'LEFT$("ABCD",4)'	; "ABCD"
TESTSTRG03:	.asciz	'LEFT$("ABCD",66)'	; "ABCD"
TESTSTRG04:	.asciz	'LEFT$("",0)'		; ""
TESTSTRG05:	.asciz	'LEFT$("",5)'		; ""

TESTSTRH:	.asciz	'TESTS OF RIGHT$'
TESTSTRH01:	.asciz	'RIGHT$("ABCD",2)'	; "CD"
TESTSTRH02:	.asciz	'RIGHT$("ABCD",4)'	; "ABCD"
TESTSTRH03:	.asciz	'RIGHT$("ABCD",66)'	; "ABCD"
TESTSTRH04:	.asciz	'RIGHT$("",0)'		; ""
TESTSTRH05:	.asciz	'RIGHT$("",5)'		; ""

TESTSTRI:	.asciz	'TESTS OF MID$'
TESTSTRI01:	.asciz	'MID$("ABCD",66,66)'	; ""
TESTSTRI02:	.asciz	'MID$("ABCD",2,0)'	; ""
TESTSTRI03:	.asciz	'MID$("ABCD",1,1)'	; "A"
TESTSTRI04:	.asciz	'MID$("ABCD",2,2)'	; "BC"
TESTSTRI05:	.asciz	'MID$("ABCD",3,66)'	; "CD"
TESTSTRI06:	.asciz	'MID$("ABCD",4,1)'	; "D"
TESTSTRI07:	.asciz	'MID$("ABCD",3,255)'	; "CD"

TESTSTRX:	.asciz	'TESTS OF ERROR HANDLING'
TESTSTRX01:	.asciz	'2 + "2"'		; TYPE MISMATCH
TESTSTRX02:	.asciz	'2 AND "2"'		; TYPE MISMATCH
TESTSTRX03:	.asciz	'"THIS" = 3'		; TYPE MISMATCH
TESTSTRX04:	.asciz	'"THIS" / "THAT"'	; TYPE MISMATCH
TESTSTRX05:	.asciz	'"THIS" AND "THAT"'	; TYPE MISMATCH
TESTSTRX06:	.asciz	'-"THIS"'		; TYPE MISMATCH

TESTSTRX07:	.asciz	'NOT "THIS"'		; TYPE MISMATCH
TESTSTRX08:	.asciz	'ABS("THIS")'		; TYPE MISMATCH
TESTSTRX09:	.asciz	'SGN("THIS")'		; TYPE MISMATCH
TESTSTRX0A:	.asciz	'PEEK("THIS")'		; TYPE MISMATCH
TESTSTRX0B:	.asciz	'RND("THIS")'		; TYPE MISMATCH
TESTSTRX0C:	.asciz	'SQR("THIS")'		; TYPE MISMATCH
TESTSTRX0D:	.asciz	'LEN(1234)'		; TYPE MISMATCH
TESTSTRX0E:	.asciz	'ASC(1234)'		; TYPE MISMATCH
TESTSTRX0F:	.asciz	'VAL(1234)'		; TYPE MISMATCH
TESTSTRX0G:	.asciz	'CHR$("THIS")'		; TYPE MISMATCH
TESTSTRX0H:	.asciz	'STR$("THIS")'		; TYPE MISMATCH
TESTSTRX0I:	.asciz	'LEFT$("THIS", "THAT")'	; TYPE MISMATCH
TESTSTRX0J:	.asciz	'LEFT$(3, 4)'		; TYPE MISMATCH
TESTSTRX0K:	.asciz	'RIGHT$("THIS", "THAT")'; TYPE MISMATCH
TESTSTRX0L:	.asciz	'RIGHT$(3, 4)'		; TYPE MISMATCH
TESTSTRX0M:	.asciz	'MID$(3, 2, 1)'		; TYPE MISMATCH
TESTSTRX0N:	.asciz	'MID$("A", "B", 1)'	; TYPE MISMATCH
TESTSTRX0O:	.asciz	'MID$("A", 3, "C")'	; TYPE MISMATCH

TESTSTRX11:	.asciz	'ASC("")'		; ILLEGAL ARGUMENT
TESTSTRX12:	.asciz	'VAL("")'		; ILLEGAL ARGUMENT
TESTSTRX13:	.asciz	'CHR$(666)'		; ILLEGAL ARGUMENT
TESTSTRX14:	.asciz	'LEFT$("THIS",666)'	; ILLEGAL ARGUMENT
TESTSTRX15:	.asciz	'RIGHT$("THIS",666)'	; ILLEGAL ARGUMENT
TESTSTRX16:	.asciz	'MID$("THIS",0,1)'	; ILLEGAL ARGUMENT
TESTSTRX17:	.asciz	'MID$("THIS",666,1)'	; ILLEGAL ARGUMENT
TESTSTRX18:	.asciz	'MID$("THIS",1,666)'	; ILLEGAL ARGUMENT

TESTSTRX21:	.asciz	'32760+10'		; OVERFLOW
TESTSTRX22:	.asciz	'3280*10'		; OVERFLOW
TESTSTRX23:	.asciz	'-32767-100'		; OVERFLOW
TESTSTRX24:	.asciz	'1000/0'		; DIVISION BY ZERO

TESTSTRX31:	.asciz	'2*(2+2'		; SYNTAX ERROR
TESTSTRX32:	.asciz	'ABS(123'		; SYNTAX ERROR
TESTSTRX33:	.asciz	'LEFT$("THIS")'		; SYNTAX ERROR
TESTSTRX34:	.asciz	'RIGHT$("THAT")'	; SYNTAX ERROR
TESTSTRX35:	.asciz	'MID$("THAT")'		; SYNTAX ERROR
TESTSTRX36:	.asciz	'MID$("THAT",2)'	; SYNTAX ERROR

TESTSTRLIST:	.asciz	'TESTS OF LIST FUNCTION'
TESTSTRLIST01:	.asciz	'LIST'			; LIST
TESTSTRLIST02:	.asciz	'LIST : LIST '		; LIST (TWICE)

TESTSTREND:	.asciz	'TESTS OF END FUNCTION'
TESTSTREND01:	.asciz	'LIST : END : LIST '	; LIST (ONCE)

TESTSTRNEW:	.asciz	'TESTS OF NEW FUNCTION'
TESTSTRNEW01:	.asciz	'LIST : NEW : LIST '	; LIST (ONCE)

TESTSTRPRINT:	.asciz	'TESTS OF PRINT FUNCTION'
TESTSTRPRINT01:	.asciz	'PRINT 1234'		; 1234
TESTSTRPRINT02:	.asciz	'PRINT 1234 + 5678'	; 6912
TESTSTRPRINT03:	.asciz	'PRINT 1234 , 5678'	; 1234	5678
TESTSTRPRINT04:	.asciz	'PRINT 1234 : ? 6666'	; 1234 (CR) 6666
TESTSTRPRINT05:	.asciz	'PRINT 1234 ; : ? 5678'	; 12345678
TESTSTRPRINT06:	.asciz	'PRINT ZZ,ZZ*10,ZZ*100'	; 70	700	7000
TESTSTRPRINT07:	.asciz	'PRINT 1234 , : ? 5678'	; 1234	5678

TESTSTRPRINT11:	.asciz	'PRINT "THIS"'		; THIS
TESTSTRPRINT12:	.asciz	'PRINT "","Z","X",123'	; 	Z	X	123
TESTSTRPRINT13:	.asciz	'PRINT STR$(66*66),666'	; 4356	666

TESTSTRLET:	.asciz	'TESTS OF VARIABLE ASSIGNATION'
TESTSTRLET01:	.asciz	'?V0,: LETV0=123 : ?V0'		; 0	123
TESTSTRLET02:	.asciz	'V0=V0*V0 :?"V0=";V0'		; 15129
TESTSTRLET03:	.asciz	'A$=CHR$(65):?"A$=";A$'		; A$=A
TESTSTRLET04:	.asciz	'A$=A$+"123":?"A$=";A$'		; A$=A123
TESTSTRLET05:	.asciz	'Z$=LEFT$(A$,2):?"Z$=";Z$'	; Z$=A1
TESTSTRLET06:	.asciz	'ZZ$=A$+A$+Z$+Z$:?"ZZ$=",ZZ$'	; ZZ$=	A123A123A1A1

TESTSTRCLR:	.asciz	'TESTS OF CLR'
TESTSTRCLR01:	.asciz	'A=123:?"A=";A,:CLR:?"A=";A'	; A=123	A=0
TESTSTRCLR02:	.asciz	'A$="ZXC":?A$,:CLR:?"A$=";A$'	; ZXC	A$=

TESTSTRREM:	.asciz	'TESTS OF REM'
TESTSTRREM01:	.asciz	'?"REMTEST";:REM TEST:?TEST'	; REMTEST

TESTSTRIF:	.asciz	'TESTS OF IF'
TESTSTRIF01:	.asciz	'IF 1 = 0 THEN ?1:?2:?3'	; ""
TESTSTRIF02:	.asciz	'IF 1 = 1 THEN ?1;:?2;:?3'	; 123
TESTSTRIF03:	.asciz	'IF 1=0 THEN?"1=0"ELSE?"1<>0"'	; 1<>0
TESTSTRIF04:	.asciz	'IF 1=1 THEN?"1=1"ELSE?"1<>1"'	; 1=1


INSTR::		.ds 128
OUTSTR::	.ds 128


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

	.ds	64
	