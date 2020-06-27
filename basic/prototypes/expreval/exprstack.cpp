#include "stdafx.h"

#include <iostream>

CExprStack::CExprStack(void)
{
}

CExprStack::~CExprStack(void)
{
}

void CExprStack::push(BYTE *elem)
{
	if (CurrExpStack >= HiExpStack) throw CError(E_EXP_STACKOVERFLOW);

	memcpy(CurrExpStack, elem, 5);

	CurrExpStack+=5;
}

BYTE *CExprStack::pop()
{
	if (CurrExpStack-5 >= LoExpStack)
	{
		CurrExpStack-=5;
		return CurrExpStack;
	}

	throw CError(E_EXP_STACKUNDERFLOW);
}

void CExprStack::Dump()
{
	BYTE *stackPtr = CurrExpStack;

	std::cout << "Expression Stack:" << std::endl;

	while(stackPtr-5 >= LoExpStack)
	{
		stackPtr-=5;

		switch(*stackPtr)
		{
		case SID_CINT: 
			{
				short number;

				memcpy(&number, stackPtr+1, sizeof(short));

				std::cout << "[CI " << number << "]" << std::endl;
			}
			break;

		case SID_CFLOAT: 
			{
				float number;

				memcpy(&number, stackPtr+1, sizeof(float));

				std::cout << "[CF " << number << "]" << std::endl;
			}
			break;

		case SID_CSTR: 
			{
				std::string str;

				BYTE length = *(stackPtr+1);

				WORD offset;
			    memcpy(&offset, stackPtr+2, sizeof(WORD));

                str.assign((const char *)(Memory+offset), *(stackPtr+1));

				std::cout << "[CS \"" << str << "\"]" << std::endl;
			}
			break;


		case SID_VAR: std::cout << "Var" << std::endl; break;
		}
	}
}