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

#define PORT1 0x2F8

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

bool io_getChar(char &ch)
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

char waitForChar()
{
	char ch = 0;
	bool done = false;

	do
	{
		done = io_getChar(ch);

		if (kbhit())
		{
			ch = getch();         	/* If key pressed, get Char */
			done = true;
		}
	}
	while (done == false);

	return ch;
}

void updateCursor()
{
	short offset = fb_currpos - fb_buffer;

	short y = offset/160;
	short x = (offset%160) / 2;

	gotoxy(x+1, y+1);
}

void fb_memsetw(char *src, char c, char a, short size)
{
	for (short i = 0; i<size; i++)
	{
		*src++ = c;
		*src++ = a;
	}
}

void fb_home()
{
	fb_currpos = fb_buffer;
	updateCursor();
}

void fb_cls()
{
	fb_defattr = fb_currattr;

	fb_memsetw(fb_buffer, 0, fb_defattr, fb_size);

	fb_home();
}

void fb_setcolor(char c)
{
	fb_currattr = c;
}

void fb_gotoxy(char x, char y)
{
	short offset = (y*160) + (x*2);
	fb_currpos = fb_buffer + offset;

	updateCursor();
}

void fb_scrollup()
{
	memmove(fb_buffer, fb_buffer+160, fb_size-160);
	fb_memsetw(fb_buffer+fb_size-160, 0, fb_defattr, 80);
}

void putChar(const char c)
{
	*fb_currpos = c;
	++fb_currpos;

	*fb_currpos = fb_currattr;
	++fb_currpos;

	if (fb_currpos == fb_buffer+fb_size)
	{
		fb_scrollup();
		fb_currpos = fb_buffer+fb_size-160;
	}

	updateCursor();
}

void fb_moveup()
{

}

void fb_movedown()
{

}

void fb_moveleft()
{
	if (fb_currpos > fb_buffer)
	{
		fb_currpos -= 2;
		updateCursor();
	}
}

void fb_moveright()
{
	fb_currpos += 2;

	if (fb_currpos == fb_buffer+fb_size)
	{
		fb_scrollup();
		fb_currpos = fb_buffer+fb_size - 160;
	}

	updateCursor();
}

void processChar()
{
	char x,y;
	char ch = waitForChar();

	switch(ch)
	{
		case 1: 	fb_cls(); 		break;
		case 2:		ch = waitForChar(); fb_setcolor(ch);	break;
		case 3:
		case 33:	fb_scrollup(); 	break;
		case 4:		fb_moveup();	break;
		case 5:		fb_movedown();	break;
		case 6:		fb_moveleft();	break;
		case 7:		fb_moveright();	break;
		case 11:   	x = waitForChar(); y = waitForChar(); fb_gotoxy(x,y);	break;
		case 12:	fb_home();		break;
	}
}

void main(void)
{
	char ch;

	outportb(PORT1 + 1 , 0);   /* Turn off interrupts - Port1 */

	/*         PORT 1 - Communication Settings         */

	outportb(PORT1 + 3 , 0x80);  /* SET DLAB ON */
	outportb(PORT1 + 0 , 0x0C);  /* Set Baud rate - Divisor Latch Low Byte */
					/* Default 0x03 =  38,400 BPS */
					/*         0x01 = 115,200 BPS */
					/*         0x02 =  57,600 BPS */
					/*         0x06 =  19,200 BPS */
					/*         0x0C =   9,600 BPS */
					/*         0x18 =   4,800 BPS */
					/*         0x30 =   2,400 BPS */
	outportb(PORT1 + 1 , 0x00);  /* Set Baud rate - Divisor Latch High Byte */
	outportb(PORT1 + 3 , 0x03);  /* 8 Bits, No Parity, 1 Stop Bit */
	outportb(PORT1 + 2 , 0xC7);  /* FIFO Control Register */
	outportb(PORT1 + 4 , 0x0B);  /* Turn on DTR, RTS, and OUT2 */

	fb_cls();

	bool ok;
	do
	{
		ok = io_getChar(ch);
		if (ok == true)
		{
			if (ch == 255 || ch == 1)
			{
				processChar();
			}
			else
			{
				putChar(ch);
			}

		}

		if (kbhit())
		{
			ch = getch();         	/* If key pressed, get Char */
			outportb(PORT1, ch);	/* Send Char to Serial Port */
		}

	} while (ch !=27); /* Quit when ESC (ASC 27) is pressed */
}
