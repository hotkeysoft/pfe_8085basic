.module 	expreval
.title 		Expression evaluation

.include	'..\common\common.def'
.include	'..\variables\variable.def'
.include	'..\integer\integer.def'
.include	'..\io\io.def'
.include	'..\error\error.def'
.include	'..\program\program.def'
.include	'..\strings\strings.def'
.include	'evaluate.def'

.area	_CODE

EXP_STACKSIZE 	= 4*16
EXP_STACKHI	= EXP_STACKLO + EXP_STACKSIZE

;*********************************************************
;* EXP_INIT:  INITIALIZES MODULE
EXP_INIT::
	LXI	H,EXP_STACKLO
	SHLD	EXP_STACKCURR			; EMPTIES STACK		

	RET


;*********************************************************
;* EXP_EXPREVAL:  EXECUTES TOKENIZED EXPRESSION AT [H-L]
;*		  IN: B = INIF, C = EXECUTE
EXP_EXPREVAL::

1$:
	CALL	EXP_SKIPWHITESPACE2		; SKIP SPACES AND ':'

	MOV	A,M				; READ CURR CHAR
	ORA	A
	JZ	101$				; EXIT WITH CF = 0
	
	; IDENTIFY CURRENT FUNCTION	
	CPI	K_LIST
	JZ	2$
	
	CPI	K_END
	JZ	3$

	CPI	K_NEW
	JZ	4$

	CPI	K_PRINT
	JZ	5$
	
	CPI	K_LET
	JZ	6$
	
	CPI	SID_VAR
	JZ	6$

	CPI	K_CLR
	JZ	7$
	
	CPI	K_REM
	JZ	101$
	
	CPI	K_IF
	JZ	8$

	CPI	K_ELSE
	JZ	9$

	CPI	K_RUN
	JZ	10$

	CPI	K_GOTO
	JZ	11$

	CPI	K_GOSUB
	JZ	12$

	CPI	K_RETURN
	JZ	13$

	CPI	K_STOP
	JZ	14$

	CPI	K_CONT
	JZ	15$

	CPI	K_FOR
	JZ	16$

	CPI	K_NEXT
	JZ	17$

	CPI	K_INPUT
	JZ	18$

.if DEBUG
	CPI	K_DUMPVAR
	JZ	90$

	CPI	K_DUMPSTK
	JZ	91$

	CPI	K_DUMPSTR
	JZ	92$
.endif	
	
	JMP	ERR_UNKNOWN
	
2$:	; LIST
	CALL	EXP_DO_LIST
	JMP	100$

3$:	; END
	CALL	EXP_DO_END
	MOV	A,C				; QUIT IF EXECUTE = TRUE
	CPI	TRUE				; ELSE LOOP
	JZ	101$
	JMP	100$

4$:	; NEW
	CALL	EXP_DO_NEW
	JMP	100$

5$:	; PRINT
	CALL	EXP_DO_PRINT
	JMP	100$

6$:	; LET
	CALL	EXP_DO_LET
	JMP	100$

7$:	; CLR
	CALL	EXP_DO_CLR
	JMP	100$

8$:	; IF
	CALL	EXP_DO_IF
	JMP	101$				; EXIT

9$:	; ELSE
	CALL	EXP_DO_ELSE
	JMP	101$				; EXIT

10$:	; RUN
	CALL	EXP_DO_RUN
	JMP	100$

11$:	; GOTO
	CALL	EXP_DO_GOTO
	JZ	101$				; EXIT
	JMP	100$

12$:	; GOSUB
;	CALL	EXP_DO_GOSUB
	JMP	ERR_UNKNOWN
	JZ	101$				; EXIT
	JMP	100$

13$:	; RETURN
	CALL	EXP_DO_RETURN
	JZ	101$				; EXIT
	JMP	100$

14$:	; STOP
	CALL	EXP_DO_STOP
	JZ	101$				; EXIT
	JMP	100$
	
15$:	; CONTINUE
	CALL	EXP_DO_CONT
	JZ	101$				; EXIT
	JMP	100$
	
16$:	; FOR
;	CALL	EXP_DO_FOR
	JMP	ERR_UNKNOWN
	JMP	100$
	
17$:	; NEXT
	CALL	EXP_DO_NEXT
	JZ	101$				; EXIT
	JMP	100$
	
