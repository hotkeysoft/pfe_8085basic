#include "stdafx.h"

#include "variables.h"
#include "..\strings\strings.h"
#include <string>

void CVariables::Set(BYTE tag[2], BYTE *val)
{
	BYTE *addr = internalGet(tag);

	if (addr == NULL)	// add variable to the list
	{
		addr = New(tag);
	}

	BYTE hi2 = *addr & 192;

	if (hi2 == 0)			// 00xxxxxx = float
	{
		*((float *)(addr+2)) = GetFloat(val);
	}
	else if (hi2 == 64)		// 01xxxxxx = int
	{
		*((short *)(addr+2)) = GetInt(val);
	}
	else if (hi2 == 128)	// 10xxxxxx = string
	{
		BYTE size;
		BYTE *str = GetStr(val, size);

		if (str < LoProgram)	// Must copy
		{
			BYTE *newAddr = CStrings::Allocate((WORD)(addr-Memory), size);
			memcpy(newAddr, str, size);
			str = newAddr;
		}

		*(addr+2) = size;
		*(WORD *)(addr+3) = (WORD)(str-Memory);
	}
	else
	{
		throw CError();
	}
}


BYTE *CVariables::New(BYTE tag[2])
{
	memset(HiAutoVars, 0, 6);

	BYTE *addr = HiAutoVars;

	*HiAutoVars = tag[0];
	*(HiAutoVars+1) = tag[1];

	HiAutoVars += 6;

	return addr;
}



void CVariables::Get(BYTE tag[2], BYTE *var)
{
	BYTE *addr = internalGet(tag);
	if (addr == NULL)
	{
		addr = New(tag);
	}

	BYTE hi2 = *addr & 192;

	if (hi2 == 0)			// 00xxxxxx = float
	{
		SetFloat(var, *((float *)(addr+2)));
	}
	else if (hi2 == 64)		// 01xxxxxx = int
	{
		SetInt(var, *((short *)(addr+2)));
	}
	else if (hi2 == 128)	// 10xxxxxx = string
	{
		BYTE *str = Memory + *((WORD *)(addr+3));
		SetStr(var, str, *(addr+2));
	}
	else
	{
		throw CError();
	}


//	return ret;
}


BYTE *CVariables::internalGet(BYTE tag[2])
{
	BYTE *curr = LoAutoVars;

	while (curr+6 <= HiAutoVars)
	{
		if (*curr == tag[0] && *(curr+1) == tag[1])
		{
			return curr;
		}      
		curr += 6;
	}

	return NULL;
}

void CVariables::Dump()
{
	BYTE *curr = LoAutoVars;

	int index = 0;

	std::cerr << "Variables:" << std::endl;

	while (curr+6 <= HiAutoVars)
	{
		std::string name;
		Tag2Name(curr, name);

		std::cerr << index << "\t" << name << "\t";


		BYTE hi2 = *curr & 192;

		if (hi2 == 0)			// 00xxxxxx = float
		{
			std::cerr << "Fl  = " << *((float *)(curr+2)) << std::endl;
		}
		else if (hi2 == 64)		// 01xxxxxx = int
		{
			std::cerr << "Int = " << *((short *)(curr+2)) << std::endl;
		}
		else if (hi2 == 128)	// 10xxxxxx = string
		{
			std::cerr << "Str = \"";

			BYTE size = *(curr+2);
			WORD offset = *((WORD *)(curr+3));

			std::string str;
			str.assign((char *)(Memory+offset), size);
			
			std::cerr << str << '"' << std::endl;
		}
		else
		{
			throw CError();
		}

		curr += 6;
		index++;
	}

}
