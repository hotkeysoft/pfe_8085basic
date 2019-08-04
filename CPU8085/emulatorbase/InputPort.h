// InputPort.h: interface for the CInputPort class.
//
//////////////////////////////////////////////////////////////////////
#pragma once

#include "Common.h"

class CInputPort  
{
public:
	CInputPort() {}
	virtual ~CInputPort() {}

	virtual BYTE In() = 0;
};
