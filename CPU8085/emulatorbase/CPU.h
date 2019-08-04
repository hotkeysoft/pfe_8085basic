// CPU.h: interface for the CCPU class.
//
//////////////////////////////////////////////////////////////////////
#pragma once
#include "Memory.h"
#include "Common.h"

class CCPU  
{
public:
	CCPU(CMemory &memory);
	virtual ~CCPU();

	virtual void Reset();
	void Run();
	virtual bool Step();

	unsigned long getTime() { return m_timeTicks; };

protected:
	typedef void (CCPU::*OPCodeFunction)(BYTE);
	OPCodeFunction m_opcodesTable[256];

	enum CPUState {STOP, RUN, STEP};

	CPUState m_state;
	CMemory &m_memory;

	unsigned long m_timeTicks;
	unsigned int m_programCounter;

	// Helper functions
	BYTE getLByte(WORD w) { return BYTE(w&0x00FF); };
	BYTE getHByte(WORD w) {return BYTE((w>>8)&0x00FF); };
	WORD getWord(BYTE h, BYTE l) { return (((WORD)h)<<8) + l; };

	bool isParityOdd(BYTE b);
	bool isParityEven(BYTE b) { return !isParityOdd(b); };

private:
	void UnknownOpcode(BYTE);
};
