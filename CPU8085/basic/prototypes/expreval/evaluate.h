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

	static void BinaryCalc(KEYWORDS);
	static void BinaryRel(KEYWORDS);
	static void BinaryLog(KEYWORDS);
	static void Not();
	static void Negate();

	static void ConvertToSameType();
	static void ConvertToFloat();
	static void ConvertToInt();

	static short GetInt(BYTE *);
	static float GetFloat(BYTE *);

	static void SetInt(BYTE *, short);
	static void SetFloat(BYTE *, float);
};

