// expreval.cpp
//

#include "stdafx.h"
#include "expreval.h"
#include "evaluate.h"
#include "exprstack.h"

BYTE *currOut;
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
		*currOut = K_NOT;
		++currOut;
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
		*currOut = K_NEGATE;
		++currOut;
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
			CExprStack::push(currIn);
			currIn += length+2;
		}
		break;
	default:
		if (*currIn == '(')
		{
			++currIn;
			L0();
			++currIn; // Trailing ')'
		}
		else if (((*currIn & 0xA0) == 0xA0) || ((*currIn & 0xB0) == 0xB0))
		{
			BYTE currToken = *currIn;

			++currIn; // skips keyword
			++currIn; // skips '('
			L0();	// expression
			++currIn; // trailing ')'

			*currOut = currToken;
			++currOut;
		}
		break;
	}
}

void expreval(char *in, char *out)
{
	currOut = (BYTE *)out;
	currIn = (BYTE *)in;

	L0();

	*currOut = 0;
}
