#include "stdafx.h"

#include "common.h"
#include "error.h"

Error errorStr[] = {
	// arithmetic operators
	E_TOK_UNKNOWN,		"TOK: Unknown",
	E_TOK_NOENDSTR,		"TOK: Unterminated string constant",

	E_UNKNOWN,			"Unknown Error"
};

std::ostream operator<< (std::ostream &os, const CError &e)
{
	Error *current = errorStr;

	for (current = errorStr; current->id<=E_UNKNOWN; ++current)
	{
		if (current->id == e.m_Error)
		{
			os << "E_" << current->text << std::endl;
			return os;
		}
	}

	os << "E_Unlisted error!" << std::endl;
	return os;
}