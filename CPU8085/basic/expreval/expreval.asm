.module 	expreval
.title 		Expression evaluation

.include	'..\common\common.def'

.area	_CODE

;*********************************************************
;* EXP_EXPREVAL:  EVALUATES TOKENIZED EXPRESSION AT [H-L]
EXP_EXPREVAL::
	CALL	EXP_L0

	RET

EXP_EVALUATE:
	RET

;*********************************************************
;* EXP_L0:  LEVEL 0 (AND/OR/XOR)
EXP_L0:
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
	
	RET

2$:
	INX	H				; CURRIN++
	
	PUSH	PSW
	CALL	EXP_L1				; READ L1 EXP
	POP	PSW
	
	CALL	EXP_EVALUATE			; EVALUATE EXPRESSION
	JMP	1$				; LOOP


;*********************************************************
;* EXP_L1:  LEVEL 1 (NOT)
EXP_L1:
	MOV	A,M				; READ CURR TOKEN

	; CHECK FOR NOT
	CPI	K_NOT
	JZ	2$
	
	CALL	EXP_L2				; READ L2 EXP
	RET

2$:
	INX	H				; CURRIN++
	
	PUSH	PSW
	CALL	EXP_L2				; READ L2 EXP
	POP	PSW
	
	CALL	EXP_EVALUATE			; EVALUATE EXPRESSION
	RET

;*********************************************************
;* EXP_L2:  LEVEL 2 (= <> < > <= >=)
EXP_L2:
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
	
	CALL	EXP_EVALUATE			; EVALUATE EXPRESSION
	JMP	1$				; LOOP

;*********************************************************
;* EXP_L3:  LEVEL 3 (+ -)
EXP_L3:
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
	
	CALL	EXP_EVALUATE			; EVALUATE EXPRESSION
	JMP	1$				; LOOP

;*********************************************************
;* EXP_L4:  LEVEL 4 (* /)
EXP_L4:
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
	
	CALL	EXP_EVALUATE			; EVALUATE EXPRESSION
	JMP	1$				; LOOP

;*********************************************************
;* EXP_L5:  LEVEL 5 (UNARY -)
EXP_L5:
	MOV	A,M				; READ CURR TOKEN

	; CHECK FOR UNARY -
	CPI	K_NEGATE
	JZ	2$
	
	CALL	EXP_L6				; READ L6 EXP
	RET

2$:
	INX	H				; CURRIN++
	
	PUSH	PSW
	CALL	EXP_L6				; READ L6 EXP
	POP	PSW
	
	CALL	EXP_EVALUATE			; EVALUATE EXPRESSION
	RET


;*********************************************************
;* EXP_L6:  LEVEL 6 (POWER ^)
EXP_L6:
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
	
	CALL	EXP_EVALUATE			; EVALUATE EXPRESSION
	JMP	1$				; LOOP

;*********************************************************
;* EXP_L7:  LEVEL 7 ( (), INT, VAR, STR)
EXP_L7:
	RET


;*********************************************************
;* EXP_SKIPWHITESPACE:  SKIPS SPACES IN INPUT STR (H-L)
EXP_SKIPWHITESPACE:

1$:
	MOV	A,M				; READ CURRENT CHAR
	CPI	' 				; CHECK FOR WHITESPACE
	JZ 	1$				; LOOP
	
	RET


;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

;EXP_XXX::		.ds	1		; XXX
