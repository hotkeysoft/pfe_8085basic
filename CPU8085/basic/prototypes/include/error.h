#ifndef __ERROR_H_INCLUDED
#define __ERROR_H_INCLUDED

#include <iostream>

enum ErrorType 
{
	// tokenization errors
	E_TOK_UNKNOWN,			// unknown token
	E_TOK_NOENDSTR,			// unterminated string constant	

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
	CError(const ErrorType e = E_UNKNOWN) : m_Error(e)
	{
	}

protected:
	ErrorType m_Error;

	friend std::ostream operator<< (std::ostream &os, const CError &e);
};

std::ostream operator<< (std::ostream &os, const CError &e);


#endif
