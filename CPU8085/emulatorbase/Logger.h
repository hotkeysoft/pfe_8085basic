#pragma once
class Logger
{
public:
	Logger();
	virtual ~Logger();

	void RegisterLogCallback(void(*)(const char *));

protected:
	void LogPrintf(const char *, ...);

private:
	char m_logBuffer[1024];

	void(*m_logCallbackFunc)(const char *str);
};

