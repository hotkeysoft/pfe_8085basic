// CPU8080.cpp: implementation of the CCPU8080 class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "CPU8080.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CCPU8080::CCPU8080(CMemory &memory, CPorts &ports) 
	:	CCPU(memory),
		m_ports(ports)
{
	m_opcodesTable[0XCE] = (OPCodeFunction)ACI;

	m_opcodesTable[0210] = (OPCodeFunction)ADCr;	// B
	m_opcodesTable[0211] = (OPCodeFunction)ADCr;	// C
	m_opcodesTable[0212] = (OPCodeFunction)ADCr;	// D
	m_opcodesTable[0213] = (OPCodeFunction)ADCr;	// E
	m_opcodesTable[0214] = (OPCodeFunction)ADCr;	// H
	m_opcodesTable[0215] = (OPCodeFunction)ADCr;	// L
	m_opcodesTable[0216] = (OPCodeFunction)ADCm;	// m
	m_opcodesTable[0217] = (OPCodeFunction)ADCr;	// A

	m_opcodesTable[0200] = (OPCodeFunction)ADDr;	// B
	m_opcodesTable[0201] = (OPCodeFunction)ADDr;	// C
	m_opcodesTable[0202] = (OPCodeFunction)ADDr;	// D
	m_opcodesTable[0203] = (OPCodeFunction)ADDr;	// E
	m_opcodesTable[0204] = (OPCodeFunction)ADDr;	// H
	m_opcodesTable[0205] = (OPCodeFunction)ADDr;	// L
	m_opcodesTable[0206] = (OPCodeFunction)ADDm;	// m
	m_opcodesTable[0207] = (OPCodeFunction)ADDr;	// A

	m_opcodesTable[0XC6] = (OPCodeFunction)ADI;

	m_opcodesTable[0240] = (OPCodeFunction)ANAr;	// B
	m_opcodesTable[0241] = (OPCodeFunction)ANAr;	// C
	m_opcodesTable[0242] = (OPCodeFunction)ANAr;	// D
	m_opcodesTable[0243] = (OPCodeFunction)ANAr;	// E
	m_opcodesTable[0244] = (OPCodeFunction)ANAr;	// H
	m_opcodesTable[0245] = (OPCodeFunction)ANAr;	// L
	m_opcodesTable[0246] = (OPCodeFunction)ANAm;	// m
	m_opcodesTable[0247] = (OPCodeFunction)ANAr;	// A

	m_opcodesTable[0XE6] = (OPCodeFunction)ANI;

	m_opcodesTable[0XCD] = (OPCodeFunction)CALL;
	m_opcodesTable[0XDC] = (OPCodeFunction)CC;
	m_opcodesTable[0XFC] = (OPCodeFunction)CM;
	m_opcodesTable[0X2F] = (OPCodeFunction)CMA;
	m_opcodesTable[0X3F] = (OPCodeFunction)CMC;

	m_opcodesTable[0270] = (OPCodeFunction)CMPr;	// B
	m_opcodesTable[0271] = (OPCodeFunction)CMPr;	// C
	m_opcodesTable[0272] = (OPCodeFunction)CMPr;	// D
	m_opcodesTable[0273] = (OPCodeFunction)CMPr;	// E
	m_opcodesTable[0274] = (OPCodeFunction)CMPr;	// H
	m_opcodesTable[0275] = (OPCodeFunction)CMPr;	// L
	m_opcodesTable[0276] = (OPCodeFunction)CMPm;	// m
	m_opcodesTable[0277] = (OPCodeFunction)CMPr;	// A

	m_opcodesTable[0XD4] = (OPCodeFunction)CNC;
	m_opcodesTable[0XC4] = (OPCodeFunction)CNZ;
	m_opcodesTable[0XE4] = (OPCodeFunction)CP;
	m_opcodesTable[0XEC] = (OPCodeFunction)CPE;
	m_opcodesTable[0XFE] = (OPCodeFunction)CPI;
	m_opcodesTable[0XE4] = (OPCodeFunction)CPO;
	m_opcodesTable[0XCC] = (OPCodeFunction)CZ;
//	m_opcodesTable[0X27] = (OPCodeFunction)DAA;
	m_opcodesTable[0X09] = (OPCodeFunction)DADb;
	m_opcodesTable[0X19] = (OPCodeFunction)DADd;
	m_opcodesTable[0X29] = (OPCodeFunction)DADh;
	m_opcodesTable[0X39] = (OPCodeFunction)DADsp;

	m_opcodesTable[0005] = (OPCodeFunction)DCRr;	// B
	m_opcodesTable[0015] = (OPCodeFunction)DCRr;	// C
	m_opcodesTable[0025] = (OPCodeFunction)DCRr;	// D
	m_opcodesTable[0035] = (OPCodeFunction)DCRr;	// E
	m_opcodesTable[0045] = (OPCodeFunction)DCRr;	// H
	m_opcodesTable[0055] = (OPCodeFunction)DCRr;	// L
	m_opcodesTable[0065] = (OPCodeFunction)DCRm;	// m
	m_opcodesTable[0075] = (OPCodeFunction)DCRr;	// A
	
	m_opcodesTable[0X0B] = (OPCodeFunction)DCXb;
	m_opcodesTable[0X1B] = (OPCodeFunction)DCXd;
	m_opcodesTable[0X2B] = (OPCodeFunction)DCXh;
	m_opcodesTable[0X3B] = (OPCodeFunction)DCXsp;
//	m_opcodesTable[0XF3] = (OPCodeFunction)DI;
//	m_opcodesTable[0XFB] = (OPCodeFunction)EI;
	m_opcodesTable[0XDB] = (OPCodeFunction)IN;

	m_opcodesTable[0004] = (OPCodeFunction)INRr;	// B
	m_opcodesTable[0014] = (OPCodeFunction)INRr;	// C
	m_opcodesTable[0024] = (OPCodeFunction)INRr;	// D
	m_opcodesTable[0034] = (OPCodeFunction)INRr;	// E
	m_opcodesTable[0044] = (OPCodeFunction)INRr;	// H
	m_opcodesTable[0054] = (OPCodeFunction)INRr;	// L
	m_opcodesTable[0064] = (OPCodeFunction)INRm;	// m
	m_opcodesTable[0074] = (OPCodeFunction)INRr;	// A

	m_opcodesTable[0X03] = (OPCodeFunction)INXb;
	m_opcodesTable[0X13] = (OPCodeFunction)INXd;
	m_opcodesTable[0X23] = (OPCodeFunction)INXh;
	m_opcodesTable[0X33] = (OPCodeFunction)INXsp;
	m_opcodesTable[0XC3] = (OPCodeFunction)JMP;
	m_opcodesTable[0XDA] = (OPCodeFunction)JC;
	m_opcodesTable[0XFA] = (OPCodeFunction)JM;
	m_opcodesTable[0XD2] = (OPCodeFunction)JNC;
	m_opcodesTable[0XC2] = (OPCodeFunction)JNZ;
	m_opcodesTable[0XF2] = (OPCodeFunction)JP;
	m_opcodesTable[0XEA] = (OPCodeFunction)JPE;
	m_opcodesTable[0XE2] = (OPCodeFunction)JPO;
	m_opcodesTable[0XCA] = (OPCodeFunction)JZ;
	m_opcodesTable[0X3A] = (OPCodeFunction)LDA;
	m_opcodesTable[0X0A] = (OPCodeFunction)LDAXb;
	m_opcodesTable[0X1A] = (OPCodeFunction)LDAXd;
	m_opcodesTable[0X2A] = (OPCodeFunction)LHLD;
	m_opcodesTable[0X01] = (OPCodeFunction)LXIb;
	m_opcodesTable[0X11] = (OPCodeFunction)LXId;
	m_opcodesTable[0X21] = (OPCodeFunction)LXIh;
	m_opcodesTable[0X31] = (OPCodeFunction)LXIsp;

	m_opcodesTable[0100] = (OPCodeFunction)MOVrr;	// B,B
	m_opcodesTable[0101] = (OPCodeFunction)MOVrr;	// B,C
	m_opcodesTable[0102] = (OPCodeFunction)MOVrr;	// B,D
	m_opcodesTable[0103] = (OPCodeFunction)MOVrr;	// B,E
	m_opcodesTable[0104] = (OPCodeFunction)MOVrr;	// B,H
	m_opcodesTable[0105] = (OPCodeFunction)MOVrr;	// B,L
	m_opcodesTable[0106] = (OPCodeFunction)MOVrm;	// B,m
	m_opcodesTable[0107] = (OPCodeFunction)MOVrr;	// B,A

	m_opcodesTable[0110] = (OPCodeFunction)MOVrr;	// C,B
	m_opcodesTable[0111] = (OPCodeFunction)MOVrr;	// C,C
	m_opcodesTable[0112] = (OPCodeFunction)MOVrr;	// C,D
	m_opcodesTable[0113] = (OPCodeFunction)MOVrr;	// C,E
	m_opcodesTable[0114] = (OPCodeFunction)MOVrr;	// C,H
	m_opcodesTable[0115] = (OPCodeFunction)MOVrr;	// C,L
	m_opcodesTable[0116] = (OPCodeFunction)MOVrm;	// C,m
	m_opcodesTable[0117] = (OPCodeFunction)MOVrr;	// C,A

	m_opcodesTable[0120] = (OPCodeFunction)MOVrr;	// D,B
	m_opcodesTable[0121] = (OPCodeFunction)MOVrr;	// D,C
	m_opcodesTable[0122] = (OPCodeFunction)MOVrr;	// D,D
	m_opcodesTable[0123] = (OPCodeFunction)MOVrr;	// D,E
	m_opcodesTable[0124] = (OPCodeFunction)MOVrr;	// D,H
	m_opcodesTable[0125] = (OPCodeFunction)MOVrr;	// D,L
	m_opcodesTable[0126] = (OPCodeFunction)MOVrm;	// D,m
	m_opcodesTable[0127] = (OPCodeFunction)MOVrr;	// D,A

	m_opcodesTable[0130] = (OPCodeFunction)MOVrr;	// E,B
	m_opcodesTable[0131] = (OPCodeFunction)MOVrr;	// E,C
	m_opcodesTable[0132] = (OPCodeFunction)MOVrr;	// E,D
	m_opcodesTable[0133] = (OPCodeFunction)MOVrr;	// E,E
	m_opcodesTable[0134] = (OPCodeFunction)MOVrr;	// E,H
	m_opcodesTable[0135] = (OPCodeFunction)MOVrr;	// E,L
	m_opcodesTable[0136] = (OPCodeFunction)MOVrm;	// E,m
	m_opcodesTable[0137] = (OPCodeFunction)MOVrr;	// E,A

	m_opcodesTable[0140] = (OPCodeFunction)MOVrr;	// H,B
	m_opcodesTable[0141] = (OPCodeFunction)MOVrr;	// H,C
	m_opcodesTable[0142] = (OPCodeFunction)MOVrr;	// H,D
	m_opcodesTable[0143] = (OPCodeFunction)MOVrr;	// H,E
	m_opcodesTable[0144] = (OPCodeFunction)MOVrr;	// H,H
	m_opcodesTable[0145] = (OPCodeFunction)MOVrr;	// H,L
	m_opcodesTable[0146] = (OPCodeFunction)MOVrm;	// H,m
	m_opcodesTable[0147] = (OPCodeFunction)MOVrr;	// H,A

	m_opcodesTable[0150] = (OPCodeFunction)MOVrr;	// L,B
	m_opcodesTable[0151] = (OPCodeFunction)MOVrr;	// L,C
	m_opcodesTable[0152] = (OPCodeFunction)MOVrr;	// L,D
	m_opcodesTable[0153] = (OPCodeFunction)MOVrr;	// L,E
	m_opcodesTable[0154] = (OPCodeFunction)MOVrr;	// L,H
	m_opcodesTable[0155] = (OPCodeFunction)MOVrr;	// L,L
	m_opcodesTable[0156] = (OPCodeFunction)MOVrm;	// L,m
	m_opcodesTable[0157] = (OPCodeFunction)MOVrr;	// L,A

	m_opcodesTable[0160] = (OPCodeFunction)MOVmr;	// m,B
	m_opcodesTable[0161] = (OPCodeFunction)MOVmr;	// m,C
	m_opcodesTable[0162] = (OPCodeFunction)MOVmr;	// m,D
	m_opcodesTable[0163] = (OPCodeFunction)MOVmr;	// m,E
	m_opcodesTable[0164] = (OPCodeFunction)MOVmr;	// m,H
	m_opcodesTable[0165] = (OPCodeFunction)MOVmr;	// m,L
	m_opcodesTable[0166] = (OPCodeFunction)HLT;		// HLT
	m_opcodesTable[0167] = (OPCodeFunction)MOVmr;	// m,A

	m_opcodesTable[0170] = (OPCodeFunction)MOVrr;	// A,B
	m_opcodesTable[0171] = (OPCodeFunction)MOVrr;	// A,C
	m_opcodesTable[0172] = (OPCodeFunction)MOVrr;	// A,D
	m_opcodesTable[0173] = (OPCodeFunction)MOVrr;	// A,E
	m_opcodesTable[0174] = (OPCodeFunction)MOVrr;	// A,H
	m_opcodesTable[0175] = (OPCodeFunction)MOVrr;	// A,L
	m_opcodesTable[0176] = (OPCodeFunction)MOVrm;	// A,m
	m_opcodesTable[0177] = (OPCodeFunction)MOVrr;	// A,A

	m_opcodesTable[0006] = (OPCodeFunction)MVIr;	// B
	m_opcodesTable[0016] = (OPCodeFunction)MVIr;	// C
	m_opcodesTable[0026] = (OPCodeFunction)MVIr;	// D
	m_opcodesTable[0036] = (OPCodeFunction)MVIr;	// E
	m_opcodesTable[0046] = (OPCodeFunction)MVIr;	// H
	m_opcodesTable[0056] = (OPCodeFunction)MVIr;	// L
	m_opcodesTable[0066] = (OPCodeFunction)MVIm;	// m
	m_opcodesTable[0076] = (OPCodeFunction)MVIr;	// A

	m_opcodesTable[0X00] = (OPCodeFunction)NOP;

	m_opcodesTable[0260] = (OPCodeFunction)ORAr;	// B
	m_opcodesTable[0261] = (OPCodeFunction)ORAr;	// C
	m_opcodesTable[0262] = (OPCodeFunction)ORAr;	// D
	m_opcodesTable[0263] = (OPCodeFunction)ORAr;	// E
	m_opcodesTable[0264] = (OPCodeFunction)ORAr;	// H
	m_opcodesTable[0265] = (OPCodeFunction)ORAr;	// L
	m_opcodesTable[0266] = (OPCodeFunction)ORAm;	// m
	m_opcodesTable[0267] = (OPCodeFunction)ORAr;	// A

	m_opcodesTable[0XF6] = (OPCodeFunction)ORI;
	m_opcodesTable[0XD3] = (OPCodeFunction)OUT;
	m_opcodesTable[0XE9] = (OPCodeFunction)PCHL;
	m_opcodesTable[0XC1] = (OPCodeFunction)POPb;
	m_opcodesTable[0XD1] = (OPCodeFunction)POPd;
	m_opcodesTable[0XE1] = (OPCodeFunction)POPh;
	m_opcodesTable[0XF1] = (OPCodeFunction)POPpsw;
	m_opcodesTable[0XC5] = (OPCodeFunction)PUSHb;
	m_opcodesTable[0XD5] = (OPCodeFunction)PUSHd;
	m_opcodesTable[0XE5] = (OPCodeFunction)PUSHh;
	m_opcodesTable[0XF5] = (OPCodeFunction)PUSHpsw;

	m_opcodesTable[0X17] = (OPCodeFunction)RAL;
	m_opcodesTable[0X1F] = (OPCodeFunction)RAR;
	m_opcodesTable[0XC9] = (OPCodeFunction)RET;
	m_opcodesTable[0XD8] = (OPCodeFunction)RC;
//	m_opcodesTable[0X20] = (OPCodeFunction)RIM;		//8085
	m_opcodesTable[0XF8] = (OPCodeFunction)RM;
	m_opcodesTable[0XD0] = (OPCodeFunction)RNC;
	m_opcodesTable[0XC0] = (OPCodeFunction)RNZ;
	m_opcodesTable[0XF0] = (OPCodeFunction)RP;
	m_opcodesTable[0XE8] = (OPCodeFunction)RPE;
	m_opcodesTable[0XE0] = (OPCodeFunction)RPO;
	m_opcodesTable[0XC8] = (OPCodeFunction)RZ;
	m_opcodesTable[0X07] = (OPCodeFunction)RLC;
	m_opcodesTable[0X0F] = (OPCodeFunction)RRC;

	m_opcodesTable[0307] = (OPCodeFunction)RST;
	m_opcodesTable[0317] = (OPCodeFunction)RST;
	m_opcodesTable[0327] = (OPCodeFunction)RST;
	m_opcodesTable[0337] = (OPCodeFunction)RST;
	m_opcodesTable[0347] = (OPCodeFunction)RST;
	m_opcodesTable[0357] = (OPCodeFunction)RST;
	m_opcodesTable[0367] = (OPCodeFunction)RST;
	m_opcodesTable[0377] = (OPCodeFunction)RST;

	m_opcodesTable[0230] = (OPCodeFunction)SBBr;	// B
	m_opcodesTable[0231] = (OPCodeFunction)SBBr;	// C
	m_opcodesTable[0232] = (OPCodeFunction)SBBr;	// D
	m_opcodesTable[0233] = (OPCodeFunction)SBBr;	// E
	m_opcodesTable[0234] = (OPCodeFunction)SBBr;	// H
	m_opcodesTable[0235] = (OPCodeFunction)SBBr;	// L
	m_opcodesTable[0236] = (OPCodeFunction)SBBm;	// m
	m_opcodesTable[0237] = (OPCodeFunction)SBBr;	// A

	m_opcodesTable[0XDE] = (OPCodeFunction)SBI;
	m_opcodesTable[0X22] = (OPCodeFunction)SHLD;
//	m_opcodesTable[0X30] = (OPCodeFunction)SIM;		// 8085
	m_opcodesTable[0XF9] = (OPCodeFunction)SPHL;
	m_opcodesTable[0X32] = (OPCodeFunction)STA;
	m_opcodesTable[0X02] = (OPCodeFunction)STAXb;
	m_opcodesTable[0X12] = (OPCodeFunction)STAXd;
	m_opcodesTable[0X37] = (OPCodeFunction)STC;

	m_opcodesTable[0220] = (OPCodeFunction)SUBr;	// B
	m_opcodesTable[0221] = (OPCodeFunction)SUBr;	// C
	m_opcodesTable[0222] = (OPCodeFunction)SUBr;	// D
	m_opcodesTable[0223] = (OPCodeFunction)SUBr;	// E
	m_opcodesTable[0224] = (OPCodeFunction)SUBr;	// H
	m_opcodesTable[0225] = (OPCodeFunction)SUBr;	// L
	m_opcodesTable[0226] = (OPCodeFunction)SUBm;	// m
	m_opcodesTable[0227] = (OPCodeFunction)SUBr;	// A

	m_opcodesTable[0XD6] = (OPCodeFunction)SUI;
	m_opcodesTable[0XEB] = (OPCodeFunction)XCHG;

	m_opcodesTable[0250] = (OPCodeFunction)XRAr;	// B
	m_opcodesTable[0251] = (OPCodeFunction)XRAr;	// C
	m_opcodesTable[0252] = (OPCodeFunction)XRAr;	// D
	m_opcodesTable[0253] = (OPCodeFunction)XRAr;	// E
	m_opcodesTable[0254] = (OPCodeFunction)XRAr;	// H
	m_opcodesTable[0255] = (OPCodeFunction)XRAr;	// L
	m_opcodesTable[0256] = (OPCodeFunction)XRAm;	// m
	m_opcodesTable[0257] = (OPCodeFunction)XRAr;	// A

	m_opcodesTable[0XEE] = (OPCodeFunction)XRI;
	m_opcodesTable[0XE3] = (OPCodeFunction)XTHL;
}

