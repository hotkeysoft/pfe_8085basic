;*********************************************************
;* MODULE:	IO
;* 
;* DESCRIPTION:	INPUT/OUTPUT-RELATED FUNCTIONS
;*		UART CONTROL, TIMER CONTROL, SOUND FUNCTIONS,
;*		KEYBOARD FUNCTIONS, TERMINAL OUTPUT FUNCTIONS
;*
;* $Id: io.asm,v 1.23 2002-01-26 23:37:25 Dominic Thibodeau Exp $
;*

.module 	io
.title 		Input/Output module (term+sound)

.include	'common.def'

TIMER	=	0x40			;TIMER PORT BASE
T_C0	=	TIMER+0			;COUNTER 0
T_C1	=	TIMER+1			;COUNTER 1
T_C2	=	TIMER+2			;COUNTER 2
T_CWR	=	TIMER+3			;CONTROL WORD REGISTER

UART	=	0x60			;UART PORT BASE
U_DATA	=	UART+0	; DATA PORT (READ/WRITE)

TERM_ATTN = 	1

.area	BOOT	(ABS)

;*********************************************************
.org	0x003C
RST75:
	DI
	JMP	INTTI0

.area	_CODE

;*********************************************************
;* IO_INIT:  INITIALIZES MODULE
IO_INIT::
	CALL	IO_INITTIMER		;INITIALIZE TIMER

;	MVI	A,7			;LIGHT GRAY FG, BLACK BG
;	CALL	IO_SETCOLOR		;SET CURRENT ATTRIBUTE
	
	CALL	IO_CLS			;CLEARS THE SCREEN
	RET

;*********************************************************
;* UART ROUTINES
;*********************************************************

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

;*********************************************************
;* OUTPUT ROUTINES
;*********************************************************

;********************************************************
; IO_PUTC: SENDS A CHAR (FROM ACC) TO THE TERMINAL
IO_PUTC::
	OUT	U_DATA	
	RET

;********************************************************
; IO_PUTCR: PRINTS NEW LINE CHARACTER
IO_PUTCR::
	MVI	A,13
	OUT U_DATA
	RET

;********************************************************
; IO_PUTS: PUTS STRING - TERMINATED BY NULL OR HI BYTE=1
;	   PTR TO STRING IN HL
IO_PUTS::
	PUSH	H
	
1$:
	MOV	A,M		;LOAD CHAR FROM MEMORY
	ORA	A		;END OF STRING?
	JZ	2$
	JM	2$

	OUT U_DATA		;PRINT CHAR
	
	INX	H		;INCREMENT ADDRESS	
	
	JMP	1$		;LOOP
	
2$:
	POP	H
	RET

;********************************************************
; IO_PUTSN: PUTS STRING - LENGTH IN B, PTR IN HL
IO_PUTSN::
	PUSH	B
	
1$:
	MOV	A,B		; CHECK COUNT
	ORA	A		; CHECK IF ZERO
	JZ	2$
	
	MOV	A,M		;LOAD CHAR FROM MEMORY

	OUT U_DATA		;PRINT CHAR
	
	INX	H		;INCREMENT ADDRESS
	DCR	B
	
	JMP	1$		;LOOP
	
2$:
	POP	B
	RET
	
;********************************************************
; IO_PUTCB: PRINTS A BYTE (ACC) IN BINARY (I.E. 10011010)
IO_PUTCB::
	PUSH	B
	
	MOV	C,A		;KEEP IN NUMBER IN C
	
	MVI	B,8		;8 BINARY DIGITS
1$:
	MOV	A,C		;GET NUMBER
	RAL			;SHIFT LEFT
	MOV	C,A		;PUT BACK IN C
	JC	2$		;0 OR 1?
	
	MVI	A,#'0		;WE HAVE A ZERO
	JMP 	3$	
2$:
	MVI	A,#'1		;WE HAVE A ONE
	
