#pragma once

class CProgram
{
public:
	CProgram() {}
	~CProgram() {}

    static void New();
	static void List(short begin = 0, short end = -1);

	static void Insert(short lineNo, BYTE *contents, BYTE length);
	static void Remove(short lineNo);

protected:
	static BYTE *Find(short lineNo, BYTE **insertionPoint = NULL);
	static void Remove(BYTE *addr);
};