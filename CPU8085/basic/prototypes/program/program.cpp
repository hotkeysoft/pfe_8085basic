#include "stdafx.h"

#include "program.h"
#include "..\tokenize\untokenize.h"

#include <iostream>

// Basic line:  [Size][Line]Data.......[Size][Line]Data....etc...
//				[  8 ][ 16 ]...........[  8 ][ 16 ]..............
//				<---------Size-------->

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