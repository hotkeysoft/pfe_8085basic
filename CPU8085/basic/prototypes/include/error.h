#ifndef __ERROR_H_INCLUDED
#define __ERROR_H_INCLUDED

#include <iostream>

enum ErrorType 
{
	// tokenization errors
	E_TOK_UNKNOWN,			// unknown token
	E_TOK_NOENDSTR,			// unterminated string constant	
	E_TOK_INVALIDCHAR,		// invalid character

	// expression evaluator errors
	E_EXP_STACKOVERFLOW,	// 'formula too complex'
	E_EXP_STACKUNDERFLOW,	// syntax error?
	E_EXP_TYPEMISMATCH,		// type mismatch (i.e. int+str, str*str)
	E_EXP_OVERFLOW,			// Overflow
	E_EXP_ILLEGAL,			// Illegal argument (out or range)
	E_EXP_DIVZERO,			// Division by zero
	E_EXP_SYNTAX,			// Syntax error (missing parameter)
	E_EXP_ELSEWITHOUTIF,	// Else without if
	E_EXP_LINENOTFOUND,		// Line not found

	// variables module errors
	E_VAR_NOTINIT,			// variables used before being initialized

	E_UNKNOWN				// general error
};

struct Error
{
	ErrorType id;
	const char *text;
};

extern Error ErrorStr[];

class CError
{
public:
	CError(const ErrorType e = E_UNKNOWN) : m_error(e), m_symbol(K_NONE) 
	{
		m_tag[0] = 0;
		m_tag[1] = 0;
	}
	
	CError(const ErrorType e, KEYWORDS symbol) : m_error(e), m_symbol(symbol) 
	{
		m_tag[0] = 0;
		m_tag[1] = 0;
	}

	CError(const ErrorType e, BYTE tag[2]) : m_error(e), m_symbol(K_NONE)
	{
		m_tag[0] = tag[0];
		m_tag[1] = tag[1];
	}

protected:
	ErrorType m_error;
	KEYWORDS m_symbol;
	BYTE m_tag[2];

	friend std::ostream &operator<< (std::ostream &os, const CError &e);
};

std::ostream &operator<< (std::ostream &os, const CError &e);


#endif
