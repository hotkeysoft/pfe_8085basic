// Keyboard.cpp: implementation of the CKeyboard class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "Keyboard.h"
#include <conio.h>

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CKeyboard::CKeyboard()
{
}

CKeyboard::~CKeyboard()
{

}

BYTE CKeyboard::In()
{
	if (_kbhit() == 0)
	{
		return 0;		// bit 7 = 1 -> idle
	}
	else
	{
		m_currChar = _getch();
		while (_kbhit()) _getch();
		return m_currChar;
	}
}

bool CKeyboard::IsInterrupting()
{
	return _kbhit();
}
