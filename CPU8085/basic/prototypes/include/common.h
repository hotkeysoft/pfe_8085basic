#ifndef __COMMON_H_INCLUDED
#define __COMMON_H_INCLUDED

#include <string>

typedef unsigned char BYTE;
typedef unsigned short WORD;

enum StackID {	SID_CINT=1, SID_SFLOAT=2, SID_CSTR=4,
				SID_VAR=8,	SID_FBASE=128};

const std::string variableNameStr = " 0123456789"\
									"ABCDEFGHIJKLMNOPQRSTUVWXYZ";


struct Keywords
{
	int id;
	const char *name;
} keywords[] = {
	// arithmetic operators
	0x80, "^",	// power

	0x81, "-",	// negation (unary)

	0x82, "*",	// multiplication
	0x83, "/",	// division
		
	0x84, "+",	// addition
	0x85, "-",	// subtraction

	0x86, "<=",	// less or equal
	0x87, ">=",	// greater or equal
	0x88, "<",	// less than
	0x89, ">",	// greater than 
	0x9A, "==",

	0x9B, "NOT",	// logical & bitwise negation
	0x9C, "AND",	// logical & bitwise AND
	0x9D, "OR",		// logical & bitwise OR
	0x9E, "XOR",	// logical & bitwise exclusive-OR

	// numeric functions (return int or float)
	0xA0, "ABS",
	0xA1, "ASC",
	0xA2, "INT",
	0xA3, "IN",
	0xA4, "LEN",
	0xA5, "PEEK",
	0xA6, "RND",
	0xA7, "SGN",
	0xA8, "SQR",
	0xA9, "VAL",
	
	// string functions (return string)
	0xB0, "CHR$",
	0xB1, "LEFT$",
	0xB2, "MID$",
	0xB3, "RIGHT$",
	0xB4, "STR$",

	// methods (doesn't return value)
	0xC0, "CLR",
	0xC1, "CONT",
	0xC2, "DIM",
	0xC3, "END",
	0xC4, "FOR",
	0xC5, "GOSUB",
	0xC6, "GOTO",
	0xC7, "IF",
	0xC8, "INPUT",
	0xC9, "LET",
	0xCA, "LIST",
	0xCB, "NEW",
	0xCC, "NEXT",
	0xCD, "OUT",
	0xCE, "POKE",
	0xCF, "PRINT",
	0xD0, "REM",
	0xD1, "RETURN",
	0xD2, "RUN",
	0xD3, "STEP",
	0xD4, "SYS",
	0xD5, "THEN",
	0xD6, "TO"
};


bool Tag2Name(const WORD tag[2], std::string &name)
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

bool Name2Tag(std::string name, WORD tag[2])
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

	return true;
}

#endif