18$:	; INPUT
;	CALL	EXP_DO_INPUT
	JMP	100$

.if DEBUG
90$:	; DUMP VARIABLES
	INX	H
	CALL	VAR_DUMPVARS
	JMP	100$
	
91$:	; DUMP STACK
	INX	H
	CALL	EXP_DUMPSTACK
	JMP	100$

92$:	; DUMP STRINGS
	INX	H
	CALL	STR_DUMPSTRINGS
	JMP	100$
.endif	
	
100$:	
	CALL	EXP_SKIPWHITESPACE
	
	MOV	A,M				; READ CURR CHAR
	CPI	':				; LOOP IF ':' OR 'ELSE'
	JZ	1$
	CPI	K_ELSE
	JZ	1$
	CPI	0
	JZ	1$
	
	JMP	ERR_UNKNOWN

101$:	
	RET
	

;*********************************************************
;* EXP_DO_LIST:  EXECUTE LIST
;*		 IN: C = EXECUTE
EXP_DO_LIST:
	INX	H			; SKIP KEYWORD

	MOV	A,C
	CPI	FALSE			; CHECK EXECUTE FLAG
	RZ

	CALL	PRG_LIST
	RET

;*********************************************************
;* EXP_DO_END: 	EXECUTE END
;*		IN: C = EXECUTE
EXP_DO_END:
	INX	H			; SKIP KEYWORD

	MOV	A,C
	CPI	FALSE			; CHECK EXECUTE FLAG
	RZ

	CALL	PRG_END
	RET

;*********************************************************
;* EXP_DO_NEW: 	EXECUTE NEW
;*		IN: C = EXECUTE
EXP_DO_NEW:
	INX	H			; SKIP KEYWORD

	MOV	A,C
	CPI	FALSE			; CHECK EXECUTE FLAG
	RZ

	CALL	PRG_NEW
	RET

;*********************************************************
;* EXP_DO_PRINT:EXECUTE PRINT
;*		IN: C = EXECUTE
EXP_DO_PRINT:
	INX	H			; SKIP KEYWORD

	MVI	A,TRUE
	STA	EXP_INSNEWLINE
	
1$:
	CALL	EXP_SKIPWHITESPACE

	MOV	A,M			; READ CURRENT CHAR
	
	; CHECK EXIT CONDITIONS
	CPI	0			; END OF STRING
	JZ	100$
	CPI	':			; SEPARATOR
	JZ	100$
	CPI	K_ELSE			; ELSE KEYWORD
	JZ	100$
	
	MVI	A,TRUE
	STA	EXP_INSNEWLINE
	
	CALL	EXP_L0			; READ EXPRESSION
	
	PUSH	H
	CALL	EVAL_UNARYOP		; EXTRACT RESULT IN VAR_TEMP1
	
	MOV	A,C			; CHECK EXECUTE FLAG
	CPI	TRUE
	JNZ	4$
	
	LDA	VAR_TEMP1		; READ TYPE IN ACC
	
	CPI	SID_CINT		; CHECK FOR INT
	JZ	2$
	
	CPI	SID_CSTR		; CHECK FOR STRING
	JZ	3$
	
	JMP	ERR_UNKNOWN
	
2$:
	LHLD	VAR_TEMP1+1		; READ VALUE IN HL
	SHLD	INT_ACC0		; STORE IN INT_ACC0
	
	CALL	INT_ITOA		; CONVERT TO STRING
	CALL	IO_PUTS			; PRINT VALUE
	JMP	4$
	
3$:
	LDA	VAR_TEMP1+1		; SIZE OF STR IN ACC
	MOV	B,A			; COPY TO B
	
	LHLD	VAR_TEMP1+2		; STR PTR IN HL
	CALL	IO_PUTSN		; PRINT THE STRING
	
	JMP	4$
	
4$:
	POP	H			; RESTORE HL

	MOV	A,M			; READ CURRENT CHAR
	CPI	',
	JZ	5$
	CPI	';
	JZ	6$
	CPI	':
	JZ	100$
	CPI	0
	JZ	100$
	CPI	K_ELSE
	JZ	100$
	
	JMP	ERR_SYNTAX
	
