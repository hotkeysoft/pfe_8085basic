.module 	common
.title 		Common functions


.area	_CODE

SID_CINT	== 1
SID_CFLOAT	== 2
SID_CSTR	== 4
SID_VAR		== 8
SID_GOSUB	== 16
SID_FOR		== 32
SID_STOP	== 64
SID_FBASE	== 128

; KEYWORDS DEFINITION (VALUES)

K_NONE		== 0

K_POWER		== 0x80

K_NEGATE	== K_POWER+1

K_MULTIPLY	== K_NEGATE+1
K_DIVIDE	== K_MULTIPLY+1

K_ADD		== K_DIVIDE+1
K_SUBSTRACT	== K_ADD+1

K_NOTEQUAL	== K_SUBSTRACT+1
K_LESSEQUAL	== K_NOTEQUAL+1
K_GREATEREQUAL	== K_LESSEQUAL+1
K_LESS		== K_GREATEREQUAL+1
K_GREATER	== K_LESS+1
K_EQUAL		== K_GREATER+1

K_NOT		== K_EQUAL+1
K_AND		== K_NOT+1
K_OR		== K_AND+1
K_XOR		== K_OR+1

K_ABS		== 0xA0
K_ASC		== K_ABS+1
K_INT		== K_ASC+1
K_IN		== K_INT+1
K_LEN		== K_IN+1
K_PEEK		== K_LEN+1
K_RND		== K_PEEK+1
K_SGN		== K_RND+1
K_SQR		== K_SGN+1
K_VAL		== K_SQR+1

K_CHR		== 0xB0
K_LEFT		== K_CHR+1
K_MID		== K_LEFT+1
K_RIGHT		== K_MID+1
K_STR		== K_RIGHT+1

K_CLR		== 0xC0
K_CONT		== K_CLR+1
K_DIM		== K_CONT+1
K_END		== K_DIM+1
K_STOP		== K_END+1
K_FOR		== K_STOP+1
K_GOSUB		== K_FOR+1
K_GOTO		== K_GOSUB+1
K_IF		== K_GOTO+1
K_ELSE		== K_IF+1
K_INPUT		== K_ELSE+1
K_LET		== K_INPUT+1
K_LIST		== K_LET+1
K_NEW		== K_LIST+1
K_NEXT		== K_NEW+1
K_OUT		== K_NEXT+1
K_POKE		== K_OUT+1
K_PRINT		== K_POKE+1
K_REM		== K_PRINT+1
K_RETURN	== K_REM+1
K_RUN		== K_RETURN+1
K_STEP		== K_RUN+1
K_SYS		== K_STEP+1
K_THEN		== K_SYS+1
K_TO		== K_THEN+1

; KEYWORDS TABLE

