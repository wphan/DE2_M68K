#include "DebugMonitor.h"

/* erase chip by writing to address with data*/
void EraseFlashChip(void)
{

}

void FlashReset(void)
{

}

/* erase sector by writing to address with data*/
void FlashSectorErase(int SectorAddress)
{

}

/* program chip by writing to address with data*/
void FlashProgram(unsigned int AddressOffset, int ByteData)		// write a byte to the specified address (assumed it has been erased first)
{

}

/* program chip to read a byte */
unsigned char FlashRead(unsigned int AddressOffset)		// read a byte from the specified address (assumed it has been erased first)
{

	return 0 ; 	// dummy return to it will compile before you have written your code
}