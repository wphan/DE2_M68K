// DRAWFUNC.H - Include file for drawfunc.c

// Author: Peter J. Fondse (pfondse@hetnet.nl)

// color definitions:
#define BLACK   		0
#define BLUE    		1
#define GREEN  			2
#define RED    			4
#define YELLOW 			(RED+GREEN)
#define CYAN   			(GREEN+BLUE)
#define MAGENTA			(RED+BLUE)
#define WHITE			(RED+GREEN+BLUE)
#define TRANSPARENT     8

// layout of drawpad
typedef struct {
	short x;						// x position in current pixel
	short y;						// y position of current pixel
	short ctrl;						// control word
	short xmouse;					// x position of mouse cursor
	short ymouse;					// y position of mouse cursor
	char iflags;					// flagbits to indicate what caused interrupt
	char imask;						// maks to set IRQ level and mouse events
} DRAWPAD;

// prototypes
void erase(int);
void axis(int);
void plot(float(*)(float), float, float, float, int);
void moveto(float, float);
void lineto(float, float, int, int);
void textout(char *, int, int);
