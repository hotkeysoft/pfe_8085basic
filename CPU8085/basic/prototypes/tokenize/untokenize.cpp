#include "stdafx.h"

#include "..\include\common.h"
#include "untokenize.h"
#include "tokenize.h"


std::ostream operator<< (std::ostream &os, const untokenize &u)
{
	const char *currChar = u.m_str;

	while (1)
	{
		if (*currChar == NULL)
		{
			break;
		} 
		else if ((*currChar & 0x80) == 0x80)
		{
			if ((unsigned char)*currChar == K_NEGATE)
			{
				os << "[U-]";
			}
			else if ((unsigned char)*currChar == K_SUBSTRACT)
			{
				os << "[B-]";
			}
			else
			{
				const char *tokenStr = findTokenStr(*currChar);
				if (tokenStr != NULL)
				{
					os << "[" << tokenStr << "]";
				}
				else 
				{
					os << "[UNKNOWN]";
				}
			}

			++currChar;
		}
		else if (*currChar == SID_CINT)
		{
			++currChar;
			short number;

			memcpy(&number, currChar, sizeof(short));

			os << "[CI " << number << "]";

			currChar += sizeof(short);
		}
		else if (*currChar == SID_CFLOAT)
		{
			++currChar;
			float number;

			memcpy(&number, currChar, sizeof(float));

			os << "[CF " << number << "]";

			currChar += sizeof(float);
		}
		else if (*currChar == SID_CSTR)
		{
			++currChar;
			unsigned char length = *currChar;

			++currChar;

			std::string str;

			str.assign(currChar, length);

			os << "[CS \"" << str << "\"]";

			currChar += length;
		}
		else if (*currChar == SID_VAR)
		{
			++currChar;
			BYTE tag[2];

			tag[0] = *currChar;
			++currChar;
			tag[1] = *currChar;
			++currChar;

			std::string name;
			Tag2Name(tag, name);

			os << "[V " << name << "]";
		}
		else
		{
			os << *currChar;
			++currChar;
		}

	}

	return os;
}