CCPU8080::~CCPU8080()
{

}

void CCPU8080::Reset()
{
	CCPU::Reset();

	regA = 0;
	regB = 0;
	regC = 0;
	regD = 0;
	regE = 0;
	regH = 0;
	regL = 0;

	regSP = 0;
	flags = 0;
}

void CCPU8080::Dump()
{
	fprintf(stderr, "AF = %X %X\tCY = %c\n", regA, flags, getFlag(CY_FLAG)?'1':'0');
	fprintf(stderr, "BC = %X %X\tP  = %c\n", regB, regC, getFlag(P_FLAG)?'1':'0');
	fprintf(stderr, "DE = %X %X\tAC = %c\n", regD, regE, getFlag(AC_FLAG)?'1':'0');
	fprintf(stderr, "HL = %X %X\tZ  = %c\n", regH, regL, getFlag(Z_FLAG)?'1':'0');
	fprintf(stderr, "SP = %X   \tS  = %c\n", regSP, getFlag(S_FLAG)?'1':'0');
	fprintf(stderr, "PC = %X\n", m_programCounter);
	fprintf(stderr, "\n");
}


BYTE &CCPU8080::getRegL(BYTE opcode)
{
	opcode &= 070;

	switch(opcode)
	{
	case 000:	return regB;
	case 010:	return regC;
	case 020:	return regD;
	case 030:	return regE;
	case 040:	return regH;
	case 050:	return regL;
	case 070:	return regA;

	default:
		fprintf(stderr, "FATAL: reg flag = mem\n");
	}

	return dummy;
}

