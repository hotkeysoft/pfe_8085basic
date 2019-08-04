// Ports.cpp: implementation of the CPorts class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include <stdarg.h>
#include "Ports.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CPorts::CPorts()
{
	m_logCallbackFunc = NULL;

	for (int i=0; i<MAXPORTS; i++)
	{
		m_inputPorts[i] = NULL;
		m_outputPorts[i] = NULL;
	}
}

CPorts::~CPorts()
{

}

bool CPorts::Allocate(BYTE portNb, CInputPort *iPort)
{
	LogPrintf("Request to allocate input port #%d", portNb);

	if (m_inputPorts[portNb] != NULL)
	{
		LogPrintf("ERROR: Port already exists");
		return false;
	}

	for (int i=0; i<MAXPORTS; i++)
	{
		if (m_inputPorts[i] == iPort)
		{
			LogPrintf("ERROR: Object already allocated at #%d", i);
			return false;
		}
	}

	m_inputPorts[portNb] = iPort;

	return true;	
}

bool CPorts::Allocate(BYTE portNb, COutputPort *oPort)
{
	LogPrintf("Request to allocate output port #%d", portNb);

	if (m_outputPorts[portNb] != NULL)
	{
		LogPrintf("ERROR: Port already exists");
		return false;
	}

	for (int i=0; i<MAXPORTS; i++)
	{
		if (m_outputPorts[i] == oPort)
		{
			LogPrintf("ERROR: Object already allocated at #%d", i);
			return false;
		}
	}

	m_outputPorts[portNb] = oPort;

	return true;	
}

bool CPorts::Free(CInputPort *iPort)
{
	for (int i=0; i<MAXPORTS; i++)
	{
		if (m_inputPorts[i] == iPort)
		{
			LogPrintf("Freeing input port #%d", i);	
			m_inputPorts[i] = NULL;
			return true;
		}
	}

	LogPrintf("ERROR: CPorts::Free: input port not found");	
	return false;
}

bool CPorts::Free(COutputPort *oPort)
{
	for (int i=0; i<MAXPORTS; i++)
	{
		if (m_outputPorts[i] == oPort)
		{
			LogPrintf("Freeing output port #%d", i);	
			m_outputPorts[i] = NULL;
			return true;
		}
	}

	LogPrintf("ERROR: CPorts::Free: output port not found");	
	return false;
}

bool CPorts::In(BYTE port,BYTE &value)
{
	if (m_inputPorts[port] == NULL)
	{
		LogPrintf("ERROR: CPorts::In: port %x not allocated", port);
		return false;
	}

	value = m_inputPorts[port]->In();
	return true;
}

bool CPorts::Out(BYTE port,BYTE value)
{
	if (m_outputPorts[port] == NULL)
	{
		LogPrintf("ERROR: CPorts::Out: port %x not allocated", port);
		return false;
	}

	m_outputPorts[port]->Out(value);
	return true;
}

//////////////////////////////////////////////////////////////////////

void CPorts::RegisterLogCallback(void (*logCallbackFunc)(const char *))
{
	m_logCallbackFunc = logCallbackFunc;
}

void CPorts::LogPrintf(const char *msg, ...)
{
	va_list args;
	va_start(args, msg);

	vsprintf(m_logBuffer, msg, args);

	va_end(args);              

	strcat(m_logBuffer, "\n");

	if (m_logCallbackFunc)
	{
		m_logCallbackFunc(m_logBuffer);
	}
}