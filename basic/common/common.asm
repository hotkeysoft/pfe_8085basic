;*********************************************************
;* MODULE:	COMMON
;* 
;* DESCRIPTION:	COMMON DEFINITIONS (KEYWORDS AND CONSTANTS)
;*		PLUS COMMON FUNCTIONS (NAME2TAG, TAG2NAME, 
;*		ISDIGIT, ISALPHA, MEMSET, MEMCPY...)
;*		

.module 	common
.title 		Common functions

.include	'common.def'
.include	'..\error\error.def'

.area	_CODE

SID_CINT	== 1
SID_CFLOAT	== 2
SID_CSTR	== 4
SID_VAR		== 8
SID_GOSUB	== 16
SID_FOR		== 32
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
K_FRE		== K_ASC+1
K_LEN		== K_FRE+1
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

K_BEEP		== 0xC0
K_CLR		== K_BEEP+1
K_CLS		== K_CLR+1
K_COLOR		== K_CLS+1
K_ELSE		== K_COLOR+1
K_END		== K_ELSE+1
K_FOR		== K_END+1
K_GOSUB		== K_FOR+1
K_GOTO		== K_GOSUB+1
K_GOTOXY	== K_GOTO+1
K_IF		== K_GOTOXY+1
K_INPUT		== K_IF+1
K_LET		== K_INPUT+1
K_LIST		== K_LET+1
K_NEW		== K_LIST+1
K_NEXT		== K_NEW+1
K_POKE		== K_NEXT+1
K_PRINT		== K_POKE+1
K_REM		== K_PRINT+1
K_RETURN	== K_REM+1
K_RUN		== K_RETURN+1
K_SLEEP		== K_RUN+1
K_SOUND		== K_SLEEP+1
K_STEP		== K_SOUND+1
K_SYS		== K_STEP+1
K_THEN		== K_SYS+1
K_TO		== K_THEN+1

