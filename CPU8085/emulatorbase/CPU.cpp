#include "stdafx.h"
#include "CPU.h"

CPU::CPU(Memory &memory) : m_memory(memory)
{
	for (int i=0; i<256; i++)
	{
		m_opcodesTable[i] = &CPU::UnknownOpcode;
	}
}

CPU::~CPU()
{

}

void CPU::Reset()
{
	m_programCounter = 0;
	m_state = STOP;
	m_timeTicks = 0;
}

void CPU::Run()
{
	m_state = RUN;
	while (Step() && m_state == RUN);
}

bool CPU::Step()
{
	try
	{
		// Fetch opcode
		unsigned char opcode;
		m_state = RUN;
		m_memory.Read(m_programCounter, opcode);

		// Execute instruction
		(this->*m_opcodesTable[opcode])(opcode);
	}
	catch (std::exception e)
	{		
		e.what();
		fprintf(stderr, "Error processing instruction at 0x%04X! Stopping CPU.\n", m_programCounter);
		m_state = STOP;
	}

	return (m_state == RUN);
}

void CPU::DumpUnassignedOpcodes()
{
	for (int i = 0; i < 256; ++i)
	{
		if (m_opcodesTable[i] == &CPU::UnknownOpcode) 
		{
			fprintf(stderr, "Unassigned: 0x%02X\t0%03o\n", i, i);
		}
	}
}

void CPU::AddOpcode(BYTE opcode, OPCodeFunction f)
{
	if (m_opcodesTable[opcode] != &CPU::UnknownOpcode)
	{
		fprintf(stderr, "CPU: Opcode (0x%02X) already defined!\n", opcode);
		throw std::exception("Opcode Already defined");
	}

	m_opcodesTable[opcode] = f;
}

void CPU::UnknownOpcode(BYTE opcode)
{
	fprintf(stderr, "CPU: Unknown Opcode (0x%02X) at address 0x%04X! Stopping CPU.\n", opcode, m_programCounter);
	m_state = STOP;
}

bool CPU::isParityOdd(BYTE b)
{
	BYTE parity = 0;
	for (int i=0; i<8; i++)
	{
		parity ^= (b&1);
		b = b >> 1;
	}

	return (parity != 0);
}
