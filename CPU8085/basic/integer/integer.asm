.module 	integer
.title 		Integer module

.area	_CODE

;*********************************************************
;* INT_INC:  INCREMENTS INTEGER AT [H-L]
INT_INC::
	PUSH	B

	MVI	A,0
	
	MOV	C,M					;LOAD LOW BYTE IN C
	INX	H					;HL++
	MOV	B,M					;LOAD HI BYTE IN B
	ORA	B					;UPDATES SIGN FLAG

	JM	1$					;IF POSITIVE, MUST CHECK FOR WRAP 32767->-32768
		
	INX	B					;BC++
	ORA	B					;UPDATES SIGN FLAG1
	
	JM	3$					;STILL POSITIVE, CONTINUE AS NORMAL

2$:
	MOV	M,B					;SAVE HI BYTE IN B
	DCX	H					;HL--
	MOV	M,C					;SAVE LOW BYTE IN C	
	
	JMP	4$		

1$:
	INX	B					;BC++
	JMP	2$

3$:
;******* SET OVERFLOW HERE *****************************
	DCX	H
	RST	7
	
4$:
	POP 	B
	RET


;*********************************************************
;* INT_DEC:  DECREMENTS INTEGER AT [H-L]
INT_DEC::
	PUSH	B

	MVI	A,0
	
	MOV	C,M					;LOAD LOW BYTE IN C
	INX	H					;HL++
	MOV	B,M					;LOAD HI BYTE IN B
	ORA	B					;UPDATES SIGN FLAG

	JP	1$					;IF NEGATIVE, MUST CHECK FOR WRAP -32768->32767
		
	DCX	B					;BC++
	ANA	B					;UPDATES SIGN FLAG1
	
	JP	2$					;STILL NEGATIVE, CONTINUE AS NORMAL

3$:
	MOV	M,B					;SAVE HI BYTE IN B
	DCX	H					;HL--
	MOV	M,C					;SAVE LOW BYTE IN C	
	
	JMP	4$		

1$:
	DCX	B					;BC++
	JMP	3$

2$:
;******* SET OVERFLOW HERE *****************************
	DCX	H
	RST	7
	
4$:
	POP 	B
	RET

;*********************************************************
;* INT_NEG:  NEGATES INTEGER AT [H-L]
INT_NEG::
	PUSH	B

	MOV	A,M					;LOAD LOW BYTE IN ACC
	CMA						;COMPLEMENT ACC
	MOV 	C,A					;PUT ~LOW BYTE IN C
	
	INX	H					;HL++
	MOV	A,M					;LOAD HI BYTE IN ACC
	CMA						;COMPLEMENT ACC
	MOV	B,A					;PUT ~HIGH BYTE IN B 
	
;	WE NOW HAVE ~[HL] IN BC
	
	INX	B					;BC = ~[HL] + 1			
	
; 	PUT BACK IN [HL]

	MOV	M,B					;SAVE HI BYTE IN B
	DCX	H					;HL--
	MOV	M,C					;SAVE LOW BYTE IN C	
	
	POP	B
	RET

;*********************************************************
;* INT_ADD:  ADDS INTEGER AT [H-L] TO INTEGER IN INT_ACC0 
;* (RESULT IN INT_ACC0)
INT_ADD::
	PUSH	B
	PUSH 	D
	PUSH	H
	
	MOV	C,M					;LOAD LOW BYTE IN C
	INX	H					;HL++
	MOV	B,M					;LOAD HI BYTE IN B

	LXI	H,INT_ACC0				;ADDRESS OF INT_ACC0 IN H-L
	
	MOV	E,M					;LOAD LOW BYTE IN E
	INX	H					;HL++
	MOV	D,M					;LOAD HI BYTE IN D

;	THIS SECTION CHECKS THE SIGN OF THE TWO OPERANDS
;	IF THEY ARE SAME, WE MUST CHECK FOR POSSIBLE OVERFLOW

	MOV	A,B					;HI BYTE 1 IN A
	XRA	D					;XOR WITH HI BYTE 2
	
	JP	1$					;SIGN BYTE 0 -> CHECK FOR OVERFLOW
	
	MVI	A,0
	JMP	2$

1$:
	MVI	A,1
	
2$:	PUSH	PSW					;PUSH 1 IF MUST CHECK, OTHERWISE 0
	
