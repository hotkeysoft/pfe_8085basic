// Memory.cpp: implementation of the CMemory class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include <stdarg.h>
#include "Memory.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CMemory::CMemory()
{
	m_logCallbackFunc = NULL;
	m_currBlock = NULL;
	m_currMin = 0;
	m_currMax = 0;
}

CMemory::~CMemory()
{

}

bool CMemory::Allocate(CMemoryBlock *block)
{
	LogPrintf("Request to allocate block at %X, size = %d bytes", block->GetBaseAddress(), block->GetSize());

	CMemoryBlock *overlap = FindOverlap(block);
	if (overlap != NULL)
	{
		LogPrintf("ERROR: Found overlap: block at %X, size = %d bytes", overlap->GetBaseAddress(), overlap->GetSize());
		return false;
	}

	m_memory.push_back(block);

	return true;
}

bool CMemory::Free(CMemoryBlock *block)
{
	LogPrintf("Freeing block at %X", block->GetBaseAddress());

	m_memory.remove(block);

	return true;
}

bool CMemory::Read(WORD address, BYTE &value)
{
	LogPrintf("Read(%X)", address);

	CMemoryBlock *block = NULL;

	if (m_currBlock && address >= m_currMin && address <= m_currMax)
	{
		LogPrintf("\tUsing cached block. ret = %X", m_currBlock->read(address));
		block = m_currBlock;
	}
	else
	{
		CMemoryBlock *newBlock = FindBlock(address);
		if (newBlock)
		{
			LogPrintf("\tNew block put in cache.  ret = %X", newBlock->read(address));
			block = newBlock;
		}
		else
		{
			LogPrintf("\tERROR: Reading unallocated memory space (%X)", address);
		}
	}

	if (block)
	{
		value = block->read(address); 
		return true;
	}
	else
	{
		return false;
	}
}

bool CMemory::Write(WORD address, BYTE value)
{
	LogPrintf("Write(%X, %X)", address, value);

	CMemoryBlock *block = NULL;

	if (m_currBlock && address >= m_currMin && address <= m_currMax)
	{
		LogPrintf("\tUsing cached block.");
		block = m_currBlock;
	}
	else
	{
		CMemoryBlock *newBlock = FindBlock(address);
		if (newBlock)
		{
			LogPrintf("\tNew block put in cache.");
			block = newBlock;
		}
		else
		{
			LogPrintf("\tERROR: Writing unallocated memory space (%X)", address);
		}
	}

	if (block)
	{
		if (block->GetType() == ROM)
		{
			LogPrintf("\tERROR: Attempting to write in ROM block at %X, size = %d bytes", block->GetBaseAddress(), block->GetSize());
			return false;
		}
		else
		{
			block->write(address, value);
			return true;
		}
	}
	else
	{
		return false;
	}
}

CMemoryBlock *CMemory::FindBlock(WORD address)
{
	MemoryListType::const_iterator i;

	for (i=m_memory.begin(); i!=m_memory.end(); i++)
	{
		WORD currMin = (*i)->GetBaseAddress();
		WORD currMax = currMin + (*i)->GetSize() - 1;

		if (address>=currMin && address<=currMax)
		{
			m_currBlock = *i;
			m_currMin = m_currBlock->GetBaseAddress();
			m_currMax = m_currMin + m_currBlock->GetSize() - 1;
			return *i;
		}
	}

	return NULL;
}

CMemoryBlock *CMemory::FindOverlap(const CMemoryBlock *block)
{
	WORD min = block->GetBaseAddress();
	WORD max = min + block->GetSize() - 1;

	MemoryListType::const_iterator i;

	for (i=m_memory.begin(); i!=m_memory.end(); i++)
	{
		WORD currMin = (*i)->GetBaseAddress();
		WORD currMax = currMin + (*i)->GetSize() - 1;

		if ((min>=currMin && min<=currMax)||(max>=currMin && max<=currMax))
		{
			return *i;
		}
	}

	return NULL;
}

//////////////////////////////////////////////////////////////////////

void CMemory::RegisterLogCallback(void (*logCallbackFunc)(const char *))
{
	m_logCallbackFunc = logCallbackFunc;
}

void CMemory::LogPrintf(const char *msg, ...)
{
	if (m_logCallbackFunc)
	{
		va_list args;
		va_start(args, msg);

		vsprintf(m_logBuffer, msg, args);

		va_end(args);              

		strcat(m_logBuffer, "\n");

		m_logCallbackFunc(m_logBuffer);
	}
}