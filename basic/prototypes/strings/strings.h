#pragma once

#include "..\include\common.h"

class CStrings
{
public:
	CStrings(void);
	~CStrings(void);

	static BYTE *Allocate(WORD refBy, BYTE size);
	static void Free(BYTE *address);

	static void GarbageCollection();

	static void Clear() {LoStrStack = HiStrStack;};

	static void Dump();

protected:

};