;       PERFORM ADD

	XCHG						;SWAP HL AND DE
	
	DAD	B					;HL = HL + BC
	
	XCHG						;SWAP HL AND DE
	
	MOV	M,D					;SAVE HI BYTE IN D
	DCX	H					;HL--
	MOV	M,E					;SAVE LOW BYTE IN E	

;
;	CHECK FOR OVERFLOW?

	POP	PSW					;GET BACK VALUE PUSHED EARLIER
	ORA	A					
	JZ 	3$
	
;	WE MUST CHECK IS SIGN CHANGED
	MOV	A,B					;HI BYTE 1 IN A
	XRA	D					;XOR WITH HI BYTE 2
	
	JP	3$					;SIGN BYTE 0 -> SAME (NO OVERFLOW)

;****** SET OVERFLOW HERE *****************************
	RST 	7

3$:
	POP	H
	POP	D
	POP 	B

	RET

;*********************************************************
;* INT_SUB:  SUBSTRACTS INTEGER AT [H-L] FROM INTEGER IN INT_ACC0 
;* (RESULT IN INT_ACC0)		INT_ACC0 = INT_ACC0 - [H-L]
INT_SUB::
	CALL INT_NEG
	CALL INT_ADD
	CALL INT_NEG
	RET


;*********************************************************
;* INT_ZERO: CLEAR INTEGER AT [H-L]
INT_ZERO::
	MVI	M,0
	INX	H	
	MVI	M,0
	DCX	H	
	RET

	
;*********************************************************
;* INT_AND: LOGICAL AND INT_ACC0 WITH INTEGER AT [H-L]
;* INT_ACC0 = INT_ACC0 AND [H-L]
INT_AND::
	LDA	INT_ACC0				;LOAD LOW BYTE OF INT_ACC0 IN A
	ANA	M					;AND A WITH LOW BYTE OF H-L
	STA	INT_ACC0				;SAVE A IN LOW BYTE OF INT_ACC0
	
	INX	H					;HL++

	LDA	INT_ACC0+1
	ANA	M					;AND A WITH HI BYTE OF H-L
	STA	INT_ACC0+1				;SAVE A IN HI BYTE OF INT_ACC0

	DCX	H					;HL--
		
	RET

;*********************************************************
;* INT_OR: LOGICAL OR INT_ACC0 WITH INTEGER AT [H-L]
;* INT_ACC0 = INT_ACC0 OR [H-L]
INT_OR::
	LDA	INT_ACC0				;LOAD LOW BYTE OF INT_ACC0 IN A
	ORA	M					;OR A WITH LOW BYTE OF H-L
	STA	INT_ACC0				;SAVE A IN LOW BYTE OF INT_ACC0
	
	INX	H					;HL++

	LDA	INT_ACC0+1
	ORA	M					;OR A WITH HI BYTE OF H-L
	STA	INT_ACC0+1				;SAVE A IN HI BYTE OF INT_ACC0

	DCX	H					;HL--
		
	RET

;*********************************************************
;* INT_OR: LOGICAL XOR INT_ACC0 WITH INTEGER AT [H-L]
;* INT_ACC0 = INT_ACC0 XOR [H-L]
INT_XOR::
	LDA	INT_ACC0				;LOAD LOW BYTE OF INT_ACC0 IN A
	XRA	M					;XOR A WITH LOW BYTE OF H-L
	STA	INT_ACC0				;SAVE A IN LOW BYTE OF INT_ACC0
	
	INX	H					;HL++

	LDA	INT_ACC0+1
	XRA	M					;XOR A WITH HI BYTE OF H-L
	STA	INT_ACC0+1				;SAVE A IN HI BYTE OF INT_ACC0

	DCX	H					;HL--
		
	RET

;*********************************************************
;* INT_NOT: LOGICAL NOT INTEGER AT [H-L]
;* [H-L] = ![H-L]
INT_NOT::
	MOV	A,M					;LOAD LOW BYTE OF [H-L] IN A
	CMA						;A = ~A
	MOV	M,A					;SAVE A IN LOW BYTE OF [H-L]
	
	INX	H					;HL++

	MOV	A,M					;LOAD HI BYTE OF [H-L] IN A
	CMA						;A = ~A
	MOV	M,A					;SAVE A IN HI BYTE OF [H-L]

	DCX	H					;HL--
		
	RET