BYTE &CCPU8080::getRegR(BYTE opcode)
{
	opcode &= 007;

	switch(opcode)
	{
	case 000:	return regB;
	case 001:	return regC;
	case 002:	return regD;
	case 003:	return regE;
	case 004:	return regH;
	case 005:	return regL;
	case 007:	return regA;

	default:
		fprintf(stderr, "FATAL: reg flag = mem\n");
	}

	return dummy;
}

void CCPU8080::adjustParity(BYTE data)
{
	setFlag(P_FLAG, isParityEven(data));
}

void CCPU8080::adjustSign(BYTE data)
{
	setFlag(S_FLAG, (data&128)?true:false);
}

void CCPU8080::adjustZero(BYTE data)
{
	setFlag(Z_FLAG, (data==0));
}

void CCPU8080::MOVrr(BYTE opcode)
{
	getRegL(opcode) = getRegR(opcode);

	m_timeTicks += 4;
	m_programCounter++;
}

void CCPU8080::MOVmr(BYTE opcode)
{
	m_memory.Write(getHL(), getRegR(opcode));

	m_timeTicks += 7;
	m_programCounter++;
}

void CCPU8080::MOVrm(BYTE opcode)
{

	m_memory.Read(getHL(), getRegL(opcode));

	m_timeTicks += 7;
	m_programCounter++;
}

