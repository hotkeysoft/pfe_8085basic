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
;* STR_COPY:	COPY STRING (NULL TERMINATED)
;*		SOURCE:	DE
;*		DEST: 	HL
STR_COPY::
	PUSH	D
	PUSH	H

1$:
	LDAX	D				; SOURCE IN ACC
	ORA	A				; CHECK IS EOS
	MOV	M,A				; COPY TO DEST
	JZ	2$				; QUIT IF EOS
	
	INX	D				; SOURCE++
	INX	H				; DEST++
	JMP	1$				; LOOP
	
2$:	
	POP	H
	POP	D
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
