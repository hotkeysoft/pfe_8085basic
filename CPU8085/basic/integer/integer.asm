;*********************************************************
;* MODULE:	INTEGER
;* 
;* DESCRIPTION:	FUNCTIONS RELATED TO NUMBERS: ADD, SUBSTRACT,
;*		MULTIPLY, DIVIDE, SQR, COMPARE, ITOA, ATOI, ETC
;*
;* $Id: integer.asm,v 1.20 2001-12-03 00:23:58 Dominic Thibodeau Exp $
;*

.module 	integer
.title 		Integer module

.include	'..\common\common.def'
.include	'..\error\error.def'

.area	_CODE

;*********************************************************
;* INT_INIT:  INITIALIZES MODULE
INT_INIT::
	; PSEUDO-RANDOM NUMBER GENERATOR INITIALIZATION
	LXI	H,0x6255			; SET CONSTANTS NEEDED TO
	SHLD	INT_RNDCONST1			; GENERATE PSEUDO-RANDOM 
	LXI	H,0x3619			; NUMBERS. (CONSTANTS NEED
	SHLD	INT_RNDCONST2			; TO BE IN RAM, SINCE INT_MUL
	LXI	H,0x0000			; SHIFTS THE NUMBER DURING 
	SHLD	INT_RNDSEED			; MULTIPLY OPERATION
					
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
	
;	CHECK FOR OVERFLOW (0x7FFF->0x8000)
	MVI	A,0x80
	CMP	B			
	JNZ	1$

	MVI	A,0x00
	CMP	C
	JNZ	1$
	
	MVI	A,TRUE
	STA	INT_OVERFLOW				;SET OVERFLOW FLAG
	
1$:	
	
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

	MVI	A,TRUE
	STA	INT_OVERFLOW				;SET OVERFLOW FLAG

3$:
	POP	H
	POP	D
	POP 	B

	RET

;*********************************************************
;* INT_SUB:  SUBSTRACTS INTEGER AT [H-L] FROM INTEGER IN INT_ACC0 
;* (RESULT IN INT_ACC0)		INT_ACC0 = INT_ACC0 - [H-L]
INT_SUB::
	CALL 	INT_NEG					;NEGATES 2ND OPERAND
	CALL 	INT_ADD					;PRERFORM SUBSTRACTION
	CALL 	INT_NEG					;GET BACK 2ND OPERAND
	RET

;*********************************************************
;* INT_CMP:  COMPARES INTEGER AT [H-L] WITH INTEGER IN INT_ACC0 
;* RESULTS:  ACC = 0x00 -> SAME
;*	     ACC = 0x01 -> INT_ACC0 > [H-L]
;*	     ACC = 0xFF -> INT_ACC0 < [H-L]
;* **HL, INT_ACC0 IS MODIFIED**
INT_CMP::
	MVI	A,FALSE
	STA	INT_OVERFLOW				; RESET OVERFLOW FLAG

	CALL 	INT_SUB					; PERFORM SUBSTRACTION
	
	; CHECK FOR EQUALITY
	LHLD	INT_ACC0				; INT_ACC0 IN H-L
	
	MOV	A,H					; A = HI BYTE
	ORA	A					; UPDATE FLAGS
	JNZ	NOTEQUAL

	MOV	A,L					; A = LO BYTE
	ORA	A					; UPDATE FLAGS	
	JNZ	NOTEQUAL
	
	MVI	A,0					; WE HAVE EQUALITY
	RET
	
NOTEQUAL:
	
	; COMPARE SIGN FLAG WITH OVERFLOW
	
	LDA	INT_OVERFLOW				; OVERFLOW == FALSE(0) OR TRUE(-1)
	XRA	H					; XOR WITH HI BYTE
	
	; NOW CHECK SIGN BYTE (0 IF SF == OF)
	
	JP	GREATER
	
	MVI	A,0xFF					; INT_ACC0 < [H-L]
	RET
	

GREATER:
	MVI	A,0x01					; INT_ACC0 > [H-L]
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
55$:
;	END SHIFT ONCE
	
	DCR	E					;E--
	JNZ	1$					;LOOP N TIMES

	MOV	M,B					;SAVE HI BYTE IN B
	DCX	H					;HL--
	MOV	M,C					;SAVE LOW BYTE IN C

	JMP	3$

2$:
	MVI	A,TRUE
	STA	INT_OVERFLOW				;SET OVERFLOW FLAG
	JMP	55$

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
;* INT_MUL: MULTIPLIES INT_ACC0 WITH INTEGER AT [H-L]
;* RESULT IN INT_ACC0 - USES TEMP REG INT_ACC1
;* INT_ACC0 = INT_ACC0 * [H-L]
INT_MUL::
	PUSH	B	
	PUSH	D
	PUSH	H
	
	MOV	B,M					; KEEP INT AT [H-L]
	INX	H
	MOV	C,M
	PUSH	B
	DCX	H
	
;	CHECK SIGN OF [H-L]
	PUSH 	H					;KEEP HL
	
	INX	H					;HL++
	MVI	A,0
	MOV	B,M					;HI BYTE OF [H-L] IN B
	ORA	B					;CHECK SIGN
	JP	1$
	
	DCX 	H					;HL--
	CALL	INT_NEG					;NEGATES IF NEGATIVE
	
1$:
;	CHECK SIGN OF INT_ACC0
	LXI	H,INT_ACC0+1
	MVI	A,0	
	MOV	C,M					;HI BYTE OF INT_ACC0 IN C
	ORA	C
	JP	2$

	DCX 	H					;HL--
	CALL	INT_NEG

2$:
	MOV	A,C					;C IN A
	XRA	B					;A = A XOR B;  PARITY BIT = 0 IF SAME SIGN

	LHLD	INT_ACC0				;COPY ACC0 TO ACC1
	SHLD	INT_ACC1

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
	POP	B					;RESTORE INITIAL INT
	POP	H					;RESTORE INITIAL HL
	
	MOV	M,B					;PUT BACK INT IN [H-L]
	INX	H
	MOV	M,C
	DCX	H		
	
	POP	D	
	POP	B
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
	PUSH	B
	PUSH	D
	PUSH	H

;	CHECK SIGN OF [H-L]
	PUSH 	H					;KEEP HL
	
	INX	H					;HL++
	MVI	A,0
	MOV	B,M					;HI BYTE OF [H-L] IN B
	ORA	B					;CHECK SIGN
	JP	1$
	
	DCX 	H					;HL--
	CALL	INT_NEG					;NEGATES IF NEGATIVE
	
1$:
;	CHECK SIGN OF INT_ACC0
	LXI	H,INT_ACC0+1
	MVI	A,0	
	MOV	C,M					;HI BYTE OF INT_ACC0 IN C
	ORA	C
	JP	2$

	DCX 	H					;HL--
	CALL	INT_NEG

2$:
	POP	H
	MOV	A,C					;C IN A
	XRA	B					;A = A XOR B;  PARITY BIT = 0 IF SAME SIGN
	PUSH	PSW					;KEEP SIGN BIT ON STACK

	MVI	A,0
	ORA	A					;CLEAR CARRY BIT

	MOV	C,M					;MSB OF DIVISOR
	INX	H
	MOV	B,M					;LSB OF DIVISOR
	DCX 	H
	
	; CHECK FOR DIVISOR = 0
	CMP	B
	JNZ	NOTZERO
	
	CMP	C
	JNZ	NOTZERO
	
	JMP	ERR_DIVZERO
	
NOTZERO:
	
	CALL 	INT_NEG					;GET -DIVISOR
	
	MOV	E,M					;MSB OF -DIVISOR
	INX	H
	MOV	D,M					;LSB OF -DIVISOR
	DCX	H
	
	CALL	INT_NEG					;GET BACK DIVISOR
	
	LXI	H,0

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

	POP	PSW					;GET PARITY BIT BACK	
	JP	6$					;SAME SIGN - DONT INVERT RESULT
	
	LXI	H,INT_ACC0					
	CALL	INT_NEG					;NEGATES RESULT

6$:	
	POP	H
	POP	D
	POP	B
	RET
	
;*********************************************************
;* INT_ITOA: CONVERTS INTEGER IN INT_ACC0 TO ASCII STRING
;*	     RETURNS PTR TO BEGIN OF STRING (HL)
;*	     PLUS LENGTH OF STRING (ACC)
INT_ITOA::
;	LOAD VALUE IN HL
	LHLD	INT_ACC0

;	CHECK FOR ZERO
	MOV	A,H
	CPI	0
	JNZ	NONZERO
	
	MOV	A,L
	CPI	0
	JNZ	NONZERO
	
;	SPECIAL CASE: ZERO
	MVI	A,'0
	STA	INT_ACCSTR

	MVI	A,0
	STA	INT_ACCSTR+1
	
	LXI	H,INT_ACCSTR
	MVI	A,1
	RET
	
NONZERO:
	PUSH	B
	PUSH	D

	PUSH	H					;PUSH ON THE STACK

	MOV	A,H
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
	SHLD	INT_ACC0


; 	'FORMAT' STRING (I.E. RETURN PTR TO FIRST NON-ZERO CHAR)

	LXI	H,INT_ACCSTR+1				;FIRST NUMBER
	MVI	B,6					;NB OF CHARS IN STRING

FORMAT:
	MOV	A,M					;READ CHAR
	CPI	'0
	JNZ	LASTZERO
	
	INX	H
	DCR	B
	JMP	FORMAT
	
LASTZERO:
	DCX	H
	LDA	INT_ACCSTR				;READ SIGN
	CPI	'- 					;CHECK IF NEGATIVE
	JZ	ISNEG
	
	; NUMBER IS POSITIVE
	INX	H
	DCR	B
	JMP	FOUND
	
ISNEG:	
	MOV	M,A					;PUT AT NEW POS
	
FOUND:
	MOV	A,B					;COPY LEN TO ACC
	POP	D
	POP	B
	
	RET

;*********************************************************
;* INT_ATOI: CONVERTS ASCII STRING AT (H-L) INTO INTEGER
;* (PUT IN INT_ACC0)
;* USES TEMP REGISTERS: INT_ACC1, INT_ACC2, INT_ACC3
INT_ATOI::
	MVI	A,10			; STORE 10 IN IACC2
	STA	INT_ACC2		; 
	MVI	A,0			;
	STA	INT_ACC2+1		;
	
	STA	INT_ACC3		; ZERO IACC3
	STA	INT_ACC3+1		;
	
	STA	INT_ACC0		; ZERO IACC0
	STA	INT_ACC0+1		;
	
	MOV	A,M			; FIRST CHAR IN ACC
	
	CPI	'+			; CHECK FOR POSITIVE SIGN 
	JZ	PPOS
	
	CPI	'-			; CHECK FOR NEGATIVE SIGN
	JNZ	POS			

	INX	H			; HL++
	
	STC				; SET CARRY
	PUSH	PSW			; PUT ON THE STACK

	JMP	NONEG
	
PPOS:	INX	H			; HL++
	
POS:
	ORA	A			; RESET CARRY FLAG
	PUSH	PSW			; PUT ON THE STACK

NONEG:
	MOV	A,M			; CURRENT CHAR IN ACC
	INX	H			; HL++

	CALL	C_ISDIGIT		; CONTINUE WHILE CHAR IS DIGIT
	JNC 	END
	
	SUI	'0			; CONVERT FROM ASCII
	STA	INT_ACC3		; STORE VALUE IN INT_ACC3
	
	PUSH	H			; KEEP ADDRESS
	
	MVI	A,FALSE			; RESET OVERFLOW
	STA	INT_OVERFLOW
	
	LXI	H,INT_ACC2		; INT_ACC0 *= 10
	CALL	INT_MUL			;
	
	LXI	H,INT_ACC3		; INT_ACC0 += INT_ACC3
	CALL	INT_ADD			;
	
	LDA	INT_OVERFLOW		; CHECK FOR OVERFLOW
	CPI	TRUE
	JZ	ERR_OVERFLOW
	
	POP	H			; RESTORE ADDRESS
	
	JMP	NONEG
	
END:
	DCX	H
	
	POP	PSW			; RESTORE CARRY FLAG
	
	JNC	END2			; CHECK IF NUMBER IS NEGATIVE
	
	PUSH	H
	LXI	H,INT_ACC0
	CALL 	INT_NEG			; IF SO, NEGATE IT
	POP	H
	
END2:	
	RET
	
;*********************************************************
;* INT_ABS: INT AT (H-L) IS REPLACED WITH ITS ABSOLUTE VALUE
;*	    IF (H-L) >= 0 -> NO CHANGE
;*	    IF (H-L) < 0 -> (H-L) = -(H-L)
INT_ABS::
	INX	H
	MOV	A,M			; GET HI BYTE IN ACC
	DCX	H
	
	ORA	A			; UPDATE FLAGS
	RP				; RETURN IF POSITIVE
	
	CALL	INT_NEG			; NEGATES NUMBER
	
	RET

;*********************************************************
;* INT_SGN: INT AT (H-L) IS REPLACED WITH ITS 'SIGN':
;*	    IF (H-L) = 0 -> NO CHANGE
;*	    IF (H-L) < 0 -> (H-L) = -1
;*	    IF (H-L) > 0 -> (H-L) = +1
INT_SGN::
	INX	H
	MOV	A,M			; GET HI BYTE IN ACC
	ORA	A			; UPDATE FLAGS
	JM	2$			; CHECK IF NEGATIVE
	
	MVI	M,0x00			; HI BYTE = 0 ANYWAY
	DCX	H			; HL--
	
	JNZ	1$			; CHECK IF POSITIVE
	
	MOV	A,M			; GET LO BYTE IN ACC
	ORA	A			; CHECK LO BYTE
	JNZ	1$			; CHECK IF POSITIVE
	
	; ZERO
	MVI	M,0x00			; REPLACE WITH 0x0000
	RET
	
1$:	; POSITIVE
	MVI	M,0x01			; REPLACE WITH 0x0001
	RET
	
2$:	; NEGATIVE
	MVI	M,0xFF			; REPLACE WITH 0xFFFF
	DCX	H
	MVI	M,0xFF
	RET

;*********************************************************
;* INT_RND: GENERATES PSEUDO-RANDOM NUMBER, FULL
;*	    RANGE OF INT (-32768..32767)
;*	    RESULT IN INT_ACC0
INT_RND::
	PUSH	H
	
	LHLD	INT_RNDSEED		; LOAD CURRENT SEED IN HL
	SHLD	INT_ACC0		; COPY IN INT_ACC0
	
	LXI	H,INT_RNDCONST1		; SEED *= RNDCONST1
	CALL	INT_MUL
	
	LXI	H,INT_RNDCONST2		; SEED += RNDCONST2
	CALL	INT_ADD
	
	LHLD	INT_ACC0		; READ NEW BALUE
	SHLD	INT_RNDSEED		; SAVE AS NEW SEED
	
	MVI	A,0
	STA	INT_OVERFLOW		; RESET OVERFLOW FLAG
	
	POP	H
	RET

;*********************************************************
;* INT_RANDOMIZE: SET RANDOM SEED.  SEED IN HL
INT_RANDOMIZE::
	SHLD	INT_RNDSEED
	RET


;*********************************************************
;* INT_SQR: CALCULATES SQUARE ROOT OF INT AT [H-L]
;*	    RESULT IN INT_ACC0
;*	    QUICK AND DIRTY, BUT **SLOW**
INT_SQR::
	PUSH	H
	
	MVI	A,0
	
	;SOURCE IN BC
	MOV	C,M			; LO BYTE OF SOURCE
	INX	H
	MOV	B,M			; HI BYTE OF SOURCE

	ORA	B			; UPDATE FLAGS
	JM	ERR_ILLEGAL		; NO NEGATIVE NUMBER

	LXI	H,1			; SQUARE = 1
	LXI	D,3			; DELTA = 3

LOOP:
	MOV	A,B			; LOOP WHILE BC >= HL
	CMP	H			; HI BYTE
	JB	EXIT			;
	JNZ	SKIP			; IF EQUAL, CHECK LOW
	
	MOV	A,C			; LO BYTE
	CMP	L			;
	JB	EXIT

SKIP:
	DAD	D			; SQUARE += DELTA
	INX	D			; DELTA += 2
	INX	D
	JMP	LOOP

EXIT:
	; DELTA = DELTA / 2 - 1
	ORA	A			; RESET FLAGS
		
	MOV	A,E			; LO BYTE IN A
	RAR				; ROTATE RIGHT
	MOV	E,A			; BACK IN E
	
	ORA	A			; RESET FLAGS

	MOV	A,D			; HI BYTE IN A
	RAR				; ROTATE RIGHT THRU CARRY
	MOV	D,A			; BACK IN D
	
	JNC	SKIP2
	
	MVI	A,0x80			; SET HI BIT OF E
	ORA	E
	MOV	E,A			; BACK IN E
	
SKIP2:

	DCX	D			; DELTA--
	
	; PUT RESULT IN INT_ACC0
	MOV	A,D
	STA	INT_ACC0+1		; SET HI BYTE
	MOV	A,E
	STA	INT_ACC0		; SET LO BYTE


	POP	H

	RET

;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

INT_OVERFLOW::	.ds	1

INT_ACC0::	.ds	2
INT_ACC1::	.ds	2
INT_ACC2::	.ds	2
INT_ACC3::	.ds 	2

INT_ACCSTR::	.ds	7

INT_RNDSEED:	.ds	2
INT_RNDCONST1:	.ds	2
INT_RNDCONST2:	.ds	2
