.module 	strings
.title 		Strings module

.include	'..\common\common.def'

.area	BOOT	(ABS)

.org	0x0038
RST7:	
	HLT

.area	_CODE

;*********************************************************
;* STR_XXX:  	
STR_XXX::
	RET

;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

;STR_XXX::		.ds	4		; 
