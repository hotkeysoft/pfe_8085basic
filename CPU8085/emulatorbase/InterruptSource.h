#pragma once
class CInterruptSource
{
public:
	CInterruptSource() {}
	virtual ~CInterruptSource() {}

	virtual bool IsInterrupting() = 0;
};

