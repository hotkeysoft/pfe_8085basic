#include "Logger.h"
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

Logger::Logger() : m_logCallbackFunc(NULL) 
{
}

Logger::~Logger()
{
}

void Logger::RegisterLogCallback(void(*logCallbackFunc)(const char *))
{
	m_logCallbackFunc = logCallbackFunc;
}

void Logger::LogPrintf(const char *msg, ...)
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