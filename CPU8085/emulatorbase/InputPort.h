// InputPort.h: interface for the CInputPort class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_INPUTPORT_H__BDFB5560_8D56_4D13_9164_5ED9ACA52981__INCLUDED_)
#define AFX_INPUTPORT_H__BDFB5560_8D56_4D13_9164_5ED9ACA52981__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Common.h"

class CInputPort  
{
public:
	CInputPort();
	virtual ~CInputPort();

	virtual BYTE In() = 0;

protected:

};

#endif // !defined(AFX_INPUTPORT_H__BDFB5560_8D56_4D13_9164_5ED9ACA52981__INCLUDED_)