5$:	;	',' SEPARATOR
	INX	H			; SKIP ','
	
	MOV	A,C			; CHECK EXECUTE FLAG
	CPI	TRUE
	JNZ	1$			; LOOP 
	
	MVI	A,9			; TAB
	CALL	IO_PUTC			; PRINT IT

	MVI	A,FALSE
	STA	EXP_INSNEWLINE		; DO NOT INSERT LINE AT THE END

	JMP	1$			; LOOP
	
6$:	;	';' SEPARATOR
	INX	H			; SKIP ';'
	MVI	A,FALSE
	STA	EXP_INSNEWLINE		; DO NOT INSERT LINE AT THE END
	JMP	1$

100$:
	LDA	EXP_INSNEWLINE		; CHECK IF WE HAVE TO INSERT NEW LINE
	CPI	TRUE
	JNZ 	101$
	
	MOV	A,C			; CHECK EXECUTE FLAG
	CPI	TRUE
	JNZ	101$
	
	CALL	IO_PUTCR		; INSERT NEW LINE	
101$:
	RET

;*********************************************************
;* EXP_DO_LET:	EXECUTE VARIABLE ASSIGNATION
;*		IN: C = EXECUTE
EXP_DO_LET:
	PUSH	B
	PUSH	D
	
	CPI	K_LET			; CHECK FOR LET KEYWORD
	JNZ	NOLET
	
	INX	H			; SKIP 'LET' KEYWORD
	CALL	EXP_SKIPWHITESPACE	; SKIP WHITESPACE
	
NOLET:	
	MOV	A,M			; READ CURR CHAR
	CPI	SID_VAR			; MAKE SURE IT'S A VARIABLE
	JNZ	ERR_SYNTAX
	
	INX	H			; SKIP VARIABLE ID
	
	
	MOV	D,C			; COPY 'EXECUTE' VAR TO D
	
	MOV	B,M			; READ VARIABLE NAME
	INX	H			; IN BC
	MOV	C,M			
	INX	H
	
	CALL	EXP_SKIPWHITESPACE	; SKIP WHITESPACE
	
	MOV	A,M			; READ CURR CHAR
	CPI	K_EQUAL			; MUST BE '='
	JNZ	ERR_SYNTAX		
	
	INX	H			; SKIP '='
	
	CALL	EXP_L0			; READ EXPRESSION

	PUSH	H
	CALL	EVAL_UNARYOP		; EXTRACT RESULT IN VAR_TEMP1
	
	MOV	A,D			; CHECK EXECUTE FLAG
	CPI	TRUE
	JNZ	END
	
	LXI	H,VAR_TEMP1		; SET VARIABLE
	CALL	VAR_SET
	
END:
	POP	H
	POP	D
	POP	B
	RET

;*********************************************************
;* EXP_DO_CLR: 	EXECUTE CLR
;*		IN: C = EXECUTE
EXP_DO_CLR:
	INX	H			; SKIP KEYWORD

	MOV	A,C
	CPI	FALSE			; CHECK EXECUTE FLAG
	RZ

	PUSH	H
	LHLD	PRG_HIPTR		; READ TOP OF PRG MEMORY
	SHLD	VAR_LOPTR		; CLEAR VARIABLE MEMORY
	SHLD	VAR_HIPTR
	
	LHLD	STR_HIPTR		; CLEAR STRING MEMORY
	SHLD	STR_LOPTR
	POP	H

	RET

;*********************************************************
;* EXP_DO_IF: 	EXECUTE IF
;*		IN: B = INIF
;*		IN: C = EXECUTE
EXP_DO_IF:
	MOV	A,B			; NESTED IF ARE NOT ALLOWED
	CPI	TRUE
	JZ	ERR_SYNTAX

	PUSH	B
	
	INX	H			; SKIP KEYWORD

	CALL	EXP_L0			; READ EXPRESSION
	
	PUSH	H
	CALL	EVAL_UNARYOP		; EXTRACT RESULT IN VAR_TEMP1

	LDA	VAR_TEMP1		; READ TYPE OF VARIABLE IN ACC
	CPI	SID_CINT		; MUST EVALUATE TO INT
	JNZ	ERR_TYPEMISMATCH

	MVI	B,TRUE			; INIF = TRUE	
	MVI	C,TRUE			; SET RESULT = TRUE
	
	LHLD	VAR_TEMP1+1		; CHECK RESULT OF EVALUATION
	MVI	A,0
	CMP	H			; HI BYTE
	JNZ	1$
	
	CMP	L			; LO BYTE
	JNZ	1$

	MVI	C,FALSE			; CHANGE RESULT TO FALSE
	
