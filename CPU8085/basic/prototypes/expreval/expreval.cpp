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

	WORD test[2] = {128 + 11, 0};

	while(1)
	{
		std::cout << "Var name: ";
		std::cin >> varName;
		if (varName == "")
			break;

		bool ret1 = Name2Tag(varName, test);
		bool ret2 = Tag2Name(test, varName);

		if (ret1 == false)
		{
			std::cout << "Name2Tag failed..." << std::endl;
		}
		else if (ret2 == false)
		{
			std::cout << "Tag2Name failed..." << std::endl;
		}
		else
		{
			std::cout << "Got back " << varName << std::endl;
		}
	}


	return 0;
}

