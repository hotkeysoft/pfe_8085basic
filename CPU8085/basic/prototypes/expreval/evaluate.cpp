#include "stdafx.h"
#include "evaluate.h"
#include "exprstack.h"
#include "..\variables\variables.h"

#include <math.h>

CEvaluate::CEvaluate(void)
{
}

CEvaluate::~CEvaluate(void)
{
}

void CEvaluate::Evaluate(KEYWORDS k)
{
	switch(k)
	{
	case K_POWER:		BinaryOp(); ConvertToSameType();	BinaryCalc(k);	break;
	case K_MULTIPLY:	BinaryOp(); ConvertToSameType();	BinaryCalc(k);	break;
	case K_FDIVIDE:		BinaryOp(); ConvertToFloat();		BinaryCalc(k);	break;
	case K_IDIVIDE:		BinaryOp(); ConvertToInt();			BinaryCalc(k);	break;
	case K_ADD:			BinaryOp(); ConvertToSameType();	BinaryCalc(k);	break;
	case K_SUBSTRACT:	BinaryOp(); ConvertToSameType();	BinaryCalc(k);	break;

	case K_NOTEQUAL:	BinaryOp(); ConvertToSameType();	BinaryRel(k);	break;
	case K_LESSEQUAL:	BinaryOp(); ConvertToSameType();	BinaryRel(k);	break;
	case K_GREATEREQUAL:BinaryOp(); ConvertToSameType();	BinaryRel(k);	break;
	case K_LESS:		BinaryOp(); ConvertToSameType();	BinaryRel(k);	break;
	case K_GREATER:		BinaryOp(); ConvertToSameType();	BinaryRel(k);	break;
	case K_EQUAL:		BinaryOp(); ConvertToSameType();	BinaryRel(k);	break;

	case K_AND:			BinaryOp(); ConvertToInt();		BinaryLog(k);	break;
	case K_OR:			BinaryOp(); ConvertToInt();		BinaryLog(k);	break;
	case K_XOR:			BinaryOp(); ConvertToInt();		BinaryLog(k);	break;

	case K_NOT:			UnaryOp();  Not();		break;

	case K_NEGATE:		UnaryOp();	Negate();	break;

	case K_ABS:			UnaryOp();	Abs();		break;
	case K_ASC:			UnaryOp();	Asc();		break;
	case K_INT:			UnaryOp();	Int();		break;
	case K_LEN:			UnaryOp();	Len();		break;
	case K_PEEK:		UnaryOp();	Peek();		break;
	case K_RND:			UnaryOp();	Rnd();		break;
	case K_SGN:			UnaryOp();	Sgn();		break;
	case K_SQR:			UnaryOp();	Sqr();		break;
	case K_VAL:			UnaryOp();	Val();		break;

	default:
		break;
	}
}

void CEvaluate::BinaryOp()
{
	BYTE *op1 = CExprStack::pop();
	BYTE *op2 = CExprStack::pop();

	if (*op1 == SID_VAR)
	{
		CVariables::Get(op1+1, tempVar1);
	}
	else
	{
		memcpy(tempVar1, op1, 5);
	}

	if (*op2 == SID_VAR)
	{
		CVariables::Get(op2+1, tempVar2);
	}
	else
	{
		memcpy(tempVar2, op2, 5);
	}
}

void CEvaluate::UnaryOp()
{
	BYTE *op = CExprStack::pop();

	if (*op == SID_VAR)
	{
		CVariables::Get(op+1, tempVar1);
	}
	else
	{
		memcpy(tempVar1, op, 5);
	}
}

void CEvaluate::ConvertToSameType()
{
	if (*tempVar1 != *tempVar2)	// do variable promotion if needed
	{
		if (*tempVar1 == SID_CSTR || *tempVar2 == SID_CSTR)
		{
			// (str [op] str) is the only possibility
			throw CError(E_EXP_TYPEMISMATCH);
		}
		else if (*tempVar1 == SID_CINT) 
		{
			// promote to float
			float fVal = (float)GetInt(tempVar1);
			SetFloat(tempVar1, fVal);
		}
		else if (*tempVar2 == SID_CINT)
		{
			// promote to float
			float fVal = (float)GetInt(tempVar2);
			SetFloat(tempVar2, fVal);
		}
	}
}

