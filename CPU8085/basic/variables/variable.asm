.module 	variable
.title 		Variable module

.include	'..\common\common.def'
.include	'..\error\error.def'
.include	'..\program\program.def'
.include	'..\integer\integer.def'
.include	'..\strings\strings.def'
.include	'..\io\io.def'

.area	_CODE

;*********************************************************
;* VAR_GET:  	GET VARIABLE (TAG IN BC)
;*		COPY IN VAR AT (H-L)
VAR_GET::
	PUSH	D
	
	; CHECK FOR 'TI' VARIABLE
	MVI	A,'T
	CMP	B
	JNZ	0$
	
	MVI	A,'I
	CMP	C
	JNZ	0$
	
	; LOAD TICNT VARIABLE
	LDA	TICNT
	MOV	E,A
	LDA	TICNT+1
	MOV	D,A
	
	PUSH	H
	
	; PUT IN HL AS INT
	MVI	M,SID_CINT
	INX	H
	MOV	M,E
	INX	H
	MOV	M,D
	
	POP	H
	
	POP	D
	RET
	
0$:
	XCHG					; SWAP HL<->DE
	
	CALL	VAR_INTERNALGET			; FIND VARIABLE
	
	MOV	A,H				; CHECK IF NOT FOUND
	ORA	A
	JNZ	1$
	
	; NOT FOUND - CREATE NEW VARIABLE
	CALL	VAR_INTERNALNEW
	
1$:	; HL CONTAINS ADDRESS OF VARIABLE
	XCHG					; SWAP HL<->DE

	INX	D				; GO TO BEGIN OF INT DATA
	INX	D

	PUSH	H				; SAVE INITIAL PARAM

	INX	H
	
	; COPY DATA
	LDAX	D				; BYTE 1
	MOV	M,A		
	INX	D
	INX	H
	
	LDAX	D				; BYTE 2
	MOV	M,A		
	INX	D
	INX	H

	LDAX	D				; BYTE 3
	MOV	M,A		
	
	POP	H				; GET BACK HL

	; IDENTIFY TYPE OF VARIABLE
	MOV	A,B				; TAG[0] IN ACC
	ORA	A				; UPDATE FLAGS
	JM	2$				; CHECK IF INT/FLOAT

	; WE HAVE AN INTEGER
	MVI	M,SID_CINT			; SET AS INT
	POP	D
	RET

2$:	; WE HAVE A STRING
	MVI	M,SID_CSTR			; SET AS STRING
	POP	D
	RET


;*********************************************************
;* VAR_SET:  	SET VARIABLE (TAG IN BC)
;*		WITH DATA AT (H-L) (STACK FORMAT)
VAR_SET::
	PUSH	D
	PUSH	H
	
	; CHECK FOR 'TI' VARIABLE
	MVI	A,'T
	CMP	B
	JNZ	0$
	
	MVI	A,'I
	CMP	C
	JNZ	0$

	MOV	A,M				; CHECK TYPE
	CPI	SID_CINT
	JNZ	ERR_TYPEMISMATCH		; MUST BE INT
	INX	H
	
	; SAVE IN TICNT
	MOV	A,M				; LO BYTE
	STA	TICNT
	INX	H
	MOV	A,M				; HI BYTE
	STA	TICNT+1
	
	POP	H
	POP	D
	RET
		
0$:
	XCHG					; SWAP HL<->DE
	
	CALL	VAR_INTERNALGET			; FIND VARIABLE
	
	MOV	A,H				; CHECK IF NOT FOUND
	ORA	A
	JNZ	SSKIP
	
	; NOT FOUND - CREATE NEW VARIABLE
	CALL	VAR_INTERNALNEW
	
SSKIP:	; HL CONTAINS ADDRESS OF VARIABLE
	XCHG					; SWAP HL<->DE

	LDAX	D				; LOAD TAG[0] IN ACC
	ORA	A				; UPDATE FLAGS
	JP	SSKIP2				; CHECK HI BYTE (1=STR)
	
	; STRING VARIABLE
	MOV	A,M				; READ VARIABLE TYPE
	CPI	SID_CSTR			; MUST BE STRING
	JNZ	ERR_TYPEMISMATCH
	INX	H				; SKIP TYPE
	
	MOV	A,M				; SIZE OF STRING IN A
	INX	D				; SKIP TAG
	INX	D
	STAX	D				; STORE SIZE
	INX	D				; DEST++

	INX	H				; SKIP SIZE

	MOV	C,M
	INX	H
	MOV	B,M
	INX	H

	CALL	STR_GETUNIQUEPTR		; CHECK IF STRING NEEDS TO 
						; BE COPIED, PERFORM THE ACTUAL
						; COPYING, AND RETURN PTR TO 
						; KNOWN 'GOOD' STRING

	; STRING PTR IS IN BC
	LDAX	D				; READ LO BYTE OF OLD ADDRESS
	MOV	L,A
	MOV	A,C				; LO BYTE OF ADDRESS
	STAX	D				; WRITE IT
	INX	D

	LDAX	D				; READ HI BYTE OF OLD ADDRESS
	MOV	H,A
	MOV	A,B				; HI BYTE OF ADDRESS
	STAX	D
	
	CALL	STR_FREE			; FREE OLD STRING (IF NEEDED)
	
	POP	H
	POP	D
	RET
	
