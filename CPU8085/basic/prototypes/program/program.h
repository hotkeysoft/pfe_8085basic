#pragma once

class CProgram
{
public:
	CProgram() {}
	~CProgram() {}

	static void Init();
    static void New();
	static void List(short begin = 0, short end = -1);

	static void Insert(short lineNo, BYTE *contents, BYTE length);
	static void Remove(short lineNo);

	static void Run(short lineNo = 0);
	static void Goto(short lineNo);
	static void Gosub(short lineNo, BYTE *returnPoint, bool inIf);
	static void Return();

	static void End();
	static void Stop(BYTE *returnPoint, bool inIf);
	static void Continue();

protected:
	static BYTE *NewLine;
	static BYTE *CurrLine;
	static BYTE *CurrPos;

	static bool IsEnd;
	static bool InIf;

	static void DoIt();

	static BYTE *Find(short lineNo, BYTE **insertionPoint = NULL);
	static void Remove(BYTE *addr);
};