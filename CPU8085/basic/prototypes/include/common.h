#ifndef __COMMON_H_INCLUDED
#define __COMMON_H_INCLUDED

#include <string>

typedef unsigned char BYTE;
typedef unsigned short WORD;

enum StackID {	SID_CINT=1, SID_SFLOAT=2, SID_CSTR=4,
				SID_VAR=8,	SID_FBASE=128};

const std::string variableNameStr = " 0123456789"\
									"ABCDEFGHIJKLMNOPQRSTUVWXYZ";


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