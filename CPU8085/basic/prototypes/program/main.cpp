// main.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#include "..\tokenize\tokenize.h"
#include "..\tokenize\untokenize.h"
#include "..\variables\variables.h"
#include "..\strings\strings.h"

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

	BYTE tag1[2];
	BYTE tag2[2];
	BYTE tag3[2];
	BYTE tag4[2];
	BYTE tag5[2];

	try
	{

	}
	catch (CError e)
	{
		std::cerr << e;
	}

	return 0;
}

