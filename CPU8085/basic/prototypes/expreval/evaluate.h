#pragma once

#include "..\include\common.h"

class CEvaluate
{
public:
	CEvaluate(void);
	~CEvaluate(void);

	static void Evaluate(KEYWORDS);

protected:
	static void BinaryOp();
	static void UnaryOp();

	static void ConvertToSameType();
	static void ConvertToFloat();
	static void ConvertToInt();

	static short GetInt(BYTE *);
	static float GetFloat(BYTE *);

	static void SetInt(BYTE *, short);
	static void SetFloat(BYTE *, float);

	static void BinaryCalc(KEYWORDS);
	static void BinaryRel(KEYWORDS);
	static void BinaryLog(KEYWORDS);
	static void Not();
	static void Negate();

	static void Abs();
	static void Asc();
	static void Int();
	static void Len();
	static void Peek();
	static void Rnd();
	static void Sgn();
	static void Sqr();
	static void Val();
};

