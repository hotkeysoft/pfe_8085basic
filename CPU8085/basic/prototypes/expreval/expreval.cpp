// expreval.cpp
//

#include "stdafx.h"
#include "expreval.h"

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
		BYTE currToken = *currIn;
		if (currToken == K_AND || currToken == K_OR || currToken == K_XOR)
		{
			++currIn;
			L1();
			*currOut = currToken;
			++currOut;
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
		BYTE currToken = *currIn;
		if (currToken == K_NOTEQUAL || 
			currToken == K_LESSEQUAL || 
			currToken == K_GREATEREQUAL || 
			currToken == K_LESS || 
			currToken == K_GREATER ||
			currToken == K_EQUAL)
		{
			++currIn;
			L3();
			*currOut = currToken;
			++currOut;
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
		BYTE currToken = *currIn;
		if (currToken == K_ADD || currToken == K_SUBSTRACT)
		{
			++currIn;
			L4();
			*currOut = currToken;
			++currOut;
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
		BYTE currToken = *currIn;
		if (currToken == K_MULTIPLY || currToken == K_DIVIDE)
		{
			++currIn;
			L5();
			*currOut = currToken;
			++currOut;
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
		BYTE currToken = *currIn;
		if (currToken == K_POWER)
		{
			++currIn;
			L7();
			*currOut = currToken;
			++currOut;
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
		memcpy(currOut, currIn, sizeof(short)+1);
		currOut += sizeof(short)+1;
		currIn += sizeof(short)+1;
		break;
	case SID_CFLOAT:
		memcpy(currOut, currIn, sizeof(float)+1);
		currIn += sizeof(float)+1;
		currOut += sizeof(float)+1;
		break;
	case SID_VAR:
		memcpy(currOut, currIn, 3);
		currIn += 3;
		currOut += 3;
		break;
//	case SID_CSTR:
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
