.module 	strings
.title 		Strings module

.include	'..\common\common.def'

.area	BOOT	(ABS)

.org	0x0038
RST7:	
	HLT

.area	_CODE

;*********************************************************
;* STR_ALLOCATE:	ALLOCATES SPACE FOR A STRING
;*			IN: LENGTH IN ACC
;*			    'PARENT' PTR IN 'BC'
;*			RETURNS ADDRESS IN (H-L)
STR_ALLOCATE::
	; KEEP SIZE
	PUSH	PSW
	
	ADI	3				; ADD 3 TO LENGTH
							; (STRLEN + REF PTR)
	; CALCULATE -ACC
	CMA					; ACC = ~ACC
	INR	A				; ACC = ~ACC+1
	
	LHLD	STR_LOPTR			; LOAD LO STR PTR
	MVI	D,0xFF	
	MOV	E,A				; -LEN IN DE
	
	DAD	D				; LO STR PTR -= LEN
	
	SHLD	STR_LOPTR			; SAVE LO STR PTR
	
	MOV	M,C				; LO BYTE 'PARENT'
	INX	H
	
	MOV	M,B				; HI BYTE 'PARENT'
	INX	H
	
	POP	PSW				; GET BACK LENGTH
	
	MOV	M,A				; STORE LENGTH
	INX	H
	
	RET
	
;*********************************************************
;* STR_FREE:	FREE STR AT (H-L) (SETS 'PARENT' TO 0)
STR_FREE::
	PUSH	H				; KEEP ADDRESS
	
	DCX	H
	DCX	H
	MVI	M,0
	DCX	H
	MVI	M,0
	
	POP	H				; RESTORE ADDRESS
	RET
	
;*********************************************************
;* STR_COPY:	COPY STRING, LENGTH IN B
;*		SOURCE:	DE
;*		DEST: 	HL
STR_COPY::

	ORA	A				; CHECK LENGTH > 0
	RZ

1$:
	LDAX	D				; SOURCE IN ACC
	MOV	M,A				; COPY TO DEST
	
	INX	D				; SOURCE++
	INX	H				; DEST++
	DCR	B				; COUNTER--
	JNZ	1$				; LOOP
	
	RET

;*********************************************************
;* STR_CMP:	COMPARE STRINGS
;*		STR1:	DE, LEN: B
;*		STR2: 	HL, LEN: C
;* RESULTS:  ACC = 0x00 -> SAME
;*	     ACC = 0x01 -> STR1 > STR2
;*	     ACC = 0xFF -> STR1 < STR2
;*
STR_CMP::

LOOP:	
	; CHECK FOR END OF STRING
	MOV	A,B				; LEN1 IN ACC
	ORA	A				; CHECK FOR 0
	JZ	END

	MOV	A,C				; LEN2 IN ACC
	ORA	A				; CHECK FOR 0
	JZ	END
	
	; COMPARE TWO CHARS
	LDAX	D				; CURR STR1 CHAR IN ACC
	CMP	M				; COMPARE WITH STR2 CHAR
	
	JZ	SKIP
	JB	LESS
	JMP	MORE
	
SKIP:	; THE TWO CHARS ARE EQUAL
	INX	D				; STR1PTR++
	INX	H				; STR2PTR++
	DCR	B				; LENGTH1--
	DCR	C				; LENGTH2--
	JMP	LOOP
	
	
END:	; END OF AT LEAST ONE STRING
	MOV	A,B				; LEN1 IN ACC
	ORA	A				; CHECK FOR ZERO
	JNZ	MORE	
	
	MOV	A,C				; LEN2 IN ACC
	ORA	A				; CHECK FOR ZERO
	JNZ	LESS
	

EQUAL:	; EQUAL, RETURN 0
	MVI	A,0
	RET

LESS:	; LESS, RETURN -1
	MVI	A,0xFF
	RET

MORE:	; MORE, RETURN +1
	MVI	A,0x01
	RET


;*********************************************************
;* STR_GARBAGECOLLECTION:
STR_GARBAGECOLLECTION::
	RET


;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

STR_LOPTR::		.ds	2		; BOTTOM OF STR MEMORY
STR_HIPTR::		.ds	2		; TOP OF STR MEMORY
