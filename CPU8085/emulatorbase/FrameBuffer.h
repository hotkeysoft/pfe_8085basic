// FrameBuffer.h: interface for the CFrameBuffer class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_FRAMEBUFFER_H__9C12DEE7_4862_4AA6_90D3_1B98C5CD17B6__INCLUDED_)
#define AFX_FRAMEBUFFER_H__9C12DEE7_4862_4AA6_90D3_1B98C5CD17B6__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "MemoryBlock.h"

class CFrameBuffer : public CMemoryBlock  
{
public:
	CFrameBuffer(WORD baseAddress, WORD size);

	virtual ~CFrameBuffer();

	virtual void write(WORD address, char data);
};

#endif // !defined(AFX_FRAMEBUFFER_H__9C12DEE7_4862_4AA6_90D3_1B98C5CD17B6__INCLUDED_)