1$:
	; RESULT IN C (TRUE/FALSE)
	POP	H			; GET BACK HL
	
	CALL	EXP_SKIPWHITESPACE	; SKIP WHITESPACE
	
	MOV	A,M			; READ CURR CHAR
	CPI	K_THEN			; MUST BE THEN OR GOTO
	JZ	2$
	CPI	K_GOTO
	JZ	4$
	
	JMP	ERR_SYNTAX
	
2$:	; THEN
	INX	H			; SKIP KEYWORD
	CALL	EXP_EXPREVAL		; EVALUATE EXPRESSION
	
	CALL	EXP_SKIPWHITESPACE	; SKIP WHITESPACE
	
	MOV	A,M			; CHECK FOR ELSE
	CPI	K_ELSE
	JNZ	3$
	
	; ELSE
	INX	H			; SKIP KEYWORD
	
	MOV	A,C			; EXECUTE = !EXECUTE
	CMA
	MOV	C,A
	MVI	B,TRUE	

	
	CALL	EXP_EXPREVAL		; EVALUATE EXPRESSION
	
3$:
	POP	B
	RET

4$:
	CALL	EXP_EXPREVAL		; EVALUATE EXPRESSION
	POP	B
	RET

;*********************************************************
;* EXP_DO_ELSE:	EXECUTE ELSE
;*		IN: B = INIF
EXP_DO_ELSE:
	MOV	A,B			; CHECK FOR ELSE WITHOUT IF
	CPI	FALSE
	JZ	ERR_ELSEWITHOUTIF
	
	RET

;*********************************************************
;* EXP_DO_RUN:	EXECUTE RUN
;*		IN: C = EXECUTE
EXP_DO_RUN:
	INX	H			; SKIP KEYWORD

	MOV	A,C
	CPI	FALSE			; CHECK EXECUTE FLAG
	RZ

	PUSH	H			; KEEP CURRENT POS
	CALL	PRG_RUN			; RUN PROGRAM
	POP	H			; RESTORE POS
	
	RET

;*********************************************************
;* EXP_DO_RETURN:	EXECUTE RETURN
;*			IN: C = EXECUTE
EXP_DO_RETURN:
	INX	H			; SKIP KEYWORD

	MOV	A,C
	CPI	FALSE			; CHECK EXECUTE FLAG
	RZ

	CALL	PRG_RETURN		; EXECUTE RETURN
	
	RET

;*********************************************************
;* EXP_DO_STOP:		EXECUTE STOP
;*			IN: B = INIF
;*			IN: C = EXECUTE
EXP_DO_STOP:
	INX	H			; SKIP KEYWORD

	MOV	A,C
	CPI	FALSE			; CHECK EXECUTE FLAG
	RZ

	CALL	PRG_STOP		; EXECUTE STOP
	
	RET

;*********************************************************
;* EXP_DO_CONT:		EXECUTE CONTINUE
;*			IN: C = EXECUTE
EXP_DO_CONT:
	INX	H			; SKIP KEYWORD

	MOV	A,C
	CPI	FALSE			; CHECK EXECUTE FLAG
	RZ

	CALL	PRG_CONTINUE		; EXECUTE CONTINUE
	
	RET

;*********************************************************
;* EXP_DO_NEXT:		EXECUTE NEXT
;*			IN: C = EXECUTE
EXP_DO_NEXT:
	INX	H			; SKIP KEYWORD

	MOV	A,C
	CPI	FALSE			; CHECK EXECUTE FLAG
	RZ

	CALL	PRG_NEXT		; EXECUTE NEXT
	
	RET

