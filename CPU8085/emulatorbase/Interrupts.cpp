#include "StdAfx.h"
#include "Interrupts.h"
#include <stdarg.h>

CInterrupts::CInterrupts()
{
	m_logCallbackFunc = NULL;

	for (int i = 0; i<MAXINTERRUPT; i++)
	{
		m_interrupts[i] = NULL;
	}
}

CInterrupts::~CInterrupts()
{
}

bool CInterrupts::Allocate(BYTE intNb, CInterruptSource * intSource)
{
	LogPrintf("Request to allocate interrupt source #%d", intNb);

	if (m_interrupts[intNb] != NULL)
	{
		LogPrintf("ERROR: Interrupt already exists");
		return false;
	}

	for (int i = 0; i<MAXINTERRUPT; i++)
	{
		if (m_interrupts[i] == intSource)
		{
			LogPrintf("ERROR: Object already allocated at #%d", i);
			return false;
		}
	}

	m_interrupts[intNb] = intSource;

	return true;
}

bool CInterrupts::Free(CInterruptSource * intSource)
{
	for (int i = 0; i<MAXINTERRUPT; i++)
	{
		if (m_interrupts[i] == intSource)
		{
			LogPrintf("Freeing interrupt #%d", i);
			m_interrupts[i] = NULL;
			return true;
		}
	}

	LogPrintf("ERROR: CInterrupts::Free: interrupt source not found");
	return false;
}

bool CInterrupts::IsInterrupting(BYTE intNb)
{
	if (m_interrupts[intNb] == NULL)
	{
		return false;
	}

	return m_interrupts[intNb]->IsInterrupting();
}

//////////////////////////////////////////////////////////////////////

void CInterrupts::RegisterLogCallback(void(*logCallbackFunc)(const char *))
{
	m_logCallbackFunc = logCallbackFunc;
}

void CInterrupts::LogPrintf(const char *msg, ...)
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
