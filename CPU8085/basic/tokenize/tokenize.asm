.module 	tokenize
.title 		Tokenization of basic statements


.area	_CODE

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


