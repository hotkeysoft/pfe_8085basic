// OutputPort.h: interface for the COutputPort class.
//
//////////////////////////////////////////////////////////////////////

#pragma once

#include "Common.h"

class COutputPort  
{
public:
	COutputPort() {};
	virtual ~COutputPort() {};

	virtual void Out(BYTE value) = 0;
};
