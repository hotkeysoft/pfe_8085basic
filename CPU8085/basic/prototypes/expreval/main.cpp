// main.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#include "..\tokenize\tokenize.h"
#include "..\tokenize\untokenize.h"
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

	LoAutoVars = Memory+2048;
	HiAutoVars = Memory+2048;

	char str[256];

	char out[256];

	while (1)
	{
		std::cin.getline((char *)Memory, 255);
		if (strcmp(str, "") == 0)
			break;

		try
		{
			tokenize1((char *)Memory);
			tokenize2((char *)Memory, (char *)(Memory+256));

			std::cout << untokenize((char *)(Memory+256)) << std::endl;

			expreval((char *)(Memory+256), out);

			CExprStack::Dump();

			CExprStack::Empty();
//			std::cout << untokenize(out) << std::endl;
		}
		catch (CError e)
		{
			std::cerr << e;
		}
	}

	return 0;
}

