 /* Name       : Sample Comm's Program - Polled Version - termpoll.c     */
 /* Written By : Craig Peacock <cpeacock@senet.com.au>                   */
 /* Date       : Saturday 22nd February 1997                             */

 /*        Copyright 1997 CRAIG PEACOCK <cpeacock@senet.com.au>          */

 /*         See http://www.senet.com.au/~cpeacock/serial1.htm            */
 /*                       For More Information                           */

#include <dos.h>
#include <stdio.h>
#include <conio.h>
#include <mem.h>
#include <iostream.h>
#include <fstream.h>
#include <string.h>

#define PORT1 0x3F8

  /* Defines Serial Ports Base Address */
  /* COM1 0x3F8                        */
  /* COM2 0x2F8			       */
  /* COM3 0x3E8			       */
  /* COM4 0x2E8			       */

char *fb_buffer = (char *)MK_FP(0xB800, 0);
char *fb_currpos = fb_buffer;
char fb_currattr = 7;
char fb_defattr = 7;
const short fb_size = (80*25)*2;

enum bool {false, true};

bool echo = true;
bool immediateMode = true;
char *immediatePos = NULL;

int getX(char *pos)
{
	return ((pos-fb_buffer)%160) / 2;
}

int getY(char *pos)
{
	return (pos-fb_buffer)/160;
}

bool isEmpty(int line)
{
	char *begin = fb_buffer + (line * 160);
	char *end = begin + 160;

	for (char *temp = begin; temp < end; temp+=2)
	{
		if (*temp != 0)
		{
			return false;
		}
	}

	return true;
}

void io_putChar(unsigned char ch)
{
	char in;

	do
	{
		in = inportb(PORT1+5);
	}
	while ((in & 0x20) == 0);

	while ((inportb(PORT1+6) & 16) == 0);

	outportb(PORT1, ch);
}

bool io_getChar(unsigned char &ch)
{
	ch = inportb(PORT1 + 5);     /* Check to see if char has been */
								/* received.                     */
	if (ch & 1)
	{
		ch = inportb(PORT1); 	/* If so, then get Char          */
		return true;
	}

	return false;
}

void io_putLine(const char *str)
{
	for (int i=0; i<80 && str[i]; ++i)
	{
		io_putChar(str[i]);
	}
	io_putChar(13);
}

unsigned char waitForChar()
{
	unsigned char ch = 0;

	while (io_getChar(ch) == false);

	return ch;
}

void updateCursor()
{
	gotoxy(getX(fb_currpos)+1, getY(fb_currpos)+1);
}

void fb_memsetw(char *src, char c, char a, short size)
{
	for (short i = 0; i<size; i++)
	{
		*src++ = c;
		*src++ = a;
	}
}

void fb_homeX()
{
	fb_currpos = getY(fb_currpos)*160 + fb_buffer;
	updateCursor();
}

void fb_homeY()
{
	fb_currpos = getX(fb_currpos)*2 + fb_buffer;
	updateCursor();
}

void fb_homeXY()
{
	fb_currpos = fb_buffer;
	updateCursor();
}

void fb_endX()
{
	fb_currpos = getY(fb_currpos)*160 + fb_buffer + 160 - 4;
	updateCursor();
}

void fb_endY()
{
	fb_currpos = getX(fb_currpos)*2 + fb_buffer + (24*160);
	updateCursor();
}

void fb_endXY()
{
	fb_currpos = fb_buffer+fb_size-4;
	updateCursor();
}

void fb_cls()
{
	fb_defattr = fb_currattr;

	fb_memsetw(fb_buffer, 0, fb_defattr, fb_size);

	fb_homeXY();
}

void fb_setcolor(char c)
{
	fb_currattr = c;
}

void fb_gotoxy(char x, char y)
{
	if (x < 79 && y <= 25)
	{
		short offset = ((y-1)*160) + ((x-1)*2);
		fb_currpos = fb_buffer + offset;

		updateCursor();
	}
}

void fb_scrollup()
{
	memmove(fb_buffer, fb_buffer+160, fb_size-160);
	fb_memsetw(fb_buffer+fb_size-160, 0, fb_defattr, 80);
}

void fb_insertLine()
{
	int currY = getY(fb_currpos);

	// begin of line
	char *temp = fb_buffer + (currY*160);

	for (int y = 24; y>currY; --y)
	{
		memcpy(fb_buffer+(y*160), fb_buffer+((y-1)*160), 160);
	}

	fb_memsetw(temp, 0, fb_defattr, 80);
}

void fb_tab()
{
	fb_currpos = ((fb_currpos-fb_buffer)/16+1)*16 + fb_buffer;

	if (fb_currpos >= fb_buffer+fb_size)
	{
		fb_scrollup();
		fb_currpos = fb_buffer+fb_size - 160;
	}
}