void CEvaluate::ConvertToFloat()
{
	switch (*tempVar1)
	{
	case SID_CFLOAT: break; // nothing to do
	case SID_CINT: 
		{
			float fVal = (float)GetInt(tempVar1);
			SetFloat(tempVar1, fVal);
		}
		break;
	default:
		throw CError(E_EXP_TYPEMISMATCH);    
	}

	switch (*tempVar2)
	{
	case SID_CFLOAT: break; // nothing to do
	case SID_CINT: 
		{
			float fVal = (float)GetInt(tempVar2);
			SetFloat(tempVar2, fVal);
		}
		break;
	default:
		throw CError(E_EXP_TYPEMISMATCH);
	}
}

void CEvaluate::ConvertToInt()
{
	switch (*tempVar1)
	{
	case SID_CINT: break; // nothing to do
	case SID_CFLOAT: 
		{
			float fVal = GetFloat(tempVar1);
			if (fVal>32767.0 || fVal<-32768.0)
			{
				throw CError(E_EXP_OVERFLOW);    				
			}
			SetInt(tempVar1, (short)fVal);
		}
		break;
	default:
		throw CError(E_EXP_TYPEMISMATCH);    
	}

	switch (*tempVar2)
	{
	case SID_CINT: break; // nothing to do
	case SID_CFLOAT: 
		{
			float fVal = GetFloat(tempVar2);
			if (fVal>32767.0 || fVal<-32768.0)
			{
				throw CError(E_EXP_OVERFLOW);    				
			}
			SetInt(tempVar2, (short)fVal);
		}
		break;
	default:
		throw CError(E_EXP_TYPEMISMATCH);
	}
}


void CEvaluate::BinaryCalc(KEYWORDS k)
{
    if (*tempVar1 == SID_CINT)
	{
		short op1 = GetInt(tempVar1);
		short op2 = GetInt(tempVar2);
		short result;

		switch(k)
		{
		case K_POWER:		result = (short)pow(op2, op1);	break;
		case K_MULTIPLY:	result = op2 * op1;		break;
		case K_ADD:			result = op2 + op1;		break;
		case K_SUBSTRACT:	result = op2 - op1;		break;
		case K_IDIVIDE:		
			if (op1 == 0) 
			{
				throw CError(E_EXP_DIVZERO);
			}
			result = op2 / op1;		
			break;
		default:
			throw CError(E_EXP_TYPEMISMATCH);
			break;
		}

		SetInt(tempVar3, result);
		CExprStack::push(tempVar3);
	}
	else if (*tempVar1 == SID_CFLOAT)
	{
		float op1 = GetFloat(tempVar1);
		float op2 = GetFloat(tempVar2);
		float result;

		switch(k)
		{
		case K_POWER:		result = (float)pow(op2, op1);	break;
		case K_MULTIPLY:	result = op2 * op1;		break;
		case K_ADD:			result = op2 + op1;		break;
		case K_SUBSTRACT:	result = op2 - op1;		break;
		case K_FDIVIDE:		
			if (op1 == 0.0) 
			{
				throw CError(E_EXP_DIVZERO);
			}
			result = op2 / op1;		
			break;
		default:
			throw CError(E_EXP_TYPEMISMATCH);
			break;
		}

		SetFloat(tempVar3, result);
		CExprStack::push(tempVar3);
	}
	else
	{
		throw CError(E_EXP_TYPEMISMATCH);
	}
}

