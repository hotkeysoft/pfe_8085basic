#include "stdafx.h"
#include "exprstack.h"

#include <iostream>

CExprStack::CExprStack(void)
{
}

CExprStack::~CExprStack(void)
{
}

void CExprStack::push(BYTE *elem)
{
	switch(*elem)
	{
	case SID_CFLOAT:	pushCFLOAT(elem);		break;
	case SID_CINT:		pushCINT(elem);			break;
	case SID_CSTR:		pushCSTR(elem);			break;
	case SID_VAR:		pushVAR(elem);			break;
	}
}

void CExprStack::pushCINT(BYTE *elem)
{
	if (CurrExpStack >= HiExpStack) throw CError(E_EXP_STACKOVERFLOW);

	memcpy(CurrExpStack, elem, 1+sizeof(int));

	CurrExpStack+=5;
}

void CExprStack::pushCFLOAT(BYTE *elem)
{
	if (CurrExpStack >= HiExpStack) throw CError(E_EXP_STACKOVERFLOW);

	memcpy(CurrExpStack, elem, 1+sizeof(float));

	CurrExpStack+=5;
}

void CExprStack::pushCSTR(BYTE *elem)
{
	if (CurrExpStack >= HiExpStack) throw CError(E_EXP_STACKOVERFLOW);

	// store offset from Memory[], since ptr doesn't fit.  
	// On micro, ptr takes only two bytes
	
	*(CurrExpStack) = *(elem);			// Type=STR
	*(CurrExpStack+1) = *(elem+1);			// str length
	WORD offset = (elem+2)-Memory;			// 'address'
    memcpy(CurrExpStack+2, &offset, sizeof(WORD));

	CurrExpStack+=5;	
}

void CExprStack::pushVAR(BYTE *elem)
{
	if (CurrExpStack >= HiExpStack) throw CError(E_EXP_STACKOVERFLOW);

	memcpy(CurrExpStack, elem, 3);

	CurrExpStack+=5;
}

BYTE *CExprStack::pop()
{
	if (CurrExpStack-5 >= LoExpStack)
	{
		CurrExpStack-=5;
		return CurrExpStack;
	}
	else
	{
		throw CError(E_EXP_STACKUNDERFLOW);
	}
	return 0;
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