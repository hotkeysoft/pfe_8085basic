// stdafx.h : include file for standard system include files,
//  or project specific include files that are used frequently, but
//      are changed infrequently
//

#if !defined(AFX_STDAFX_H__0D3141ED_5677_43A7_8A70_3ECB4C23710B__INCLUDED_)
#define AFX_STDAFX_H__0D3141ED_5677_43A7_8A70_3ECB4C23710B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#define WIN32_LEAN_AND_MEAN		// Exclude rarely-used stuff from Windows headers

#include <stdio.h>

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

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDAFX_H__0D3141ED_5677_43A7_8A70_3ECB4C23710B__INCLUDED_)