void CEvaluate::BinaryRel(KEYWORDS k)
{
    if (*tempVar1 == SID_CINT)
	{
		short op1 = GetInt(tempVar1);
		short op2 = GetInt(tempVar2);
		bool result;

		switch(k)
		{
		case K_NOTEQUAL:		result = (op2 != op1);	break;
		case K_LESSEQUAL:		result = (op2 <= op1);	break;
		case K_GREATEREQUAL:	result = (op2 >= op1);	break;
		case K_LESS:			result = (op2 < op1);	break;
		case K_GREATER:			result = (op2 > op1);	break;
		case K_EQUAL:			result = (op2 == op1);	break;
		default:
			throw CError(E_EXP_TYPEMISMATCH);
			break;
		}

		SetInt(tempVar3, result?-1:0);
		CExprStack::push(tempVar3);
	}
	else if (*tempVar1 == SID_CFLOAT)
	{
		float op1 = GetFloat(tempVar1);
		float op2 = GetFloat(tempVar2);
		bool result;

		switch(k)
		{
		case K_NOTEQUAL:		result = (op2 != op1);	break;
		case K_LESSEQUAL:		result = (op2 <= op1);	break;
		case K_GREATEREQUAL:	result = (op2 >= op1);	break;
		case K_LESS:			result = (op2 < op1);	break;
		case K_GREATER:			result = (op2 > op1);	break;
		case K_EQUAL:			result = (op2 == op1);	break;
		default:
			throw CError(E_EXP_TYPEMISMATCH);
			break;
		}

		SetInt(tempVar3, result?-1:0);
		CExprStack::push(tempVar3);
	}
	else if (*tempVar1 == SID_CSTR)
	{
		BYTE size1;
		BYTE size2;

		BYTE *addr1 = GetStr(tempVar1, size1);
		BYTE *addr2 = GetStr(tempVar2, size2);

		std::string op1;
		std::string op2;

		op1.assign((char *)addr1, size1);
		op2.assign((char *)addr2, size2);

		bool result;

		switch(k)
		{
		case K_NOTEQUAL:		result = (op2 != op1);	break;
		case K_LESSEQUAL:		result = (op2 <= op1);	break;
		case K_GREATEREQUAL:	result = (op2 >= op1);	break;
		case K_LESS:			result = (op2 < op1);	break;
		case K_GREATER:			result = (op2 > op1);	break;
		case K_EQUAL:			result = (op2 == op1);	break;
		default:
			throw CError(E_EXP_TYPEMISMATCH);
			break;
		}

		SetInt(tempVar3, result?-1:0);
		CExprStack::push(tempVar3);
	}
	else
	{
		throw CError(E_EXP_TYPEMISMATCH);
	}
}

void CEvaluate::BinaryLog(KEYWORDS k)
{
    if (*tempVar1 == SID_CINT)
	{
		short op1 = GetInt(tempVar1);
		short op2 = GetInt(tempVar2);
		short result;

		switch(k)
		{
		case K_AND:		result = (op2 & op1);	break;
		case K_OR:		result = (op2 | op1);	break;
		case K_XOR:		result = (op2 ^ op1);	break;
		default:
			throw CError(E_EXP_TYPEMISMATCH);
			break;
		}

		SetInt(tempVar3, result);
		CExprStack::push(tempVar3);
	}
	else
	{
		throw CError(E_EXP_TYPEMISMATCH);
	}
}

void CEvaluate::Negate()
{
    if (*tempVar1 == SID_CINT)
	{
		short op = GetInt(tempVar1);

		SetInt(tempVar3, -op);
		CExprStack::push(tempVar3);
	}
	else if (*tempVar1 == SID_CFLOAT)
	{
		float op = GetFloat(tempVar1);

		SetFloat(tempVar3, -op);
		CExprStack::push(tempVar3);
	}
	else
	{
		throw CError(E_EXP_TYPEMISMATCH);
	}
}

void CEvaluate::Not()
{
	short op;

	switch (*tempVar1)
	{
	case SID_CINT: op = GetInt(tempVar1);	break;
	case SID_CFLOAT: 
		{
			float fVal = GetFloat(tempVar1);
			if (fVal>32767.0 || fVal<-32768.0)
			{
				throw CError(E_EXP_OVERFLOW);    				
			}
			
			op = (short)fVal;
		}
		break;
	default:
		throw CError(E_EXP_TYPEMISMATCH);    
	}

	SetInt(tempVar3, ~op);
	CExprStack::push(tempVar3);
}

void CEvaluate::Abs()
{    
	if (*tempVar1 == SID_CINT)
	{
		short op = GetInt(tempVar1);
		
		if (op < 0)
		{
			SetInt(tempVar3, -op);
		}
		else
		{
			SetInt(tempVar3, op);
		}

		CExprStack::push(tempVar3);
	}
	else if (*tempVar1 == SID_CFLOAT)
	{
		float op = GetFloat(tempVar1);

		if (op < 0)
		{
			SetFloat(tempVar3, -op);
		}
		else
		{
			SetFloat(tempVar3, op);
		}

		CExprStack::push(tempVar3);
	}
	else
	{
		throw CError(E_EXP_TYPEMISMATCH);
	}
}

