.module 	testpit
.title 		Test PIT

STACK		=	0xFFFF		;SYSTEM STACK

TIMER	=	0x40			;TIMER PORT BASE
T_C0	=	TIMER+0			;COUNTER 0
T_C1	=	TIMER+1			;COUNTER 1
T_C2	=	TIMER+2			;COUNTER 2
T_CWR	=	TIMER+3			;CONTROL WORD REGISTER

.area	BOOT	(ABS)

.org 	0x0000

RST0:
	DI
	LXI	SP,STACK	;INITALIZE STACK
	JMP START

;*********************************************************
;* MAIN PROGRAM
;*********************************************************
.area 	_CODE

START:

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

LOOP:
	
	JMP LOOP


;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

