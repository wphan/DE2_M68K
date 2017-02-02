// DRAWPAD.C - Drawpad demonstration program

// This program assumes a drawpad of size 300x200 pixels

// See also DRAWPAD.H (header) and DRAWPAD.A68 (assembly function)

// Author: Peter J. Fondse (pfondse@hetnet.nl)

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "drawpad.h"

#define IRQ 4									// IRQ level for mouse buttons

void *timerint = 0x00000040;                    // H/W timer interrupt vector addres
void *mouseint = 0x00000100;					// mouse interrupt vector address
DRAWPAD *drawpad = 0x0000E020;					// I/O address of drawpad

void main(void)
{
	char buf[16];

	drawpad->ctrl = BLUE << 4;   				// Erase drawpad with blue background
	gotoxy(50, 30);
	textout("Left button", RED, 3); 			// red text at (50,30) size 30 pixels
	gotoxy(50, 80);
	textout("Right button", GREEN, 3); 		    // green text at (50,80) size 30 pixels
	gotoxy(20, 130);
	textout("Cursor position", YELLOW, 3); 		// yellow text at (20,130) size 30 pixels
	gotoxy(20, 30);
	rect(21, 81, TRANSPARENT, WHITE, 2);		// white rectangle for button indicators
	gotoxy(0, 189);
	lineto(300, 189, WHITE, 1);    				// white line for progress indicator
	*timerint = progressproc;					// set H/W timer vector to progressproc()
	*mouseint = buttonproc;						// set mouseinterrupt vector to buttonproc()
	intlevel(3);								// enable IRQ 4 and higher
	drawpad->imask = (IRQ << 4) | LBUTTONDOWN | LBUTTONUP | RBUTTONDOWN | RBUTTONUP;                      // mouse IRQ = 4, all buttons active
	for (;;) {
		static int x = -1, y = -1;
		if (x != drawpad->xmouse || y != drawpad->ymouse) {
			x = drawpad->xmouse;				// update mouse position only when changed
			y = drawpad->ymouse;
			sprintf(buf, "%d,%d     ", x, y);	// convert mouseposition to text
			gotoxy(200, 130);
			textout(buf, WHITE, 3);				// write mouse position at (200,130)
		}
	}
}

// goto (x,y)
void gotoxy(int x, int y)
{
	drawpad->x = x;
	drawpad->y = y;
	drawpad->ctrl = 0x0080;
}

// line to (x,y) with color 'color' and width 'w'
void lineto(int x, int y, int color, int width)
{
	drawpad->x = x;
	drawpad->y = y;
	drawpad->ctrl = (color << 4) | width;
}

// ellipse (circle) width 'w', height 'h', fill-color 'color', border-color 'border', border-width 'bw'
void ellipse(int w, int h, int color, int border, int bw)
{
	drawpad->x += w;
	drawpad->y += h;
	drawpad->ctrl = 0x1000 | (color << 8) | (border << 4) | bw;
}

// rectangle width 'w', height 'h', fill-color 'color', border-color 'border', border-width 'bw'
void rect(int w, int h, int color, int border, int bw)
{
	drawpad->x += w;
	drawpad->y += h;
	drawpad->ctrl = 0x2000 | (color << 8) | (border << 4) | bw;
}

// text 's', color 'color', heigth 10 * 'size'
void textout(char *s, int color, int size)
{
	while (*s) drawpad->ctrl = 0x8000 | (*s++ << 8) | (color << 4) | size;
}

// the interrupt functions
interrupt void buttonproc(void)
{
	short x = drawpad->x, y = drawpad->y;		// save position

	if (drawpad->iflags & LBUTTONDOWN) {		// check left button down
		gotoxy(25, 40);
		ellipse(10, 10, RED, RED, 1);			// draw red dot
	}
	else if (drawpad->iflags & LBUTTONUP) {		// check left button up
		gotoxy(25, 40);
		ellipse(10, 10, BLUE, BLUE, 1);			// draw blue dot (= background)
	}
	else if (drawpad->iflags & RBUTTONDOWN) {	// check right button down
		gotoxy(25, 90);
		ellipse(10, 10, GREEN, GREEN, 1);		// draw green dot
	}
	else if (drawpad->iflags & RBUTTONUP) {		// check right button up
		gotoxy(25, 90);
		ellipse(10, 10, BLUE, BLUE, 1);			// draw blue dot (= background)
	}
	drawpad->iflags = 0;
	gotoxy(x, y);								// goto saved position
}

interrupt void progressproc(void)
{
	short x = drawpad->x, y = drawpad->y;       // save position
	static int len;
	static int color = CYAN;

	gotoxy(0, 190);								// goto start postition
	rect(len++, 10, color, color, 1);			// draw progress bar
	if (len > 300) {                            // at end
		len = 0;                                // reset and
		color = (color == CYAN) ? BLUE : CYAN;  // change color cyan <-> blue
	}
	gotoxy(x, y);                               // goto saved position
}