;*********************************************************
;* INT_SHLP: SHIFTS *POSITIVE* INTEGER AT [H-L] 'ACC' BITS 
;* TO THE LEFT (PAD WITH 0)	[H-L] = [H-L]<<(A)
;* OVERFLOWS IF BIT 7 BECOMES 1
INT_SHLP:
	PUSH 	B
	PUSH 	D

	MOV	E,A					;NUMBER OF BITS TO SHIFT IN D-E
	ORA	E					;RESETS CARRY BIT

	JZ	3$					;NOTHING TO SHIFT
	
	MOV	C,M					;LOAD LOW BYTE IN C
	INX	H					;HL++
	MOV	B,M					;LOAD HI BYTE IN B

1$:

;	LOW BYTE
	MOV	A,C					;LOW BYTE IN A
	RAL						;ROTATE ACC LEFT 1 BIT
	MOV	C,A					;STORE BACK IN C
	
;	HI BYTE
	MOV	A,B					;HI BYTE IN A
	RAL						;ROTATE ACC LEFT 1 BIT
	MOV	B,A					;STORE BACK IN B

	ORA	B
	JM	2$					;OVERFLOW IF NUMBER BIT 7 IS SET

;	END SHIFT ONCE
	
	DCR	E					;E--
	JNZ	1$					;LOOP N TIMES

	MOV	M,B					;SAVE HI BYTE IN B
	DCX	H					;HL--
	MOV	M,C					;SAVE LOW BYTE IN C

	JMP	3$

2$:
;****** SET OVERFLOW HERE *****************************
	RST	7

3$:
	POP	D
	POP	B
	RET

;*********************************************************
;* INT_SHR: SHIFTS INTEGER AT [H-L] 'ACC' BITS TO THE RIGHT 
;* (PAD WITH 0)	[H-L] = [H-L]>>(A)
INT_SHR:
	PUSH 	B
	PUSH 	D

	MOV	E,A					;NUMBER OF BITS TO SHIFT IN D-E

	ORA	E					;CHECK IF NB = 0
	JZ	2$					;NOTHING TO SHIFT
	
	MOV	C,M					;LOAD LOW BYTE IN C
	INX	H					;HL++
	MOV	B,M					;LOAD HI BYTE IN B

1$:
	ORA	A					;RESET CARRY BIT

;	HI BYTE
	MOV	A,B					;HI BYTE IN A
	RAR						;ROTATE ACC LEFT 1 BIT
	MOV	B,A					;STORE BACK IN B

;	LOW BYTE
	MOV	A,C					;LOW BYTE IN A
	RAR						;ROTATE ACC LEFT 1 BIT
	MOV	C,A					;STORE BACK IN C

;	END SHIFT ONCE
	
	DCR	E					;E--
	JNZ	1$					;LOOP N TIMES

	MOV	M,B					;SAVE HI BYTE IN B
	DCX	H					;HL--
	MOV	M,C					;SAVE LOW BYTE IN C

2$:
	POP	D
	POP	B
	RET

;*********************************************************
;* INT_MUL: MULTIPLIES INT_ACC1 WITH INTEGER AT [H-L]
;* INT_ACC0 = INT_ACC1 * [H-L]
INT_MUL::
	PUSH	PSW
	PUSH	B	
	PUSH	D
	PUSH	H
	
	MVI	A,0
	
;	CHECK SIGN OF [H-L]
	PUSH 	H					;KEEP HL
	
	INX	H					;HL++
	MOV	B,M					;HI BYTE OF [H-L] IN B
	ORA	B					;CHECK SIGN
	JP	1$
	
	DCX 	H					;HL--
	CALL	INT_NEG					;NEGATES IF NEGATIVE
	
1$:
;	CHECK SIGN OF INT_ACC1
	LXI	H,INT_ACC1+1
	MOV	C,M					;HI BYTE OF INT_ACC1 IN C
	ORA	C
	JP	2$

	DCX 	H					;HL--
	CALL	INT_NEG

