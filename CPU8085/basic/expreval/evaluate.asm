.module 	evaluate
.title 		Expression evaluation

.include	'expreval.def'
.include	'..\common\common.def'
.include	'..\variables\variable.def'

.area	_CODE


;*********************************************************
;* EVAL_EVALUATE: 	EVALUATE FUNCTION (KEYWORD IN ACC)
EVAL_EVALUATE::

	STA	EVAL_CURRKEYWORD

	CPI	K_POWER
	JZ	CALC
	
	CPI	K_MULTIPLY
	JZ	CALC	
	
	CPI	K_DIVIDE
	JZ	CALC
	
	CPI	K_ADD
	JZ	CALC
	
	CPI	K_SUBSTRACT
	JZ	CALC
	
	RET

CALC:
	CALL	EVAL_BINARYOP
	CALL	EVAL_CHECKSAMETYPE
	CALL	EVAL_BINARYCALC
	JMP	END
	
END:
	RET

;*********************************************************
;* EVAL_UNARYOP: 	EXTRACT PARAMETERS FOR UNARY
;*			OPERATION (VAR_TEMP1)
EVAL_UNARYOP:
	CALL	EVAL_COPY1
	RET

;*********************************************************
;* EVAL_BINARYOP: 	EXTRACT PARAMETERS FOR BINARY 
;*			OPERATION (VAR_TEMP1, VAR_TEMP2)
EVAL_BINARYOP:
	CALL	EVAL_COPY1
	CALL	EVAL_COPY2
	RET

;*********************************************************
;* EVAL_TERNARYOP: 	EXTRACT PARAMETERS FOR TERNARY
;*			OPERATION (VAR_TEMP1, VAR_TEMP2,
;*			VAR_TEMP3)
EVAL_TERNARYOP:
	CALL	EVAL_COPY1
	CALL	EVAL_COPY2
	CALL	EVAL_COPY3
	RET

;*********************************************************
;* EVAL_CHECKSAMSTYPE: 	CHECKS IF VAR_TEMP1 & VAR_TEMP2
;*			ARE OF SAME TYPE
EVAL_CHECKSAMETYPE:

	RET

;*********************************************************
;* EVAL_BINARYCALC: 	EVALUATES BINARY CALCULATION
;*			(+, -, * /)
EVAL_BINARYCALC:

	RET

;*********************************************************
;* EVAL_COPY1: 	POP FROM EXP STACK AND COPY VAR TO VAR_TEMP1
EVAL_COPY1:
	CALL	EXP_POP				; ADDR OF DATA IN H-L
	
	MOV	A,M				; DATA TYPE IN ACC
	
	CPI	SID_VAR				; CHECK IF VAR
	JZ	VAR
	
	STA	VAR_TEMP1			; BYTE 1
	INX	H
	
	MOV	A,M
	STA	VAR_TEMP1+1			; BYTE 2
	INX	H
	
	MOV	A,M				; BYTE 3
	STA	VAR_TEMP1+2
	INX	H

	MOV	A,M				; BYTE 4
	STA	VAR_TEMP1+3
	INX	H
	
	RET
		
;*********************************************************
;* EVAL_COPY2: 	POP FROM EXP STACK AND COPY VAR TO VAR_TEMP2
EVAL_COPY2:
	CALL	EXP_POP				; ADDR OF DATA IN H-L
	
	MOV	A,M				; DATA TYPE IN ACC
	
	CPI	SID_VAR				; CHECK IF VAR
	JZ	VAR
	
	STA	VAR_TEMP2			; BYTE 1
	INX	H
	
	MOV	A,M
	STA	VAR_TEMP2+1			; BYTE 2
	INX	H
	
	MOV	A,M				; BYTE 3
	STA	VAR_TEMP2+2
	INX	H

	MOV	A,M				; BYTE 4
	STA	VAR_TEMP2+3
	INX	H
	
	RET

;*********************************************************
;* EVAL_COPY3: 	POP FROM EXP STACK AND COPY VAR TO VAR_TEMP3
EVAL_COPY3:
	CALL	EXP_POP				; ADDR OF DATA IN H-L
	
	MOV	A,M				; DATA TYPE IN ACC
	
	CPI	SID_VAR				; CHECK IF VAR
	JZ	VAR
	
	STA	VAR_TEMP3			; BYTE 1
	INX	H
	
	MOV	A,M
	STA	VAR_TEMP3+1			; BYTE 2
	INX	H
	
	MOV	A,M				; BYTE 3
	STA	VAR_TEMP3+2
	INX	H

	MOV	A,M				; BYTE 4
	STA	VAR_TEMP3+3
	INX	H
	
	RET


VAR:
	HLT


;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

EVAL_CURRKEYWORD:	.ds	1		; CURRENT KEYWORD