void CCPU8080::MVIr(BYTE opcode)
{
	m_memory.Read(m_programCounter+1, getRegL(opcode));

	m_timeTicks += 7;
	m_programCounter+=2;
}

void CCPU8080::MVIm(BYTE opcode)
{
	BYTE value;
	m_memory.Read(m_programCounter+1, value);
	m_memory.Write(getHL(), value);

	m_timeTicks += 10;
	m_programCounter+=2;
}

void CCPU8080::LXIb(BYTE opcode)
{
	m_memory.Read(m_programCounter+1, regC);
	m_memory.Read(m_programCounter+2, regB);

	m_timeTicks += 10;
	m_programCounter+=3;
}

void CCPU8080::LXId(BYTE opcode)
{
	m_memory.Read(m_programCounter+1, regE);
	m_memory.Read(m_programCounter+2, regD);

	m_timeTicks += 10;
	m_programCounter+=3;
}

void CCPU8080::LXIh(BYTE opcode)
{
	m_memory.Read(m_programCounter+1, regL);
	m_memory.Read(m_programCounter+2, regH);

	m_timeTicks += 10;
	m_programCounter+=3;
}

void CCPU8080::STAXb(BYTE opcode)
{
	m_memory.Write(getWord(regB, regC), regA);

	m_timeTicks += 7;
	m_programCounter++;
}

