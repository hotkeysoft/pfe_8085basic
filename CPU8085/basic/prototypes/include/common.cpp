#include "stdafx.h"

#include "common.h"
#include <math.h>

Keyword keywords[] = {
	// arithmetic operators
	K_POWER,		"^",

	K_NEGATE,		"-",	// negation (unary)

	K_MULTIPLY,		"*",
	K_DIVIDE,		"/",
		
	K_ADD,			"+",
	K_SUBSTRACT,	"-",

	K_LESSEQUAL,	"<=",
	K_GREATEREQUAL, ">=",
	K_LESS,			"<",
	K_GREATER,		">",
	K_EQUAL,		"==",

	K_NOT,			"NOT",	// logical & bitwise negation
	K_AND,			"AND",	// logical & bitwise AND
	K_OR,			"OR",	// logical & bitwise OR
	K_XOR,			"XOR",	// logical & bitwise exclusive-OR

	K_ASSIGN,		"=",	// assignation operator

	// numeric functions (return int or float)
	K_ABS,			"ABS",
	K_ASC,			"ASC",
	K_INT,			"INT",
	K_IN,			"IN",
	K_LEN,			"LEN",
	K_PEEK,			"PEEK",
	K_RND,			"RND",
	K_SGN,			"SGN",
	K_SQR,			"SQR",
	K_VAL,			"VAL",
	
	// string functions (return string)
	K_CHR,			"CHR$",
	K_LEFT,			"LEFT$",
	K_MID,			"MID$",
	K_RIGHT,		"RIGHT$",
	K_STR,			"STR$",

	// methods (doesn't return value)
	K_CLR,			"CLR",
	K_CONT,			"CONT",
	K_DIM,			"DIM",
	K_END,			"END",
	K_FOR,			"FOR",
	K_GOSUB,		"GOSUB",
	K_GOTO,			"GOTO",
	K_IF,			"IF",
	K_INPUT,		"INPUT",
	K_LET,			"LET",
	K_LIST,			"LIST",
	K_NEW,			"NEW",
	K_NEXT,			"NEXT",
	K_OUT,			"OUT",
	K_POKE,			"POKE",
	K_PRINT,		"PRINT",
	K_PRINT,		"?",
	K_REM,			"REM",
	K_RETURN,		"RETURN",
	K_RUN,			"RUN",
	K_STEP,			"STEP",
	K_SYS,			"SYS",
	K_THEN,			"THEN",
	K_TO,			"TO",
	K_NONE,			NULL
};


bool Tag2Name(const BYTE tag[2], std::string &name)
{
	BYTE char1;
	BYTE char2;

	char suffix;

	BYTE hi2 = tag[0] & 192;

	if (hi2 == 0)			// 00xxxxxx = float
	{
		suffix = 0;
	}
	else if (hi2 == 64)		// 01xxxxxx = int
	{
		suffix = '%';
	}
	else if (hi2 == 128)	// 10xxxxxx = string
	{
		suffix = '$';
	}
	else
	{
		return false;
	}

	char1 = tag[0] & 63;	// 00xxxxxx
	char2 = tag[1] & 63;	// 00xxxxxx

	if (char1 < 11 ||
		char1 >= variableNameStr.length() || 
		char2 >= variableNameStr.length())
	{
		return false;
	}

	name = variableNameStr[char1];

	if (char2 > 0)
	{
		name += variableNameStr[char2];
	}

	if (suffix != 0)
	{
		name += suffix;
	}

	return true;
}

bool Name2Tag(std::string name, BYTE tag[2])
{
	// first character
	if (name.length() < 1 || !isalpha(name[0]))
	{
		return false;		
	}

	tag[0] = variableNameStr.find(toupper(name[0]));
	if (tag[0] == std::string::npos)
	{
		return false;
	}

	// modifier (last char of string)
	switch (name[name.length()-1])
	{
		case '$':	tag[0] |= 128;	name.erase(name.end()-1);	break;
		case '%':	tag[0] |= 64;	name.erase(name.end()-1);	break;
		default:	break;
	}

	if (name.length() > 1)
	{
		if (!isalpha(name[1]) && !isdigit(name[1]))
		{
			return false;
		}

		tag[1] = variableNameStr.find(toupper(name[1]));
		if (tag[1] == std::string::npos)
		{
			return false;
		}
	}
	else
	{
		tag[1] = 0x00;
	}

	return true;
}

bool stringToFloat(const char *currIn, float &number, int &length)
{
	length = 0;
	number = 0;

	int ExpInt = 0;

	int Exp = 0;	
	bool ExpPositive = true;


	bool positive = true;

	// sign
	if (*currIn == '-')
	{
		positive = false;
		++currIn;
		++length;
	}
	else if (*currIn == '+')
	{
		positive = true;
		++currIn;
		++length;
	}

	// integer part
	while(isdigit(*currIn))
	{
		number *= 10.0;
		number += (*currIn - '0');

		++currIn;
		++length;
	}

	// decimal part
	if (*currIn == '.')
	{
		++currIn;
		++length;

		while(isdigit(*currIn))
		{
			number *= 10.0;
			number += (*currIn - '0');

			++currIn;
			++length;

			--ExpInt;
		}
	}

	// exp part
	if (toupper(*currIn) == 'E')
	{
		++currIn;
		++length;

		// sign
		if (*currIn == '-')
		{
			ExpPositive = false;
			++currIn;
			++length;
		}
		else if (*currIn == '+')
		{
			ExpPositive = true;
			++currIn;
			++length;
		}

		while(isdigit(*currIn))
		{
			Exp *= 10;
			Exp += (*currIn - '0');

			++currIn;
			++length;
		}

		if (ExpPositive == false)
		{
			Exp = -Exp;
		}
	}

	if (positive == false)
	{
		number = -number;
	}

	number *= pow(10, Exp+ExpInt);

	return true;
}