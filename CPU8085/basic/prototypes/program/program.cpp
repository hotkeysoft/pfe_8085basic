#include "stdafx.h"

#include "program.h"
#include "..\tokenize\untokenize.h"
#include "..\expreval\exprstack.h"
#include "..\expreval\expreval.h"

#include <iostream>

// Basic line:  [Size][Line]Data.......[Size][Line]Data....etc...
//				[  8 ][ 16 ]...........[  8 ][ 16 ]..............
//				<---------Size-------->

BYTE *CProgram::NewLine = NULL;
BYTE *CProgram::CurrLine = NULL;
BYTE *CProgram::CurrPos = NULL;
bool CProgram::IsEnd = false;
bool CProgram::InIf = false;

void CProgram::New()
{
	HiProgram = LoProgram;

	LoAutoVars = HiProgram;
	HiAutoVars = HiProgram;
}

void CProgram::Init()
{
	NewLine = NULL;
	CurrLine = NULL;
	CurrPos = NULL;
	IsEnd = false;
	InIf = false;
}

void CProgram::List(short begin, short end)
{
	BYTE *curr = LoProgram;

	while (curr < HiProgram)
	{
		int size = *curr;

		WORD line = *((WORD *)(curr+1));

		std::cout << line << " " << untokenize((char *)(curr+3)) << std::endl;

		curr += size;
	}
}

void CProgram::Insert(short lineNo, BYTE *contents, BYTE length)
{
	BYTE *insertionPoint = NULL;
	BYTE *addr = Find(lineNo, &insertionPoint);

	if (addr != NULL)
	{
		Remove(addr);
	}
	else
	{
		addr = insertionPoint;
	}

	memmove(addr+length+3, addr, HiProgram-addr);

	*addr = length+3;
	*((WORD *)(addr+1)) = lineNo;

    memcpy(addr+3, contents, length);

	HiProgram += length+3;
	LoAutoVars = HiProgram;
	HiAutoVars = HiProgram;
}

void CProgram::Remove(short lineNo)
{
	BYTE *addr = Find(lineNo);

	if (addr == NULL)		// nothing to do
	{
		return;
	}

	Remove(addr);
}

void CProgram::Remove(BYTE *addr)
{
	BYTE size = *addr;		// size of line-block

	memmove(addr, addr+size, HiProgram-(addr+size));

	HiProgram -= size;
	LoAutoVars = HiProgram;
	HiAutoVars = HiProgram;
}

BYTE *CProgram::Find(short lineNo, BYTE **insertionPoint)
{
	BYTE *curr = LoProgram;

	while (curr < HiProgram)
	{
		WORD currLine = *((WORD *)(curr+1));
		
		if (currLine == lineNo)
		{
			return curr;
		}
		else if (currLine > lineNo)
		{
			if (insertionPoint)
			{
				*insertionPoint = curr;
			}
			return NULL;
		}

		curr += *curr;
	}

	if (insertionPoint)
	{
		*insertionPoint = HiProgram;
	}
	return NULL;
}

void CProgram::Run(short lineNo)
{
	LoAutoVars = HiProgram;
	HiAutoVars = HiProgram;

	if (HiProgram == LoProgram)
	{
		return;
	}

	if (lineNo == 0)
	{
		lineNo = *(WORD *)(LoProgram+1);
	}

	CurrLine = Find(lineNo);
	CurrPos = 0;

	if (CurrLine == NULL)
	{
		throw CError(E_EXP_LINENOTFOUND);
	}

	IsEnd = false;
	InIf = false;
	NewLine = NULL;

	DoIt();
}

void CProgram::DoIt()
{
	while (IsEnd == false && CurrLine < HiProgram)
	{
		if (CurrPos)
		{
			BYTE *temp = CurrPos;
			CurrPos = 0;
			expreval((char *)(temp), InIf);
		}
		else if (CurrLine)
		{
			expreval((char *)(CurrLine+3));
		}

		if (CurrPos)
		{
			CurrLine = NewLine;
			NewLine = 0;
		}
		else if (NewLine)
		{
			CurrLine = NewLine;
			NewLine = 0;
			CurrPos = 0;
			InIf = false;
		}
		else
		{
			CurrLine+=*CurrLine;
			CurrPos = 0;
			InIf = false;
		}
	}  	

	CurrLine = 0;
	CurrPos = 0;
	IsEnd = false;
	InIf = false;
}

void CProgram::Goto(short lineNo)
{
	NewLine = Find(lineNo);

	if (NewLine == NULL)
	{
		throw CError(E_EXP_LINENOTFOUND);
	}

	if (CurrLine == NULL)
	{
		IsEnd = false;
		DoIt();
	}
}

void CProgram::Gosub(short lineNo, BYTE *returnPoint, bool inIf)
{
	NewLine = Find(lineNo);

	if (NewLine == NULL)
	{
		throw CError(E_EXP_LINENOTFOUND);
	}

	BYTE temp[5];

	*temp = SID_GOSUB;
	*((WORD *)(temp+1)) = (WORD)(CurrLine-Memory);
	*(temp+3) = (BYTE)(returnPoint-CurrLine);
	*(temp+4) = (inIf==true)?1:0;

	CExprStack::push(temp);

	if (CurrLine == NULL)
	{
		IsEnd = false;
		DoIt();
	}
}

void CProgram::Return()
{
	BYTE *temp = CExprStack::pop();

	if (*temp != SID_GOSUB)
	{
		throw CError();
	}

	NewLine = Memory+*((WORD *)(temp+1));
	CurrPos = NewLine + *(temp+3);
	InIf = (*(temp+4)==0)?false:true;
}

void CProgram::End()
{
	IsEnd = true;
}

void CProgram::Stop(BYTE *returnPoint, bool inIf)
{
	if (CurrLine == 0)
	{
		std::cout << "Break" << std::endl;
		return;
	}

	IsEnd = true;

	BYTE temp[5];

	*temp = SID_STOP;
	*((WORD *)(temp+1)) = (WORD)(CurrLine-Memory);
	*(temp+3) = (BYTE)(returnPoint-CurrLine);
	*(temp+4) = (inIf==true)?1:0;

	CExprStack::push(temp);

	std::cout << "Break in " << *((short *)(CurrLine+1)) << std::endl;
}

void CProgram::Continue()
{
	if (CExprStack::isEmpty())
	{
		return;
	}

	BYTE *temp = CExprStack::pop();

	if (*temp != SID_STOP)
	{
		throw CError();
	}

	CurrLine = Memory+*((WORD *)(temp+1));
	CurrPos = CurrLine + *(temp+3);
	InIf = (*(temp+4)==0)?false:true;
	IsEnd = false;

	DoIt();
}