void CCPU8080::STAXd(BYTE opcode)
{
	m_memory.Write(getWord(regD, regE), regA);

	m_timeTicks += 7;
	m_programCounter++;
}

void CCPU8080::LDAXb(BYTE opcode)
{
	m_memory.Read(getWord(regB, regC), regA);
	
	m_timeTicks += 7;
	m_programCounter++;
}
void CCPU8080::LDAXd(BYTE opcode)
{
	m_memory.Read(getWord(regD, regE), regA);
	
	m_timeTicks += 7;
	m_programCounter++;
}

void CCPU8080::STA(BYTE opcode)
{
	BYTE valH, valL;

	m_memory.Read(m_programCounter+1, valL);
	m_memory.Read(m_programCounter+2, valH);

	m_memory.Write(getWord(valH, valL), regA);

	m_timeTicks += 13;
	m_programCounter+=3;
}

void CCPU8080::LDA(BYTE opcode)
{
	BYTE valH, valL;

	m_memory.Read(m_programCounter+1, valL);
	m_memory.Read(m_programCounter+2, valH);

	m_memory.Read(getWord(valH, valL), regA);

	m_timeTicks += 13;
	m_programCounter+=3;
}

void CCPU8080::SHLD(BYTE opcode)
{
	BYTE valH, valL;

	m_memory.Read(m_programCounter+1, valL);
	m_memory.Read(m_programCounter+2, valH);

	m_memory.Write(getWord(valH, valL), regL);
	m_memory.Write(getWord(valH, valL)+1, regH);

	m_timeTicks += 16;
	m_programCounter+=3;
}

void CCPU8080::LHLD(BYTE opcode)
{
	BYTE valH, valL;

	m_memory.Read(m_programCounter+1, valL);
	m_memory.Read(m_programCounter+2, valH);

	m_memory.Read(getWord(valH, valL), regL);
	m_memory.Read(getWord(valH, valL)+1, regH);

	m_timeTicks += 16;
	m_programCounter+=3;
}

void CCPU8080::XCHG(BYTE opcode)
{
	BYTE oldH, oldL;

	oldL = regL; oldH = regH;
	
	regL = regE; regH = regD;
	regE = oldL; regD = oldH;

	m_timeTicks += 4;
	m_programCounter++;
}

void CCPU8080::push(BYTE h, BYTE l)
{
	regSP--;
	m_memory.Write(regSP, h);
	regSP--;
	m_memory.Write(regSP, l);

	m_timeTicks += 12;
	m_programCounter++;
}

void CCPU8080::PUSHb(BYTE opcode)
{
	push(regB, regC);
}

void CCPU8080::PUSHd(BYTE opcode)
{
	push(regD, regE);
}

void CCPU8080::PUSHh(BYTE opcode)
{
	push(regH, regL);
}

void CCPU8080::PUSHpsw(BYTE opcode)
{
	push(regA, flags);
}

void CCPU8080::pop(BYTE &h, BYTE &l)
{
	m_memory.Read(regSP, l);
	regSP++;
	m_memory.Read(regSP, h);
	regSP++;

	m_timeTicks += 12;
	m_programCounter++;
}

void CCPU8080::POPb(BYTE opcode)
{
	pop(regB, regC);
}

void CCPU8080::POPd(BYTE opcode)
{
	pop(regD, regE);
}

void CCPU8080::POPh(BYTE opcode)
{
	pop(regH, regL);
}

void CCPU8080::POPpsw(BYTE opcode)
{
	pop(regA, flags);
}

void CCPU8080::XTHL(BYTE opcode)
{
	BYTE oldH, oldL;

	oldL = regL; oldH = regH;
	
	m_memory.Read(regSP, regL);
	m_memory.Read(regSP+1, regH);
	
	m_memory.Write(regSP, oldL);
	m_memory.Write(regSP+1, oldH);

	m_timeTicks += 16;
	m_programCounter++;
}

void CCPU8080::SPHL(BYTE opcode)
{
	regSP = getHL();

	m_timeTicks += 6;
	m_programCounter++;
}

void CCPU8080::LXIsp(BYTE opcode)
{
	BYTE valH, valL;

	m_memory.Read(m_programCounter+1, valL);
	m_memory.Read(m_programCounter+2, valH);

	regSP = getWord(valH, valL);

	m_timeTicks += 10;
	m_programCounter+=3;
}

void CCPU8080::INXsp(BYTE opcode)
{
	regSP++;

	m_timeTicks += 6;
	m_programCounter++;
}

void CCPU8080::DCXsp(BYTE opcode)
{
	regSP--;

	m_timeTicks += 6;
	m_programCounter++;
}

void CCPU8080::jumpIF(bool condition, int timeT)
{
	if (condition == true)
	{
		BYTE valH, valL;

		m_memory.Read(m_programCounter+1, valL);
		m_memory.Read(m_programCounter+2, valH);

		m_timeTicks += timeT;
		m_programCounter = getWord(valH, valL);
	}
	else
	{
		m_timeTicks += timeT;
		m_programCounter += 3;
	}
}

void CCPU8080::JMP(BYTE opcode)
{
	jumpIF(true, 7);
}

void CCPU8080::JC(BYTE opcode)
{
	jumpIF(getFlag(CY_FLAG) == true, 10);
}

void CCPU8080::JNC(BYTE opcode)
{
	jumpIF(getFlag(CY_FLAG) == false, 10);
}

void CCPU8080::JZ(BYTE opcode)
{
	jumpIF(getFlag(Z_FLAG) == true, 10);
}

void CCPU8080::JNZ(BYTE opcode)
{
	jumpIF(getFlag(Z_FLAG) == false, 10);
}

void CCPU8080::JP(BYTE opcode)
{
	jumpIF(getFlag(S_FLAG) == false, 10);
}

