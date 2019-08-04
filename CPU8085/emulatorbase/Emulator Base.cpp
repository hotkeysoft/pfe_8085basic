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
#include <iostream>
#include <fstream>
#include <time.h>

#include <Windows.h>

class Timer : public CInterruptSource
{
	virtual bool IsInterrupting() override
	{
		DWORD ticks = GetTickCount();
		if (m_start == 0)
		{
			m_start = ticks;
			return false;
		}

		DWORD delta = ticks - m_start;
		if (delta > 100) 
		{
			m_start = ticks;
			return true;
		}
		return false;
	}

	DWORD m_start = 0;
};

class UART_LSR : public CInputPort
{
	// Inherited via CInputPort
	virtual BYTE In() override
	{
		// Always ready
		return 0x20;
	}
};

class UART_THR : public COutputPort
{
	// Inherited via COutputPort
	virtual void Out(BYTE value) override
	{
		if (isprint(value)) 
		{
			fprintf(stdout, "%c", value);
		}
		else if (value == 0x0D)
		{
			fprintf(stdout, "\n");
		}
		else
		{
			fprintf(stdout, "[0x%X]", value);
		}
	}
};

class UART_MCR : public CInputPort, public COutputPort
{
public:
	UART_MCR() { m_value = 0; }
	// Inherited via CInputPort
	virtual BYTE In() override
	{
		return m_value;
	}

	// Inherited via COutputPort
	virtual void Out(BYTE value) override
	{
		if (!(m_value & 0x1) && (value & 0x01))
		{
			fprintf(stdout, "[XON]");
		}
		else if ((m_value & 0x1) && !(value & 0x01))
		{
			fprintf(stdout, "[XOFF]");
		}

		if (!(m_value & 0x04) && (value & 0x04))
		{
			fprintf(stdout, "[SOUNDON]");
		}
		else if ((m_value & 0x04) && !(value & 0x04))
		{
			fprintf(stdout, "[SOUNDOFF]");
		}
		m_value = value;
	}

	BYTE m_value;
};


void LogCallback(const char *str)
{
	fprintf(stderr, str);
}

const char HexNumbers[] = "0123456789ABCDEF";

BYTE hexToByte(const std::string &hexStr)
{
	if (hexStr.length() < 2)
		return 0;

	const char* n1 = strchr(HexNumbers, toupper(hexStr[0]));
	const char* n2 = strchr(HexNumbers, toupper(hexStr[1]));

	if (!n1 || !n2)
		throw std::exception("Invalid hex digit");

	return BYTE(n1-HexNumbers)*16 + BYTE(n2-HexNumbers);
}

WORD hexToWord(const std::string &hexStr)
{
	if (hexStr.length() < 4)
		return 0;

	return hexToByte(hexStr.substr(0, 2)) * 256 +
		hexToByte(hexStr.substr(2, 2));
}

bool readIntelHex(const std::string &fileName, std::vector<CMemoryBlock> &data)
{
	std::ifstream file(fileName.c_str(), std::ios::in);

	if (!file)
	{
		std::cerr << "Error opening file: " << fileName << std::endl;
		return false;
	}

	int lastAddr = -1;
	std::vector<BYTE> currBuffer;

	while (file)
	{
		std::string line;
		std::getline(file, line);

		if (!file)
			break;

		std::cout << line << std::endl;

		if (line[0] != ':')	// Lines should begin with S
			goto abort;

		BYTE nbBytes = hexToByte(line.substr(1, 2));

		if (line.length() - 11 < nbBytes * 2)
		{
			std::cerr << "Unexpected record length" << std::endl;
			goto abort;
		}

		WORD blockAddr = hexToWord(line.substr(3, 4));
		BYTE type = hexToByte(line.substr(7, 1));
		BYTE checksum = hexToByte(line.substr((nbBytes*2)+9, 2));

		if (type == 1) // record type = eof
		{
			if (lastAddr != -1) // save last block, if any
			{
				data.push_back(CMemoryBlock(lastAddr, currBuffer, ROM));
			}
			break;
		}

		if (type != 0) // record type should be 'data'
		{
			std::cerr << "Unexpected record type" << std::endl;
			goto abort;
		}	

		if (lastAddr + currBuffer.size() != blockAddr)	// new block
		{
			if (lastAddr != -1) // save last block
			{
				std::cout << "Saving block at: " << lastAddr << ", size: " << currBuffer.size() << std::endl;
				data.push_back(CMemoryBlock(lastAddr, currBuffer, ROM));
			}
			lastAddr = blockAddr;
			currBuffer.clear();
		}
		
		BYTE sum = 0;
		for (int i = 0; i<nbBytes + 4; i++)
		{
			BYTE currByte = hexToByte(line.substr(i * 2 + 1, 2));
			sum += currByte;

			if (i >= 4) {
				currBuffer.push_back(currByte);
			}
		}

		sum += checksum;
		if (sum != 0)
		{
			std::cerr << "Checksum error" << std::endl;
			goto abort;
		}
	}

	file.close();
	return true;

abort:
	file.close();
	std::cerr << "Abort." << std::endl;
	return false;
}

bool readSRecord(const std::string &fileName, std::vector<CMemoryBlock> &data)
{
	std::ifstream file(fileName.c_str(), std::ios::in);

	if (!file)
	{
		std::cerr << "Error opening file: " << fileName << std::endl;
		return false;
	}

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
	std::cerr << "Error reading data" << std::endl;
	return false;
}

int main(void)
{
	CMemory memory;
//	memory.RegisterLogCallback(LogCallback);

	std::vector<CMemoryBlock> monitorRom;
	if (readIntelHex("D:\\Projects\\CPU8085\\basic\\main\\main.ihx", monitorRom))
	{
		for (int i=0; i<monitorRom.size(); i++)
			memory.Allocate(&(monitorRom[i]));
	}

//	CFrameBuffer video_memory(0x1000, 1024);

	CMemoryBlock buffer_memory(0x8000, 0x8000, RAM);

//	memory.Allocate(&video_memory);
	memory.Allocate(&buffer_memory);

	CPorts ports;
	ports.RegisterLogCallback(LogCallback);

	CKeyboard keyboard;
	ports.Allocate(0x60, &keyboard);

	//TODO: Port allocation is really dumb
	UART_THR thr;
	UART_MCR mcr;
	UART_LSR lsr;	
	ports.Allocate(0x60, &thr);
	ports.Allocate(0x64, &(CInputPort&)mcr); // Especially this
	ports.Allocate(0x64, &(COutputPort&)mcr); 
	ports.Allocate(0x65, &lsr);

	Timer timer;

	CInterrupts interrupts;
	interrupts.Allocate(CCPU8080::RST65, &keyboard);
	interrupts.Allocate(CCPU8080::TRAP, &timer);

	CCPU8080 cpu(memory, ports, interrupts);
	cpu.Reset();

	time_t startTime, stopTime;
	time(&startTime);

	while (cpu.Step()/* && !keyboard.IsEscape()*/) {};

	time(&stopTime);

	fprintf(stderr, "Time elapsed: %I64u\n", stopTime-startTime);
	cpu.getTime();
	fprintf(stderr, "CPU ticks: %u\n", cpu.getTime());
	if (stopTime - startTime > 1)
	{
		fprintf(stderr, "Avg speed: %I64u ticks/s\n", cpu.getTime() / (stopTime - startTime));
	}

	return 0;
}