SSKIP2:
	; INT VARIABLE
	INX	D				; GO TO BEGIN OF INT DATA
	INX	D

	MOV	A,M				; READ VARIABLE TYPE
	INX	H
	CPI	SID_CINT			; MUST BE INT
	JNZ	ERR_TYPEMISMATCH
	
	; COPY DATA
	MOV	A,M				; BYTE 1
	STAX	D
	INX	D
	INX	H
	
	MOV	A,M				; BYTE 2
	STAX	D

END:
	POP	H
	POP	D
	RET

;*********************************************************
;* VAR_INTERNALNEW:  	CREATES NEW VARIABLE, FROM TAG IN BC
;*			DOES NOT CHECK FOR EXISTANCE OF VARIABLE
;*			ADDRESS.  RETURNS ADDRESS OF NEW VAR
;*			IN HL
VAR_INTERNALNEW::
	LHLD	VAR_HIPTR			; GO TO TOP OF VAR AREA
	
	PUSH	H
	
	MOV	M,B				; WRITE TAG[0]
	INX	H				; HL++
	MOV	M,C				; WRITE TAG[1]
	INX	H				; HL++
	
	; FILL THE REST WITH ZEROS
	MVI	M,0				
	INX	H
	MVI	M,0
	INX	H
	MVI	M,0
	INX	H
	
	SHLD	VAR_HIPTR			; NEW TOP OF VAR AREA

	POP	H				; GET BACK ADDRESS OF NEW VAR
	RET


;*********************************************************
;* VAR_INTERNALGET:  	SEARCH FOR VARIABLE, SETS HL
;*			IF FOUND, ELSE 0x0000
;*			INPUT: TAG IN BC
VAR_INTERNALGET::
	PUSH	D
	
	LHLD	VAR_HIPTR			; TOP OF VAR PTR IN HL
	XCHG					; SWAP HL<->DE
	LHLD	VAR_LOPTR			; DE = BOTTOM OF VAR MEM

LOOP:	
	; CHECK IF WE GOT TO TOP OF VAR MEMORY
	MOV	A,E				; LO BYTE IN ACC
	CMP	L				; COMPARE WITH LO CURR POS
	JNZ	SKIP

	MOV	A,D				; HI BYTE IN ACC
	CMP	H				; COMPARE WITH HI CURR POS 
	JNZ	SKIP

	; EQUAL
	LXI	H,0				; RETURN 0
	POP	D
	RET
	
SKIP:
	MOV	A,B				; TAG[0] IN ACC
	CMP	M				; CHECK WITH CURR VAR
	INX	H				; HL++
	JNZ	PLUS4
	
	MOV	A,C				; TAG[1] IN ACC
	CMP	M				; CHECK WITH CURR VAR
	INX	H				; HL++
	JNZ	PLUS3				
	
	; FOUND IT
	DCX	H				; GO BACK TO BEGINNING
	DCX	H				; OF VAR 
	POP	D
	RET
	
PLUS4:	
	INX	H
PLUS3:
	INX	H
	INX	H
	INX	H
	JMP	LOOP

.if DEBUG
VAR_DUMPVARS::
	PUSH	B
	PUSH	D
	PUSH	H
	
	LHLD	VAR_HIPTR
	XCHG
	LHLD	VAR_LOPTR
	
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

	; PRINT VARIABLE NAME
	MOV	B,M				; READ TAG
	INX	H				; IN BC
	MOV	C,M
	INX	H
	
	PUSH	H
	LXI	H,VAR_TEMPSTR			; DEST FOR STRING NAME
	CALL	C_TAG2NAME			; CONVERT TAG TO STRING
	CALL	IO_PUTS				; PRINT IT
	
	MVI	A,' 
	CALL	IO_PUTC
	
	POP	H

	MOV	A,B				; CHECK VARIABLE TYPE
	ORA	A
	JP	3$

	; STRING
	PUSH	D
	
	MOV	B,M				; READ SIZE IN B
	INX	H
	
	MOV	E,M				; READ STR PTR
	INX	H
	
	MOV	D,M
	INX	H

	PUSH	H
	
	XCHG
	MVI	A,'(
	CALL	IO_PUTC
	
	CALL	IO_PUTHLHEX
	
	MVI	A,')
	CALL	IO_PUTC
	
	MVI	A,' 
	CALL	IO_PUTC

	MVI	A,'"
	CALL	IO_PUTC
	
	CALL	IO_PUTSN

	MVI	A,'"
	CALL	IO_PUTC

	XCHG
	
	CALL	IO_PUTCR
	
	POP	H
	POP	D
	
	JMP	1$
	
3$:	; INTEGER
	
	MVI	A,' 
	CALL	IO_PUTC
	
	MOV	A,M				; READ LO BYTE (VALUE)
	STA	INT_ACC0
	INX	H
	MOV	A,M				; READ HI BYTE (VALUE)
	STA	INT_ACC0+1
	INX	H
	INX	H
		
	PUSH	H
	
	CALL	INT_ITOA
	CALL	IO_PUTS
	POP	H

	CALL	IO_PUTCR
	
	JMP	1$

.endif

;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

VAR_TEMP1::		.ds	4		; TEMPORARY VARIABLE
VAR_TEMP2::		.ds	4		; TEMPORARY VARIABLE
VAR_TEMP3::		.ds	4		; TEMPORARY VARIABLE

VAR_LOPTR::		.ds	2		; BOTTOM OF VAR MEMORY
VAR_HIPTR::		.ds	2		; TOP OF VAR MEMORY

VAR_TEMPSIZE:		.ds	1		; USED BY SET

.if DEBUG
VAR_TEMPSTR:		.ds	4		; USED BY DUMPVARS
.endif
