// Memory.h: interface for the CMemory class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_MEMORY_H__60FF0DB0_3E09_4674_AB6E_4A0158B56F77__INCLUDED_)
#define AFX_MEMORY_H__60FF0DB0_3E09_4674_AB6E_4A0158B56F77__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "MemoryBlock.h"
#include "Common.h"
#include <list>

typedef std::list<CMemoryBlock *> MemoryListType;

class CMemory  
{
public:
	CMemory();
	virtual ~CMemory();

	bool Allocate(CMemoryBlock *block);
	bool Free(CMemoryBlock *block);

	bool Read(WORD address, BYTE &value);
	bool Write(WORD address, BYTE value);

	void RegisterLogCallback(void (*)(const char *));

private:
	MemoryListType m_memory;

	CMemoryBlock *FindBlock(WORD address);
	CMemoryBlock *FindOverlap(const CMemoryBlock *block);

	void LogPrintf(const char *, ...);
	char m_logBuffer[1024];

	CMemoryBlock *m_currBlock;
	WORD m_currMin, m_currMax;

	void (*m_logCallbackFunc)(const char *str);
};

#endif // !defined(AFX_MEMORY_H__60FF0DB0_3E09_4674_AB6E_4A0158B56F77__INCLUDED_)
