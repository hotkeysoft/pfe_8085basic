// main.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#include "..\tokenize\tokenize.h"
#include "..\tokenize\untokenize.h"
#include "..\variables\variables.h"
#include "..\strings\strings.h"
#include "program.h"

#include <iostream>
#include <string>

int main(int argc, char* argv[])
{
	LoExpStack = Memory+1024;
	HiExpStack = LoExpStack+80;
	CurrExpStack = LoExpStack;

	LoStrStack = Memory+30000;
	HiStrStack = LoStrStack;

	LoProgram = Memory+2048;
	HiProgram = Memory+2048;

	LoAutoVars = Memory+2048;
	HiAutoVars = Memory+2048;

	tempVar1 = Memory+768;
	tempVar2 = tempVar1+5;
	tempVar3 = tempVar2+5;

	try
	{
		char str[256] = "print A, B, C$: goto 10 ";
		char str2[256];
		tokenize1(str);
		BYTE length = tokenize2(str, str2);

		CProgram::Insert(10, (BYTE *)str2, length);
		CProgram::Insert(20, (BYTE *)str2, length);
		CProgram::Insert(30, (BYTE *)str2, length);
		CProgram::Insert(40, (BYTE *)str2, length);
		CProgram::Insert(50, (BYTE *)str2, length);
		CProgram::Insert(60, (BYTE *)str2, length);

		CProgram::List();

		//std::cout << "Remove 10" << std::endl;
		//CProgram::Remove(10);
		//CProgram::List();

		//std::cout << "Remove 60" << std::endl;
		//CProgram::Remove(60);
		//CProgram::List();

		//std::cout << "Remove 40" << std::endl;
		//CProgram::Remove(40);
		//CProgram::List();

		strcpy(str, "For i=1 to 10:print i: next i");
		tokenize1(str);
		length = tokenize2(str, str2);

		//std::cout << "Inserting 5, 12, 32, 4" << std::endl;
		//CProgram::Insert(5, (BYTE *)str2, length);
		//CProgram::Insert(12, (BYTE *)str2, length);
		//CProgram::Insert(32, (BYTE *)str2, length);
		//CProgram::Insert(4, (BYTE *)str2, length);
		
		std::cout << "Replacing 10, 60" << std::endl;
		CProgram::Insert(10, (BYTE *)str2, length);
		CProgram::Insert(60, (BYTE *)str2, length);

		CProgram::List();

	}
	catch (CError e)
	{
		std::cerr << e;
	}

	return 0;
}

