// expreval.cpp
//

#include "stdafx.h"
#include "expreval.h"
#include "evaluate.h"
#include "exprstack.h"
#include "..\program\program.h"

BYTE *currIn;

void L1();
void L2();
void L3();
void L4();
void L5();
void L6();
void L7();

void L0()
{
	// ship whitespace
	while(*currIn == ' ')
	{
		++currIn;
	}

	L1();

	while (1)
	{
		KEYWORDS currToken = (KEYWORDS)*currIn;
		if (currToken == K_AND || 
			currToken == K_OR || 
			currToken == K_XOR)
		{
			++currIn;
			L1();
			CEvaluate::Evaluate(currToken);
		}
		else
		{
			break;
		}
	}
}

void L1()
{
	if (*currIn == K_NOT)
	{
		++currIn;
		L2();
		CEvaluate::Evaluate(K_NOT);	
	}
	else
	{
		L2();
	}
}

void L2()
{
	L3();

	while (1)
	{
		KEYWORDS currToken = (KEYWORDS)*currIn;
		if (currToken == K_NOTEQUAL || 
			currToken == K_LESSEQUAL || 
			currToken == K_GREATEREQUAL || 
			currToken == K_LESS || 
			currToken == K_GREATER ||
			currToken == K_EQUAL)
		{
			++currIn;
			L3();
			CEvaluate::Evaluate(currToken);
		}
		else
		{
			break;
		}
	}
}

void L3()
{
	L4();

	while (1)
	{
		KEYWORDS currToken = KEYWORDS(*currIn);
		if (currToken == K_ADD || currToken == K_SUBSTRACT)
		{
			++currIn;
			L4();
			CEvaluate::Evaluate(currToken);
		}
		else
		{
			break;
		}
	}
}

void L4()
{
	L5();

	while (1)
	{
		KEYWORDS currToken = KEYWORDS(*currIn);
		if (currToken == K_MULTIPLY || currToken == K_FDIVIDE || currToken == K_IDIVIDE)
		{
			++currIn;
			L5();
			CEvaluate::Evaluate(currToken);
		}
		else
		{
			break;
		}
	}
}

void L5()
{
	if (*currIn == K_NEGATE)
	{
		++currIn;
		L6();
		CEvaluate::Evaluate(K_NEGATE);	
	}
	else
	{
		L6();
	}
}

void L6()
{
	L7();
	while (1)
	{
		KEYWORDS currToken = KEYWORDS(*currIn);
		if (currToken == K_POWER)
		{
			++currIn;
			L7();
			CEvaluate::Evaluate(currToken);
		}
		else
		{
			break;
		}
	}
}

void L7()
{
	// ship whitespace
	while(*currIn == ' ')
	{
		++currIn;
	}

	switch(*currIn)
	{
	case SID_CINT:
		CExprStack::push(currIn);
		currIn += sizeof(short)+1;
		break;
	case SID_CFLOAT:
		CExprStack::push(currIn);
		currIn += sizeof(float)+1;
		break;
	case SID_VAR:
		CExprStack::push(currIn);
		currIn += 3;
		break;
	case SID_CSTR:
		{
			BYTE length = *(currIn+1);
			SetStr(tempVar1, currIn+2, length);
			CExprStack::push(tempVar1);
			currIn += length+2;
		}
		break;
	default:
		if (*currIn == '(')
		{
			++currIn;

			L0();

			if (*currIn != ')')
			{
				throw CError(E_EXP_SYNTAX);
			}
			++currIn; // Trailing ')'
		}
		else if (((*currIn & 0xA0) == 0xA0) || ((*currIn & 0xB0) == 0xB0))
		{
			KEYWORDS currToken = (KEYWORDS)*currIn;

			++currIn; // skips keyword

			while(*currIn == ' ')
			{
				++currIn;
			}

			if (*currIn != '(')
			{
				throw CError(E_EXP_SYNTAX);
			}
			++currIn; // skips '('

			L0();	// expression

			// read second parameter if needed
			if (currToken == K_LEFT || currToken == K_RIGHT || currToken == K_MID)
			{
				if (*currIn != ',')
				{
					throw CError(E_EXP_SYNTAX);
				}

				++currIn;
				L0();	// expression

				if (currToken == K_MID)	// third parameter
				{
					if (*currIn != ',')
					{
						throw CError(E_EXP_SYNTAX);
					}

					++currIn;
					L0();	// expression
				}
			}

			if (*currIn != ')')
			{
				throw CError(E_EXP_SYNTAX);
			}
			++currIn; // Trailing ')'

			CEvaluate::Evaluate(currToken);
		}
		break;
	}

	// ship whitespace
	while(*currIn == ' ')
	{
		++currIn;
	}
	
}

void DoList()
{
	++currIn;
	CProgram::List();
}

void DoPrint()
{
	++currIn;

	bool insertNewLine = true;

	while(*currIn && *currIn!=':')
	{
		insertNewLine = true;

		L0();

		CEvaluate::UnaryOp();	// value in tempVar1
		switch(*tempVar1)
		{
		case SID_CINT: std::cout << GetInt(tempVar1); break;
		case SID_CFLOAT: std::cout << GetFloat(tempVar1); break;
		case SID_CSTR: 
			{
				std::string tempStr;
				BYTE size;
				char *addr = (char *)GetStr(tempVar1, size);
				tempStr.assign(addr, size);

				std::cout << tempStr;
			}
			break;
		}

		switch(*currIn)
		{
		case ',':	std::cout << '\t';	++currIn;	break;
		case ';':	++currIn;	insertNewLine = false; break;
		case ':':	break;
		case 0:		break;
		default:	throw CError();
		}
	}

	if (insertNewLine)
	{
		std::cout << std::endl;
	}
}

void expreval(char *in)
{
	currIn = (BYTE *)in;

	while (*currIn)
	{

		// ship whitespace
		while(*currIn == ' ' || *currIn == ':')
		{
			++currIn;
		}

		switch(*currIn)
		{
		case K_LIST:		DoList();		break;
		case K_PRINT:		DoPrint();		break;

		default: throw CError();
		}

		// ship whitespace
		while(*currIn == ' ')
		{
			++currIn;
		}

		if (*currIn && *currIn != ':')
		{
			throw CError();
		}
	}

//	L0();
}
