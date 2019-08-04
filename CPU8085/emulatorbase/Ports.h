// Ports.h: interface for the CPorts class.
//
//////////////////////////////////////////////////////////////////////
#pragma once

#include "Common.h"
#include "InputPort.h"
#include "OutputPort.h"
#include <list>

const int MAXPORTS = 256;

class CPorts  
{
public:
	CPorts();
	virtual ~CPorts();

	bool Allocate(BYTE portNb, CInputPort *iPort);
	bool Allocate(BYTE portNb, COutputPort *oPort);

	bool Free(CInputPort *iPort);
	bool Free(COutputPort *oPort);

	bool In(BYTE port, BYTE &value);
	bool Out(BYTE port, BYTE value);

	void RegisterLogCallback(void (*)(const char *));

private:
	CInputPort *m_inputPorts[MAXPORTS];
	COutputPort *m_outputPorts[MAXPORTS];

	void LogPrintf(const char *, ...);
	char m_logBuffer[1024];

	void (*m_logCallbackFunc)(const char *str);
};
