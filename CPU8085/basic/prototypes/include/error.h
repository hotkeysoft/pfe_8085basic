#ifndef __ERROR_H_INCLUDED
#define __ERROR_H_INCLUDED

enum ErrorType 
{
	// tokenization errors
	E_TOK_UNKNOWN,			// unknown token
	E_TOK_NOENDSTR,			// unterminated string constant	


	E_UNKNOWN				// general error
};

class CError
{
public:
	CError(const ErrorType e = E_UNKNOWN) : m_Error(e)
	{
	}

protected:
	ErrorType m_Error;

};


#endif