void CCPU8080::JM(BYTE opcode)
{
	jumpIF(getFlag(S_FLAG) == true, 10);
}

void CCPU8080::JPE(BYTE opcode)
{
	jumpIF(getFlag(P_FLAG) == true, 10);
}

void CCPU8080::JPO(BYTE opcode)
{
	jumpIF(getFlag(P_FLAG) == false, 10);
}

void CCPU8080::PCHL(BYTE opcode)
{
	m_timeTicks += 6;
	m_programCounter = getHL();
}

void CCPU8080::callIF(bool condition)
{
	if (condition == true)
	{
		BYTE valL, valH;
		m_memory.Read(m_programCounter+1, valL);
		m_memory.Read(m_programCounter+2, valH);
		
		regSP--;
		m_memory.Write(regSP, getHByte(m_programCounter+3));
		regSP--;
		m_memory.Write(regSP, getLByte(m_programCounter+3));

		m_timeTicks += 18;
		m_programCounter = getWord(valH, valL);
	}
	else
	{
		m_timeTicks += 9;
		m_programCounter+=3;
	}
}

void CCPU8080::CALL(BYTE opcode)
{
	callIF(true);
}

void CCPU8080::CC(BYTE opcode)
{
	callIF(getFlag(CY_FLAG) == true);
}

void CCPU8080::CNC(BYTE opcode)
{
	callIF(getFlag(CY_FLAG) == false);
}

void CCPU8080::CZ(BYTE opcode)
{
	callIF(getFlag(Z_FLAG) == true);
}

void CCPU8080::CNZ(BYTE opcode)
{
	callIF(getFlag(Z_FLAG) == false);
}

void CCPU8080::CP(BYTE opcode)
{
	callIF(getFlag(S_FLAG) == false);
}

void CCPU8080::CM(BYTE opcode)
{
	callIF(getFlag(S_FLAG) == true);
}

void CCPU8080::CPE(BYTE opcode)
{
	callIF(getFlag(P_FLAG) == true);
}

void CCPU8080::CPO(BYTE opcode)
{
	callIF(getFlag(P_FLAG) == false);
}

void CCPU8080::retIF(bool condition, int timeT)
{
	if (condition == true)
	{
		BYTE valL, valH;

		m_memory.Read(regSP, valL);
		regSP++;
		m_memory.Read(regSP, valH);
		regSP++;		

		m_timeTicks += timeT;
		m_programCounter = getWord(valH, valL);
	}
	else
	{
		m_timeTicks += 6;
		m_programCounter++;
	}
}

void CCPU8080::RET(BYTE opcode)
{
	retIF(true, 10);
}

void CCPU8080::RC(BYTE opcode)
{
	retIF(getFlag(CY_FLAG) == true, 12);
}

void CCPU8080::RNC(BYTE opcode)
{
	retIF(getFlag(CY_FLAG) == false, 12);
}

void CCPU8080::RZ(BYTE opcode)
{
	retIF(getFlag(Z_FLAG) == true, 12);
}

void CCPU8080::RNZ(BYTE opcode)
{
	retIF(getFlag(Z_FLAG) == false, 12);
}

void CCPU8080::RP(BYTE opcode)
{
	retIF(getFlag(S_FLAG) == false, 12);
}

void CCPU8080::RM(BYTE opcode)
{
	retIF(getFlag(S_FLAG) == true, 12);
}

void CCPU8080::RPE(BYTE opcode)
{
	retIF(getFlag(P_FLAG) == true, 12);
}

void CCPU8080::RPO(BYTE opcode)
{
	retIF(getFlag(P_FLAG) == true, 12);
}

void CCPU8080::RST(BYTE opcode)
{
	regSP--;
	m_memory.Write(regSP, getHByte(m_programCounter));
	regSP--;
	m_memory.Write(regSP, getLByte(m_programCounter));

	WORD vector;

	opcode &= 070;

	switch(opcode)
	{
	case 000:	vector = 0x0;
	case 010:	vector = 0x8;
	case 020:	vector = 0x10;
	case 030:	vector = 0x18;
	case 040:	vector = 0x20;
	case 050:	vector = 0x28;
	case 060:	vector = 0x30;
	case 070:	vector = 0x38;
	}

	m_timeTicks += 12;
	m_programCounter = vector;
}

void CCPU8080::INRr(BYTE opcode)
{
	BYTE &reg = getRegL(opcode);
	reg++;

	adjustParity(reg);
	adjustZero(reg);
	adjustSign(reg);
	setFlag(AC_FLAG, (reg&0x0F)==0);

	m_timeTicks += 4;
	m_programCounter++;
}

void CCPU8080::DCRr(BYTE opcode)
{
	BYTE &reg = getRegL(opcode);
	reg--;

	adjustParity(reg);
	adjustZero(reg);
	adjustSign(reg);
	setFlag(AC_FLAG, (reg&0x0F)!=0x0F);

	m_timeTicks += 4;
	m_programCounter++;
}

void CCPU8080::INRm(BYTE opcode)
{
	BYTE value;
	m_memory.Read(getHL(), value);
	value++;
	m_memory.Write(getHL(), value);

	adjustParity(value);
	adjustZero(value);
	adjustSign(value);
	setFlag(AC_FLAG, (value&0x0F)==0);

	m_timeTicks += 10;
	m_programCounter++;
}

void CCPU8080::DCRm(BYTE opcode)
{
	BYTE value;
	m_memory.Read(getHL(), value);
	value--;
	m_memory.Write(getHL(), value);

	adjustParity(value);
	adjustZero(value);
	adjustSign(value);
	setFlag(AC_FLAG, (value&0x0F)!=0x0F);

	m_timeTicks += 10;
	m_programCounter++;
}

void CCPU8080::INXb(BYTE opcode)
{
	WORD value = getWord(regB, regC);
	value++;
	regB = getHByte(value);
	regC = getLByte(value);

	m_timeTicks += 6;
	m_programCounter++;
}

void CCPU8080::INXd(BYTE opcode)
{
	WORD value = getWord(regD, regE);
	value++;
	regD = getHByte(value);
	regE = getLByte(value);

	m_timeTicks += 6;
	m_programCounter++;
}

