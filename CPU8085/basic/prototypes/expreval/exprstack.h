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

protected:
	static void pushCINT(BYTE *);
	static void pushCFLOAT(BYTE *);
	static void pushCSTR(BYTE *);
	static void pushVAR(BYTE *);
};
