// main.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#include "tokenize.h"
#include "untokenize.h"
#include <iostream>
#include <string>

int main(int argc, char* argv[])
{
	char str[256];
	char tok1[256];
	char tok2[256];

	std::string line;

	while (1)
	{
		std::cin.getline(str, 255);
		if (strcmp(str, "") == 0)
			break;

		try
		{
			tokenize1(str, tok1);
			tokenize2(tok1, tok2);

			std::cout << untokenize(tok2) << std::endl;
		}
		catch (CError e)
		{
			std::cerr << e;
		}
	}

	return 0;
}

