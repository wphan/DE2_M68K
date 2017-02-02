/* DRAWFUNC.H - Plot mathematical function on drawpad
 *
 * A drawpad size of 512x512 pixels is assumed
 *
 * (c) Peter J. Fondse, 2005 (pfondse@hetnet.nl)
 */

#include <stdio.h>
#include <math.h>
#include "drawfunc.h"

DRAWPAD *drawpad = 0xE020;

// the function to plot: f(x) = 2sin(x)+cos(4x)

float func(float x)
{
    return 2*sin(x) + cos(4*x);
}

void main(void)
{
    erase(WHITE);                       // erase display
    axis(BLUE);                         // draw x-y axis
    plot(func, -4.0, 4.0, 0.1, RED);    // plot function from -4 to +4
    moveto(0.0, 0.0);                   // reset position
}

void erase(int color)
{
    drawpad->ctrl = color << 4;
}

void axis(int color)
{
    int i;
    char tag[8];

    moveto(-4.0, 0.0);
    lineto(4.0, 0.0, color, 1);		// x axis
    moveto(3.8, -0.2);
    textout("x", color, 2);
    moveto(0.0, 4.0);
    lineto(0.0, -4.0, color, 1);	// y axis
    moveto(0.3, 3.9);
    textout("y", color, 2);
    for (i = -3; i <= 3; i++) {
        if (i == 0) continue;
        sprintf(tag, "%d", i);
        moveto(i, 0.1);
        lineto(i, -0.1, color, 1);
        moveto(i - 0.1, -0.2);
       	textout(tag, color, 2);
        moveto(0.1, i);
        lineto(-0.1, i, color, 1);
        moveto(0.3, i + 0.1);
        textout(tag, color, 2);
    }
}

void plot(float (*f)(float), float begin, float end, float step, int color)
{
    register float x;

    for (x = begin, moveto(x, (*f)(x)); x <= end; x += 0.1) lineto(x, (*f)(x), color, 1);
    moveto(1.0, 3.6);
    textout("f(x) = 2sin(x) + cos(4x)", color, 2);
}

void moveto(float x, float y)
{
    drawpad->x = (short) (64 * x + 256);
    drawpad->y = (short) (64 * -y + 256);
    drawpad->ctrl = 0x80;
}

void lineto(float x, float y, int color, int width)
{
    drawpad->x = (short) (64 * x + 256);
    drawpad->y = (short) (64 * -y + 256);
    drawpad->ctrl = (color << 4) | width;
}

void textout(char *s, int color, int size)
{
    while (*s) drawpad->ctrl = 0x8000 | (*s++ << 8) | (color << 4) | size;
}
