// DRAWPAD.H - Include file for drawpad.c

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
#define TRANSPARENT             8

// mouse interrupt flags
#define LBUTTONDOWN      	0x01
#define LBUTTONUP		0x02
#define RBUTTONDOWN		0x04
#define RBUTTONUP		0x08

// layout of drawpad
typedef struct {
	short x;					// x position in current pixel
	short y;					// y position of current pixel
	short ctrl;					// control word
	short xmouse;					// x position of mouse cursor
	short ymouse;					// y position of mouse cursor
	char iflags;					// flagbits to indicate what gave interrupt
	char imask;					// maks to set IRQ level and mouse events
} DRAWPAD;

// prototypes
int intlevel(int);
void gotoxy(int, int);
void lineto(int, int, int, int);
void textout(char *, int, int);
void ellipse(int, int, int, int, int);
void rect(int, int, int, int, int);
interrupt void buttonproc(void);
interrupt void progressproc(void);