;*********************************************************
;* EXP_DO_GOTO:		EXECUTE GOTO
;*			IN: C = EXECUTE
EXP_DO_GOTO:
	INX	H			; SKIP KEYWORD
	
	CALL	EXP_L0			; READ EXPRESSION
	
	PUSH	H
	CALL	EVAL_UNARYOP		; EXTRACT RESULT IN VAR_TEMP1
	
	LDA	VAR_TEMP1		; GET TYPE OF VARIABLE
	CPI	SID_CINT		; MUST BE INT
	JNZ	ERR_TYPEMISMATCH
	
	LHLD	VAR_TEMP1+1		; LOAD VALUE
	
	MVI	A,0
	ORA	H			; HI BYTE IN ACC
	JM	ERR_ILLEGAL		; VALUE MUST BE POSITIVE

	MOV	A,C			; CHECK EXECUTE FLAG
	CPI	FALSE
	JZ	1$
	
	PUSH	B
	
	MOV	B,H			; COPY TO BC
	MOV	C,L

	CALL	PRG_GOTO		; EXECUTE GOTO

	POP	B
1$:
	POP	H	
	RET


;*********************************************************
;* EXP_L0:  LEVEL 0 (AND/OR/XOR)
EXP_L0::
	PUSH	B
	PUSH	D

	CALL	EXP_SKIPWHITESPACE		; SKIP SPACES
	
	CALL 	EXP_L1				; READ L1 EXP
	
1$:
	MOV	A,M				; READ CURR TOKEN

	; CHECK FOR AND/OR/XOR
	CPI	K_AND
	JZ	2$
	
	CPI	K_OR
	JZ	2$
	
	CPI	K_XOR
	JZ	2$
	
	POP	D
	POP	B	
	RET

2$:
	INX	H				; CURRIN++
	
	PUSH	PSW
	CALL	EXP_L1				; READ L1 EXP
	POP	PSW
	
	CALL	EVAL_EVALUATE			; EVALUATE EXPRESSION
	JMP	1$				; LOOP


;*********************************************************
;* EXP_L1:  LEVEL 1 (NOT)
EXP_L1:
	CALL	EXP_SKIPWHITESPACE		; SKIP SPACES
	
	MOV	A,M				; READ CURR TOKEN

	; CHECK FOR NOT
	CPI	K_NOT
	JZ	2$
	
	CALL	EXP_L2				; READ L2 EXP
	RET

2$:
	INX	H				; CURRIN++
	
	PUSH	PSW
	CALL	EXP_L1				; READ L1 EXP
	POP	PSW
	
	CALL	EVAL_EVALUATE			; EVALUATE EXPRESSION
	RET

;*********************************************************
;* EXP_L2:  LEVEL 2 (= <> < > <= >=)
EXP_L2:
	CALL	EXP_SKIPWHITESPACE		; SKIP SPACES
	
	CALL 	EXP_L3				; READ L3 EXP
	
1$:
	MOV	A,M				; READ CURR TOKEN

	; CHECK FOR < > <= >= = <>
	CPI	K_NOTEQUAL
	JZ	2$
	
	CPI	K_LESSEQUAL
	JZ	2$
	
	CPI	K_GREATEREQUAL
	JZ	2$

	CPI	K_LESS
	JZ	2$

	CPI	K_GREATER
	JZ	2$

	CPI	K_EQUAL
	JZ	2$
	
	RET

2$:
	INX	H				; CURRIN++
	
	PUSH	PSW
	CALL	EXP_L3				; READ L3 EXP
	POP	PSW
	
	CALL	EVAL_EVALUATE			; EVALUATE EXPRESSION
	JMP	1$				; LOOP

;*********************************************************
;* EXP_L3:  LEVEL 3 (+ -)
EXP_L3:
	CALL	EXP_SKIPWHITESPACE		; SKIP SPACES
	
	CALL 	EXP_L4				; READ L4 EXP
	
1$:
	MOV	A,M				; READ CURR TOKEN

	; CHECK FOR + -
	CPI	K_ADD
	JZ	2$
	
	CPI	K_SUBSTRACT
	JZ	2$
	
	RET

2$:
	INX	H				; CURRIN++
	
	PUSH	PSW
	CALL	EXP_L4				; READ L4 EXP
	POP	PSW
	
	CALL	EVAL_EVALUATE			; EVALUATE EXPRESSION
	JMP	1$				; LOOP

;*********************************************************
;* EXP_L4:  LEVEL 4 (* /)
EXP_L4:
	CALL	EXP_SKIPWHITESPACE		; SKIP SPACES
	
	CALL 	EXP_L5				; READ L5 EXP
	
1$:
	MOV	A,M				; READ CURR TOKEN

	; CHECK FOR * /
	CPI	K_MULTIPLY
	JZ	2$
	
	CPI	K_DIVIDE
	JZ	2$
	
	RET

