// main.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#include "tokenize.h"
#include "untokenize.h"

int main(int argc, char* argv[])
{
	char str[256];
	char tok1[256];

	strcpy(str, "10 let variable$ = \"blah\" + chr$(147): i = sqr ( abs ( -2.5 * B - -Z) )");

	tokenize1(str, tok1);

	std::cout << untokenize(tok1) << std::endl;
	

	return 0;
}

