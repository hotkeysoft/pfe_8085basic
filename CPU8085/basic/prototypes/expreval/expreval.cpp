// expreval.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#include "..\include\common.h"

#include <string>
#include <iostream>


BYTE Memory[65536];
								
int main(int argc, char* argv[])
{
	std::string varName;

	BYTE test[2] = {128 + 11, 0};

	while(1)
	{
		std::cout << "Var name: ";
		std::cin >> varName;
		if (varName == "")
			break;

		Name2Tag(varName, test);
		Tag2Name(test, varName);

		std::cout << "Got back " << varName << std::endl;
	}


	return 0;
}