void CCPU8080::INXh(BYTE opcode)
{
	WORD value = getHL();
	value++;
	regH = getHByte(value);
	regL = getLByte(value);

	m_timeTicks += 6;
	m_programCounter++;
}

void CCPU8080::DCXb(BYTE opcode)
{
	WORD value = getWord(regB, regC);
	value--;
	regB = getHByte(value);
	regC = getLByte(value);

	m_timeTicks += 6;
	m_programCounter++;
}

void CCPU8080::DCXd(BYTE opcode)
{
	WORD value = getWord(regD, regE);
	value--;
	regD = getHByte(value);
	regE = getLByte(value);

	m_timeTicks += 6;
	m_programCounter++;
}

void CCPU8080::DCXh(BYTE opcode)
{
	WORD value = getHL();
	value--;
	regH = getHByte(value);
	regL = getLByte(value);

	m_timeTicks += 6;
	m_programCounter++;
}

void CCPU8080::add(BYTE src, bool carry)
{
	// AC flag
	BYTE loNibble = (regA&0x0F) + (src&0x0F);

	WORD temp = regA + src;
	if (carry)
	{
		temp++;
		loNibble++;
	}

	regA = (BYTE)temp;

	setFlag(CY_FLAG, (temp>0xFF));
	setFlag(AC_FLAG, (loNibble>0x0F));
	adjustSign(regA);
	adjustZero(regA);
	adjustParity(regA);
}

void CCPU8080::ADDr(BYTE opcode)
{
	add(getRegR(opcode));

	m_timeTicks += 4;
	m_programCounter++;
}

void CCPU8080::ADCr(BYTE opcode)
{
	add(getRegR(opcode), getFlag(CY_FLAG));

	m_timeTicks += 4;
	m_programCounter++;
}

void CCPU8080::ADDm(BYTE opcode)
{
	BYTE value;
	m_memory.Read(getHL(), value);

	add(value);

	m_timeTicks += 7;
	m_programCounter++;
}

void CCPU8080::ADCm(BYTE opcode)
{
	BYTE value;
	m_memory.Read(getHL(), value);

	add(value, getFlag(CY_FLAG));

	m_timeTicks += 7;
	m_programCounter++;
}

void CCPU8080::ADI(BYTE opcode)
{
	BYTE value;
	m_memory.Read(m_programCounter+1, value);

	add(value);

	m_timeTicks += 7;
	m_programCounter+=2;
}

void CCPU8080::ACI(BYTE opcode)
{
	BYTE value;
	m_memory.Read(m_programCounter+1, value);

	add(value, getFlag(CY_FLAG));

	m_timeTicks += 7;
	m_programCounter+=2;
}

void CCPU8080::dad(WORD value)
{
	long hl = getHL();

	hl += value;

	setFlag(CY_FLAG, hl>0xFFFF);

	regH = getHByte(hl);
	regL = getLByte(hl);

	m_timeTicks += 10;
	m_programCounter++;
}

void CCPU8080::DADb(BYTE opcode)
{
	dad(getWord(regB, regC));
}

void CCPU8080::DADd(BYTE opcode)
{
	dad(getWord(regD, regE));
}

void CCPU8080::DADh(BYTE opcode)
{
	dad(getHL());
}

void CCPU8080::DADsp(BYTE opcode)
{
	dad(regSP);
}

void CCPU8080::sub(BYTE src, bool borrow)
{
	// AC flag
	char loNibble = (regA&0x0F) - (src&0x0F);
	
	int temp = regA - src;
	if (borrow)
	{
		temp--;
		loNibble--;
	}

	regA = (WORD)temp;

	setFlag(CY_FLAG, (temp<0));
	setFlag(AC_FLAG, !(loNibble<0));
	adjustSign(regA);
	adjustZero(regA);
	adjustParity(regA);

}

void CCPU8080::SUBr(BYTE opcode)
{
	sub(getRegR(opcode));

	m_timeTicks += 4;
	m_programCounter++;
}

void CCPU8080::SBBr(BYTE opcode)
{
	sub(getRegR(opcode), getFlag(CY_FLAG));

	m_timeTicks += 4;
	m_programCounter++;
}

void CCPU8080::SUBm(BYTE opcode)
{
	BYTE value;
	m_memory.Read(getHL(), value);

	sub(value);

	m_timeTicks += 7;
	m_programCounter++;
}

void CCPU8080::SBBm(BYTE opcode)
{
	BYTE value;
	m_memory.Read(getHL(), value);

	sub(value, getFlag(CY_FLAG));

	m_timeTicks += 7;
	m_programCounter++;
}

void CCPU8080::SUI(BYTE opcode)
{
	BYTE value;
	m_memory.Read(m_programCounter+1, value);

	sub(value);

	m_timeTicks += 7;
	m_programCounter+=2;
}

void CCPU8080::SBI(BYTE opcode)
{
	BYTE value;
	m_memory.Read(m_programCounter+1, value);

	sub(value, getFlag(CY_FLAG));

	m_timeTicks += 7;
	m_programCounter+=2;
}

void CCPU8080::ANAr(BYTE opcode)
{
	regA &= getRegR(opcode);

	adjustSign(regA);
	adjustZero(regA);
	adjustParity(regA);
	setFlag(AC_FLAG, true);				// Must confirm
	setFlag(CY_FLAG, false);

	m_timeTicks += 4;
	m_programCounter++;
}

void CCPU8080::XRAr(BYTE opcode)
{
	regA ^= getRegR(opcode);

	adjustSign(regA);
	adjustZero(regA);
	adjustParity(regA);
	setFlag(AC_FLAG, false);
	setFlag(CY_FLAG, false);

	m_timeTicks += 4;
	m_programCounter++;
}

void CCPU8080::ORAr(BYTE opcode)
{
	regA |= getRegR(opcode);

	adjustSign(regA);
	adjustZero(regA);
	adjustParity(regA);
	setFlag(AC_FLAG, false);
	setFlag(CY_FLAG, false);

	m_timeTicks += 4;
	m_programCounter++;
}