.if DEBUG
K_DUMPVAR	== 0xE0
K_DUMPSTR	== K_DUMPVAR+1
.endif

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

	; numeric functions (return int)
	.db K_ABS		.ascii "ABS"
	.db K_ASC		.ascii "ASC"
	.db K_FRE		.ascii "FRE"
	.db K_LEN		.ascii "LEN"
	.db K_PEEK		.ascii "PEEK"
	.db K_RND		.ascii "RND"
	.db K_SGN		.ascii "SGN"
	.db K_SQR		.ascii "SQR"
	.db K_VAL		.ascii "VAL"

	; string functions (return string)
	.db K_CHR		.ascii "CHR$"
	.db K_LEFT		.ascii "LEFT$"
	.db K_MID		.ascii "MID$"
	.db K_RIGHT		.ascii "RIGHT$"
	.db K_STR		.ascii "STR$"

	; methods (doesn't return value)
	.db K_BEEP		.ascii "BEEP"	
	.db K_CLR		.ascii "CLR"
	.db K_CLS		.ascii "CLS"
	.db K_COLOR		.ascii "COLOR"	
	.db K_ELSE		.ascii "ELSE"
	.db K_END		.ascii "END"
	.db K_FOR		.ascii "FOR"
	.db K_GOSUB		.ascii "GOSUB"
	.db K_GOTOXY		.ascii "GOTOXY"
	.db K_GOTO		.ascii "GOTO"
	.db K_IF		.ascii "IF"
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
	.db K_SLEEP		.ascii "SLEEP"
	.db K_SOUND		.ascii "SOUND"
	.db K_STEP		.ascii "STEP"
	.db K_SYS		.ascii "SYS"
	.db K_THEN		.ascii "THEN"
	.db K_TO		.ascii "TO"
	
.if DEBUG
	.db K_DUMPVAR		.ascii "DUMPVAR"
	.db K_DUMPSTR		.ascii "DUMPSTR"
.endif	
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
	JNC	ERR_UNKNOWN	; 1ST CHAR MUST BE LETTER
	
	ANI	223		; CONVERT TO UPPERCASE
	MOV	B,A		; PUT IN B
	INX	H		; HL++

	; SECOND CHAR
	MOV	A,M		; NEXT CHAR IN ACC
	CPI	'$		; CHECK IF STRING
	JZ	4$		; END OF STRING VARIABLE
	
	CALL	C_ISALPHA	; CHECK IF ALPHA
	JC	1$		; PART OF VARIABLE NAME
	CALL	C_ISDIGIT	; CHECK IF NUMBER
	JC	2$		; PART OF VARIABLE NAME

	RET			; END OF VARIABLE NAME

1$:	
	ANI	223		; CONVERT TO UPPERCASE
2$:
	MOV	C,A		; PUT IN C
	INX	H		; HL++
	
	; REST OF VARIABLE NAME	
3$:	MOV	A,M		; NEXT CHAR IN ACC
	
	CPI	'$		; CHECK IF STRING
	JZ	4$		; END OF STRING VARIABLE

	INX	H		; HL++
	
	CALL	C_ISALPHA	; CHECK IF ALPHA
	JC	3$		; PART OF VARIABLE NAME
	CALL	C_ISDIGIT	; CHECK IF NUMBER
	JC	3$		; PART OF VARIABLE NAME

	DCX	H		; HL--
	RET			; END OF VARIABLE NAME
	
4$:	; END OF THE VARIABLE NAME (STRING)
	INX	H		; HL++
	
	MOV	A,B		; 1ST CHAR OF VARIABLE NAME
	ORI	128		; SET HI BIT -> STRING VAR
	MOV	B,A		; PUT BACK IN B
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
;* C_MEMSET: 	FILLS AREA OF MEMORY BYTE IN 'ACC'
;*		ADDRESS OF AREA TO FILL IN 'HL'
;*		SIZE OF AREA TO FILL IN 'BC'
C_MEMSET::
	MVI	A,0		; RESET A
	
	CMP	C		; LOOP IF LO BYTE OF COUNTER IS NON NULL
	JNZ	1$
	
	CMP	B		; LOOP IF HI BYTE OF COUNTER IS NON NULL
	JNZ	1$

	RET
	
1$:
	PUSH	D
	MOV	D,A
	
2$:	
	MOV	M,D		; STORE FILL CHAR
	INX	H		; ADDR++
	
	DCX	B		; DECREMENT COUNTER
	
	MVI	A,0		; RESET A
	
	CMP	C		; LOOP IF LO BYTE OF COUNTER IS NON NULL
	JNZ	2$
	
	CMP	B		; LOOP IF HI BYTE OF COUNTER IS NON NULL
	JNZ	2$
	
	POP	D
	RET

;*********************************************************
;* C_MEMCPYF:	COPY A BLOCK A MEMORY
;*		(ALLOWS 'FORWARD' OVERLAP I.E. ALLOWS
;*		COPY FROM 0x8000 TO 0x9000 EVEN IF BLOCKS
;*		OVERLAP)
;*		DESTINATION IN HL
;*		SOURCE IN DE
;*		NB OF BYTES TO COPY IN BC
C_MEMCPYF::
	MVI	A,0		; RESET A
	
	CMP	C		; CHECK IF COUNTER > 0
	JNZ	1$
	
	CMP	B
	JNZ	1$

	RET

1$:
	DAD	B		; GO TO END OF DEST
	XCHG
	DAD	B		; GO TO END OF SOURCE
	XCHG
	
	DCX	D
	DCX	H
	
2$:	
	LDAX	D		; CHAR AT (DE) IN ACC
	MOV	M,A		; BACK AT (HL)
	
	DCX	D		; DE--
	DCX	H		; HL--
	DCX	B		; BC-- (COUNT)

	MVI	A,0		; RESET A
	
	CMP	C		; LOOP IF COUNTER IS NON NULL
	JNZ	2$
	
	CMP	B
	JNZ	2$
	
	INX	D
	INX	H	
	
	RET

;*********************************************************
;* C_MEMCPY:	COPY A BLOCK A MEMORY
;*		(ALLOWS 'BACKWARDS' OVERLAP I.E. ALLOWS
;*		COPY FROM 0x9000 TO 0x8000 EVEN IF BLOCKS
;*		OVERLAP)
;*		DESTINATION IN HL
;*		SOURCE IN DE
;*		NB OF BYTES TO COPY IN BC
C_MEMCPY::
	MVI	A,0		; RESET A
	
	CMP	C		; CHECK IF COUNTER > 0
	JNZ	1$
	
	CMP	B
	JNZ	1$

	RET

1$:
	PUSH	B
	PUSH	H

2$:	
	LDAX	D		; CHAR AT (DE) IN ACC
	MOV	M,A		; BACK AT (HL)
	
	INX	D		; BC++
	INX	H		; HL++
	DCX	B		; BC-- (COUNT)

	MVI	A,0		; RESET A
	
	CMP	C		; LOOP IF COUNTER IS NON NULL
	JNZ	2$

	CMP	B		; LOOP IF COUNTER IS NON NULL
	JNZ	2$

	POP	H
	POP	B	
	RET

;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)
