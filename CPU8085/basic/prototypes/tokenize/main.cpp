// main.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#include "tokenize.h"
#include "untokenize.h"

#include "..\include\error.h"

int main(int argc, char* argv[])
{
	char str[256];
	char tok1[256];
	char tok2[256];

	strcpy(str, "10 a = -123.45E+2: let variable$ = \"blah\" + chr$(147): i = sqr ( abs ( -2.5 * B - -Z) )");

	try
	{
		tokenize1(str, tok1);
		tokenize2(tok1, tok2);

		std::cout << str << std::endl << std::endl;
		std::cout << untokenize(tok1) << std::endl << std::endl;
		std::cout << untokenize(tok2) << std::endl;
	}
	catch (CError e)
	{
		std::cerr << e;
	}

	return 0;
}

