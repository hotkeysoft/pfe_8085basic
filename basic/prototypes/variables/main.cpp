// main.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

//#include "..\tokenize\tokenize.h"
//#include "..\tokenize\untokenize.h"
//#include "expreval.h"
//#include "exprstack.h"

#include "variables.h"

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

	Name2Tag("fl", tag1);
	Name2Tag("sh%", tag2);
	Name2Tag("a", tag3);
	Name2Tag("b", tag4);
	Name2Tag("a$", tag5);

	try
	{
		SetFloat(tempVar1, (float)3.141592654);
		SetInt(tempVar2, 3810);

		CVariables::Set(tag1, tempVar1);
		CVariables::Set(tag2, tempVar2);

		CVariables::Dump();

		SetFloat(tempVar1, (float)-666);
		CVariables::Set(tag1, tempVar1);

		CVariables::Dump();

		SetInt(tempVar2, 0);
		CVariables::Set(tag2, tempVar2);



		CVariables::Dump();

		CVariables::Get(tag1, tempVar1);
		CVariables::Get(tag2, tempVar1);
//		CVariables::Get(tag3, tempVar1);
	//	CVariables::Get(tag4);
	}
	catch (CError e)
	{
		std::cerr << e;
	}

	return 0;
}

