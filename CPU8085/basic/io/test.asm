.module 	iotest
.title 		Tests IO Module

.include	'io.def'

STACK	==	0xFFFF			;SYSTEM STACK

.area	BOOT	(ABS)

.org 	0x0000
	
RST0:
	DI
	LXI	SP,STACK		;INITALIZE STACK
	JMP 	START


;*********************************************************
;* MAIN PROGRAM
;*********************************************************
.area 	_CODE

START:
	CALL	IO_INIT

	MVI	A,8			;SET INTERRUPT MASK
	SIM
	EI				;ENABLE INTERRUPTS

	CALL	IO_BEEP			;MAKE SOME NOISE!

	MVI	A,10		
	CALL 	IO_DELAY		;WAIT 5 * 100 MS

	CALL	IO_CLS			;CLEAR TERMINAL SCREEN
	
	LXI	H,0x200A		;X=32, Y=10
	CALL	IO_GOTOXY
	
	LXI	H,NUMBERS
	CALL	IO_PUTS			;PRINT STRING

	MVI 	B,8			;ITERATE 8 TIMES (Y)
YLOOP:	
	MVI	A,8			
	SUB	B			;A = 8-B (0..7)
	CALL	IO_SETBG
	
	MVI	H,0x20			;X=20
	ADI	0x0B			;LINE NO + 11 IN ACC
	MOV	L,A			;ACC -> Y
	CALL	IO_GOTOXY
	
	MVI	C,16			;X LOOP (16..1)
XLOOP:	
	MVI	A,16
	SUB	C			;A = 16-C (0..15)

	CALL	IO_SETFG		;SET FG COLOR
	
	MVI	A,#'#			;PRINT A '#'
	CALL	IO_PUTC

	DCR	C
	JNZ	XLOOP

	DCR	B
	JNZ	YLOOP			;Y LOOP
	
	



LOOP:
	CALL	IO_GETCHAR
	ORA	A
	JZ	LOOP

	CALL	IO_PUTC

	JMP	LOOP

NUMBERS:	.asciz		'0123456789ABCDEF'