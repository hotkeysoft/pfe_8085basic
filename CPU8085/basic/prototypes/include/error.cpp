#include "stdafx.h"

Error errorStr[] = {
	// arithmetic operators
	E_TOK_UNKNOWN,			"TOK: Unknown",
	E_TOK_NOENDSTR,			"TOK: Unterminated string constant",
	E_TOK_INVALIDCHAR,		"TOK: Invalid symbol",

	E_EXP_STACKOVERFLOW,	"EXP: Stack overflow",
	E_EXP_STACKUNDERFLOW,	"EXP: Stack underflow",
	E_EXP_TYPEMISMATCH,		"EXP: Type mismatch",
	E_EXP_OVERFLOW,			"EXP: Overflow",
	E_EXP_ILLEGAL,			"EXP: Illegal argument",
	E_EXP_DIVZERO,			"EXP: Division by zero",

	E_UNKNOWN,			"Unknown Error"
};

std::ostream &operator<< (std::ostream &os, const CError &e)
{
	Error *current = errorStr;

	for (current = errorStr; current->id<=E_UNKNOWN; ++current)
	{
		if (current->id == e.m_error)
		{
			if (e.m_symbol != 0)
			{
				os << "E_" << current->text << ": '" << e.m_symbol << "'" << std::endl;
			}
			else
			{
				os << "E_" << current->text << std::endl;
			}

			return os;
		}
	}

	os << "E_Unlisted error!" << std::endl;
	return os;
}