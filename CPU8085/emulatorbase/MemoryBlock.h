// MemoryBlock.h: interface for the CMemoryBlock class.
//
//////////////////////////////////////////////////////////////////////
#pragma once

#include "Common.h"
#include <vector>

enum MemoryType {RAM, ROM};

class CMemoryBlock  
{
public:
	CMemoryBlock(WORD baseAddress, WORD size, MemoryType type=RAM);
	CMemoryBlock(WORD baseAddress, const std::vector<BYTE>data, MemoryType type=RAM);
	CMemoryBlock(const CMemoryBlock &block);

	virtual ~CMemoryBlock();

	void Clear(BYTE filler = 0xFF);

	WORD GetBaseAddress() const { return m_baseAddress; };
	WORD GetSize() const { return m_size; };
	MemoryType GetType() const { return m_type; };

	virtual BYTE read(WORD address);
	virtual void write(WORD address, char data);

protected:
	WORD m_baseAddress;
	WORD m_size;
	MemoryType m_type;

	BYTE *m_data;

	BYTE m_invalid;
};
