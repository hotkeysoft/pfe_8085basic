#include "stdafx.h"
#include "evaluate.h"
#include "exprstack.h"

#include <math.h>
#include <assert.h>

CEvaluate::CEvaluate(void)
{
}

CEvaluate::~CEvaluate(void)
{
}

short CEvaluate::GetInt(BYTE *var)
{
	assert(*var == SID_CINT);
	return *((short *)(var+1));
}

float CEvaluate::GetFloat(BYTE *var)
{
	assert(*var == SID_CFLOAT);
	return *((float *)(var+1));
}

void CEvaluate::SetInt(BYTE *var, short value)
{
	*var = SID_CINT;
	*((short *)(var+1)) = value;
}

void CEvaluate::SetFloat(BYTE *var, float value)
{
	*var = SID_CFLOAT;
	*((float  *)(var+1)) = value;
}

void CEvaluate::Evaluate(KEYWORDS k)
{
	switch(k)
	{
	case K_POWER:		BinaryOp(k); ConvertToSameType();	BinaryCalc(k); break;
	case K_MULTIPLY:	BinaryOp(k); ConvertToSameType();	BinaryCalc(k); break;
	case K_FDIVIDE:		BinaryOp(k); ConvertToFloat();		BinaryCalc(k); break;
	case K_IDIVIDE:		BinaryOp(k); ConvertToInt();		BinaryCalc(k); break;
	case K_ADD:			BinaryOp(k); ConvertToSameType();	BinaryCalc(k); break;
	case K_SUBSTRACT:	BinaryOp(k); ConvertToSameType();	BinaryCalc(k); break;
	default:
		break;
	}
}

void CEvaluate::BinaryOp(KEYWORDS k)
{
	BYTE *op1 = CExprStack::pop();
	BYTE *op2 = CExprStack::pop();

	if (*op1 == SID_VAR)
	{
		throw CError();
	}
	else
	{
		memcpy(tempVar1, op1, 5);
	}

	if (*op2 == SID_VAR)
	{
		throw CError();
	}
	else
	{
		memcpy(tempVar2, op2, 5);
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
		case K_IDIVIDE:		result = op2 / op1;		break;
		case K_ADD:			result = op2 + op1;		break;
		case K_SUBSTRACT:	result = op2 - op1;		break;
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
		case K_FDIVIDE:		result = op2 / op1;		break;
		case K_ADD:			result = op2 + op1;		break;
		case K_SUBSTRACT:	result = op2 - op1;		break;
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
