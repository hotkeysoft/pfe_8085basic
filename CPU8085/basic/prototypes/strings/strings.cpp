#include "stdafx.h"

#include "strings.h"

CStrings::CStrings(void)
{
}

CStrings::~CStrings(void)
{
}

BYTE *CStrings::Allocate(WORD refBy, BYTE size)
{
    LoStrStack -= (size + sizeof(WORD) + sizeof(BYTE));
	*((WORD *)LoStrStack) = refBy;
	*(LoStrStack+2) = size;
	return LoStrStack+3;
}

void CStrings::Free(BYTE *address)
{
	*((WORD *)(address-3)) = 0;	
}

void CStrings::GarbageCollection()
{

}

void CStrings::Dump()
{
	BYTE *curr = LoStrStack;

	int index = 0;

	std::cerr << "Strings:" << std::endl;

	while (curr < HiStrStack)
	{
		WORD refBy = *((WORD *)curr);
		BYTE size = *(curr+2);

		std::string str; 
		str.assign(((char *)curr+3), size);

		std::cerr << index << "," << refBy << "," << (int)size << "\t" << str << std::endl;

		curr += size+sizeof(WORD)+sizeof(BYTE);
		index++;
	}

}

