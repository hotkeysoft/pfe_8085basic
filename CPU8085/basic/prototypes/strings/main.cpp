// main.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#include "strings.h"

#include <iostream>
#include <string>

int main(int argc, char* argv[])
{
	LoExpStack = Memory+1024;
	HiExpStack = LoExpStack+80;
	CurrExpStack = LoExpStack;

	LoStrStack = Memory+30000;
	HiStrStack = LoStrStack;

	LoAutoVars = Memory+2048;
	HiAutoVars = Memory+2048;

	tempVar1 = Memory+768;
	tempVar2 = tempVar1+5;
	tempVar3 = tempVar2+5;


	try
	{	BYTE *addr1 = CStrings::Allocate(1234, 10);
		strcpy((char *)addr1, "012345678");

		BYTE *addr2 = CStrings::Allocate(1234, 5);
		strcpy((char *)addr2, "toto");

		CStrings::Dump();

		CStrings::Free(addr1);

		CStrings::Dump();
	}
	catch (CError e)
	{
		std::cerr << e;
	}

	return 0;
}

