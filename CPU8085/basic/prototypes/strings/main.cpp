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
	{
	}
	catch (CError e)
	{
		std::cerr << e;
	}

	return 0;
}

