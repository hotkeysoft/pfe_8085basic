#pragma once


#include "Common.h"
#include "InterruptSource.h"
#include <list>

const int MAXINTERRUPT = 16;

class CInterrupts
{
public:
	CInterrupts();
	virtual ~CInterrupts();

	bool Allocate(BYTE intNb, CInterruptSource *intSource);

	bool Free(CInterruptSource *intSource);

	bool IsInterrupting(BYTE intNb);

	void RegisterLogCallback(void(*)(const char *));

private:
	CInterruptSource* m_interrupts[MAXINTERRUPT];

	void LogPrintf(const char *, ...);
	char m_logBuffer[1024];

	void(*m_logCallbackFunc)(const char *str);
};
