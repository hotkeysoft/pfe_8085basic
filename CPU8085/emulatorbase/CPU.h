// CPU.h: interface for the CCPU class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_CPU_H__AEE770D8_45E3_452B_9C88_93EB93BB67FF__INCLUDED_)
#define AFX_CPU_H__AEE770D8_45E3_452B_9C88_93EB93BB67FF__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Memory.h"
#include "Common.h"

class CCPU  
{
public:
	CCPU(CMemory &memory);
	virtual ~CCPU();

	virtual void Reset();
	void Run();
	bool Step();

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

#endif // !defined(AFX_CPU_H__AEE770D8_45E3_452B_9C88_93EB93BB67FF__INCLUDED_)
