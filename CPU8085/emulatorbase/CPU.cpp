// CPU.cpp: implementation of the CCPU class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "CPU.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////


CCPU::CCPU(CMemory &memory) : m_memory(memory)
{
	for (int i=0; i<256; i++)
	{
		m_opcodesTable[i] = UnknownOpcode;
	}
}

CCPU::~CCPU()
{

}

void CCPU::Reset()
{
	m_programCounter = 0;
	m_state = STOP;
	m_timeTicks = 0;
}

void CCPU::Run()
{
	m_state = RUN;
	while (Step());
}

bool CCPU::Step()
{
	// Fetch opcode
	unsigned char opcode;
	if (m_memory.Read(m_programCounter, opcode) == true)
	{
		// Execute instruction
		(this->*m_opcodesTable[opcode])(opcode);
		return true;
	}
	else
	{
		m_state = STOP;
		return false;
	}
}

void CCPU::UnknownOpcode(unsigned char opcode)
{
	fprintf(stderr, "CPU: Unknown Opcode (%X) at address %X! Stopping CPU.\n", opcode, m_programCounter);
	m_state = STOP;
}

bool CCPU::isParityOdd(BYTE b)
{
	BYTE parity = 0;
	for (int i=0; i<8; i++)
	{
		parity ^= (b&1);
		b = b >> 1;
	}

	return (parity != 0);
}
