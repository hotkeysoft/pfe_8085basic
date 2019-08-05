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
		m_opcodesTable[i] = &CCPU::UnknownOpcode;
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
	m_state = RUN;
	if (m_memory.Read(m_programCounter, opcode) == true)
	{
		// Execute instruction
		(this->*m_opcodesTable[opcode])(opcode);
	}
	else
	{
		fprintf(stderr, "CPU: Reading invalid address 0x%04X! Stopping CPU.\n", m_programCounter);
		m_state = STOP;
	}

	return (m_state == RUN);
}

void CCPU::DumpUnassignedOpcodes()
{
	for (int i = 0; i < 256; ++i)
	{
		if (m_opcodesTable[i] == &CCPU::UnknownOpcode) 
		{
			fprintf(stderr, "Unassigned: 0x%02X\t0%03o\n", i, i);
		}
	}
}

void CCPU::AddOpcode(BYTE opcode, OPCodeFunction f)
{
	if (m_opcodesTable[opcode] != &CCPU::UnknownOpcode)
	{
		fprintf(stderr, "CPU: Opcode (0x%02X) already defined!\n", opcode);
		throw std::exception("Opcode Already defined");
	}

	m_opcodesTable[opcode] = f;
}

void CCPU::UnknownOpcode(BYTE opcode)
{
	fprintf(stderr, "CPU: Unknown Opcode (0x%02X) at address 0x%04X! Stopping CPU.\n", opcode, m_programCounter);
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
