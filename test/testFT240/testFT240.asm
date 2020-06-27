.module 	testft240
.title 		Test FT240x

STACK		=	0xFFFF		;SYSTEM STACK

UART	=	0x60			;UART PORT BASE
U_DATA	=	UART+0	; DATA PORT (READ/WRITE)

.area	BOOT	(ABS)

RST0:
	DI
	LXI	SP,STACK	;INITALIZE STACK
	JMP START
	
;*********************************************************
;* MAIN PROGRAM
;*********************************************************
.area 	_CODE

START:
	MVI	A,0b00001000		;No interrupt masked
	SIM
	EI			;ENABLE INTERRUPTS

	MVI	A, 'R
	CALL	IO_PUTC ; SEND TO UART
	MVI	A, 'E
	CALL	IO_PUTC ; SEND TO UART
	MVI	A, 'A
	CALL	IO_PUTC ; SEND TO UART
	MVI	A, 'D
	CALL IO_PUTC ; SEND TO UART
	MVI	A, 'Y
	CALL	IO_PUTC ; SEND TO UART
	MVI	A, 10
	CALL	IO_PUTC ; SEND TO UART
	MVI	A, 13
	CALL	IO_PUTC ; SEND TO UART

LOOP:
	CALL WAITFORCHAR
	CALL IO_PUTC
	
	JMP LOOP

;********************************************************
; IO_GETCHAR:  GETS A CHAR FROM KEYBOARD BUFFER (RETURNED IN ACC - 0 IF EMPTY)
IO_GETCHAR::
	RIM
	ANI 0b10000000  ; CHECK SID PIN
	JNZ NODATA;
	
	IN U_DATA
	RET
	
NODATA:	
	MVI A, 0
	RET	

;********************************************************
; IO_PUTC: SENDS A CHAR (FROM ACC) TO THE TERMINAL
IO_PUTC::
	OUT	U_DATA	
	RET

;*********************************************************
;* KEYBOARD ROUTINES
;*********************************************************
WAITFORCHAR:
1$:
	CALL	IO_GETCHAR	;CHECK TERMINAL
	ORA	A
	JZ	1$

	RET

;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