2$:
	MOV	A,C					;C IN A
	XRA	B					;A = A XOR B;  PARITY BIT = 0 IF SAME SIGN

	LXI	H,INT_ACC0				;ADDRESS OF INT_ACC0 IN H-L
	CALL 	INT_ZERO				;ZERO INT_ACC0

	POP	H					;RESTORE HL

	PUSH	PSW					;STORE PARITY BIT

	MVI	B,0					;SHIFT COUNTER
	MVI	C,16					;BIT COUNTER

3$:
	MVI	A,1
	CALL 	INT_SHR					;SHIFT ONE TO THE RIGHT
	
	DCR	C					;C++
	JZ	5$					;PROCESSED ALL BITS?
	
	JC 	4$					;CURRENT BIT == 1?
	
	INR	B					;NO, INCREMENT B
	JMP	3$					;AND LOOP
	
4$:
;	WE HAVE A ONE - DO THE SHIFT/ADD
	XCHG						;SWAP H-L WITH D-E (WE NEED TO KEEP H-L)
	
	MOV	A,B					;NUMBER OF BITS TO SHIFT
	LXI	H,INT_ACC1				;TEMP ACC1
	CALL	INT_SHLP				;SHIFT ACC1 TO THE LEFT 'B' TIMES
	
	CALL 	INT_ADD					;ADDS TO ACC0

	MVI	B,1					;RESET SHIFT COUNTER
	XCHG						;GET BACK H-L
	JMP	3$					;GO BACK						
	
5$:
	POP	PSW					;GET PARITY BIT BACK	
	JP	6$					;SAME SIGN - DONT INVERT RESULT
	
	LXI	H,INT_ACC0					
	CALL	INT_NEG					;NEGATES RESULT
	
6$:	
	POP	H
	POP	D	
	POP	B
	POP	PSW
	RET

;*********************************************************
;* INT_DIVLS: (INTERNAL - USED BY IDIV)
;* SHIFTS ONE BIT TO THE LEFT ("32-BITS" REG COMPOSED OF 
;* HL(MSW) AND INT_ACC0(LSW))
INT_DIVLS:
;	ORA	A					;CLEARS CARRY BIT

	LDA	INT_ACC0				;LSW - LSB
	RAL						;ROTATE LEFT
	STA	INT_ACC0				;PUT BACK
	
	LDA	INT_ACC0+1				;LSW - MSB
	RAL						;ROTATE LEFT
	STA	INT_ACC0+1				;PUT BACK
	
	MOV	A,L					;MBW - LSB
	RAL						;ROTATE LEFT
	MOV	L,A					;PUT BACK
	
	MOV	A,H					;MBW - MSB
	RAL						;ROTATE LEFT
	MOV	H,A					;PUT BACK
	
	RET	

;*********************************************************
;* INT_DIV: DIVIDES INT_ACC0 WITH INTEGER AT [H-L]
;* INT_ACC0 = INT_ACC0 / [H-L]
INT_DIV::
;	PUSH	B
;	PUSH	D
;	PUSH	H

	ORA	A					;CLEAR CARRY BIT

	MOV	C,M					;MSB OF DIVISOR
	INX	H
	MOV	B,M					;LSB OF DIVISOR
	DCX 	H
	
	CALL 	INT_NEG					;GET -DIVISOR
	
	MOV	E,M					;MSB OF -DIVISOR
	INX	H
	MOV	D,M					;LSB OF -DIVISOR
	DCX	H
	
	CALL	INT_NEG					;GET BACK DIVISOR
	
	MVI	H,0					;CLEAR H-L
	MVI	L,0

;	FIRST TIME: 2*A - B
	CALL	INT_DIVLS				;2*S
	
	MOV	A,L					;- B
	ADD	E
	MOV	L,A
	MOV	A,H
	ADC	D
	MOV	H,A
	
	MVI	A,15					;DO IT 15+1 TIMES
	STA	INT_ACC1				;WE HAVE RAN OUT OF REGISTERS
;							;PUT COUNTER IN MEMORY

1$:
	JC	2$

;	NO CARRY
;	2*A
	CALL	INT_DIVLS				;SHIFT EVERYTHING LEFT ONE BIT
;	2*A + B
	MOV	A,L					;ADDS DIVISOR TO H-L
	ADD	C
	MOV	L,A
	MOV	A,H
	ADC	B
	MOV	H,A

	JMP	3$

