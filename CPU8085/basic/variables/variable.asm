.module 	variable
.title 		Variable module

.area	BOOT	(ABS)

.org	0x0038
RST7:	
	HLT

.area	_CODE

;*********************************************************
;* VAR_XXX:  	XXX
VAR_XXX:
	RET

;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

VAR_TEMP1::		.ds	4		; TEMPORARY VARIABLE
VAR_TEMP2::		.ds	4		; TEMPORARY VARIABLE
VAR_TEMP3::		.ds	4		; TEMPORARY VARIABLE
