// Keyboard.h: interface for the CKeyboard class.
//
//////////////////////////////////////////////////////////////////////
#pragma once

#include "Common.h"
#include "InputPort.h"
#include "InterruptSource.h"

class CKeyboard : public CInputPort, public CInterruptSource
{
public:
	CKeyboard();
	virtual ~CKeyboard();

	bool IsEscape() { return m_currChar == 27; }

protected:
	// Inherited via CInterruptSource
	virtual bool IsInterrupting() override;

	// Inherited via CInputPort
	virtual BYTE In() override;

	BYTE m_currChar;
};
