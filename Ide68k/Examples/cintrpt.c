// CINTRPT.C - A simple program to demonstrate the interrupt processing in C
// The program uses INT7 (non-maskable)
// Other interrupt levels must set I-field in status register
// however this register is not accessible in C, only in Assembly

// Author: Peter J. Fondse (pfondse@hetnet.nl)

void *int7vec = 0x007C;               // int 7 autovector
unsigned char *leds = 0xE003;         // address of LED array
unsigned char *bar = 0xE007;          // address of BAR display

// the interrupt routine
interrupt void int7proc(void)
{
	(*leds)++;                        // increment LEDS at INT7
}

// delay
void delay(void)
{
	int i = 0;

	do {
		++i;
	} while (i < 30000);              // loop to slow things down a bit
}

// main program
void main(void)
{
	*int7vec = int7proc;              // set INT7 autovector to handler
	for (;;) {
		(*bar)++;                     // increment BAR display
		delay();
	}
}
