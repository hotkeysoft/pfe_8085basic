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
	currChar = 0;
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
		currChar = _getch();
		return (currChar | 128);
	}
}
