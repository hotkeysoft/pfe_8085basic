// main.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#include "..\tokenize\tokenize.h"
#include "..\tokenize\untokenize.h"
#include "..\variables\variables.h"
#include "..\strings\strings.h"
#include "..\program\program.h"
#include "expreval.h"
#include "exprstack.h"

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

	BYTE tag1[2];
	BYTE tag2[2];
	BYTE tag3[2];
	BYTE tag4[2];
	BYTE tag5[2];

	try
	{
		Name2Tag("pi", tag1);
		Name2Tag("sh%", tag2);
		Name2Tag("a", tag3);
		Name2Tag("b", tag4);
		Name2Tag("a$", tag5);

		SetFloat(tempVar1, (float)3.141592654);
		CVariables::Set(tag1, tempVar1);

		SetInt(tempVar1, 100);
		CVariables::Set(tag2, tempVar1);

		SetFloat(tempVar1, (float)10.0);
		CVariables::Set(tag3, tempVar1);

		SetFloat(tempVar1, (float)7.0);
		CVariables::Set(tag4, tempVar1);

		BYTE *addr = CStrings::Allocate(0, 4);
		memcpy((char *)addr, "1234", 4);

		SetStr(tempVar1, addr, 4);

		CVariables::Set(tag5, tempVar1);

		CVariables::Dump();
	}
	catch (CError e)
	{
		std::cerr << e;
	}

	while (1)
	{
		std::cin.getline((char *)Memory, 255);
		if (strcmp((char *)Memory, "") == 0)
		{
			break;
		}

		try
		{
			CExprStack::Empty();

			if (isdigit(*Memory))
			{
				short line;
				int length;
				stringToShort(Memory, line, length);

				if (line < 1)
				{
					throw CError();
				}

				if (*(Memory+length) == ' ')
				{
					++length;
				}

				tokenize1((char *)(Memory+length));
				BYTE lineLength = tokenize2((char *)(Memory+length), (char *)(Memory+256));

				if (strncmp((char *)(Memory+256), "", lineLength) == 0)
				{
					CProgram::Remove(line);
				}
				else
				{
					CProgram::Insert(line, Memory+256, lineLength);
				}

//				CProgram::List();
			}
			else	// Immediate mode
			{
				tokenize1((char *)Memory);
				tokenize2((char *)Memory, (char *)(Memory+256));

				expreval((char *)(Memory+256));
				std::cout << "Ready." << std::endl;
				CStrings::Dump();
//				CExprStack::Dump();
			}
		}
		catch (CError e)
		{
			std::cerr << e;
		}
	}

	return 0;
}

