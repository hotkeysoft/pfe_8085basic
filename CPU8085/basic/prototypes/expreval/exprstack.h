#pragma once

#include "..\include\common.h"

class CExprStack
{
public:
	CExprStack(void);
	~CExprStack(void);

	static void push(BYTE *);
	static BYTE *pop();

	static void Dump();
	static void Empty() {CurrExpStack = LoExpStack;}

};