3$:
	OUT U_DATA		;PRINT THE BIT

	DCR	B		;LOOP FOR 8 BITS
	JNZ	1$
	
	POP	B
	RET

;********************************************************
; IO_PUTCH: PRINTS A BYTE (ACC) IN HEX
IO_PUTCH::
	PUSH	PSW		;SAVE LOW DIGIT
	RRC			;MAKE HIGH.
	RRC			;DIGIT.
	RRC			;INTO.
	RRC			;LOW DIGIT.
	CALL	IO_PUTN		;PRINT HIGH DIGIT
	POP	PSW		;GET LOW DIGIT BACK
	CALL	IO_PUTN		;PRINT LOW DIGIT
	RET
	
;********************************************************	
; IO_PUTN: DISPLAYS NIBBLE IN LOWER 4 BITS OF A ('0'..'F')
IO_PUTN:
	PUSH	PSW
	ANI	0x0F		;GET RID OF EXCESS BAGGAGE
	ADI	0x30		;CONVERT TO ASCII NUMBER
	CPI	0x3A		;TEST FOR ALPHA CHARACTER
	JC	1$		;IF NOT, WE ARE OK
	ADI	7		;CONVERT TO CHARACTER
1$:	
	OUT U_DATA
	POP	PSW
	RET

;********************************************************
; IO_PUTHLHEX: SHOW 16 BIT VALUE OF HL IN HEX
IO_PUTHLHEX::
	MOV	A,H		;GET H
	CALL IO_PUTCH	;DISPLAY H IN HEX
	MOV	A,L		;GET L
	CALL IO_PUTCH	;DISPLAY L IN HEX
	RET

;*********************************************************
;* IO_ESCAPE:  ANSI ESCAPE
IO_ESCAPE:
	MVI A,27
	OUT U_DATA
	MVI A,'[
	OUT U_DATA
	RET

;*********************************************************
;* IO_CLS:  CLEARS SCREEN (FILL WITH CURRENT ATTRIBUTE)
IO_CLS::
	CALL IO_ESCAPE
	MVI	A,'2	
	OUT U_DATA
	MVI A,'J
	OUT U_DATA	
	CALL IO_HOME
	RET

;********************************************************
; IO_HOME: MOVE CURSOR TO HOME POSITION (0,0)
IO_HOME::
	CALL IO_ESCAPE
	MVI A,'f
	OUT U_DATA
	RET

;*********************************************************
;* IO_GOTOXY:  SET CURSOR POSITION;  X-Y IN H-L
;* TODO:WORKS ONLY WITH VALUES 0..8 for now
IO_GOTOXY::
	CALL IO_ESCAPE
	MOV A,L			;TERM:Y
	ADI '1
	OUT U_DATA
	MVI A,';
	OUT U_DATA
	MOV	A,H			;TERM:X
	ADI '1
	OUT U_DATA
	MVI A,'f
	OUT U_DATA

	RET

;*********************************************************
;* IO_SETFG:  SET FOREGROUND COLOR (IN ACC) (0-15)
IO_SETFG::
	PUSH	B
	
	ANI	0x0F		;CLEAR USELESS BITS
	MOV 	B,A		;FG COLOR IN B
	
	LDA	IO_CURRATTR	;CURRENT COLOR IN ACC
	ANI	0xF0		;CLEAR UPPER BITS
	
	ORA	B		;MERGE WITH BG COLOR
	
	CALL	IO_SETCOLOR	;STORE NEW ATTR VALUE
	
	POP	B
	RET

;*********************************************************
;* IO_SETBG:  SET BACKGROUND COLOR (IN ACC) (0-15)
IO_SETBG::
	PUSH	B
	
	ANI	0x0F		;CLEAR USELESS BITS
	RLC
	RLC
	RLC			;SHIFT 4 BITS TO THE LEFT
	RLC				
	MOV 	B,A		;BG COLOR IN B
	
	LDA	IO_CURRATTR	;CURRENT COLOR IN ACC
	ANI	0x0F		;CLEAR UPPER BITS
	
	ORA	B		;MERGE WITH BG COLOR
	
	CALL	IO_SETCOLOR	;STORE NEW ATTR VALUE
	
	POP	B	
	RET

