#ifndef __ERROR_H_INCLUDED
#define __ERROR_H_INCLUDED

#include <iostream>

enum ErrorType 
{
	// tokenization errors
	E_TOK_UNKNOWN,			// unknown token
	E_TOK_NOENDSTR,			// unterminated string constant	
	E_TOK_INVALIDCHAR,		// invalid character

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
	CError(const ErrorType e = E_UNKNOWN) : m_error(e), m_symbol(0) {}
	CError(const ErrorType e, char symbol) : m_error(e), m_symbol(symbol) {}

protected:
	ErrorType m_error;
	char m_symbol;

	friend std::ostream operator<< (std::ostream &os, const CError &e);
};

std::ostream operator<< (std::ostream &os, const CError &e);


#endif
