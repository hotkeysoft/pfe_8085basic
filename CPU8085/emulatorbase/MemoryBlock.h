// MemoryBlock.h: interface for the CMemoryBlock class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_MEMORYBLOCK_H__5E4DCC3F_4033_44EA_AF88_FD2E38AC2FD1__INCLUDED_)
#define AFX_MEMORYBLOCK_H__5E4DCC3F_4033_44EA_AF88_FD2E38AC2FD1__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

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

#endif // !defined(AFX_MEMORYBLOCK_H__5E4DCC3F_4033_44EA_AF88_FD2E38AC2FD1__INCLUDED_)
