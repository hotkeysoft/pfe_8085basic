// tokenize.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#include <string>
#include <map>

#include "..\include\common.h"

bool findToken(char *in, char &token, int &length)
{
	Keyword *currKeyword = keywords;


	while (currKeyword->id)
	{
		if (strnicmp(in, currKeyword->name, strlen(currKeyword->name)) == 0)
		{
			token = currKeyword->id;
			length = strlen(currKeyword->name);
			return true;
		}

		++currKeyword;
	}

	return false;
}

bool tokenize1(char *in, char *out)
{
	char *currIn = in;
	char *currOut = out;

	char token;
	int tokenLength;

	int lineNo;

	if (isdigit(*in))
	{
		lineNo = atoi(in);
		while (isdigit(*currIn))
		{
			currIn++;	
		}
	}

	while(1)
	{
		if (*currIn == NULL)
		{
			break;
		}

		switch(*currIn)
		{
		case '(':
		case ')':
		case ':':
		case ';':
		case ',':
		case ' ':
			*currOut = *currIn;
			++currIn;
			++currOut;
			break;

		case '\"':
			do
			{
				*currOut = *currIn;
				++currIn;
				++currOut;
			}
			while (*currIn != NULL && *currIn != '\"');

			if (*currIn == NULL)
			{
				return false; // unterminated string constant
			}

			*currOut = *currIn;
			++currIn;
			++currOut;
			break;

		default:
			if (findToken(currIn, token, tokenLength))
			{
				*currOut = token;
				currOut++;
				currIn += tokenLength;
			}
			else
			{
				*currOut = *currIn;
				++currIn;
				++currOut;
			}
			break;
		}
	}

	return true;
}

bool tokenize2(char *in)
{
	int pos = 0;

	while(1)
	{
		char ch = in[pos];


	}

	return true;
}

int main(int argc, char* argv[])
{
	char str[256];
	char tok1[256];
	strcpy(str, "10 let variable$ = \"blah\" + chr$(147): i = sqrt ( abs ( 2.5 * B ) )");

	tokenize1(str, tok1);

	return 0;
}