void putChar(const char c)
{
	bool insertLine = false;

	*fb_currpos = c;
	++fb_currpos;

	*fb_currpos = fb_currattr;
	++fb_currpos;

	if ((fb_currpos-fb_buffer)%160==158)
	{
		if (*fb_currpos != 27)
		{
			*fb_currpos = 27;
			++fb_currpos;

			*fb_currpos = fb_defattr;
			++fb_currpos;

			insertLine = true;
		}
		else
		{
			fb_currpos += 2;
		}
	}

	if (fb_currpos == fb_buffer+fb_size)
	{
		fb_scrollup();
		fb_currpos = fb_buffer+fb_size-160;
	}
	else if (insertLine == true)
	{
		fb_insertLine();
	}

	updateCursor();
}

void fb_moveup()
{
	if (fb_currpos-fb_buffer >= 160)
	{
		fb_currpos -= 160;
		updateCursor();
	}
}

void fb_movedown()
{
	if ((fb_buffer+fb_size) - fb_currpos > 160)
	{
		fb_currpos += 160;
		updateCursor();
	}
	else
	{
		fb_scrollup();
	}
}

void fb_moveleft()
{
	if (fb_currpos > fb_buffer)
	{
		if (getX(fb_currpos) == 0)
		{
			fb_currpos -= 2;
		}

		fb_currpos -= 2;
		updateCursor();
	}
}

void fb_moveright()
{
	fb_currpos += 2;

	if (getX(fb_currpos) == 79)
	{
		fb_currpos += 2;
	}

	if (fb_currpos >= fb_buffer+fb_size)
	{
		fb_scrollup();
		fb_currpos = fb_buffer+fb_size - 160;
	}

	updateCursor();
}

void fb_insert()
{

}

void fb_delete()
{
	// end of current line
	int begin = getY(fb_currpos);
	int end = begin;

	char *temp = fb_buffer + (end * 160) + 160 - 2;

	while (*temp == 27)
	{
		temp += 160;
		++end;
	}

	for (int i=begin; i<=end; ++i)
	{
		char *currLine = fb_buffer + (i*160);

		if (i == begin)
		{
			memmove(fb_currpos, fb_currpos+2, (currLine+160-4)-fb_currpos);
		}
		else
		{
			memmove(currLine, currLine+2, 160-4);
		}

		if (*(currLine+160-2) == 27)
		{
			// wrap around last char
			*(currLine+160-4) = *(currLine+160);
			*(currLine+160-3) = *(currLine+161);

			*(currLine+160) = 0;

			if (isEmpty(i+1))
			{
				*(currLine+160-2) = 0;
				*(currLine+160-1) = fb_defattr;
			}
		}
		else
		{
			*(currLine+160-4) = 0;
			*(currLine+160-3) = fb_defattr;
		}
	}
}


void fb_backspace()
{
	if (immediateMode == false)
	{
		if (fb_currpos <= immediatePos)
			return;
	}

	fb_moveleft();
	fb_delete();
}

void processChar()
{
	char x,y;
	char ch = waitForChar();

	switch(ch)
	{
		case 1: 	fb_cls(); 		break;
		case 2:		ch = waitForChar(); fb_setcolor(ch);	break;
		case 3:		fb_scrollup(); 	break;
		case 4:		fb_moveup();	break;
		case 5:		fb_movedown();	break;
		case 6:		fb_moveleft();	break;
		case 7:		fb_moveright();	break;
		case 11:   	x = waitForChar(); y = waitForChar(); fb_gotoxy(x,y);	break;
		case 12:	fb_homeX();		break;
		case 13:	fb_homeY();		break;
		case 14:	fb_homeXY();	break;
		case 15:	fb_endX();		break;
		case 16:	fb_endY();		break;
		case 17:	fb_endXY();		break;
		case 32:	fb_insert();	break;
		case 33:	fb_backspace();	break;
		case 34:	fb_delete();	break;

		case 64:	immediateMode = true;	immediatePos = NULL; break;
		case 65:	immediateMode = false;	immediatePos = fb_currpos; break;
	}
}

void sendLine()
{
	char *begin;
	char *end;

	// Beginning of current line
	char *curr = getY(fb_currpos)*160 + fb_buffer;

	if (immediateMode == true)
	{
		// Find beginning of statement, if multiple lines
		for (begin=curr; (begin>fb_buffer) && (*(begin-2) == 27); begin-=160);
	}
	else
	{
		begin = immediatePos;
	}

	// Find end of statement, if multiple lines
	for (end = curr+160-2; *end == 27; end+=160);

	char *tempStr = new char[(end-begin)/2 + 1];

	int i;
	char *temp;
	for (i=0,temp = begin; temp<end; temp+=2)
	{
		char ch = *temp;
		if (ch == 0)
		{
			tempStr[i++] = 32;
		}
		else if (ch == 27)
		{
		}
		else
		{
			tempStr[i++] = ch;
		}

	}
	tempStr[i] = 32;

	int j;
	for (j=i; j>=0; --j)
	{
		if (tempStr[j] != 32)
		{
			tempStr[j+1] = 0;
			break;
		}
	}

	if (j<0)
	{
		tempStr[0] = 0;
	}

	io_putLine(tempStr);

	delete []tempStr;
}