2$:
	INX	H				; CURRIN++
	
	PUSH	PSW
	CALL	EXP_L5				; READ L5 EXP
	POP	PSW
	
	CALL	EVAL_EVALUATE			; EVALUATE EXPRESSION
	JMP	1$				; LOOP

;*********************************************************
;* EXP_L5:  LEVEL 5 (UNARY -)
EXP_L5:
	CALL	EXP_SKIPWHITESPACE		; SKIP SPACES
	
	MOV	A,M				; READ CURR TOKEN

	; CHECK FOR UNARY -
	CPI	K_NEGATE
	JZ	2$
	
	CALL	EXP_L6				; READ L6 EXP
	RET

2$:
	INX	H				; CURRIN++
	
	PUSH	PSW
	CALL	EXP_L5				; READ L5 EXP
	POP	PSW
	
	CALL	EVAL_EVALUATE			; EVALUATE EXPRESSION
	RET


;*********************************************************
;* EXP_L6:  LEVEL 6 (POWER ^)
EXP_L6:
	CALL	EXP_SKIPWHITESPACE		; SKIP SPACES
	
	CALL 	EXP_L7				; READ L7 EXP
	
1$:
	MOV	A,M				; READ CURR TOKEN

	; CHECK FOR ^
	CPI	K_POWER
	JZ	2$

	RET

2$:
	INX	H				; CURRIN++
	
	PUSH	PSW
	CALL	EXP_L7				; READ L7 EXP
	POP	PSW
	
	CALL	EVAL_EVALUATE			; EVALUATE EXPRESSION
	JMP	1$				; LOOP

;*********************************************************
;* EXP_L7:  LEVEL 7 ( (), INT, VAR, STR)
EXP_L7:
	CALL	EXP_SKIPWHITESPACE		; SKIP SPACES

	MOV	A,M				; READ CURRENT CHAR
	
	CPI	SID_CINT			; CHECK FOR INTEGER
	JZ	1$
	
	CPI	SID_VAR				; CHECK FOR VAR
	JZ	2$
	
	CPI	SID_CSTR			; CHECK FOR STRING
	JZ	3$


	CPI	'(				; EXPRESSION IN '()'
	JZ	4$

	MOV	B,A
	ANI	0xE0				; FUNCTIONS (0xAX & 0xBX)
	CPI	0xA0
	MOV	A,B
	JZ	5$

	JMP	9$

1$:
	CALL	EXP_PUSH
	INX	H
	INX	H
	INX	H
	JMP	9$

2$:
	CALL	EXP_PUSH
	INX	H
	INX	H
	INX	H
	JMP	9$

3$:
	STA	VAR_TEMP1			; SET VAR_TEMP1
	INX	H
	
	MOV	A,M				; LENGTH
	STA	VAR_TEMP1+1
	INX	H
	
	MOV	C,A				; LENGTH IN B-C
	MVI	B,0		

	MOV	A,L
	STA	VAR_TEMP1+2			; LO BYTE OF STR ADDRESS
	
	MOV	A,H
	STA	VAR_TEMP1+3			; HI BYTE OF STR ADDRESS

	DAD	B				; MOVE TO END OF STRING

	PUSH	H
	
	LXI	H,VAR_TEMP1			; ADDRESS OF VAR_TEMP1 IN HL
	CALL	EXP_PUSH
	
	POP	H
		
	JMP	9$

4$:
	INX	H				; SKIP '('
	
	CALL	EXP_L0				; READ EXPRESSION
	
	MOV	A,M				; CHECK FOR ')'
	CPI	')
	JNZ	ERR_SYNTAX
	
	INX	H				; SKIP ')'
	
	JMP	9$

