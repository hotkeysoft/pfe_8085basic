// expreval.cpp
//

#include "stdafx.h"
#include "expreval.h"
#include "evaluate.h"
#include "exprstack.h"
#include "..\program\program.h"
#include "..\variables\variables.h"

BYTE *currIn;

void Execute(bool inIf = false, bool execute = true);

void L1();
void L2();
void L3();
void L4();
void L5();
void L6();
void L7();

void SkipWhitespace()
{
	while(*currIn == ' ')
	{
		++currIn;
	}
}

void L0()
{
	SkipWhitespace();

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
	SkipWhitespace();

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

			SkipWhitespace();

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

	SkipWhitespace();	
}

void DoList(bool execute)
{
	++currIn;
	if (execute)
	{
		CProgram::List();
	}
}

void DoPrint(bool execute)
{
	++currIn;

	bool insertNewLine = true;

	while(*currIn && !(*currIn==':' || *currIn==K_ELSE))
	{
		insertNewLine = true;

		L0();

		CEvaluate::UnaryOp();	// value in tempVar1
		if (execute)
		{
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
		}

		switch(*currIn)
		{
		case ',':	
			if (execute) {std::cout << '\t';} ++currIn; break;
		case ';':	++currIn;	insertNewLine = false; break;
		case ':':	break;
		case 0:		break;
		case K_ELSE:break;
		default:	throw CError(E_EXP_SYNTAX);
		}
	}

	if (insertNewLine && execute)
	{
		std::cout << std::endl;
	}
}

void DoLet(bool execute, bool keyword)
{
	if (keyword == true)
	{
		++currIn;

		SkipWhitespace();
	}

	if (*currIn != SID_VAR)
	{
		throw CError(E_EXP_SYNTAX);
	}

	++currIn;
	BYTE variableName[2];
	variableName[0] = *currIn++;
	variableName[1] = *currIn++;

	SkipWhitespace();

	if (*currIn != K_ASSIGN)
	{
		throw CError(E_EXP_SYNTAX);
	}

	++currIn;

	// Get Expression
	L0();

	CEvaluate::UnaryOp();	// value in tempVar1

	if (execute)
	{
		CVariables::Set(variableName, tempVar1);
	}
}

void DoClr(bool execute)
{
	++currIn;
	if (execute)
	{
		HiAutoVars = LoAutoVars;
	}
}

void DoNew(bool execute)
{
	++currIn;
	if (execute)
	{
		CProgram::New();
	}
}

void DoGoto(bool execute)
{
	++currIn;
	short lineNo;

	L0();

	CEvaluate::UnaryOp();	// value in tempVar1

	if (*tempVar1 == SID_CINT)
	{
		lineNo = GetInt(tempVar1);
	}
	else if (*tempVar1 == SID_CFLOAT) 
	{
		float fLineNo = GetFloat(tempVar1);
        if (fLineNo<1.0f || fLineNo>32767.0f)
		{
			throw CError(E_EXP_ILLEGAL);
		}

        lineNo = (short)fLineNo;
	}
	else 
	{
		throw CError(E_EXP_TYPEMISMATCH);
	}


	if (execute)
	{
		std::cout << "GOTO " << lineNo << std::endl;
	}
	else
	{
		std::cout << "SKIP_GOTO " << lineNo << std::endl;
	}
}

void DoIf(bool execute)
{
	++currIn;

	// Get Expression
	L0();

	CEvaluate::UnaryOp();	// value in tempVar1

	bool result;

	switch(*tempVar1)
	{
	case SID_CINT:		result = GetInt(tempVar1)==0?false:true; break;
	case SID_CFLOAT:	result = GetFloat(tempVar1)==0.0?false:true; break;
	default: throw CError(E_EXP_TYPEMISMATCH);
	}

	SkipWhitespace();

	if (*currIn == K_THEN)
	{
		++currIn;

		Execute(true, result);
	}
	else if (*currIn == K_GOTO)
	{
//		++currIn;

		//DoGoto(result);
		Execute(true, result);
	}
	else throw CError(E_EXP_SYNTAX);
}

void DoElse(bool inIf, bool execute)
{
	++currIn;

	if (inIf == false)
	{
		throw CError(E_EXP_ELSEWITHOUTIF);
	}

	Execute(false, !execute);
}

void Execute(bool inIf, bool execute)
{
	while (*currIn)
	{

		// skip whitespace
		while(*currIn == ' ' || *currIn == ':')
		{
			++currIn;
		}

		switch(*currIn)
		{
		case K_LIST:		DoList(execute);		break;
		case K_PRINT:		DoPrint(execute);		break;
		case K_CLR:			DoClr(execute);			break;
		case K_NEW:			DoNew(execute);			break;
		case K_LET:			DoLet(execute, true);	break;
		case SID_VAR:		DoLet(execute, false);	break;
		case K_IF:			DoIf(execute);			break;
		case K_ELSE:		DoElse(inIf, execute);	break;
		case K_GOTO:		DoGoto(execute);		break;

		default: throw CError();
		}

		SkipWhitespace();

		if (*currIn && !(*currIn == ':' || *currIn == K_ELSE))
		{
			throw CError();
		}
	}
}

void expreval(char *in)
{
	currIn = (BYTE *)in;

	Execute();
}
