// Emulator Base.cpp : Defines the entry point for the console application.
//
#include "stdafx.h"
#include "Memory.h"
#include "MemoryBlock.h"
#include "FrameBuffer.h"
#include "Keyboard.h"
#include "Ports.h"
#include "CPU8080.h"
#include <conio.h>
#include <vector>
#include <string>
#include <fstream>
#include <time.h>

void LogCallback(const char *str)
{
	fprintf(stderr, str);
}

const char HexNumbers[] = "0123456789ABCDEF";

BYTE hexToByte(const std::string &hexStr)
{
	if (hexStr.length() < 2)
		return 0;

	return (strchr(HexNumbers, toupper(hexStr[0]))-HexNumbers)*16 +
		(strchr(HexNumbers, toupper(hexStr[1]))-HexNumbers);
}

WORD hexToWord(const std::string &hexStr)
{
	if (hexStr.length() < 4)
		return 0;

	return hexToByte(hexStr.substr(0, 2)) * 256 +
		hexToByte(hexStr.substr(2, 2));
}

bool readSRecord(const std::string &fileName, std::vector<CMemoryBlock> &data)
{
	std::ifstream file(fileName.c_str(), std::ios::in);

	int lastAddr = -1;
	std::vector<BYTE> currBuffer;

	while (file)
	{
		std::string temp;
		std::getline(file, temp);

		if (!file)
			break;

		if (temp[0] != 'S')	// Lines should begin with S
			goto abort;

		if (temp[1] == '9') // record type = eof
		{
			if (lastAddr != -1) // save last block, if any
			{
				data.push_back(CMemoryBlock(lastAddr, currBuffer, ROM));
			}
			break;
		}

		if (temp[1] != '1') // record type should be 'data'
			goto abort;

		BYTE nbBytes = hexToByte(temp.substr(2,2));

		if (temp.length()-4 < nbBytes*2)
			goto abort;

		nbBytes -= 3;

		WORD blockAddr = hexToWord(temp.substr(4, 4));

		if (lastAddr+currBuffer.size() != blockAddr)	// new block
		{
			if (lastAddr != -1) // save last block
			{
				data.push_back(CMemoryBlock(lastAddr, currBuffer, ROM));
			}
			lastAddr = blockAddr;
			currBuffer.clear();
		}
		
		for (int i=0; i<nbBytes; i++)
		{
			currBuffer.push_back(hexToByte(temp.substr(i*2+8,2)));
		}
	}

	file.close();
	return true;

abort:
	file.close();
	return false;
}

int main(void)
{
	CMemory memory;
//	memory.RegisterLogCallback(LogCallback);

	std::vector<CMemoryBlock> monitorRom;
	if (readSRecord("D:\\monitor.hex", monitorRom))
	{
		for (int i=0; i<monitorRom.size(); i++)
			memory.Allocate(&(monitorRom[i]));
	}

	std::vector<CMemoryBlock> basicRom;
	if (readSRecord("D:\\basic.hex", basicRom))
	{
		for (int i=0; i<basicRom.size(); i++)
			memory.Allocate(&(basicRom[i]));
	}


	CFrameBuffer video_memory(0x1000, 1024);

	CMemoryBlock buffer_memory(0x1400, 0xFFFF-0x1400, RAM);

	memory.Allocate(&video_memory);
	memory.Allocate(&buffer_memory);

	CPorts ports;

	CKeyboard keyboard;
	ports.Allocate(0, &keyboard);

	CCPU8080 cpu(memory, ports);
	cpu.Reset();

	time_t startTime, stopTime;
	time(&startTime);

	do
	{
		if (cpu.Step() == false)
			break;
	} 
	while (keyboard.currChar != 27);

	time(&stopTime);

	fprintf(stderr, "Time elapsed: %u\n", stopTime-startTime);
	cpu.getTime();
	fprintf(stderr, "CPU ticks: %u\n", cpu.getTime());
	fprintf(stderr, "Avg speed: %u ticks/s", cpu.getTime()/(stopTime-startTime));

	return 0;
}


