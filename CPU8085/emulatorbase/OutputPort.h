// OutputPort.h: interface for the COutputPort class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_OUTPUTPORT_H__CC05BBE7_D38B_44C6_8784_4C8CD307170D__INCLUDED_)
#define AFX_OUTPUTPORT_H__CC05BBE7_D38B_44C6_8784_4C8CD307170D__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Common.h"

class COutputPort  
{
public:
	COutputPort();
	virtual ~COutputPort();

	virtual void Out(BYTE value) = 0;

protected:

};

#endif // !defined(AFX_OUTPUTPORT_H__CC05BBE7_D38B_44C6_8784_4C8CD307170D__INCLUDED_)
