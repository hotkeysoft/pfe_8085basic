#pragma once
#include "PortConnector.h"
class PortAggregator : public PortConnector
{
public:
	PortAggregator() {}
	virtual ~PortAggregator() {}

	bool Connect(PortConnector &ports);
};

