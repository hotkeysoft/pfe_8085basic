// Ports.h: interface for the CPorts class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_PORTS_H__B598A830_AD36_4003_8470_B2E03B1D6871__INCLUDED_)
#define AFX_PORTS_H__B598A830_AD36_4003_8470_B2E03B1D6871__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

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

#endif // !defined(AFX_PORTS_H__B598A830_AD36_4003_8470_B2E03B1D6871__INCLUDED_)
