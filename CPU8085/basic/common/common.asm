.module 	common
.title 		Common functions


.area	_CODE

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

K_TABLE:
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
;* IO_INIT:  INITIALIZES MODULE
;IO_INIT::
;	CALL	IO_INITMISC		;INITIALIZE MISC OUTPUTS
;	RET

;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

;TICNT:		.ds	2			;TIMER - COUNTER

;IOKBUF:	.ds	16			;KEYBOARD BUFFER


