.module 	strings
.title 		Strings module

.include	'..\common\common.def'
.include	'..\io\io.def'

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
	PUSH	D
	
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
	
	POP	D
	RET
	
;*********************************************************
;* STR_FREE:	FREE STR AT (H-L) (SETS 'PARENT' TO 0)
STR_FREE::
	PUSH	D
	PUSH	H				; KEEP ADDRESS
	
	XCHG					; SWAP HL<->DE
	LHLD	STR_LOPTR			; BOTTOM OF STR PTR IN HL
	XCHG					; SWAP HL<->DE
	
	; COMPARE STRPTR WITH STR_LOPTR
	; (ONLY FREE IF STRPTR > STR_LOPTR)
	MOV	A,H				; COMPARE HI BYTE
	CMP	D
	JB	2$
	JNZ	1$
	
	; HI BYTE ARE EQUAL
	MOV	A,L				; COMPARE LO BYTE
	CMP	E
	JB	2$

1$:	; 'FREE' STRING
	DCX	H
	DCX	H
	MVI	M,0
	DCX	H
	MVI	M,0
	
2$:	
	POP	H				; RESTORE ADDRESS
	POP	D
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

1$:	
	; CHECK FOR END OF STRING
	MOV	A,B				; LEN1 IN ACC
	ORA	A				; CHECK FOR 0
	JZ	3$

	MOV	A,C				; LEN2 IN ACC
	ORA	A				; CHECK FOR 0
	JZ	3$
	
	; COMPARE TWO CHARS
	LDAX	D				; CURR STR1 CHAR IN ACC
	CMP	M				; COMPARE WITH STR2 CHAR
	
	JZ	2$
	JB	5$
	JMP	6$
	
2$:	; THE TWO CHARS ARE EQUAL
	INX	D				; STR1PTR++
	INX	H				; STR2PTR++
	DCR	B				; LENGTH1--
	DCR	C				; LENGTH2--
	JMP	1$
	
	
3$:	; END OF AT LEAST ONE STRING
	MOV	A,B				; LEN1 IN ACC
	ORA	A				; CHECK FOR ZERO
	JNZ	6$	
	
	MOV	A,C				; LEN2 IN ACC
	ORA	A				; CHECK FOR ZERO
	JNZ	5$
	

4$:	; EQUAL, RETURN 0
	MVI	A,0
	RET

5$:	; LESS, RETURN -1
	MVI	A,0xFF
	RET

6$:	; MORE, RETURN +1
	MVI	A,0x01
	RET


;*********************************************************
;* STR_GARBAGECOLLECTION:
STR_GARBAGECOLLECTION::
	RET

.if DEBUG
STR_DUMPSTRINGS::
	PUSH	B
	PUSH	D
	PUSH	H
	
	LHLD	STR_HIPTR
	XCHG
	LHLD	STR_LOPTR
	
1$:
	MOV	A,E
	CMP	L
	JNZ	2$
	
	MOV	A,D
	CMP	H
	JNZ	2$
	
	CALL	IO_PUTCR	
	POP	H
	POP	D
	POP	B
	RET		
	
2$:
	MVI	A,'[
	CALL	IO_PUTC

	CALL	IO_PUTHLHEX

	MVI	A,']
	CALL	IO_PUTC

	MVI	A,' 
	CALL	IO_PUTC


	MVI	A,'(
	CALL	IO_PUTC
	
	MOV	C,M			; READ LO BYTE (PARENT)
	INX	H
	MOV	B,M			; READ HI BYTE (PARENT)
	INX	H
	
	MOV	A,B
	CALL	IO_PUTCH		; PRINT PARENT PTR
	MOV	A,C
	CALL	IO_PUTCH
	
	MVI	A,')
	CALL	IO_PUTC	

	MVI	A,' 
	CALL	IO_PUTC
	MVI	A,'"
	CALL	IO_PUTC
	
	MOV	B,M			; READ SIZE
	INX	H
	CALL	IO_PUTSN		; PRINT STRING
	
	MVI	A,'"
	CALL	IO_PUTC
	CALL	IO_PUTCR

	JMP	1$
.endif


;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

STR_LOPTR::		.ds	2		; BOTTOM OF STR MEMORY
STR_HIPTR::		.ds	2		; TOP OF STR MEMORY
