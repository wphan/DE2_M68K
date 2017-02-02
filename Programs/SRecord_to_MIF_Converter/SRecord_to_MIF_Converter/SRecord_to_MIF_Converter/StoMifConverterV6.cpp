#include <stdio.h>
#include <stdlib.h>
#include <conio.h>

int main(int argc, char *argv[])
{
	int depth = 16384;
	char wkstr[256];

	unsigned  long address;
	unsigned  digit;
	unsigned  count, i, j;

	FILE *SourceFilePtr;
	FILE *DestFilePtr;


	if ((SourceFilePtr = fopen("C:\\Users\\wphan\\Dropbox\\skool\\CPEN412\\assignments\\M68kDebugMonitor\\out\\m68kdebugmonitor.hex", "r")) == NULL)	{
		fprintf(stderr, "Cannot Open S-Record File 'C:\\Users\\wphan\\Dropbox\\skool\\CPEN412\\assignments\\M68kDebugMonitor\\M68kdebugmonitor.hex' for conversion to '.MIF' format\n");
		fprintf(stderr, "Hit any key to exit.....");
		getch();
		return 0;
	}

	if ((DestFilePtr = fopen("C:\\Users\\wphan\\Dropbox\\skool\\CPEN412\\assignments\\M68kDebugMonitor\\out\\m68kdebugmonitor.mif", "w")) == NULL)	{
		fprintf(stderr, "Cannot Open/Create file 'C:\\Users\\wphan\\Dropbox\\skool\\CPEN412\\assignments\\M68kDebugMonitor\\M68kdebugmonitor.mif' to store output of file conversion\n");
		fprintf(stderr, "Hit any key to exit.....");
		getch();
		return 0;
	}

	// write this to the output file, just for compatibility

	printf("---------------------------------------------------------------------------\n");
	printf("CONVERTING S-RECORD File Produced by Assembler into MIF format for Download\n");
	printf("---------------------------------------------------------------------------\n");



	fprintf(DestFilePtr, "-- Copyright (C) 1991-2007 Altera Corporation\n");
	fprintf(DestFilePtr, "-- Your use of Altera Corporation's design tools, logic functions \n");
	fprintf(DestFilePtr, "-- and other software and tools, and its AMPP partner logic \n");
	fprintf(DestFilePtr, "-- functions, and any output files from any of the foregoing \n");
	fprintf(DestFilePtr, "-- (including device programming or simulation files), and any \n");
	fprintf(DestFilePtr, "-- associated documentation or information are expressly subject \n");
	fprintf(DestFilePtr, "-- to the terms and conditions of the Altera Program License \n");
	fprintf(DestFilePtr, "-- Subscription Agreement, Altera MegaCore Function License \n");
	fprintf(DestFilePtr, "-- Agreement, or other applicable license agreement, including, \n");
	fprintf(DestFilePtr, "-- without limitation, that your use is for the sole purpose of \n");
	fprintf(DestFilePtr, "-- programming logic devices manufactured by Altera and sold by \n");
	fprintf(DestFilePtr, "-- Altera or its authorized distributors.  Please refer to the \n");
	fprintf(DestFilePtr, "-- applicable agreement for further details.\n");
	fprintf(DestFilePtr, "\n");
	fprintf(DestFilePtr, "-- Quartus II generated Memory Initialization File (.mif)\n");
	fprintf(DestFilePtr, "\n");
	fprintf(DestFilePtr, "WIDTH=16;\n");
	fprintf(DestFilePtr, "DEPTH=16384;\n\n");

	fprintf(DestFilePtr, "ADDRESS_RADIX=HEX;\n");
	fprintf(DestFilePtr, "DATA_RADIX=HEX;\n\n");

	fprintf(DestFilePtr, "CONTENT BEGIN\n");

	while (fgets(wkstr, 255, SourceFilePtr) != NULL)	{
		printf("%s", wkstr);

		// IGNORE S0 records and S9, S8, S7 records
		if (wkstr[0] == 'S')	{
			if ((wkstr[1] == '0') || (wkstr[1] == '9') || (wkstr[1] == '8') || (wkstr[1] == '7'))
				continue;
		}

		// IF record is S1 (i.e. 4 digit address)

		if (wkstr[0] == 'S' && wkstr[1] == '1') {
			sscanf(&wkstr[2], "%2X", &count);
			sscanf(&wkstr[4], "%4X", &address);

			address = address >> 1;	// halve address for 16 bit proms

			for (i = 0, j = 0; i< count - 3; i = i + 2, j++) {
				sscanf(&wkstr[(i * 2) + 8], "%4x", &digit);
				fprintf(DestFilePtr, "         %04X  :   %04X; \n", (j + address) % depth, digit);
				//		  printf("         %04X  :   %04X; \n",(j+address)%depth, digit);
			}
		}

		// IF record is S2 (i.e. 6 digit address)

		if (wkstr[0] == 'S' && wkstr[1] == '2') {
			sscanf(&wkstr[2], "%2X", &count);
			sscanf(&wkstr[4], "%6X", &address);

			// if compiler puts out addresses greater than 0xFFFF i.e. size of on chip rom

			if (address < 0x10000)	{
				address = address >> 1;	// halve address for 16 bit proms

				for (i = 0, j = 0; i< count - 4; i = i + 2, j++) {
					sscanf(&wkstr[(i * 2) + 10], "%4x", &digit);
					fprintf(DestFilePtr, "         %04X  :   %04X; \n", (j + address) % depth, digit);
					//printf("         %04X  :   %04X; \n",(j+address)%depth, digit);
				}
			}
		}

		// IF record is S3 (i.e. 8 digit address)

		if (wkstr[0] == 'S' && wkstr[1] == '3') {
			sscanf(&wkstr[2], "%2X", &count);
			sscanf(&wkstr[4], "%8X", &address);

			// if compiler puts out addresses greater than 0xFFFF i.e. size of on chip rom

			if (address < 0x10000)	{
				address = address >> 1;	// halve address for 16 bit proms

				for (i = 0, j = 0; i < count - 5; i = i + 2, j++) {
					sscanf(&wkstr[(i * 2) + 12], "%4x", &digit);
					fprintf(DestFilePtr, "         %04X  :   %04X; \n", (j + address) % depth, digit);
					//printf("         %04X  :   %04X; \n",(j+address)%depth, digit);
				}
			}
		}
	}

	fprintf(DestFilePtr, "END;\n");
	printf("\n-------------------\n");
	printf("CONVERSION COMPLETE\n");
	printf("-------------------\n");

	system("PAUSE");
	return 0;

}