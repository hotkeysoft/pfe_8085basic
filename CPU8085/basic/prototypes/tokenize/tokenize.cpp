#include "stdafx.h"

#include "..\include\common.h"
#include "tokenize.h"

// Returns token ID from string token
bool findToken(const char *in, char &token, int &length)
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

// Returns string token from ID
const char *findTokenStr(const unsigned char token)
{
	Keyword *currKeyword = keywords;

	while (currKeyword->id)
	{
		if (currKeyword->id == (token))
		{
			return currKeyword->name;
		}

		++currKeyword;
	}

	return NULL;
}

// Tokenize, pass 1: converts keywords to tokens,
// ignore variables, constants & delimiters
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

	unsigned char lastToken = 0;

	while(1)
	{
		if (*currIn == NULL)
		{
			*currOut = NULL;
			break;
		}

		switch(*currIn)
		{
		case '(':
		case ')':
		case ':':
		case ';':
		case ',':
			*currOut = *currIn;
			++currIn;
			++currOut;
			lastToken = *currIn;
			break;

		case ' ':	// whitespace.. should be ignored
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
			lastToken = *currIn;
			break;

		case '-':	// special case not handled by findToken function
			switch (lastToken)
			{
			// could be simplified, if whole category is used (check MSBits = 0x80)
			case K_POWER:
			case K_NEGATE:
			case K_MULTIPLY:
			case K_DIVIDE:		
			case K_ADD:
			case K_SUBSTRACT:
			case K_LESSEQUAL:
			case K_GREATEREQUAL:
			case K_LESS:
			case K_GREATER:
			case K_EQUAL:
			case K_NOT:
			case K_AND:
			case K_OR:
			case K_XOR:
			case K_ASSIGN:

			case '(':
			case ':':
			case ';':
			case ',':
				*currOut = (char)K_NEGATE;
				++currIn;
				++currOut;
				lastToken = (char)K_NEGATE;	
				break;

			default: 
				*currOut = (char)K_SUBSTRACT;
				++currIn;
				++currOut;
				lastToken = (char)K_SUBSTRACT;	
				break;
			}
			break;
		default:
			if (findToken(currIn, token, tokenLength))
			{
				*currOut = token;
				currOut++;
				currIn += tokenLength;
				lastToken = token;
			}
			else
			{
				*currOut = *currIn;
				++currIn;
				++currOut;
				lastToken = 0;
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