;*********************************************************
;* IO_SETCOLOR:  SET COLOR; COMBINED COLOR IN ACC
IO_SETCOLOR::
	PUSH	PSW

	MVI	A,TERM_ATTN		;TERM:ATTN
	OUT U_DATA
	MVI	A,2			;TERM:SETCOLOR
	OUT U_DATA

	POP	PSW
	OUT U_DATA			;TERM:ATTRIBUTE
	
	STA	IO_CURRATTR		;STORE ATTRIBUTE
	
	RET

;*********************************************************
;* IO_SETINPUTMODE:  TOGGLES TO INPUT MODE
IO_SETINPUTMODE::
	MVI	A,TERM_ATTN		;TERM:ATTN
	OUT U_DATA
	MVI	A,65			;TERM:INPUTMODE
	OUT U_DATA
	RET

;*********************************************************
;* IO_SETINTERACTIVEMODE:  TOGGLES TO INTERACTIVE MODE
IO_SETINTERACTIVEMODE::
	MVI	A,TERM_ATTN		;TERM:ATTN
	OUT U_DATA
	MVI	A,64			;TERM:INTERACTIVEMODE
	OUT U_DATA
	RET

;*********************************************************
;* TIMER ROUTINES
;*********************************************************

;*********************************************************
;* IO_INITTIMER:  INITIALIZES TIMERS
IO_INITTIMER::
	LXI	H,0x0000		;CLEAR H-L
	SHLD	TICNT			;H-L IN WORD AT 'TICNT'

;* SET COUNTER 0 (PRESCALER, 2MHz clock -> 20KHz)
	MVI	A,0x36			;COUNTER 0, LSB+MSB, MODE 3, NOBCD
	OUT	T_CWR
	
;* SOURCE:2MHz,  DEST:20KHz, DIVIDE BY 100 (0x0064)

	MVI	A,0x64			;LSB
	OUT	T_C0
	
	MVI	A,0x00			;MSB
	OUT	T_C0


;* SET COUNTER 1 (TIMER CLOCK, 10Hz)

	MVI	A,0x74			;COUNTER 1, LSB+MSB, MODE 2, NOBCD
	OUT	T_CWR
	
;* SOURCE:20KHz,  DEST:10HZ, DIVIDE BY 2000 (0x07D0)

	MVI	A,0xD0			;LSB
	OUT	T_C1
	
	MVI	A,0x07			;MSB
	OUT	T_C1

;* SET COUNTER 2 (SOUND, SOURCE = 20KHZ)

	MVI	A,0xB6			;COUNTER 2, LSB+MSB, MODE 3, NOBCD
	OUT	T_CWR

	RET

;*********************************************************
;* INTTI0:  INTERRUPT HANDLER FOR TIMER 0. INCREMENTS TICNT
INTTI0:
	PUSH	H
	
	LHLD	TICNT
	INX	H
	SHLD	TICNT
	POP	H
	
	EI
	RET


;*********************************************************
;* IO_BEEP:  MAKES A 440HZ BEEP FOR 1/2 SECOND
IO_BEEP::
.if ~DEBUG
	MVI	A,45			;LA4 440HZ
	CALL	IO_SOUNDON
	MVI	A,5		
	CALL 	IO_DELAY		;WAIT 5 * 100 MS
	CALL	IO_SOUNDOFF
.endif	
	RET

