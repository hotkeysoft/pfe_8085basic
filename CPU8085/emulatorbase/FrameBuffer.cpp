// FrameBuffer.cpp: implementation of the CFrameBuffer class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "FrameBuffer.h"


#include "windows.h"
#include "wincon.h"


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CFrameBuffer::CFrameBuffer(WORD baseAddress, WORD size)
	:	CMemoryBlock(baseAddress, size, RAM)
{

}

CFrameBuffer::~CFrameBuffer()
{

}

void CFrameBuffer::write(WORD address,char data)
{
	CMemoryBlock::write(address, data);

	DWORD dummy;
	COORD pos;
	pos.X = (address-m_baseAddress)%64;
	pos.Y = (address-m_baseAddress)/64;
	WriteConsoleOutputCharacter(GetStdHandle(STD_OUTPUT_HANDLE), &data, 1, pos, &dummy);
}
