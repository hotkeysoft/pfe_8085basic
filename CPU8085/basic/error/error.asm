.module 	error
.title 		Error handling

.area	BOOT	(ABS)

.org	0x0038
RST7:	
	HLT

.area	_CODE

;*********************************************************
;* ERR_XXX:  	XXX
ERR_XXX:
	RET

;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

;ERR_XXX::		.ds	1		; XXX
