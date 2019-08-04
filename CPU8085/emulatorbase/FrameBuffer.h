// FrameBuffer.h: interface for the CFrameBuffer class.
//
//////////////////////////////////////////////////////////////////////
#pragma once

#include "MemoryBlock.h"

class CFrameBuffer : public CMemoryBlock  
{
public:
	CFrameBuffer(WORD baseAddress, WORD size);

	virtual ~CFrameBuffer();

	virtual void write(WORD address, char data);
};
