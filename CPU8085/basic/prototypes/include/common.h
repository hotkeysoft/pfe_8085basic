#ifndef __COMMON_H_INCLUDED
#define __COMMON_H_INCLUDED

#include <string>

typedef unsigned char BYTE;
typedef unsigned short WORD;

enum StackID {	SID_CINT=1, SID_CFLOAT=2, SID_CSTR=4,
				SID_VAR=8,	SID_FBASE=128};

const std::string variableNameStr = " 0123456789"\
									"ABCDEFGHIJKLMNOPQRSTUVWXYZ";

enum KEYWORDS { 
	K_NONE		= 0,

	K_POWER		= 0x80,

	K_NEGATE,

	K_MULTIPLY,
	K_IDIVIDE,
	K_FDIVIDE,

	K_ADD,
	K_SUBSTRACT,

	K_NOTEQUAL,
	K_LESSEQUAL,
	K_GREATEREQUAL,
	K_LESS,
	K_GREATER,
	K_EQUAL,

	K_NOT,
	K_AND,
	K_OR,
	K_XOR,

	K_ASSIGN,

	K_ABS		= 0xA0,
	K_ASC,
	K_INT,
//	K_IN,
	K_LEN,
	K_PEEK,
	K_RND,
	K_SGN,
	K_SQR,
	K_VAL,
	
	K_CHR		= 0xB0,
	K_LEFT,
	K_MID,
	K_RIGHT,
	K_STR,

	K_CLR		= 0xC0,
	K_CONT,
	K_DIM,
	K_END,
	K_FOR,
	K_GOSUB,
	K_GOTO,
	K_IF,
	K_INPUT,
	K_LET,
	K_LIST,
	K_NEW,
	K_NEXT,
//	K_OUT,
	K_POKE,
	K_PRINT,
	K_REM,
	K_RETURN,
	K_RUN,
	K_STEP,
	K_SYS,
	K_THEN,
	K_TO,
};

struct Keyword
{
	KEYWORDS id;
	const char *name;
};

extern Keyword keywords[];

extern BYTE Memory[];

extern BYTE *LoExpStack;
extern BYTE *HiExpStack;
extern BYTE *CurrExpStack;

extern BYTE *LoStrStack;
extern BYTE *HiStrStack;

extern BYTE *LoProgram;
extern BYTE *HiProgram;

extern BYTE *LoAutoVars;
extern BYTE *HiAutoVars;

extern BYTE *tempVar1;
extern BYTE *tempVar2;
extern BYTE *tempVar3;
 
void Tag2Name(const BYTE tag[2], std::string &name);
void Name2Tag(std::string name, BYTE tag[2]);

void stringToFloat(const BYTE *currIn, float &number, int &length);
void stringToShort(const BYTE *currIn, short &number, int &length);

short GetInt(BYTE *);
float GetFloat(BYTE *);
BYTE *GetStr(BYTE *var, BYTE &size);

BYTE  ConvertToByte(BYTE *);

void SetInt(BYTE *, short);
void SetFloat(BYTE *, float);
void SetStr(BYTE *var, BYTE *addr, BYTE size);

#endif