void upload()
{
	char Filename[16];
	char line[256];

	clrscr();
	cout << "File to load? ";
	cin.getline(Filename, 16);

	ifstream fs(Filename);
	if (!fs)
	{
		cout << "File not found" << endl;
		do; while (kbhit==0);
		getch();
		clrscr();
		fb_gotoxy(1,1);
		return;
	}

	io_putLine("new");

	cout << "Loading...";
	while(fs)
	{
		fs.getline(line,256);
		io_putLine(line);
		cout << ".";
	}
	cout << endl;

	fs.close();

	clrscr();
	fb_gotoxy(1,1);
}

void download()
{
	char Filename[16];
	char line[256];
	unsigned char ch;

	clrscr();
	cout << "File to save as? ";
	cin.getline(Filename, 16);

	ofstream fs(Filename);

	io_putLine("list");

	char *ptr = line;
	*ptr = 0;

	cout << "Saving...";
	while(1)
	{
		if (io_getChar(ch) == true)
		{
			if (ch == 13)
			{
				*ptr++ = 0;

				if (strcmp(line, "Ready.") == 0)
				{
					break;
				}

				cout << ".";
				fs << line << endl;

				ptr = line;
				*ptr = 0;
			}
			else
			{
				*ptr++ = ch;
			}
		}
	}
	cout << endl;

	fs.close();

	clrscr();
	fb_gotoxy(1,1);
	io_putLine("");
}

void main(void)
{
	unsigned char ch;

	outportb(PORT1 + 1 , 0);   /* Turn off interrupts - Port1 */

	/*         PORT 1 - Communication Settings         */

	outportb(PORT1 + 3 , 0x80);  /* SET DLAB ON */
	outportb(PORT1 + 0 , 0x18);  /* Set Baud rate - Divisor Latch Low Byte */
					/* Default 0x03 =  38,400 BPS */
					/*         0x01 = 115,200 BPS */
					/*         0x02 =  57,600 BPS */
					/*         0x06 =  19,200 BPS */
					/*         0x0C =   9,600 BPS */
					/*         0x18 =   4,800 BPS */
					/*         0x30 =   2,400 BPS */
	outportb(PORT1 + 1 , 0x00);  /* Set Baud rate - Divisor Latch High Byte */
	outportb(PORT1 + 3 , 0x03);  /* 8 Bits, No Parity, 1 Stop Bit */
	outportb(PORT1 + 2 , 0x00);  /* FIFO Control Register */
	outportb(PORT1 + 4 , 0x0B);  /* Turn on DTR, RTS, and OUT2 */

	fb_cls();

	bool exit = false;
	do
	{
		// Check for data coming from remote computer
		if (io_getChar(ch) == true)
		{
			if (ch == 9) // tab
			{
				fb_tab();
			}
			else if (ch == 1)
			{
				processChar();
			}
			else
			{
				if (ch == 13)
				{
					fb_homeX();
					fb_movedown();
				}
				else
				{
					if (ch < 255)
					{
						putChar(ch);
					}
				}
			}
		}

		// Check for data coming from local keyboard
		if (kbhit()!=0)
		{
			ch = getch();

			if (ch == 8)
			{
				fb_backspace();
			}
			else if (ch == 9)
			{
				fb_tab();
			}
			else if (ch == 27) // Escape
			{
				outportb(PORT1, 27);
			}
			else if (ch == 0)
			{
				ch = getch();
				if (ch == 0x2D)
				{
					exit = true;
				}

				if (immediateMode == true)
				{
					switch (ch)
					{
						case 0x49:  upload(); 		break;
						case 0x51:	download(); 	break;
						case 0x48:	fb_moveup();	break;
						case 0x4b:	fb_moveleft();	break;
						case 0x4d:	fb_moveright();	break;
						case 0x50:	fb_movedown();	break;

						case 0x47:	fb_homeX();		break;
						case 0x4f:	fb_endX();		break;
						case 0x75:	fb_endY();		break;
						case 0x77:	fb_homeY();		break;

						case 0x52:	fb_insert();	break;
						case 0x53:	fb_delete();	break;
					}
				}
			}
			else
			{
				if (ch == 13)
				{
					sendLine();
					fb_homeX();
					fb_movedown();
				}
				else
				{
					if (ch >= 32 && ch < 255)
					{
						putChar(ch);
					}
				}
			}
		}
	}
	while (exit == false);
}