void CEvaluate::Asc()
{
	if (*tempVar1 == SID_CSTR)
	{
		char ch = 0;
	
		// Check length first
		if (*(tempVar1+1) == 0)
		{
			throw CError(E_EXP_ILLEGAL);
		}

		WORD offset = *((WORD *)(tempVar1+2));

		ch = Memory[offset];
		
		SetInt(tempVar3, ch);

		CExprStack::push(tempVar3);
	}
	else
	{
		throw CError(E_EXP_TYPEMISMATCH);
	}
}

void CEvaluate::Int()
{
	switch (*tempVar1)
	{
	case SID_CINT: break; // nothing to do
	case SID_CFLOAT: 
		{
			float fVal = GetFloat(tempVar1);
			if (fVal>32767.0 || fVal<-32768.0)
			{
				throw CError(E_EXP_OVERFLOW);    				
			}
			SetInt(tempVar1, (short)fVal);
		}
		break;
	default:
		throw CError(E_EXP_TYPEMISMATCH);
	}

	CExprStack::push(tempVar1);
}

void CEvaluate::Len()
{
	if (*tempVar1 == SID_CSTR)
	{
		short len = *(tempVar1+1);
		
		SetInt(tempVar3, len);

		CExprStack::push(tempVar3);
	}
	else
	{
		throw CError(E_EXP_TYPEMISMATCH);
	}
}

void CEvaluate::Peek()
{
	WORD address;
	switch (*tempVar1)
	{
	case SID_CINT: 
		address = GetInt(tempVar1);
		break; 
	case SID_CFLOAT: 
		{
			float fVal = GetFloat(tempVar1);
			if (fVal>65535.0 || fVal<0.0)
			{
				throw CError(E_EXP_ILLEGAL);    				
			}

			address = (WORD)fVal;
		}
		break;
	default:
		throw CError(E_EXP_TYPEMISMATCH);
	}

	SetInt(tempVar1, Memory[address]);

	CExprStack::push(tempVar1);
}

void CEvaluate::Rnd()
{
	switch (*tempVar1)
	{
	case SID_CINT: 
	case SID_CFLOAT: 
		{
			float fVal = (float)rand()/(float)RAND_MAX;

			SetFloat(tempVar1, fVal);

			CExprStack::push(tempVar1);
		}
		break;
	default:
		throw CError(E_EXP_TYPEMISMATCH);
	}
}

void CEvaluate::Sgn()
{
	if (*tempVar1 == SID_CINT)
	{
		short op = GetInt(tempVar1);
		
		if (op < 0)
		{
			SetInt(tempVar3, -1);
		}
		else if (op > 0)
		{
			SetInt(tempVar3, +1);
		}
		else
		{
			SetInt(tempVar3, 0);
		}

		CExprStack::push(tempVar3);
	}
	else if (*tempVar1 == SID_CFLOAT)
	{
		float op = GetFloat(tempVar1);

		if (op < 0)
		{
			SetInt(tempVar3, -1);
		}
		else if (op > 0)
		{
			SetInt(tempVar3, +1);
		}
		else
		{
			SetInt(tempVar3, 0);
		}

		CExprStack::push(tempVar3);
	}
	else
	{
		throw CError(E_EXP_TYPEMISMATCH);
	}
}

void CEvaluate::Sqr()
{	
	float val;

	if (*tempVar1 == SID_CINT)
	{
		val = GetInt(tempVar1);
	}
	else if (*tempVar1 == SID_CFLOAT)
	{
		val = GetFloat(tempVar1);
	}
	else
	{
		throw CError(E_EXP_TYPEMISMATCH);
	}

	if (val < 0.0)
	{
		throw CError(E_EXP_ILLEGAL);
	}

	SetFloat(tempVar3, (float)sqrt(val));
	CExprStack::push(tempVar3);
}

void CEvaluate::Val()
{
	if (*tempVar1 == SID_CSTR)
	{
		// Check length first
		if (*(tempVar1+1) == 0)
		{
			throw CError(E_EXP_ILLEGAL);
		}

		WORD offset = *((WORD *)(tempVar1+2));

		int dummy;
		float value;

		stringToFloat(Memory+offset, value, dummy);

		SetFloat(tempVar3, value);

		CExprStack::push(tempVar3);
	}
	else
	{
		throw CError(E_EXP_TYPEMISMATCH);
	}
}