;*********************************************************
;* IO_SOUNDON:  PROGRAMS COUNTER 0 AND ENABLES SOUND OUTPUT
IO_SOUNDON::
.if ~DEBUG
	PUSH	H
	PUSH	B
	
	PUSH	PSW
	CALL	IO_SOUNDOFF		;TURNS OFF SOUND BEFORE REPROGRAMMING
	POP	PSW
	
	RLC				;OFFSET *= 2 (TABLE CONTAINS WORDS)

	MVI	B,0
	MOV	C,A			;OFFSET IN B-C
	
	LXI	H,NOTES			;TABLE BASE IN H-L
	DAD	B			;ADD OFFSET TO H-L
	
	MOV	A,M			;BYTE AT H-L IN A (NOTE LSB)
	
	OUT	T_C2			;DIVIDER LSB TO COUNTER
	
	INX	H			;H-L POINTS TO NEXT BYTE
	MOV	A,M			;BYTE AD H-L IN A (NOTE MSB)
	
	OUT	T_C2			;DIVIDER MSB TO COUNTER	
	
;	IN	MISC			;INPUT MISC REGISTER
;	ORI	0x04			;TURNS ON BIT 2
;	OUT	MISC			;OUTPUT MISC REGISTER
	
	POP	B
	POP	H
.endif
	RET

;*********************************************************
;* IO_SOUNDOFF:  DISABLES SOUND OUTPUT
IO_SOUNDOFF::
.if ~DEBUG
;	IN	MISC			;INPUT MISC REGISTER
;	ANI	0xFB			;TURNS OFF BIT 2
;	OUT	MISC			;OUTPUT MISC REGISTER
.endif	
	RET

;*********************************************************
;* IO_DELAY, WAITS ACC * 100MS
IO_DELAY::
.if ~DEBUG
	PUSH 	H
	PUSH	D

	LHLD	TICNT			;LOAD CURRENT COUNT IN H-L

	MOV	E,A			;COUNT IN D-E
	MVI	D,0
	
	DAD	D			;ADD TO H-L
	
	XCHG				;EXCHANGE D&E, H&L, TARGET NOW IN D-E
	
1$:	LHLD	TICNT			;LOAD CURRENT COUNT IN H-L

	MOV	A,H			;MSB IN A
	XRA	D			;COMPARE WITH MSB OF TARGET
	JNZ	1$			;DIFFERENT -> LOOP
	
	MOV	A,L			;LSB IN A
	XRA	E			;COMPARE WITH LSB OF TARGET
	JNZ	1$			;DIFFERENT -> LOOP	
	
;* WE ARE DONE!
	
	POP	D
	POP	H
.endif	
	RET


NOTES:	.dw	0xDC29,0xCFCE,0xC424,0xB922,0xAEBE,0xA4EF,0x9BAE,0x92F1,0x8AB1,0x82E9,0x7B90,0x74A0
	.dw	0x6E15,0x67E7,0x6212,0x5C91,0x575F,0x5278,0x4DD7,0x4978,0x4559,0x4174,0x3DC8,0x3A50
	.dw	0x370A,0x33FA,0x3109,0x2E49,0x2BB0,0x293C,0x26EB,0x24BC,0x22AC,0x20BA,0x1EE4,0x1D28
	.dw	0x1B85,0x19FA,0x1885,0x1724,0x15D8,0x149E,0x1376,0x125E,0x1156,0x105D,0x0F72,0x0E94
	.dw	0x0DC3,0x0CFD,0x0C42,0x0B92,0x0AEC,0x0A4F,0x09BB,0x092F,0x08AB,0x082F,0x07B9,0x074A
	.dw	0x06E1,0x067E,0x0621,0x05C9,0x0576,0x0527,0x04DD,0x0498,0x0456,0x0417,0x03DC,0x03A5
	.dw	0x0371,0x033F,0x0311,0x02E5,0x02BB,0x0294,0x026F,0x024C,0x022B,0x020C,0x01EE,0x01D3

;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	_DATA	(REL,CON)

TICNT::		.ds	2			;TIMER - COUNTER

IO_CURRATTR:	.ds	1			;CONSOLE - CURRENT ATTRIBUTE
