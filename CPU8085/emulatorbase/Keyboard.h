// Keyboard.h: interface for the CKeyboard class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_KEYBOARD_H__CDDF00BE_98E2_46CD_B483_E8AA26663F11__INCLUDED_)
#define AFX_KEYBOARD_H__CDDF00BE_98E2_46CD_B483_E8AA26663F11__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Common.h"
#include "InputPort.h"

class CKeyboard : public CInputPort  
{
public:
	CKeyboard();
	virtual ~CKeyboard();

	virtual BYTE In();

	BYTE currChar;

protected:
};

#endif // !defined(AFX_KEYBOARD_H__CDDF00BE_98E2_46CD_B483_E8AA26663F11__INCLUDED_)
