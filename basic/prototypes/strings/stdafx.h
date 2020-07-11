// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

#define WIN32_LEAN_AND_MEAN		// Exclude rarely-used stuff from Windows headers
#include <stdio.h>
#include <tchar.h>

#include "..\include\common.h"
#include "..\include\error.h"
#include "..\expreval\expreval.h"
#include "..\expreval\evaluate.h"
#include "..\expreval\exprstack.h"
#include "..\program\program.h"
#include "..\variables\variables.h"
#include "..\strings\strings.h"
#include "..\tokenize\tokenize.h"
#include "..\tokenize\untokenize.h"