K_TABLE::
	; arithmetic operators
	.db K_POWER		.ascii	"^"

	.db K_NEGATE		.ascii "-" ; negation (unary)

	.db K_MULTIPLY		.ascii "*"
	.db K_DIVIDE		.ascii "/"
	
	.db K_ADD		.ascii "+"
	.db K_SUBSTRACT		.ascii "-"

	.db K_NOTEQUAL		.ascii "<>"
	.db K_LESSEQUAL		.ascii "<="
	.db K_GREATEREQUAL	.ascii ">="
	.db K_LESS		.ascii "<"
	.db K_GREATER		.ascii ">"
	.db K_EQUAL		.ascii "="

	.db K_NOT		.ascii "NOT"	; logical & bitwise negation
	.db K_AND		.ascii "AND"	; logical & bitwise AND
	.db K_OR		.ascii "OR"	; logical & bitwise OR
	.db K_XOR		.ascii "XOR"	; logical & bitwise exclusive-OR

	; numeric functions (return int or float)
	.db K_ABS		.ascii "ABS"
	.db K_ASC		.ascii "ASC"
	.db K_INT		.ascii "INT"
	.db K_LEN		.ascii "LEN"
	.db K_PEEK		.ascii "PEEK"
	.db K_SGN		.ascii "SGN"
	.db K_VAL		.ascii "VAL"

	; string functions (return string)
	.db K_CHR		.ascii "CHR$"
	.db K_LEFT		.ascii "LEFT$"
	.db K_MID		.ascii "MID$"
	.db K_RIGHT		.ascii "RIGHT$"
	.db K_STR		.ascii "STR$"

	; methods (doesn't return value)
	.db K_CLR		.ascii "CLR"
	.db K_CONT		.ascii "CONT"
	.db K_END		.ascii "END"
	.db K_STOP		.ascii "STOP"
	.db K_FOR		.ascii "FOR"
	.db K_GOSUB		.ascii "GOSUB"
	.db K_GOTO		.ascii "GOTO"
	.db K_IF		.ascii "IF"
	.db K_ELSE		.ascii "ELSE"
	.db K_INPUT		.ascii "INPUT"
	.db K_LET		.ascii "LET"
	.db K_LIST		.ascii "LIST"
	.db K_NEW		.ascii "NEW"
	.db K_NEXT		.ascii "NEXT"
	.db K_POKE		.ascii "POKE"
	.db K_PRINT		.ascii "PRINT"
	.db K_PRINT		.ascii "?"
	.db K_REM		.ascii "REM"
	.db K_RETURN		.ascii "RETURN"
	.db K_RUN		.ascii "RUN"
	.db K_STEP		.ascii "STEP"
	.db K_SYS		.ascii "SYS"
	.db K_THEN		.ascii "THEN"
	.db K_TO		.ascii "TO"
	.db K_NONE
			
;*********************************************************
;* C_TAG2NAME:  CONVERTS ENCODED VARIABLE NAME (IN B-C)
;* 		WRITES ASCII NAME IN STR AT (H-L)
C_TAG2NAME::
	PUSH	H

	MOV	A,B		; FIRST CHAR IN ACC
	ANI	127		; STRIP HI BIT
	
	MOV	M,A		; FIRST LETTER IN STR
	INX	H		; HL++
	
	MOV	A,C		; SECOND CHAR IN ACC
	ORA	A		; SKIP IF ZERO
	JZ	1$			
	
	MOV	M,A		; SECOND LETTER IN STR
	INX	H		; HL++

	; SUFFIX, IF ANY
1$:	MOV	A,B		; FIRST CHAR IN ACC
	ORA	A		; CHECK SIGN BIT
	JP	2$		; IF SIGN = 0, NO SUFFIX (INT)
	
	MVI	M,'$		; STRING
	INX	H		; HL++
	
2$:
	MVI	M,0		; END OF STRING

	POP	H
	RET

;*********************************************************
;* C_NAME2TAG:  CONVERTS NAME AT (H-L)
;*		TO ENCODED VARIABLE NAME (IN B-C)
C_NAME2TAG::
	MVI	C,0
	
	; FIRST CHAR	
	MOV	A,M		; FIRST CHAR IN ACC
	CALL	C_ISALPHA	; CHECK IF ALPHA
	JNC	4$		; 1ST CHAR MUST BE LETTER
	
	ANI	223		; CONVERT TO UPPERCASE
	MOV	B,A		; PUT IN B
	INX	H		; HL++

	; SECOND CHAR
	MOV	A,M		; NEXT CHAR IN ACC
	CPI	'$		; CHECK IF STRING
	JZ	3$		; END OF STRING VARIABLE
	
	CALL	C_ISALPHA	; CHECK IF ALPHA
	JC	1$		; PART OF VARIABLE NAME
	CALL	C_ISDIGIT	; CHECK IF NUMBER
	JC	1$		; PART OF VARIABLE NAME

	RET			; END OF VARIABLE NAME
	
1$:
	ANI	223		; CONVERT TO UPPERCASE
	MOV	C,A		; PUT IN C
	INX	H		; HL++
	
	; REST OF VARIABLE NAME	
2$:	MOV	A,M		; NEXT CHAR IN ACC
	
	CPI	'$		; CHECK IF STRING
	JZ	3$		; END OF STRING VARIABLE

	INX	H		; HL++
	
	CALL	C_ISALPHA	; CHECK IF ALPHA
	JC	2$		; PART OF VARIABLE NAME
	CALL	C_ISDIGIT	; CHECK IF NUMBER
	JC	2$		; PART OF VARIABLE NAME

	DCX	H		; HL--
	RET			; END OF VARIABLE NAME
	
3$:	; END OF THE VARIABLE NAME (STRING)
	INX	H		; HL++
	
	MOV	A,B		; 1ST CHAR OF VARIABLE NAME
	ORI	128		; SET HI BIT -> STRING VAR
	MOV	B,A		; PUT BACK IN B
	RET
	
4$:
	HLT			; HANDLE ERROR
	RET

;*********************************************************
;* NAME2TAG:  	CONVERTS STRING AT (X-Y)
;*		TO INTEGER (IN B-C)
C_STR2INT::	

	RET

;*********************************************************
;* C_ISALPHA:  	CF=1 IF ACC IN [a..zA..Z]
C_ISALPHA::
	CPI	'A		; ACC < 'A'
	JB	1$		; NOT LETTER
	
	CPI	'Z + 1		; ACC <= 'Z'
	JB	2$		; LETTER
	
	CPI	'a		; ACC < 'a'
	JB	1$		; NOT LETTER
	
	CPI	'z + 1		; ACC <= 'z'
	JB 	2$		; LETTER
	
1$:
	ORA	A		; CLEAR CARRY
	RET

2$:
	STC			; SET CARRY
	RET



;*********************************************************
;* C_ISDIGIT:  	CF=1 IF ACC IN [0..9]
C_ISDIGIT::
	CPI	'0		; ACC < '0'
	JB	1$		; NOT NUMBER
	
	CPI	'9 + 1		; ACC > '9'
	JAE	1$		; NOT NUMBER
	
	STC			; SET CARRY
	RET
	
1$:
	ORA	A		; CLEAR CARRY
	RET
	


;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

;TICNT:		.ds	2			;TIMER - COUNTER