void CCPU8080::cmp(BYTE src)
{
	// AC flag
	char loNibble = (regA&0x0F) - (src&0x0F);
	
	int temp = regA - src;

	setFlag(CY_FLAG, (temp<0));
	setFlag(AC_FLAG, !(loNibble<0));
	adjustSign((WORD)temp);
	adjustZero((WORD)temp);
	adjustParity((WORD)temp);
}

void CCPU8080::CMPr(BYTE opcode)
{
	cmp(getRegR(opcode));

	m_timeTicks += 4;
	m_programCounter++;
}

void CCPU8080::ANAm(BYTE opcode)
{
	BYTE value;
	m_memory.Read(getHL(), value);

	regA &= value;

	adjustSign(regA);
	adjustZero(regA);
	adjustParity(regA);
	setFlag(AC_FLAG, true);			// Must confirm
	setFlag(CY_FLAG, false);

	m_timeTicks += 7;
	m_programCounter++;
}

void CCPU8080::XRAm(BYTE opcode)
{
	BYTE value;
	m_memory.Read(getHL(), value);

	regA ^= value;

	adjustSign(regA);
	adjustZero(regA);
	adjustParity(regA);
	setFlag(AC_FLAG, false);
	setFlag(CY_FLAG, false);

	m_timeTicks += 7;
	m_programCounter++;
}

void CCPU8080::ORAm(BYTE opcode)
{
	BYTE value;
	m_memory.Read(getHL(), value);

	regA |= value;

	adjustSign(regA);
	adjustZero(regA);
	adjustParity(regA);
	setFlag(AC_FLAG, false);
	setFlag(CY_FLAG, false);

	m_timeTicks += 7;
	m_programCounter++;
}

void CCPU8080::CMPm(BYTE opcode)
{
	BYTE value;
	m_memory.Read(getHL(), value);

	cmp(value);

	m_timeTicks += 7;
	m_programCounter++;
}

void CCPU8080::ANI(BYTE opcode)
{
	BYTE value;
	m_memory.Read(m_programCounter+1, value);

	regA &= value;

	adjustSign(regA);
	adjustZero(regA);
	adjustParity(regA);
	setFlag(AC_FLAG, true);			// Must confirm
	setFlag(CY_FLAG, false);

	m_timeTicks += 7;
	m_programCounter+=2;
}

void CCPU8080::XRI(BYTE opcode)
{
	BYTE value;
	m_memory.Read(m_programCounter+1, value);

	regA ^= value;

	adjustSign(regA);
	adjustZero(regA);
	adjustParity(regA);
	setFlag(AC_FLAG, false);
	setFlag(CY_FLAG, false);

	m_timeTicks += 7;
	m_programCounter+=2;
}

void CCPU8080::ORI(BYTE opcode)
{
	BYTE value;
	m_memory.Read(m_programCounter+1, value);

	regA |= value;

	adjustSign(regA);
	adjustZero(regA);
	adjustParity(regA);
	setFlag(AC_FLAG, false);
	setFlag(CY_FLAG, false);

	m_timeTicks += 7;
	m_programCounter+=2;
}

void CCPU8080::CPI(BYTE opcode)
{
	BYTE value;
	m_memory.Read(m_programCounter+1, value);

	cmp(value);

	m_timeTicks += 7;
	m_programCounter+=2;
}

void CCPU8080::RLC(BYTE opcode)
{
	bool msb = (regA & 128)?true:false;

	regA = (regA << 1);
	regA |= (msb?1:0);

	setFlag(CY_FLAG, msb);

	m_timeTicks += 4;
	m_programCounter++;
}

void CCPU8080::RRC(BYTE opcode)
{
	bool lsb = (regA & 1)?true:false;

	regA = (regA >> 1);
	regA &= ~128;
	regA |= (lsb?128:0);

	setFlag(CY_FLAG, lsb);

	m_timeTicks += 4;
	m_programCounter++;
}

void CCPU8080::RAL(BYTE opcode)
{
	bool msb = (regA & 128)?true:false;

	regA = (regA << 1);
	regA |= (getFlag(CY_FLAG)?1:0);

	setFlag(CY_FLAG, msb);

	m_timeTicks += 4;
	m_programCounter++;
}

void CCPU8080::RAR(BYTE opcode)
{
	bool lsb = (regA & 1)?true:false;

	regA = (regA >> 1);
	regA &= ~128;
	regA |= (getFlag(CY_FLAG)?128:0);

	setFlag(CY_FLAG, lsb);

	m_timeTicks += 4;
	m_programCounter++;
}

void CCPU8080::CMA(BYTE opcode)
{
	regA = ~regA;

	m_timeTicks += 4;
	m_programCounter++;
}

void CCPU8080::STC(BYTE opcode)
{
	setFlag(CY_FLAG, true);

	m_timeTicks += 4;
	m_programCounter++;
}

void CCPU8080::CMC(BYTE opcode)
{
	setFlag(CY_FLAG, !getFlag(CY_FLAG));

	m_timeTicks += 4;
	m_programCounter++;
}

void CCPU8080::DAA(BYTE opcode)
{
	m_timeTicks += 4;
	m_programCounter++;
}

void CCPU8080::IN(BYTE opcode)
{
	BYTE portNb;
	m_memory.Read(m_programCounter+1, portNb);
	m_ports.In(portNb, regA);

	m_timeTicks += 10;
	m_programCounter+=2;
}

void CCPU8080::OUT(BYTE opcode)
{
	BYTE portNb;
	m_memory.Read(m_programCounter+1, portNb);
	m_ports.Out(portNb, regA);

	m_timeTicks += 10;
	m_programCounter+=2;
}

void CCPU8080::EI(BYTE opcode)
{
	m_programCounter++;
}

void CCPU8080::DI(BYTE opcode)
{
	m_programCounter++;
}

void CCPU8080::NOP(BYTE opcode)
{
	m_timeTicks += 4;
	m_programCounter++;
}

void CCPU8080::HLT(BYTE opcode)
{
	fprintf(stderr, "HLT\n");
	m_state = STOP;
	m_timeTicks += 5;
	m_programCounter++;
}