5$:
	PUSH	PSW				; SAVE CURRENT TOKEN
	
	INX	H				; SKIP KEYWORD
	CALL	EXP_SKIPWHITESPACE		; SKIP SPACES
	
	MOV	A,M				; READ CURRENT CHAR
	CPI	'(				; CHECK FOR '('
	JNZ	ERR_SYNTAX
	
	INX	H				; SKIP '('
	
	CALL	EXP_L0				; READ EXPRESSION
	
	POP	PSW				; RESTORE CURRENT TOKEN
	PUSH	PSW				; PUT IT BACK FOR LATER
	
	; WATCH FOR FUNCTIONS TAKING MORE THAN 1 PARAMETER
	CPI	K_LEFT				; LEFT$(1,2)
	JZ	8$				; 2 PARAMS	
	
	CPI	K_RIGHT				; RIGHT$(1,2)
	JZ	8$				; 2 PARAMS
	
	CPI	K_MID				; MID$(1,2,3)
	JZ	7$				; 3 PARAMS
6$:	
	MOV	A,M				; READ CURRENT CHAR
	CPI	')				; LOOK FOR ')'
	JNZ	ERR_SYNTAX
	
	INX	H				; SKIP ')'
	
	POP	PSW				; GET BACK TOKEN
	CALL	EVAL_EVALUATE
	
	JMP	9$

7$:
	MOV	A,M				; READ CURRENT CHAR
	CPI	',				; CHECK FOR ','
	JNZ	ERR_SYNTAX
	
	INX	H				; SKIP ','
	
	CALL	EXP_L0				; READ EXPRESSION

8$:	
	MOV	A,M				; READ CURRENT CHAR
	CPI	',				; CHECK FOR ','
	JNZ	ERR_SYNTAX
	
	INX	H				; SKIP ','
	
	CALL	EXP_L0				; READ EXPRESSION

	JMP	6$

9$:	CALL	EXP_SKIPWHITESPACE		; SKIP SPACES
	RET


;*********************************************************
;* EXP_SKIPWHITESPACE:  SKIPS SPACES IN INPUT STR (H-L)
EXP_SKIPWHITESPACE:

1$:
	MOV	A,M				; READ CURRENT CHAR
	CPI	' 				; CHECK FOR WHITESPACE
	RNZ					; RETURN IF NOT FOUND
	INX	H
	JMP	1$

;*********************************************************
;* EXP_SKIPWHITESPACE2:  SKIPS SPACES AND ':' IN INPUT STR (H-L)
EXP_SKIPWHITESPACE2:
1$:
	MOV	A,M				; READ CURRENT CHAR
	CPI	' 				; CHECK FOR WHITESPACE
	JZ	2$
	CPI	':				; CHECK FOR ':'
	JZ	2$
	
	RET
	
2$:
	INX	H
	JMP	1$

;*********************************************************
;* EXP_SKIPWHITESPACE3:  SKIPS SPACES,':'And K_ELSE IN INPUT STR (H-L)
EXP_SKIPWHITESPACE3:
1$:
	MOV	A,M				; READ CURRENT CHAR
	CPI	' 				; CHECK FOR WHITESPACE
	JZ	2$
	CPI	':				; CHECK FOR ':'
	JZ	2$
	CPI	K_ELSE
	JZ	2$
	
	RET
	
2$:
	INX	H
	JMP	1$

;*********************************************************
;* EXP_CLRSTACK: 	RESETS STACK
EXP_CLRSTACK::
	PUSH	H
	LXI	H,EXP_STACKLO
	SHLD	EXP_STACKCURR
	POP	H
	RET

;*********************************************************
;* EXP_PUSH:  PUSHES DATA AT (H-L) ON EXP STACK
;*	      *MODIFIES D-E*
EXP_PUSH::
	PUSH	H

	XCHG					; HL <-> DE
	LHLD	EXP_STACKCURR			; READ CURR STACK POS IN HL
	XCHG					; HL <-> DE

	; CHECK IF STACK IS FULL
	MVI	A,>(EXP_STACKHI)		; CHECK HI BYTE
	CMP	D
	JNZ	1$
	
	MVI	A,<(EXP_STACKHI)		; CHECK LO BYTE
	CMP	E
	JZ	ERR_STACKOVERFLOW
	
1$:
	; 1	
	MOV	A,M				; READ CHAR
	STAX	D				; PUT ON STACK
	INX	H
	INX	D

	; 2	
	MOV	A,M				; READ CHAR
	STAX	D				; PUT ON STACK
	INX	H
	INX	D

	; 3	
	MOV	A,M				; READ CHAR
	STAX	D				; PUT ON STACK
	INX	H
	INX	D

	; 4	
	MOV	A,M				; READ CHAR
	STAX	D				; PUT ON STACK
	INX	H
	INX	D

	; UPDATE EXP_STACKCURR
	MOV	A,E				; LO BYTE
	STA	EXP_STACKCURR
	
	MOV	A,D				; HI BYTE
	STA	EXP_STACKCURR+1

	POP	H	
	RET