;	2*A - B
2$:
;	2*A
	LDA	INT_ACC0
	ORI	1
	STA	INT_ACC0
	
	CALL	INT_DIVLS				;SHIFT EVERYTHING LEFT ONE BIT
	MOV	A,L					;SUBSTRACTS DIVISOR FROM H-L
	ADD	E
	MOV	L,A
	MOV	A,H
	ADC	D
	MOV	H,A

3$:
	LDA	INT_ACC1				;GET BACK COUNTER
	DCR	A					;COUNTER--
	STA	INT_ACC1
	JNZ	1$
	
	JC	4$
	
;	FINAL STEP: RESTORE
	MOV	A,L					;ADDS DIVISOR TO H-L
	ADD	C
	MOV	L,A
	MOV	A,H
	ADC	B
	MOV	H,A
	
	JMP	5$
	
4$:
	LDA	INT_ACC0				;SET LAST BIT...
	ORI	1
	STA	INT_ACC0
		
5$:
	
;	POP	H
;	POP	D
;	POP	B
	RET
	
;*********************************************************
;* INT_ITOA: CONVERTS INTEGER IN INT_ACC0 TO ASCII STRING AT INT_ACCSTR
INT_ITOA::
	PUSH	B
	PUSH	D
	PUSH	H

;	SAVE INT_ACC0
	LDA	INT_ACC0
	MOV	L,A					;LOW BYTE

	LDA	INT_ACC0+1
	MOV	H,A					;HIGH BYTE

	PUSH	H					;PUSH ON THE STACK

	ORA	A					;UPDATES THE SIGN FLAG
	PUSH	PSW					;WE HAVE TO REMEMBER THE SIGN FLAG
	
	JP	1$
	
	LXI	H,INT_ACC0					
	CALL	INT_NEG					;NEGATES INT_ACC0
	
1$:

;	CLEAR EVERYTHING
	LXI	B,0
	LXI	D,0
	LXI	H,0

	MVI	L,17

2$:	
	DCR	L					;CHECK EXIT CONDITION
	JZ 	14$

	MOV	A,L					;TIME TO SWAP BYTES?
	CPI	8
	JNZ 	3$
	
	LDA	INT_ACC0				;REPLACE HI BYTE WITH LOW
	STA	INT_ACC0+1
	
3$:
	LDA	INT_ACC0+1				;LOAD ACC0 LOW BYTE IN A
	ORA	A
	RAL						;ROTATE LEFT THRU CARRY
	STA	INT_ACC0+1				;STORE BACK

	PUSH	PSW

;******************************************************
;	BIN2BCD - REG B
	MOV	A,B
	SUI	0x50					;SUBSTRACTS 4 FROM HI NIBBLE
	JM	4$
	ADI	0x30					;IF HI NIBBLE >5, ADD 3
4$:
	ADI	0x50					;PUT BACK 4 REMOVED BEFORE
	
	MOV	B,A					;PUT BACK IN B
	
;******************************************************
;	BIN2BCD - REG C
	MOV	A,C
	SUI	0x50					;SUBSTRACTS 4 FROM HI NIBBLE
	JM	5$
	ADI	0x30					;IF HI NIBBLE >5, ADD 3
5$:
	ADI	0x50					;PUT BACK 4 REMOVED BEFORE
	
	MOV	C,A					;PUT BACK IN C

;******************************************************
;	BIN2BCD - REG D
	MOV	A,D
	SUI	0x50					;SUBSTRACTS 4 FROM HI NIBBLE
	JM	6$
	ADI	0x30					;IF HI NIBBLE >5, ADD 3
6$:
	ADI	0x50					;PUT BACK 4 REMOVED BEFORE
	
	MOV	D,A					;PUT BACK IN B

;******************************************************
;	BIN2BCD - REG E
	MOV	A,E
	SUI	0x50					;SUBSTRACTS 4 FROM HI NIBBLE
	JM	7$
	ADI	0x30					;IF HI NIBBLE >5, ADD 3
7$:
	ADI	0x50					;PUT BACK 4 REMOVED BEFORE
	
	MOV	E,A					;PUT BACK IN B

;******************************************************
;	BIN2BCD - REG H
	MOV	A,H
	SUI	0x50					;SUBSTRACTS 4 FROM HI NIBBLE
	JM	8$
	ADI	0x30					;IF HI NIBBLE >5, ADD 3
