#include "stdafx.h"

#include "program.h"
#include "..\tokenize\untokenize.h"
#include "..\expreval\exprstack.h"

#include <iostream>

extern void expreval(char *in);

// Basic line:  [Size][Line]Data.......[Size][Line]Data....etc...
//				[  8 ][ 16 ]...........[  8 ][ 16 ]..............
//				<---------Size-------->

BYTE *CProgram::NewLine = NULL;
BYTE *CProgram::CurrLine = NULL;
BYTE *CProgram::CurrPos = NULL;
bool CProgram::IsEnd = false;

void CProgram::New()
{
	HiProgram = LoProgram;

	LoAutoVars = HiProgram;
	HiAutoVars = HiProgram;
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
		throw CError();
	}

	IsEnd = false;

	while (IsEnd == false && CurrLine < HiProgram)
	{
		NewLine = NULL;

		std::cout << std::endl << *((WORD *)(CurrLine+1)) << "\t";

		if (CurrPos)
		{
			BYTE *temp = CurrPos;
			CurrPos = 0;
			expreval((char *)(temp+3));
		}
		else
		{
			expreval((char *)(CurrLine+3));
		}

		if (CurrPos)
		{
			CurrLine = NewLine;
		}
		else if (NewLine)
		{
			CurrLine = NewLine;
			CurrPos = 0;
		}
		else
		{
			CurrLine+=*CurrLine;
			CurrPos = 0;
		}
	}  	
}

void CProgram::Goto(short lineNo)
{
	NewLine = Find(lineNo);

	if (NewLine == NULL)
	{
		throw CError();
	}
}

void CProgram::Gosub(short lineNo, BYTE *returnPoint)
{
	NewLine = Find(lineNo);

	if (NewLine == NULL)
	{
		throw CError();
	}

	BYTE temp[5];

	*temp = SID_GOSUB;
	*((WORD *)(temp+1)) = (WORD)(CurrLine-Memory);
	*((WORD *)(temp+3)) = (WORD)(returnPoint-Memory);

	CExprStack::push(temp);
}

void CProgram::Return()
{
	BYTE *temp = CExprStack::pop();

	if (*temp != SID_GOSUB)
	{
		throw CError();
	}

	NewLine = Memory+*((WORD *)(temp+1));
	CurrPos = Memory+*((WORD *)(temp+3));
}

void CProgram::End()
{
	IsEnd = true;
}

void CProgram::Stop()
{
	IsEnd = true;
}

void CProgram::Continue()
{

}