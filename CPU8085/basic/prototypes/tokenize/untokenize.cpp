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
		}
		else if (*currChar == SID_CINT)
		{
			++currChar;
			short number;

			memcpy(&number, currChar, sizeof(short));

			os << "[I " << number << "]";

			currChar += sizeof(short);
		}
		else if (*currChar == SID_CFLOAT)
		{
			++currChar;
			float number;

			memcpy(&number, currChar, sizeof(float));

			os << "[F " << number << "]";

			currChar += sizeof(float);
		}
		else
		{
			os << *currChar;
		}


		++currChar;
	}

	return os;
}
