.module 	program
.title 		Program module

.include	'..\common\common.def'
.include	'..\error\error.def'

.area	_CODE

;*********************************************************
;* PRG_xxx:
PRG_xxx::
	RET

;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

;PRG_xxx::		.ds	2		;