8$:
	ADI	0x50					;PUT BACK 4 REMOVED BEFORE
	
	MOV	H,A					;PUT BACK IN B

	POP	PSW

;******************************************************
;	MUSICAL CHAIR...
;******************************************************
;	(B)  ->  C  ->  D  ->  E  ->  H  	
	MOV	A,B					;B IN A	

	JNC	9$					;SET BIT 3?

	ORI	8					;YES		
9$:
	RAL						;ROTATE LEFT THRU CARRY
	MOV	B,A					;PUT BACK IN B
	
;******************************************************
;	 B   -> (C) ->  D  ->  E  ->  H  	
	MOV	A,C					;C IN A	

	JNC	10$					;SET BIT 3?

	ORI	8					;YES		
10$:
	RAL						;ROTATE LEFT THRU CARRY
	MOV	C,A					;PUT BACK IN C
	
;******************************************************
;	 B   ->  C  -> (D) ->  E  ->  H  	
	MOV	A,D					;D IN A	

	JNC	11$					;SET BIT 3?

	ORI	8					;YES		
11$:
	RAL						;ROTATE LEFT THRU CARRY
	MOV	D,A					;PUT BACK IN D
	
;******************************************************
;	 B   ->  C  ->  D  -> (E) ->  H  	
	MOV	A,E					;E IN A	

	JNC	12$					;SET BIT 3?

	ORI	8					;YES		
12$:
	RAL						;ROTATE LEFT THRU CARRY
	MOV	E,A					;PUT BACK IN E


;******************************************************
;	 B   ->  C  ->  D  ->  E  -> (H)  	
	MOV	A,H					;H IN A	

	JNC	13$					;SET BIT 3?

	ORI	8					;YES		
13$:
	RAL						;ROTATE LEFT THRU CARRY
	MOV	H,A					;PUT BACK IN H

	JMP	2$
	
14$:
	POP	PSW					;GET BACK THE SIGN FLAG

;*******************************************************
; 	PUT IN INT_ACCSTR (STRING - UNFORMATTED)
	JP	15$
	
	MVI	A,#'-
	JMP	16$
15$:
	MVI	A,#' 

16$:
	STA	INT_ACCSTR				;SIGN CHAR
	
;	N * 10000	
	MOV	A,H	
	RRC
	RRC						;DIVIDE BY 16 
	RRC						;(HI NIBBLE -> LOW)
	RRC						
	ADI	#'0					;CONVERT TO CHAR
	STA	INT_ACCSTR+1				;PUT IN STRING

;	N * 1000	
	MOV	A,E
	RRC
	RRC						;DIVIDE BY 16 
	RRC						;(HI NIBBLE -> LOW)
	RRC						
	ADI	#'0					;CONVERT TO CHAR
	STA	INT_ACCSTR+2				;PUT IN STRING

;	N * 100
	MOV	A,D
	RRC
	RRC						;DIVIDE BY 16 
	RRC						;(HI NIBBLE -> LOW)
	RRC						
	ADI	#'0					;CONVERT TO CHAR
	STA	INT_ACCSTR+3				;PUT IN STRING
	
;	N * 10
	MOV	A,C
	RRC
	RRC						;DIVIDE BY 16 
	RRC						;(HI NIBBLE -> LOW)
	RRC						
	ADI	#'0					;CONVERT TO CHAR
	STA	INT_ACCSTR+4				;PUT IN STRING
	
;	N * 1
	MOV	A,B
	RRC
	RRC						;DIVIDE BY 16 
	RRC						;(HI NIBBLE -> LOW)
	RRC						
	ADI	#'0					;CONVERT TO CHAR
	STA	INT_ACCSTR+5				;PUT IN STRING
	
	MVI	A,0
	STA	INT_ACCSTR+6
	

;	RESTORE INT_ACC0
	POP	H
	
	MOV	A,L
	STA	INT_ACC0				;LOW BYTE
	
	MOV	A,H
	STA	INT_ACC0+1				;HIGH BYTE


	POP	H
	POP	D
	POP	B
	
	RET
	

;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

INT_ACC0::	.ds	2
INT_ACC1::	.ds	2
INT_ACC2::	.ds	2
INT_ACC3::	.ds 	2

INT_ACCSTR::	.ds	7