;*********************************************************
;* EXP_POP:  SETS H-L TO TOP ITEM OF THE EXP STACK
;*	      *MODIFIES D-E*
;*	TODO: ADD VALIDATION
EXP_POP::
	LHLD	EXP_STACKCURR

	; CHECK IF STACK IS EMPTY
	MVI	A,>(EXP_STACKLO)		; CHECK HI BYTE
	CMP	H
	JNZ	1$
	
	MVI	A,<(EXP_STACKLO)		; CHECK LO BYTE
	CMP	L
	JZ	ERR_STACKUNDERFLOW
	
1$:
	LXI	D,-4
	DAD	D			; EXP_STACKCURR -= 5
	
	SHLD	EXP_STACKCURR		; UPDATE VARIABLE

	RET

.if DEBUG
EXP_DUMPSTACK::
	PUSH	B
	PUSH	D
	PUSH	H
	
	LXI	H,EXP_STACKLO		; BOTTOM OF STACK IN HL
	XCHG				; HL<->DE
	
	LHLD	EXP_STACKCURR		; CURRENT STACK POS IN HL
	
1$:
	MOV	A,L			; CHECK IF BOTTOM OF STACK
	CMP	E			; COMPARE LOW BYTE
	JNZ	2$
	
	MOV	A,H
	CMP	D			; COMPARE HI BYTE
	JNZ	2$
	
	; END OF STACK
	CALL	IO_PUTCR	
	POP	H
	POP	D
	POP	B
	RET
	
2$:
	LXI	B,-4			; GO BACK 4 BYTES
	DAD	B			; CURRPOS -= 4
	
	PUSH	H			; KEEP FOR LATER
	
	MOV	A,M
	CPI	SID_CINT
	JZ	4$
	
	CPI	SID_CSTR
	JZ	5$
	
	CPI	SID_VAR
	JZ	6$

3$:
	POP	H			; RESTORE PLACE IN STACK
	JMP	1$
		
	RET
	
4$:	; PRINT CONST INT
	PUSH	H
	LXI	H,SINTSTR
	CALL	IO_PUTS
	POP	H
	
	INX	H			; HL++
	MOV	A,M			; LO BYTE OF INT IN ACC
	STA	INT_ACC0
	
	INX	H			; HL++
	MOV	A,M			; HI BYTE OF INT IN ACC
	STA	INT_ACC0+1
	
	CALL	INT_ITOA		; CONVERT TO STRING
	CALL	IO_PUTS			; PRINT IT
		
	MVI	A,']
	CALL	IO_PUTC
	JMP	3$
	
5$:	; PRINT CONST STR
	PUSH	H
	LXI	H,SSTRSTR
	CALL	IO_PUTS
	POP	H
	
	INX	H			; HL++
	MOV	B,M			; LENGTH OF STR IN B
	
	PUSH	D
	PUSH	H
	
	INX	H			; HL++
	MOV	E,M			; LO BYTE OF STR PTR IN E
	
	INX	H			; HL++
	MOV	D,M			; HI BYTE OF STR PTR IN D
	
	XCHG
	
	CALL	IO_PUTSN
	
	POP	H
	POP	D
	
	MVI	A,'"
	CALL	IO_PUTC
	
	MVI	A,']
	CALL	IO_PUTC
	JMP	3$
	
6$:	; PRINT VAR
	LXI	H,SVARSTR
	CALL	IO_PUTS
	JMP	3$

SINTSTR:	.asciz	'[CI '
SSTRSTR: 	.asciz	'[CS "'
SVARSTR:	.asciz	'[VAR]'

EXP_CLEARSTACK::
	PUSH	H
	LXI	H,EXP_STACKLO		; BOTTOM OF STACK IN HL
	SHLD	EXP_STACKCURR		; CLEAR STACK
	POP	H
	RET
.endif

;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

EXP_STACKLO:	.ds	EXP_STACKSIZE	; EXPRESSION STACK

EXP_STACKCURR:	.ds	2		; CURRENT POS IN STACK

EXP_INSNEWLINE:	.ds	1	; USED BY DO_PRINT