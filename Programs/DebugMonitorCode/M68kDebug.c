#include "DebugMonitor.h"

/**************************************************************
* 68 Debug Monitor + Disassembler
* Copyright Paul Davies 2014
***************************************************************

/******************************************************************/
/* IMPORTANT DO NOT INITIALISE GLOBAL VARIABLES - DO IT in MAIN() */
/* IMPORTANT DO NOT INITIALISE GLOBAL VARIABLES - DO IT in MAIN() */
/* IMPORTANT DO NOT INITIALISE GLOBAL VARIABLES - DO IT in MAIN() */
/* IMPORTANT DO NOT INITIALISE GLOBAL VARIABLES - DO IT in MAIN() */
/* IMPORTANT DO NOT INITIALISE GLOBAL VARIABLES - DO IT in MAIN() */
/* IMPORTANT DO NOT INITIALISE GLOBAL VARIABLES - DO IT in MAIN() */
/* IMPORTANT DO NOT INITIALISE GLOBAL VARIABLES - DO IT in MAIN() */
/******************************************************************/

unsigned int i, x, y, z, PortA_Count;
int     Trace, GoFlag;                       // used in tracing/single stepping

// 68000 register dump and preintialise value (these can be changed by the user program when it is running, e.g. stack pointer, registers etc

unsigned int d0,d1,d2,d3,d4,d5,d6,d7 ;
unsigned int a0,a1,a2,a3,a4,a5,a6 ;
unsigned int PC, SSP, USP ;
unsigned short int SR;

// Breakpoint variables
unsigned int BreakPointAddress[8];                      //array of 8 breakpoint addresses
unsigned short int BreakPointInstruction[8] ;           // to hold the instruction opcode at the breakpoint
unsigned int BreakPointSetOrCleared[8] ;
unsigned int InstructionSize ;

// watchpoint variables
unsigned int WatchPointAddress[8];                      //array of 8 breakpoint addresses
unsigned int WatchPointSetOrCleared[8] ;
char WatchPointString[8][100] ;


// for disassembly of program
char    Instruction[100] ;
char    TempString[100] ;

/************************************************************************************
*Subroutine to give the 68000 something useless to do to waste 1 mSec
************************************************************************************/
void Wait1ms(void)
{
    long int  i ;
    for(i = 0; i < 1000; i ++)
        ;
}

/************************************************************************************
*Subroutine to give the 68000 something useless to do to waste 3 mSec
**************************************************************************************/
void Wait3ms(void)
{
    int i ;
    for(i = 0; i < 3; i++)
        Wait1ms() ;
}

/*********************************************************************************************
*Subroutine to initialise the display by writing some commands to the LCD internal registers
*********************************************************************************************/
void Init_LCD(void)
{
    LCDcommand = (char)(0x0c) ;
    Wait3ms() ;
    LCDcommand = (char)(0x38) ;
    Wait3ms() ;
}

/******************************************************************************
*subroutine to output a single character held in d1 to the LCD display
*it is assumed the character is an ASCII code and it will be displayed at the
*current cursor position
*******************************************************************************/
void Outchar(int c)
{
    LCDdata = (char)(c);
    Wait1ms() ;
}

/**********************************************************************************
*subroutine to output a message at the current cursor position of the LCD display
************************************************************************************/
void OutMess(char *theMessage)
{
    char c ;
    while((c = *theMessage++) != (char)(0))
        Outchar(c) ;
}

/******************************************************************************
*subroutine to clear the line by issuing 24 space characters
*******************************************************************************/
void Clearln(void)
{
    unsigned char i ;
    for(i = 0; i < 24; i ++)
        Outchar(' ') ;  /* write a space char to the LCD display */
}

/******************************************************************************
*subroutine to move the cursor to the start of line 1 and clear that line
*******************************************************************************/
void Oline0(char *theMessage)
{
    LCDcommand = (char)(0x80) ;
    Wait3ms();
    Clearln() ;
    LCDcommand = (char)(0x80) ;
    Wait3ms() ;
    OutMess(theMessage) ;
}

/******************************************************************************
*subroutine to move the cursor to the start of line 2 and clear that line
*******************************************************************************/
void Oline1(char *theMessage)
{
    LCDcommand = (char)(0xC0) ;
    Wait3ms();
    Clearln() ;
    LCDcommand = (char)(0xC0) ;
    Wait3ms() ;
    OutMess(theMessage) ;
}

void InstallExceptionHandler( void (*function_ptr)(), int level)
{
    volatile long int *RamVectorAddress = (volatile long int *)(0x00840000) ;   // pointer to the Ram based interrupt vector table created in Cstart in debug monitor

    RamVectorAddress[level] = (long int *)(function_ptr);
}


void TestLEDS(void)
{
    int delay ;
    unsigned char count = 0 ;

    while(1)    {
        PortA = PortB = PortC = PortD = HEX_A = HEX_B = HEX_C = HEX_D = count++ ;
        for(delay = 0; delay < 100000; delay ++)
            ;
    }
}

void SwitchTest(void)
{
    int i, switches = 0 ;

    while(1)    {
        switches = (PortB << 8) | (PortA) ;
        printf("\rSwitches SW[15-0] = ") ;
        for( i = (int)(0x00008000); i > 0; i = i >> 1)  {
            if((switches & i) == 0)
                printf("0") ;
            else
                printf("1") ;
        }
    }
}

/*********************************************************************************************
*Subroutine to initialise the RS232 Port by writing some commands to the internal registers
*********************************************************************************************/
void Init_RS232(void)
{
    RS232_Control = (char)(0x15) ; //  %00010101    divide by 16 clock, set rts low, 8 bits no parity, 1 stop bit transmitter interrupt disabled
    RS232_Baud = (char)(0x1) ;      // program baud rate generator 000 = 230k, 001 = 115k, 010 = 57.6k, 011 = 38.4k, 100 = 19.2, all others = 9600
}

int kbhit(void)
{
    if(((char)(RS232_Status) & (char)(0x02)) == (char)(0x02))    // wait for Tx bit in status register to be '1'
        return 1 ;
    else
        return 0 ;
}

/*********************************************************************************************************
**  Subroutine to provide a low level output function to 6850 ACIA
**  This routine provides the basic functionality to output a single character to the serial Port
**  to allow the board to communicate with HyperTerminal Program
**
**  NOTE you do not call this function directly, instead you call the normal putchar() function
**  which in turn calls _putch() below). Other functions like puts(), printf() call putchar() so will
**  call _putch() also
*********************************************************************************************************/

int _putch( int c)
{
    while(((char)(RS232_Status) & (char)(0x02)) != (char)(0x02))    // wait for Tx bit in status register or 6850 serial comms chip to be '1'
        ;

    (char)(RS232_TxData) = ((char)(c) & (char)(0x7f));                      // write to the data register to output the character (mask off bit 8 to keep it 7 bit ASCII)
    return c ;                                              // putchar() expects the character to be returned
}

/*********************************************************************************************************
**  Subroutine to provide a low level input function to 6850 ACIA
**  This routine provides the basic functionality to input a single character from the serial Port
**  to allow the board to communicate with HyperTerminal Program Keyboard (your PC)
**
**  NOTE you do not call this function directly, instead you call the normal _getch() function
**  which in turn calls _getch() below). Other functions like gets(), scanf() call _getch() so will
**  call _getch() also
*********************************************************************************************************/

int _getch( void )
{
    int c ;
    while(((char)(RS232_Status) & (char)(0x01)) != (char)(0x01))    // wait for Rx bit in 6850 serial comms chip status register to be '1'
        ;

    c = (RS232_RxData & (char)(0x7f));                   // read received character, mask off top bit and return as 7 bit ASCII character
    _putch(c);
    return c ;
}

// flush the input stream for any unread characters

void FlushKeyboard(void)
{
    char c ;

    while(1)    {
        if(((char)(RS232_Status) & (char)(0x01)) == (char)(0x01))    // if Rx bit in status register is '1'
            c = ((char)(RS232_RxData) & (char)(0x7f)) ;
        else
            return ;
     }
}

// converts hex char to 4 bit binary equiv in range 0000-1111 (0-F)
// char assumed to be a valid hex char 0-9, a-f, A-F

char xtod(int c)
{
    if ((char)(c) <= (char)('9'))
        return c - (char)(0x30);    // 0 - 9 = 0x30 - 0x39 so convert to number by sutracting 0x30
    else if((char)(c) > (char)('F'))    // assume lower case
        return c - (char)(0x57);    // a-f = 0x61-66 so needs to be converted to 0x0A - 0x0F so subtract 0x57
    else
        return c - (char)(0x37);    // A-F = 0x41-46 so needs to be converted to 0x0A - 0x0F so subtract 0x37
}

int Get2HexDigits(char *CheckSumPtr)
{
    register int i = (xtod(_getch()) << 4) | (xtod(_getch()));

    if(CheckSumPtr)
        *CheckSumPtr += i ;

    return i ;
}

int Get4HexDigits(char *CheckSumPtr)
{
    return (Get2HexDigits(CheckSumPtr) << 8) | (Get2HexDigits(CheckSumPtr));
}

int Get6HexDigits(char *CheckSumPtr)
{
    return (Get4HexDigits(CheckSumPtr) << 8) | (Get2HexDigits(CheckSumPtr));
}

int Get8HexDigits(char *CheckSumPtr)
{
    return (Get4HexDigits(CheckSumPtr) << 16) | (Get4HexDigits(CheckSumPtr));
}

char *strcatInstruction(char *s) {    return strcat(Instruction,s) ; }
char *strcpyInstruction(char *s) {    return strcpy(Instruction,s) ; }

void DisassembleProgram(void )
{
    char c ;
    int i, j ;
    unsigned short int *ProgramPtr ; // pointer to where the program is stored

    printf("\r\nEnter Start Address: ") ;
    ProgramPtr = Get8HexDigits(0) ;
    printf("\r\n<ESC> = Abort, SPACE to Continue") ;
    while(1)    {
        for(i = 0; i < 20; i ++)
        {
            InstructionSize = 1 ;                   // assume all instruction are at least 1 word
            DisassembleInstruction(ProgramPtr) ;    // build up string for disassembled instruction at address in programptr

            if(InstructionSize == 1)
                printf("\r\n%08X  %04X                        %s", ProgramPtr, ProgramPtr[0], Instruction) ;

            else if(InstructionSize == 2)
                printf("\r\n%08X  %04X %04X                   %s", ProgramPtr, ProgramPtr[0], ProgramPtr[1], Instruction) ;

            else if(InstructionSize == 3)
                printf("\r\n%08X  %04X %04X %04X              %s", ProgramPtr, ProgramPtr[0], ProgramPtr[1], ProgramPtr[2], Instruction) ;

            else if(InstructionSize == 4)
                printf("\r\n%08X  %04X %04X %04X %04X         %s", ProgramPtr, ProgramPtr[0], ProgramPtr[1], ProgramPtr[2], ProgramPtr[3], Instruction) ;

            else if(InstructionSize == 5)
                printf("\r\n%08X  %04X %04X %04X %04X %04X    %s", ProgramPtr, ProgramPtr[0], ProgramPtr[1], ProgramPtr[2], ProgramPtr[3], ProgramPtr[4], Instruction) ;

            ProgramPtr += InstructionSize ;
        }


        c = _getch() ;
        if(c == 0x1b)          // break on ESC
            return ;
    }
}

void DumpMemory(void)   // simple dump memory fn
{
    int i, j ;
    unsigned char *RamPtr,c ; // pointer to where the program is download (assumed)

    printf("\r\nDump Memory Block: <ESC> to Abort, <SPACE> to Continue") ;
    printf("\r\nEnter Start Address: ") ;
    RamPtr = Get8HexDigits(0) ;

    while(1)    {
        for(i = 0; i < 16; i ++)    {
            printf("\r\n%08x ", RamPtr) ;
            for(j=0; j < 16; j ++)  {
                printf("%02X",RamPtr[j]) ;
                putchar(' ') ;
            }

            // now display the data as ASCII at the end

            printf("  ") ;
            for(j = 0; j < 16; j++) {
                c = ((char)(RamPtr[j]) & 0x7f) ;
                if((c > (char)(0x7f)) || (c < ' '))
                    putchar('.') ;
                else
                    putchar(RamPtr[j]) ;
            }
            RamPtr = RamPtr + 16 ;
        }
        printf("\r\n") ;

        c = _getch() ;
        if(c == 0x1b)          // break on ESC
            break ;
     }
}

void FillMemory()
{
    char *StartRamPtr, *EndRamPtr ;
    unsigned char FillData ;

    printf("\r\nFill Memory Block") ;
    printf("\r\nEnter Start Address: ") ;
    StartRamPtr = Get8HexDigits(0) ;

    printf("\r\nEnter End Address: ") ;
    EndRamPtr = Get8HexDigits(0) ;

    printf("\r\nEnter Fill Data: ") ;
    FillData = Get2HexDigits(0) ;
    printf("\r\nFilling Addresses [$%08X - $%08X] with $%02X", StartRamPtr, EndRamPtr, FillData) ;

    while(StartRamPtr < EndRamPtr)
        *StartRamPtr++ = FillData ;
}

void Load_SRecordFile()
{
    int i, Address, AddressSize, DataByte, NumDataBytesToRead, LoadFailed, FailedAddress, AddressFail ;
    int result, ByteCount ;

    char c, CheckSum, ReadCheckSum, HeaderType ;
    char *RamPtr ;                          // pointer to Memory where downloaded program will be stored

    LoadFailed = 0 ;                        //assume LOAD operation will pass
    AddressFail = 0 ;

    printf("\r\nDownload Program to Memory....<ESC> to Cancel") ;
    printf("\r\nWaiting for Laptop to send '.HEX' file:\r\n") ;

    while(1)    {
        CheckSum = 0 ;
        do {
            c = toupper(_getch()) ;

            if(c == 0x1b )      // if break
                return;
         }while(c != (char)('S'));   // wait for S start of header

        HeaderType = _getch() ;

        if(HeaderType == (char)('0') || HeaderType == (char)('5'))       // ignore s0, s5 records
            continue ;

        if(HeaderType >= (char)('7'))
            break ;                 // end load on s7,s8,s9 records

// get the bytecount

        ByteCount = Get2HexDigits(&CheckSum) ;

// get the address, 4 digits for s1, 6 digits for s2, and 8 digits for s3 record

        if(HeaderType == (char)('1')) {
            AddressSize = 2 ;       // 2 byte address
            Address = Get4HexDigits(&CheckSum);
        }
        else if (HeaderType == (char)('2')) {
            AddressSize = 3 ;       // 3 byte address
            Address = Get6HexDigits(&CheckSum) ;
        }
        else    {
            AddressSize = 4 ;       // 4 byte address
            Address = Get8HexDigits(&CheckSum) ;
        }

        RamPtr = (char *)(Address) ;                            // point to download area

        NumDataBytesToRead = ByteCount - AddressSize - 1 ;

        for(i = 0; i < NumDataBytesToRead; i ++) {     // read in remaining data bytes (ignore address and checksum at the end
            DataByte = Get2HexDigits(&CheckSum) ;
            *RamPtr++ = DataByte ;                      // store downloaded byte in Ram at specified address
        }

// checksum is the 1's complement of the sum of all data pairs following the bytecount, i.e. it includes the address and the data itself

        ReadCheckSum = Get2HexDigits(0) ;

        if((~CheckSum&0Xff) != (ReadCheckSum&0Xff))   {
            LoadFailed = 1 ;
            FailedAddress = Address ;
            break;
        }
        putchar('\n') ;
     }

     if(LoadFailed == 1) {
        printf("\r\nLoad Failed at Address = [$%08X]\r\n", FailedAddress) ;
     }

     else
        puts("\r\nLoad Successful.....\r\n");


     // pause at the end to wait for download to finish transmitting at the end of S8 etc

     for(i = 0; i < 400000; i ++)
        ;

     FlushKeyboard() ;
}

void MemoryChange(void)
{
    unsigned char *RamPtr,c ; // pointer to memory
    int Data ;

    printf("\r\nExamine and Change Memory") ;
    printf("\r\n<ESC> to Stop, <SPACE> to Advance, '-' to Go Back, <DATA> to change") ;

    printf("\r\nEnter Address: ") ;
    RamPtr = Get8HexDigits(0) ;

    while(1)    {
        printf("\r\n[%08x] : %02x  ", RamPtr, *RamPtr) ;
        c = tolower(_getch()) ;

       if(c == (char)(0x1b))
            return ;                                // abort on escape

       else if((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f')) {  // are we trying to change data at this location by entering a hex char
            Data = (xtod(c) << 4) | (xtod(_getch()));
            *RamPtr = (char)(Data) ;
            if(*RamPtr != Data) {
                printf("\r\nWarning Change Failed: Wrote [%02x], Read [%02x]", Data, *RamPtr) ;
            }
        }
        else if(c == (char)('-'))
            RamPtr -= 2 ; ;

        RamPtr ++ ;
    }
}

void ProgramFlashChip(void)
{
    char c;
    int i ;
    unsigned char *RamPtr = (unsigned char *)(ProgramStart) ;      // pointer to start of user program
    unsigned char *FlashPtr = (unsigned char *)(FlashStart);		// pointer to flash chip base address;

    printf("\r\nProgram Flash Memory.....[Y/N]?") ;

    c = tolower(_getch()) ;

    if(c != 'y') {
        printf("\r\nProgramming ABANDONED.....") ;
        return ;
    }

    FlashReset() ;
    printf("\r\nErasing Flash Memory.....") ;

    //erase first 64 as 8 sectors of 8k each
    for(i = 0; i < 8; i++)
        FlashSectorErase( i );


    //erase next sectors of 64 k block

    for(i = 1; i < Num_FlashSectors + 1 ; i++)
        FlashSectorErase( i << 3 );

    printf("\r\nProgramming Flash Memory.....") ;

    for(i = 0; i < FlashSize; i ++) {   // i = address offset to the Flash chip
        FlashProgram(i, *RamPtr++) ;    // address offset into flash, byte data
    }

    printf("\r\nVerifying.....");

    FlashReset() ;
    RamPtr = (unsigned char *)(ProgramStart) ;      // reset pointer to start of user program

    for(i = 0; i < FlashSize; i ++) {
        if(FlashRead(i) != *RamPtr++) {
            RamPtr -- ;
            printf("\r\nFAILED.....") ;
            return ;
        }
    }
    printf("\r\nPASSED") ;
}

//
// Load a program from Flash Chip and copies to Dram
//

void LoadFromFlashChip(void)
{
    char c;
    int i ;
    unsigned char *RamPtr = (unsigned char *)(ProgramStart) ;      // pointer to start of user program
    unsigned char *FlashPtr = (unsigned char *)(FlashStart);		// pointer to flash chip base address;


    FlashReset() ;


    // test for type of copy, software or DMA by reading switch 17 (Port B bit 1) on DE2 board.

    printf("\r\nLoading Program From Flash....Using ") ;
    if(((char)(PortC & 0x02)) != (char)(0x02))    {
        printf("Software") ;
        for(i = 0; i < FlashSize; i ++) {
            *RamPtr++ =  FlashPtr[i << 1] ;
        }
    }

    else    {
        printf("DMA") ;
        // todo - program a DMA controller if one is present
    }

    printf("\r\nProgram Loaded.....") ;
}


// get rid of excess spaces

void FormatInstructionForTrace(void)
{
    unsigned short int i ;
    char c, temp[100], *iptr, *tempptr ;

    for(i=0; i < 100; i++)
        temp[i] = 0 ;

    iptr = Instruction ;
    tempptr = temp ;

    do{
        c = *iptr++ ;
        *tempptr++ = c ;  // copy chars over

        if(c == ' ')  {   // if copied space
            while(*iptr == ' ') {
                if(*iptr == 0)  // if end of string then done
                    break ;

                iptr++ ; // skip over remaining spaces
            }
            strcat(tempptr,iptr) ;
        }
    }while(c != 0) ;

    strcpyInstruction(temp) ;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// IMPORTANT
// Softcore 68k does not support the Native Trace mode of the original 68000 so tracing
// has to be done with an interrupt (IRQ Level 6)
//
// To allow the 68000 to execute one more instruction after each pseudo trace (IRQ6)
// the IRQ is removed in hardware once the TG68 reads the IRQ autovector (i.e. acknowledges the IRQ)
//
// on return from the IRQ service handler, the first access to the user memory program space
// generates a fresh IRQ (in hardware) to generate a new trace, this allows the tg68 to
// execute one more new instruction (without it the TG68 would trace on the same instruction
// each time and not after the next one). It also means it doesn't simgle step outside the user
// program area
//
// The bottom line is the Trace handler, which includes the Dump registers below
// cannot access the user memory to display for example the Instruction Opcode or to disassemble etc
// as this would lead to a new IRQ being reset and the TG68 would trace on same instruction
// NOT SURE THIS IS TRUE NOW THAT TRACE HANDLER HAS BEEN MODIVIED TO NOT AUTOMATICALLY GENERATE A TRACE EXCEPTION
// INSTEAD IT IS DONE IN THE 'N' COMMAND FOR NEXT
/////////////////////////////////////////////////////////////////////////////////////////////////////


void DumpRegisters()
{
    short i, x, j, k ;
    unsigned char c, *BytePointer;

// buld up strings for displaying watchpoints

    for(x = 0; x < (short)(8); x++)
    {
        if(WatchPointSetOrCleared[x] == 1)
        {
            sprintf(WatchPointString[x], "$%08X  ", WatchPointAddress[x]) ;
            BytePointer = (char *)(WatchPointAddress[x]) ;

            for(j = 0; j < (short)(16); j+=2)
            {
                for(k = 0; k < (short)(2); k++)
                {
                    sprintf(TempString, "%02X", BytePointer[j+k]) ;
                    strcat(WatchPointString[x], TempString) ;
                }
                strcat(WatchPointString[x]," ") ;
            }

            strcat(WatchPointString[x], "  ") ;
            BytePointer = (char *)(WatchPointAddress[x]) ;

            for(j = 0; j < (short)(16); j++)
            {
                c = ((char)(BytePointer[j]) & 0x7f) ;
                if((c > (char)(0x7f)) || (c < (char)(' ')))
                    sprintf(TempString, ".") ;
                else
                    sprintf(TempString, "%c", BytePointer[j]) ;
                strcat(WatchPointString[x], TempString) ;
            }
        }
        else
            strcpy(WatchPointString[x], "") ;
    }

    printf("\r\n\r\n D0 = $%08X  A0 = $%08X",d0,a0) ;
    printf("\r\n D1 = $%08X  A1 = $%08X",d1,a1) ;
    printf("\r\n D2 = $%08X  A2 = $%08X",d2,a2) ;
    printf("\r\n D3 = $%08X  A3 = $%08X",d3,a3) ;
    printf("\r\n D4 = $%08X  A4 = $%08X",d4,a4) ;
    printf("\r\n D5 = $%08X  A5 = $%08X",d5,a5) ;
    printf("\r\n D6 = $%08X  A6 = $%08X",d6,a6) ;
    printf("\r\n D7 = $%08X  A7 = $%08X",d7,((SR & (unsigned short int)(0x2000)) == ((unsigned short int)(0x2000))) ? SSP : USP) ;
    printf("\r\n\r\nUSP = $%08X  (A7) User SP", USP ) ;
    printf("\r\nSSP = $%08X  (A7) Supervisor SP", SSP) ;
    printf("\r\n SR = $%04X   ",SR) ;

// display the status word in characters etc.

    printf("   [") ;
    if((SR & (unsigned short int)(0x8000)) == (unsigned short int)(0x8000)) putchar('T') ; else putchar('-') ;      // Trace bit(bit 15)
    if((SR & (unsigned short int)(0x2000)) == (unsigned short int)(0x2000)) putchar('S') ; else putchar('U') ;      // supervisor bit  (bit 13)

    if((SR & (unsigned short int)(0x0400)) == (unsigned short int)(0x0400)) putchar('1') ; else putchar('0') ;      // IRQ2 Bit (bit 10)
    if((SR & (unsigned short int)(0x0200)) == (unsigned short int)(0x0200)) putchar('1') ; else putchar('0') ;      // IRQ1 Bit (bit 9)
    if((SR & (unsigned short int)(0x0100)) == (unsigned short int)(0x0100)) putchar('1') ; else putchar('0') ;      // IRQ0 Bit (bit 8)

    if((SR & (unsigned short int)(0x0010)) == (unsigned short int)(0x0010)) putchar('X') ; else putchar('-') ;      // X Bit (bit 4)
    if((SR & (unsigned short int)(0x0008)) == (unsigned short int)(0x0008)) putchar('N') ; else putchar('-') ;      // N Bit (bit 3)
    if((SR & (unsigned short int)(0x0004)) == (unsigned short int)(0x0004)) putchar('Z') ; else putchar('-') ;      // Z Bit (bit 2)
    if((SR & (unsigned short int)(0x0002)) == (unsigned short int)(0x0002)) putchar('V') ; else putchar('-') ;      // V Bit (bit 1)
    if((SR & (unsigned short int)(0x0001)) == (unsigned short int)(0x0001)) putchar('C') ; else putchar('-') ;      // C Bit (bit 0)
    putchar(']') ;

    printf("\r\n PC = $%08X  ", PC) ;
    if(*(unsigned short int *)(PC) != 0x4e4e)   {
        DisassembleInstruction(PC) ;
        FormatInstructionForTrace() ;
        printf("%s", Instruction) ;
    }

    else
        printf("[BREAKPOINT]") ;

    printf("\r\n") ;

    for(i=0; i < 8; i++)    {
        if(WatchPointSetOrCleared[i] == 1)
            printf("\r\nWP%d = %s", i, WatchPointString[i]) ;
    }

}

// Trace Exception Handler
void DumpRegistersandPause(void)
{
    printf("\r\n\r\n\r\n\r\n\r\n\r\nSingle Step  :[ON]") ;
    printf("\r\nBreak Points :[Disabled]") ;
    DumpRegisters() ;
    printf("\r\nPress <SPACE> to Execute Next Instruction");
    printf("\r\nPress <ESC> to Resume Program") ;
    menu() ;
}

void ChangeRegisters(void)
{
    // get register name d0-d7, a0-a7, up, sp, sr, pc

    int reg_val ;
    char c, reg[3] ;

    reg[0] = tolower(_getch()) ;
    reg[1] = c = tolower(_getch()) ;

    if(reg[0] == (char)('d'))  {    // change data register
        if((reg[1] > (char)('7')) || (reg[1] < (char)('0'))) {
            printf("\r\nIllegal Data Register : Use D0-D7.....\r\n") ;
            return ;
        }
        else {
            printf("\r\nD%c = ", c) ;
            reg_val = Get8HexDigits(0) ;    // read 32 bit value from user keyboard
        }

        // bit cludgy but d0-d7 not stored as an array for good reason
        if(c == (char)('0'))
            d0 = reg_val ;
        else if(c == (char)('1'))
            d1 = reg_val ;
        else if(c == (char)('2'))
            d2 = reg_val ;
        else if(c == (char)('3'))
            d3 = reg_val ;
        else if(c == (char)('4'))
            d4 = reg_val ;
        else if(c == (char)('5'))
            d5 = reg_val ;
        else if(c == (char)('6'))
            d6 = reg_val ;
        else
            d7 = reg_val ;
    }
    else if(reg[0] == (char)('a'))  {    // change address register, a7 is the user stack pointer, sp is the system stack pointer
        if((c > (char)('7')) || (c < (char)('0'))) {
            printf("\r\nIllegal Address Register : Use A0-A7.....\r\n") ;
            return ;
        }
        else {
            printf("\r\nA%c = ", c) ;
            reg_val = Get8HexDigits(0) ;    // read 32 bit value from user keyboard
        }
        // bit cludgy but a0-a7 not stored as an array for good reason
        if(c == (char)('0'))
            a0 = reg_val ;
        else if(c == (char)('1'))
            a1 = reg_val ;
        else if(c == (char)('2'))
            a2 = reg_val ;
        else if(c == (char)('3'))
            a3 = reg_val ;
        else if(c == (char)('4'))
            a4 = reg_val ;
        else if(c == (char)('5'))
            a5 = reg_val ;
        else if(c == (char)('6'))
            a6 = reg_val ;
        else
            USP = reg_val ;
    }
    else if((reg[0] == (char)('u')) && (c == (char)('s')))  {
           if(tolower(_getch()) == 'p')  {    // change user stack pointer
                printf("\r\nUser SP = ") ;
                USP = Get8HexDigits(0) ;    // read 32 bit value from user keyboard
           }
           else {
                printf("\r\nIllegal Register....") ;
                return ;
           }
    }

    else if((reg[0] == (char)('s')) && (c == (char)('s')))  {
           if(tolower(_getch()) == 'p')  {    // change system stack pointer
                printf("\r\nSystem SP = ") ;
                SSP = Get8HexDigits(0) ;    // read 32 bit value from user keyboard
           }
           else {
                printf("\r\nIllegal Register....") ;
                return ;
           }
    }

    else if((reg[0] == (char)('p')) && (c == (char)('c')))  {    // change program counter
          printf("\r\nPC = ") ;
          PC = Get8HexDigits(0) ;    // read 32 bit value from user keyboard
    }

    else if((reg[0] == (char)('s')) && (c == (char)('r')))  {    // change status register
          printf("\r\nSR = ") ;
          SR = Get4HexDigits(0) ;    // read 16 bit value from user keyboard
    }
    else
        printf("\r\nIllegal Register: Use A0-A7, D0-D7, SSP, USP, PC or SR\r\n") ;

    DumpRegisters() ;
}

void BreakPointDisplay(void)
{
   int i, BreakPointsSet = 0 ;

// any break points  set

    for(i = 0; i < 8; i++)  {
       if(BreakPointSetOrCleared[i] == 1)
            BreakPointsSet = 1;
    }

    if(BreakPointsSet == 1) {
        printf("\r\n\r\nNum     Address      Instruction") ;
        printf("\r\n---     ---------    -----------") ;
    }
    else
        printf("\r\nNo BreakPoints Set") ;


    for(i = 0; i < 8; i++)  {
    // put opcode back to disassemble it, then put break point back
        if(BreakPointSetOrCleared[i] == 1)  {
            *(unsigned short int *)(BreakPointAddress[i]) = BreakPointInstruction[i];
            DisassembleInstruction(BreakPointAddress[i]) ;
            FormatInstructionForTrace() ;
            *(unsigned short int *)(BreakPointAddress[i]) = (unsigned short int)(0x4e4e) ;
            printf("\r\n%3d     $%08x",i, BreakPointAddress[i]) ;
            printf("    %s", Instruction);
        }
    }
    printf("\r\n") ;
}

void WatchPointDisplay(void)
{
   int i ;
   int WatchPointsSet = 0 ;

// any watchpoints set

    for(i = 0; i < 8; i++)  {
       if(WatchPointSetOrCleared[i] == 1)
            WatchPointsSet = 1;
    }

    if(WatchPointsSet == 1) {
        printf("\r\nNum     Address") ;
        printf("\r\n---     ---------") ;
    }
    else
        printf("\r\nNo WatchPoints Set") ;

    for(i = 0; i < 8; i++)  {
        if(WatchPointSetOrCleared[i] == 1)
            printf("\r\n%3d     $%08x",i, WatchPointAddress[i]) ;
     }
    printf("\r\n") ;
}

void BreakPointClear(void)
{
    unsigned int i ;
    volatile unsigned short int *ProgramBreakPointAddress ;

    BreakPointDisplay() ;

    printf("\r\nEnter Break Point Number: ") ;
    i = xtod(_getch()) ;           // get break pointer number

    if((i < 0) || (i > 7))   {
        printf("\r\nIllegal Range : Use 0 - 7") ;
        return ;
    }

    if(BreakPointSetOrCleared[i] == 1)  {       // if break point set
        ProgramBreakPointAddress = (volatile unsigned short int *)(BreakPointAddress[i]) ;     // point to the instruction in the user program we are about to change
        BreakPointAddress[i] = 0 ;
        BreakPointSetOrCleared[i] = 0 ;
        *ProgramBreakPointAddress = BreakPointInstruction[i] ;  // put original instruction back
        BreakPointInstruction[i] = 0 ;
        printf("\r\nBreak Point Cleared.....\r\n") ;
    }
    else
        printf("\r\nBreak Point wasn't Set.....") ;

    BreakPointDisplay() ;
    return ;
}

void WatchPointClear(void)
{
    unsigned int i ;

    WatchPointDisplay() ;

    printf("\r\nEnter Watch Point Number: ") ;
    i = xtod(_getch()) ;           // get watch pointer number

    if((i < 0) || (i > 7))   {
        printf("\r\nIllegal Range : Use 0 - 7") ;
        return ;
    }

    if(WatchPointSetOrCleared[i] == 1)  {       // if watch point set
        WatchPointAddress[i] = 0 ;
        WatchPointSetOrCleared[i] = 0 ;
        printf("\r\nWatch Point Cleared.....\r\n") ;
    }
    else
        printf("\r\nWatch Point Was not Set.....") ;

    WatchPointDisplay() ;
    return ;

}

void DisableBreakPoints(void)
{
   int i ;
   volatile unsigned short int *ProgramBreakPointAddress ;

   for(i = 0; i < 8; i++)  {
      if(BreakPointSetOrCleared[i] == 1)    {                                                    // if break point set
          ProgramBreakPointAddress = (volatile unsigned short int *)(BreakPointAddress[i]) ;     // point to the instruction in the user program where the break point has been set
          *ProgramBreakPointAddress = BreakPointInstruction[i];                                  // copy the instruction back to the user program overwritting the $4e4e
      }
   }
}

void EnableBreakPoints(void)
{
   int i ;
   volatile unsigned short int *ProgramBreakPointAddress ;

   for(i = 0; i < 8; i++)  {
      if(BreakPointSetOrCleared[i] == 1)    {                                                     // if break point set
           ProgramBreakPointAddress = (volatile unsigned short int *)(BreakPointAddress[i]) ;     // point to the instruction in the user program where the break point has been set
           *ProgramBreakPointAddress = (unsigned short int)(0x4e4e);                              // put the breakpoint back in user program
      }
   }
}

void KillAllBreakPoints(void)
{
   int i ;
   volatile unsigned short int *ProgramBreakPointAddress ;

   for(i = 0; i < 8; i++)  {
       // clear BP
       ProgramBreakPointAddress = (volatile unsigned short int *)(BreakPointAddress[i]) ;     // point to the instruction in the user program where the break point has been set
       *ProgramBreakPointAddress = BreakPointInstruction[i];                                  // copy the instruction back to the user program
       BreakPointAddress[i] = 0 ;                                                             // set BP address to NULL
       BreakPointInstruction[i] = 0 ;
       BreakPointSetOrCleared[i] = 0 ;                                                        // mark break point as cleared for future setting
   }
   //BreakPointDisplay() ;       // display the break points
}

void KillAllWatchPoints(void)
{
   int i ;

   for(i = 0; i < 8; i++)  {
       WatchPointAddress[i] = 0 ;                                                             // set BP address to NULL
       WatchPointSetOrCleared[i] = 0 ;                                                        // mark break point as cleared for future setting
   }
   //WatchPointDisplay() ;       // display the break points
}


void SetBreakPoint(void)
{
    int i ;
    int BPNumber;
    int BPAddress;
    volatile unsigned short int *ProgramBreakPointAddress ;

    // see if any free break points

    for(i = 0; i < 8; i ++) {
        if( BreakPointSetOrCleared[i] == 0)
            break ;         // if spare BP found allow user to set it
    }

    if(i == 8) {
        printf("\r\nNo FREE Break Points.....") ;
        return ;
    }

    printf("\r\nBreak Point Address: ") ;
    BPAddress = Get8HexDigits(0) ;
    ProgramBreakPointAddress = (volatile unsigned short int *)(BPAddress) ;     // point to the instruction in the user program we are about to change

    if((BPAddress & 0x00000001) == 0x00000001)  {   // cannot set BP at an odd address
        printf("\r\nError : Break Points CANNOT be set at ODD addresses") ;
        return ;
    }

    if(BPAddress < 0x00008000)  {   // cannot set BP at an odd address
        printf("\r\nError : Break Points CANNOT be set for ROM in Range : [$0-$00007FFF]") ;
        return ;
    }

    // search for first free bp or existing same BP

    for(i = 0; i < 8; i++)  {
        if(BreakPointAddress[i] == BPAddress)   {
            printf("\r\nError: Break Point Already Exists at Address : %08x\r\n", BPAddress) ;
            return ;
        }
        if(BreakPointSetOrCleared[i] == 0) {
            // set BP here
            BreakPointSetOrCleared[i] = 1 ;                                 // mark this breakpoint as set
            BreakPointInstruction[i] = *ProgramBreakPointAddress ;          // copy the user program instruction here so we can put it back afterwards
            DisassembleInstruction(ProgramBreakPointAddress) ;
            FormatInstructionForTrace() ;
            printf("\r\nBreak Point Set at Address: [$%08x], Instruction = %s", ProgramBreakPointAddress, Instruction) ;
            *ProgramBreakPointAddress = (unsigned short int)(0x4e4e)    ;   // put a Trap14 instruction at the user specified address
            BreakPointAddress[i] = BPAddress ;                              // record the address of this break point in the debugger
            printf("\r\n") ;
            BreakPointDisplay() ;       // display the break points
            return ;
        }
    }
}

void SetWatchPoint(void)
{
    int i ;
    int WPNumber;
    int WPAddress;
    volatile unsigned short int *ProgramWatchPointAddress ;

    // see if any free break points

    for(i = 0; i < 8; i ++) {
        if( WatchPointSetOrCleared[i] == 0)
            break ;         // if spare WP found allow user to set it
    }

    if(i == 8) {
        printf("\r\nNo FREE Watch Points.....") ;
        return ;
    }

    printf("\r\nWatch Point Address: ") ;
    WPAddress = Get8HexDigits(0) ;

    // search for first free wp or existing same wp

    for(i = 0; i < 8; i++)  {
        if(WatchPointAddress[i] == WPAddress && WPAddress != 0)   {     //so we can set a wp at 0
            printf("\r\nError: Watch Point Already Set at Address : %08x\r\n", WPAddress) ;
            return ;
        }
        if(WatchPointSetOrCleared[i] == 0) {
            WatchPointSetOrCleared[i] = 1 ;                                 // mark this watchpoint as set
            printf("\r\nWatch Point Set at Address: [$%08x]", WPAddress) ;
            WatchPointAddress[i] = WPAddress ;                              // record the address of this watch point in the debugger
            printf("\r\n") ;
            WatchPointDisplay() ;       // display the break points
            return ;
        }
    }
}


void HandleBreakPoint(void)
{
    volatile unsigned short int *ProgramBreakPointAddress ;

    // now we have to put the break point back to run the instruction
    // PC will contain the address of the TRAP instruction but advanced by two bytes so lets play with that

    PC = PC - 2 ;  // ready for user to resume after reaching breakpoint

    printf("\r\n\r\n\r\n\r\n@BREAKPOINT") ;
    printf("\r\nSingle Step : [ON]") ;
    printf("\r\nBreakPoints : [Enabled]") ;

    // now clear the break point (put original instruction back)

    ProgramBreakPointAddress = PC ;

    for(i = 0; i < 8; i ++) {
        if(BreakPointAddress[i] == PC) {        // if we have found the breakpoint
            BreakPointAddress[i] = 0 ;
            BreakPointSetOrCleared[i] = 0 ;
            *ProgramBreakPointAddress = BreakPointInstruction[i] ;  // put original instruction back
            BreakPointInstruction[i] = 0 ;
        }
    }

    DumpRegisters() ;
    printf("\r\nPress <SPACE> to Execute Next Instruction");
    printf("\r\nPress <ESC> to Resume User Program\r\n") ;
    menu() ;
}

void UnknownCommand()
{
    printf("\r\nUnknown Command.....\r\n") ;
    Help() ;
}

// system when the users program executes a TRAP #15 instruction to halt program and return to debug monitor

void CallDebugMonitor(void)
{
    printf("\r\nProgram Ended (TRAP #15)....") ;
    menu();
}

void Breakpoint(void)
{
       char c;
       c = toupper(_getch());

        if( c == (char)('D'))                                      // BreakPoint Display
            BreakPointDisplay() ;

        else if(c == (char)('K')) {                                 // breakpoint Kill
            printf("\r\nKill All Break Points...(y/n)?") ;
            c = toupper(_getch());
            if(c == (char)('Y'))
                KillAllBreakPoints() ;
        }
        else if(c == (char)('S')) {
            SetBreakPoint() ;
        }
        else if(c == (char)('C')) {
            BreakPointClear() ;
        }
        else
            UnknownCommand() ;
}

void Watchpoint(void)
{
       char c;
       c = toupper(_getch());

        if( c == (char)('D'))                                      // WatchPoint Display
            WatchPointDisplay() ;

        else if(c == (char)('K')) {                                 // wtahcpoint Kill
            printf("\r\nKill All Watch Points...(y/n)?") ;
            c = toupper(_getch());
            if(c == (char)('Y'))
                KillAllWatchPoints() ;
        }
        else if(c == (char)('S')) {
            SetWatchPoint() ;
        }
        else if(c == (char)('C')) {
            WatchPointClear() ;
        }
        else
            UnknownCommand() ;
}

void DMenu(void)
{
    char c;
    c = toupper(_getch());

    if( c == (char)('U'))                                     // Dump Memory
            DumpMemory() ;

    else if(c == (char)('I'))   {
        DisableBreakPoints() ;
        DisassembleProgram() ;
        EnableBreakPoints() ;
    }

    else
        UnknownCommand() ;

}

void Help(void)
{
    char *banner = "\r\n----------------------------------------------------------------" ;

    printf(banner) ;
    printf("\r\n  Debugger Command Summary") ;
    printf(banner) ;
    printf("\r\n  .(reg)       - Change Registers: e.g A0-A7,D0-D7,PC,SSP,USP,SR");
    printf("\r\n  BD/BS/BC/BK  - Break Point: Display/Set/Clear/Kill") ;
    printf("\r\n  C            - Copy Program from Flash to Main Memory") ;
    printf("\r\n  DI           - Disassemble Program");
    printf("\r\n  DU           - Dump Memory Contents to Screen") ;
    printf("\r\n  E            - Enter String into Memory") ;
    printf("\r\n  F            - Fill Memory with Data") ;
    printf("\r\n  G            - Go Program Starting at Address: $%08X", PC) ;
    printf("\r\n  L            - Load Program (.HEX file) from Laptop") ;
    printf("\r\n  M            - Memory Examine and Change");
    printf("\r\n  P            - Program Flash Memory with User Program") ;
    printf("\r\n  R            - Display 68000 Registers") ;
    printf("\r\n  S            - Toggle ON/OFF Single Step Mode") ;
    printf("\r\n  TM           - Test Memory") ;
    printf("\r\n  TS           - Test DE2 Switches: SW0-SW15") ;
    printf("\r\n  TD           - Test DE2 Displays: LEDs and 7-Segment") ;
    printf("\r\n  WD/WS/WC/WK  - Watch Point: Display/Set/Clear/Kill") ;
    printf(banner) ;
}


void menu(void)
{
    char c,c1 ;

    while(1)    {
        FlushKeyboard() ;               // dump unread characters from keyboard
        printf("\r\n#") ;
        c = toupper(_getch());

        if( c == (char)('L'))                  // load s record file
             Load_SRecordFile() ;

        else if( c == (char)('D'))             // dump memory
            DMenu() ;

        else if( c == (char)('E'))             // Enter String into memory
            EnterString() ;

        else if( c == (char)('F'))             // fill memory
            FillMemory() ;

        else if( c == (char)('G'))  {           // go user program
            printf("\r\nProgram Running.....") ;
            printf("\r\nPress <RESET> button <Key0> on DE2 to stop") ;
            GoFlag = 1 ;
            go() ;
        }

        else if( c == (char)('M'))           // memory examine and modify
             MemoryChange() ;

        else if( c == (char)('P'))            // Program Flash Chip
             ProgramFlashChip() ;

        else if( c == (char)('C'))             // copy flash chip to ram and go
             LoadFromFlashChip();

        else if( c == (char)('R'))             // dump registers
             DumpRegisters() ;

        else if( c == (char)('.'))           // change registers
             ChangeRegisters() ;

        else if( c == (char)('B'))              // breakpoint command
            Breakpoint() ;

        else if( c == (char)('T'))  {          // Test command
             c1 = toupper(_getch()) ;
             if(c1 == (char)('M'))                    // memory test
                MemoryTest() ;
             else if( c1 == (char)('S'))              // Switch Test command
                SwitchTest() ;
             else if( c1 == (char)('D'))              // display Test command
                TestLEDS() ;
             else
                UnknownCommand() ;
        }

        else if( c == (char)(' ')) {             // Next instruction command
            DisableBreakPoints() ;
            if(Trace == 1 && GoFlag == 1)   {    // if the program is running and trace mode on then 'N' is valid
                TraceException = 1 ;             // generate a trace exception for the next instruction if user wants to single step though next instruction
                return ;
            }
            else
                printf("\r\nError: Press 'G' first to start program") ;
        }

        else if( c == (char)('S')) {             // single step
             if(Trace == 0) {
                DisableBreakPoints() ;
                printf("\r\nSingle Step  :[ON]") ;
                printf("\r\nBreak Points :[Disabled]") ;
                SR = SR | (unsigned short int)(0x8000) ;    // set T bit in status register
                printf("\r\nPress 'G' to Trace Program from address $%X.....",PC) ;
                printf("\r\nPush <RESET Button> to Stop.....") ;
                DumpRegisters() ;

                Trace = 1;
                TraceException = 1;
                x = *(unsigned int *)(0x00000074) ;       // simulate responding to a Level 5 IRQ by reading vector to reset Trace exception generator
            }
            else {
                Trace = 0 ;
                TraceException = 0 ;
                x = *(unsigned int *)(0x00000074) ;       // simulate responding to a Level 5 IRQ by reading vector to reset Trace exception generator
                EnableBreakPoints() ;
                SR = SR & (unsigned short int)(0x7FFF) ;    // clear T bit in status register
                printf("\r\nSingle Step : [OFF]") ;
                printf("\r\nBreak Points :[Enabled]") ;
                printf("\r\nPress <ESC> to Resume User Program.....") ;
            }
        }

        else if(c == (char)(0x1b))  {   // if user choses to end trace and run program
            Trace = 0;
            TraceException = 0;
            x = *(unsigned int *)(0x00000074) ;   // read IRQ 5 vector to reset trace vector generator
            EnableBreakPoints() ;
            SR = SR & (unsigned short int)(0x7FFF) ;    // clear T bit in status register

            printf("\r\nSingle Step  :[OFF]") ;
            printf("\r\nBreak Points :[Enabled]");
            printf("\r\nProgram Running.....") ;
            printf("\r\nPress <RESET> button <Key0> on DE2 to stop") ;
            return ;
        }

        else if( c == (char)('W'))              // Watchpoint command
            Watchpoint() ;

        else
            UnknownCommand() ;
    }
}

void PrintErrorMessageandAbort(char *string) {
    printf("\r\n\r\nProgram ABORT !!!!!!\r\n") ;
    printf("%s\r\n", string) ;
    menu() ;
}

void IRQMessage(int level) {
     printf("\r\n\r\nProgram ABORT !!!!!");
     printf("\r\nUnhandled Interrupt: IRQ%d !!!!!", level) ;
     menu() ;
}

void UnhandledIRQ1(void) {
     IRQMessage(1);
}

void UnhandledIRQ2(void) {
    IRQMessage(2);
}

void UnhandledIRQ3(void){
    IRQMessage(3);
}

void UnhandledIRQ4(void) {
     IRQMessage(4);
}

void UnhandledIRQ5(void) {
    IRQMessage(5);
}

void UnhandledIRQ6(void) {
    PrintErrorMessageandAbort("ADDRESS ERROR: 16 or 32 Bit Transfer to/from an ODD Address....") ;
    menu() ;
}

void UnhandledIRQ7(void) {
    IRQMessage(7);
}

void UnhandledTrap(void) {
    PrintErrorMessageandAbort("Unhandled Trap !!!!!") ;
}

void BusError() {
   PrintErrorMessageandAbort("BUS Error!") ;
}

void AddressError() {
   PrintErrorMessageandAbort("ADDRESS Error!") ;
}

void IllegalInstruction() {
    PrintErrorMessageandAbort("ILLEGAL INSTRUCTION") ;
}

void Dividebyzero() {
    PrintErrorMessageandAbort("DIVIDE BY ZERO") ;
}

void Check() {
   PrintErrorMessageandAbort("'CHK' INSTRUCTION") ;
}

void Trapv() {
   PrintErrorMessageandAbort("TRAPV INSTRUCTION") ;
}

void PrivError() {
    PrintErrorMessageandAbort("PRIVILEGE VIOLATION") ;
}

void UnitIRQ() {
    PrintErrorMessageandAbort("UNINITIALISED IRQ") ;
}

void Spurious() {
    PrintErrorMessageandAbort("SPURIOUS IRQ") ;
}

void EnterString(void)
{
    unsigned char *Start;
    unsigned char c;

    printf("\r\nStart Address in Memory: ") ;
    Start = Get8HexDigits(0) ;

    printf("\r\nEnter String (ESC to end) :") ;
    while((c = getchar()) != 0x1b)
        *Start++ = c ;

    *Start = 0x00;  // terminate with a null
}

void MemoryTest(void)
{
    unsigned int *RamPtr, counter1=1 ;
    register unsigned int i ;
    unsigned int Start, End ;
    char c ;

    printf("\r\nStart Address: ") ;
    Start = Get8HexDigits(0) ;
    printf("\r\nEnd Address: ") ;
    End = Get8HexDigits(0) ;

	// TODO

	// add your code to test memory here using 32 bit reads and writes of data between the start and end of memory
}


void main(void)
{
    char c ;
    unsigned char *SramPtr = (unsigned char *)(0x00010000) ;

    int i ;

    char *BugMessage = "68k Bug V1.74";
    char *CopyrightMessage = "Copyright (C) PJ Davies 2012";

    KillAllBreakPoints() ;

    i = x = y = z = PortA_Count = 0;
    Trace = GoFlag = 0;                       // used in tracing/single stepping

    d0=d1=d2=d3=d4=d5=d6=d7=0 ;
    a0=a1=a2=a3=a4=a5=a6=0 ;
    PC = ProgramStart, SSP=0x00880000, USP = 0x00870000;
    SR = 0x2000;                            // clear interrupts enable tracing  uses IRQ6

// Initialise Breakpoint variables

    for(i = 0; i < 8; i++)  {
        BreakPointAddress[i] = 0;               //array of 8 breakpoint addresses
        WatchPointAddress[i] = 0 ;
        BreakPointInstruction[i] = 0;           // to hold the instruction at the break point
        BreakPointSetOrCleared[i] = 0;          // indicates if break point set
        WatchPointSetOrCleared[i] = 0;
    }

// clear memory in static ram at address 00010000 for 16k

    for(i = 0; i < 16384; i++)
        *SramPtr++ = (unsigned char)(0) ;

    Init_RS232() ;     // initialise the RS232 port
    Init_LCD() ;

    for( i = 32; i < 48; i++)
       InstallExceptionHandler(UnhandledTrap, i) ;		        // install Trap exception handler on vector 32-47

    InstallExceptionHandler(menu, 47) ;		                   // TRAP #15 call debug and end program

    InstallExceptionHandler(UnhandledIRQ1, 25) ;		      // install handler for interrupts
    InstallExceptionHandler(UnhandledIRQ2, 26) ;		      // install handler for interrupts
    InstallExceptionHandler(UnhandledIRQ3, 27) ;		      // install handler for interrupts
    InstallExceptionHandler(UnhandledIRQ4, 28) ;		      // install handler for interrupts
    InstallExceptionHandler(UnhandledIRQ5, 29) ;		      // install handler for interrupts
    InstallExceptionHandler(UnhandledIRQ6, 30) ;		      // install handler for interrupts
    InstallExceptionHandler(UnhandledIRQ7, 31) ;		      // install handler for interrupts


    InstallExceptionHandler(HandleBreakPoint, 46) ;		           // install Trap 14 Break Point exception handler on vector 46
    InstallExceptionHandler(DumpRegistersandPause, 29) ;		   // install TRACE handler for IRQ5 on vector 29

    InstallExceptionHandler(BusError,2) ;                          // install Bus error handler
    InstallExceptionHandler(AddressError,3) ;                      // install address error handler (doesn't work on soft core 68k implementation)
    InstallExceptionHandler(IllegalInstruction,4) ;                // install illegal instruction exception handler
    InstallExceptionHandler(Dividebyzero,5) ;                      // install /0 exception handler
    InstallExceptionHandler(Check,6) ;                             // install check instruction exception handler
    InstallExceptionHandler(Trapv,7) ;                             // install trapv instruction exception handler
    InstallExceptionHandler(PrivError,8) ;                         // install Priv Violation exception handler
    InstallExceptionHandler(UnitIRQ,15) ;                          // install uninitialised IRQ exception handler
    InstallExceptionHandler(Check,24) ;                            // install spurious IRQ exception handler


    FlushKeyboard() ;                        // dump unread characters from keyboard
    TraceException = 0 ;                     // clear trace exception port to remove any software generated single step/trace


    // test for auto flash boot and run from Flash by reading switch 17 on DE1 board. If set, copy program from flash into Dram and run

    while(((char)(PortC & 0x02)) == (char)(0x02))    {
        LoadFromFlashChip();
        printf("\r\nRunning.....") ;
        Oline1("Running.....") ;
        GoFlag = 1;
        go() ;
    }

    // otherwise start the debug monitor

    Oline0(BugMessage) ;
    Oline1("By: PJ Davies") ;

    printf("\r\n%s", BugMessage) ;
    printf("\r\n%s", CopyrightMessage) ;

    menu();
}


void FormatInstruction(void)    // for disassembly
{
    short i, ilen = 0 ;

    char *iptr = Instruction ;
    char *Formatted[80], *fptr ;

    fptr = Formatted ;
    for(i = 0; i < (short)(80); i ++)
        Formatted[i] = (char)(0);          // set formatted string to null

    while((*iptr != ' '))   {   // while ot a space char
        *fptr++ = *iptr++ ;     // copy string until space or end encountered
        ilen ++ ;               // count length of string as we go
        if(*iptr == 0)          // if we got the end and copied the NUL then return
            return ;
    }

   // must still be more text to process otherwise we would have returned above if got to the end

    for(i = 0; i < ((short)(8) - ilen); i++)
        *fptr++ = ' ' ;        // make sure first operand appears in field 8 of formatted string

    // now skip over any spaces in original unformatted string before copying the rest


    while((*iptr == ' '))
        iptr++ ;

    strcat(fptr,iptr) ;
    strcpyInstruction(Formatted) ;
}


unsigned short int Decode2BitOperandSize(unsigned short int OpCode)
{
    unsigned short int DataSize ;       // used to determine the size of data following say an immediate instruction such as addi etc

    OpCode = (OpCode & (unsigned short int)(0x00C0)) >> 6 ;             // get bits 7 and 6 into positions 1,0
    if(OpCode == (unsigned short int)(0))   {
        strcatInstruction(".B ") ;
        DataSize = 1 ;
    }
    else if(OpCode == (unsigned short int)(1)) {
        strcatInstruction(".W ") ;
        DataSize = 1 ;
    }
    else {
        strcatInstruction(".L ") ;
        DataSize = 2 ;
    }
    return DataSize;
}

void Decode3BitDataRegister(unsigned short int OpCode)                // Data Register in Bits 11, 10 and 9
{
    unsigned char RegNumber[3] ;

    RegNumber[0] = 'D' ;
    RegNumber[1] = (unsigned char)(0x30) + (unsigned char)((OpCode & 0x0E00) >> 9) ;   // get data register number in bits 2,1,0 and convert to ASCII equiv
    RegNumber[2] = 0 ;

    strcatInstruction(RegNumber) ;        // write register number to the disassembled instruction
}

void Decode3BitAddressRegister(unsigned short int Reg)                // Address Register in Bits 2,1,0
{
    unsigned char RegNumber[3];

    RegNumber[0] = 'A' ;
    RegNumber[1] = (unsigned char)(0x30) + (unsigned char)(Reg) ;   // get data register number in bits 2,1,0 and convert to ASCII equiv
    RegNumber[2] = 0 ;

    strcatInstruction(RegNumber) ;        // write register number to the disassembled instruction
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Special function is used to print 8,16, 32 bit operands after move #
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void DecodeBWLDataAfterOpCodeForMove(unsigned short int *OpCode )
{
    unsigned char OperandSize ;

    OperandSize = (*OpCode >> 12) & (unsigned short int)(0x0003) ;               // get bits 13,12 into 1,0 as these define size of #operand
    InstructionSize += 1;

    if(OperandSize == (char)(1))                // #byte value
         sprintf(TempString, "#$%X", (unsigned int)(OpCode[1]));
    else if(OperandSize == (char)(3))          // #word value
         sprintf(TempString, "#$%X", (unsigned int)(OpCode[1]));
    else if(OperandSize == (char)(2)) {                                       // long value
         sprintf(TempString, "#$%X", ((unsigned int)(OpCode[1]) << 16) | (unsigned int)(OpCode[2])); // create 3
         InstructionSize += 1;
    }

    strcatInstruction(TempString) ;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This function is used to print 8,16, 32 bit operands after the opcode, this is in instruction like ADD # where immediate addressing is used as source
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void DecodeBWLDataAfterOpCode(unsigned short int *OpCode )
{
    unsigned char OperandSize ;

    OperandSize = (*OpCode & (unsigned short int)(0x01C0)) >> 6 ;               // get bits 8,7 and 6 into positions 1,0, these define size of operand
    InstructionSize += 1;

    if((OperandSize == (char)(0)) || (OperandSize == (char)(4)))                // #byte value
         sprintf(TempString, "#$%X", (unsigned int)(OpCode[1]));

// #word value 7 is used by divs.w instruction (not divu)
// however used by instructions like adda, cmpa, suba # to mean long value -
// bugger - have to build a special case and look at opcode to see what instruction is

    else if((OperandSize == (char)(1)) || (OperandSize == (char)(5)) || (OperandSize == (char)(3)))         //# byte or word value
         sprintf(TempString, "#$%X", (unsigned int)(OpCode[1]));
    else if((OperandSize == (char)(2))  || (OperandSize == (char)(6)) || (OperandSize == (char)(7)))    {    //# long value
         sprintf(TempString, "#$%X", ((unsigned int)(OpCode[1]) << 16) | (unsigned int)(OpCode[2]) ); // create 3
         InstructionSize += 1;
    }

    // special case for divs - bugger!!!
    if((*OpCode & (unsigned short int)(0xF1C0)) == (unsigned short int)(0x81C0)) // it's the divs instruction
    {
        InstructionSize = 2 ;
        sprintf(TempString, "#$%X", (unsigned int)(OpCode[1]));
    }

    strcatInstruction(TempString) ;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This function decodes the MODE|EA bits opcode in bits 5,4,3,2,1,0 or 11-6
// DataSize is used to gain access to the operand used by EA, e.g. ADDI  #$2344422,$234234
// since the data following the opcode is actually the immediate data which could be 1 or 2 words
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void Decode6BitEA(unsigned short int *OpCode, int EAChoice, unsigned short int DataSize, unsigned short int IsItMoveInstruction)     // decode Mode/Register
{
    unsigned char OperandMode, OperandRegister, OperandSize;
    short int ExWord1, ExWord2 ;                       // get any extra 16 bit word associated with EA
    unsigned char RegNumber[3];

    signed char offset ;

    unsigned short int Xn, XnSize ;

    if(EAChoice == 0)   {   // if EA in bits 5-0
        OperandMode = ((unsigned char)(*OpCode >> 3) & (unsigned short int)(0x7)) ;    // get bits 5,4,3 into position 2,1,0
        OperandRegister = ((unsigned char)(*OpCode) & (unsigned short int)(0x7)) ;
    }
    else    {               // else EA in bits 11-6
        OperandMode = ((unsigned char)(*OpCode >> 6) & (unsigned short int)(0x7)) ;
        OperandRegister = ((unsigned char)(*OpCode >> 9) & (unsigned short int)(0x7)) ;
    }

    if(EAChoice == 0)    {
        ExWord1 = OpCode[1+DataSize] ;
        ExWord2 = OpCode[2+DataSize] ;
    }
    else if(EAChoice == 1)   {
        ExWord1 = OpCode[3+DataSize] ;
        ExWord2 = OpCode[4+DataSize] ;
    }
    else if(EAChoice == 2)   {  // for move instruction
        ExWord1 = OpCode[1+DataSize] ;
        ExWord2 = OpCode[2+DataSize] ;
    }

    if(OperandMode == (unsigned char)(0)) {                    // Effective Address = Dn
        RegNumber[0] = 'D' ;
        RegNumber[1] = (unsigned char)(0x30 + OperandRegister) ;
        RegNumber[2] = 0 ;
        strcatInstruction(RegNumber) ;
    }

   else if(OperandMode == (unsigned char)(1)) {                    // Effective Address = An
        Decode3BitAddressRegister(OperandRegister) ;
    }

    else if(OperandMode == (unsigned char)(2)) {                    // Effective Address = (An)
        strcatInstruction("(") ;
        Decode3BitAddressRegister(OperandRegister) ;
        strcatInstruction(")") ;
    }

    else if(OperandMode == (unsigned char)(3)) {                    // Effective Address = (An)+
        strcatInstruction("(") ;
        Decode3BitAddressRegister(OperandRegister) ;
        strcatInstruction(")+") ;
    }

    else if(OperandMode == (unsigned char)(4)) {                    // Effective Address = -(An)
        strcatInstruction("-(") ;
        Decode3BitAddressRegister(OperandRegister) ;
        strcatInstruction(")") ;
    }

    else if(OperandMode == (unsigned char)(5)) {                    // Effective Address = (d16, An)
        sprintf(TempString, "%d(A%d)", ExWord1, OperandRegister) ;
        strcatInstruction(TempString) ;
        InstructionSize += 1;
    }

    else if(OperandMode == (unsigned char)(6)) {                    // Effective Address = (d8, An, Xn)
        offset = ExWord1 & (short int)(0x00FF);
        sprintf(TempString, "%d(A%d,", offset, OperandRegister) ;
        strcatInstruction(TempString) ;
        InstructionSize += 1;

        // decode the Xn bit
        if((ExWord1 & (unsigned short int)(0x8000)) == (unsigned short int)(0x0000))
            strcatInstruction("D") ;
        else
            strcatInstruction("A") ;

        Xn = (ExWord1 & (unsigned short int)(0x7000)) >> 12 ;        // get Xn register Number into bits 2,1,0
        sprintf(TempString, "%d",Xn) ;                               // generate string for reg number 0 -7
        strcatInstruction(TempString) ;

        XnSize = (ExWord1 & (unsigned short int)(0x0800)) >> 11 ;    // get xn size into bit 0
        if(XnSize == 0)
            strcatInstruction(".W)") ;
        else
            strcatInstruction(".L)") ;
    }

    else if(OperandMode == (unsigned char)(7)) {
        if(OperandRegister == 0) {                               // EA = (xxx).W
            sprintf(TempString, "$%X", ExWord1) ;
            strcatInstruction(TempString) ;
            InstructionSize += 1;
        }
        else if(OperandRegister == 1)   {                         // EA = (xxx).L
            sprintf(TempString, "$%X", ((unsigned int)(ExWord1) << 16) | (unsigned int)(ExWord2)); // create 32 bit address
            strcatInstruction(TempString) ;
            InstructionSize += 2;
        }

        else if(OperandRegister == 4) {                                 // source EA = #Immediate addressing
            if(IsItMoveInstruction == 0)        //not move instruction
                DecodeBWLDataAfterOpCode(OpCode);
            else
                DecodeBWLDataAfterOpCodeForMove(OpCode);

        }

        else if(OperandRegister == 2) {                                 // source EA = (d16,PC)
            sprintf(TempString, "%d(PC)", ExWord1) ;
            strcatInstruction(TempString) ;
            InstructionSize += 1;
        }

        else if(OperandRegister == 3) {                                 // source EA = (d8,PC, Xn)
            offset = ExWord1 & (short int)(0x00FF);
            sprintf(TempString, "%d(PC,", offset ) ;
            strcatInstruction(TempString) ;
            InstructionSize += 1;

        // decode the Xn bit
            if((ExWord1 & (unsigned short int)(0x8000)) == (unsigned short int)(0x0000))
                strcatInstruction("D") ;
            else
                strcatInstruction("A") ;

            Xn = (ExWord1 & (unsigned short int)(0x7000)) >> 12 ;        // get Xn register Number into bits 2,1,0
            sprintf(TempString, "%d",Xn) ;                               // generate string for reg number 0 -7
            strcatInstruction(TempString) ;

            XnSize = (ExWord1 & (unsigned short int)(0x0800)) >> 11 ;    // get xn size into bit 0
            if(XnSize == 0)
                strcatInstruction(".W)") ;
            else
                strcatInstruction(".L)") ;
        }
    }
}

void Decode3BitOperandMode(unsigned short int *OpCode)               // used with instructions like ADD determines source/destination
{
    unsigned short int OperandMode;

    OperandMode = (*OpCode & (unsigned short int)(0x0100)) >> 8 ;    // get bit 8 into position 0, defines source and destination
    Decode2BitOperandSize(*OpCode);                                  // add .b, .w, .l size indicator to instruction string

    if(OperandMode == 0)     {                                      // Destination is a Data Register
        Decode6BitEA(OpCode,0,0,0) ;
        strcatInstruction(",") ;
        Decode3BitDataRegister(*OpCode) ;
    }
    else {                                                         // Destination is in EA
        Decode3BitDataRegister(*OpCode) ;
        strcatInstruction(",") ;
        Decode6BitEA(OpCode,0,0,0) ;
    }
}

void DecodeBranchCondition(unsigned short int Condition)
{
    if(Condition == (unsigned short int)(0x04))
        strcatInstruction("CC") ;
    else if(Condition == (unsigned short int)(0x05))
        strcatInstruction("CS") ;
    else if(Condition == (unsigned short int)(0x07))
        strcatInstruction("EQ") ;
    else if(Condition == (unsigned short int)(0x0C))
        strcatInstruction("GE") ;
    else if(Condition == (unsigned short int)(0x0E))
        strcatInstruction("GT") ;
    else if(Condition == (unsigned short int)(0x02))
        strcatInstruction("HI") ;
    else if(Condition == (unsigned short int)(0x0F))
        strcatInstruction("LE") ;
    else if(Condition == (unsigned short int)(0x03))
        strcatInstruction("LS") ;
    else if(Condition == (unsigned short int)(0x0D))
        strcatInstruction("LT") ;
    else if(Condition == (unsigned short int)(0x0B))
        strcatInstruction("MI") ;
    else if(Condition == (unsigned short int)(0x06))
        strcatInstruction("NE") ;
    else if(Condition == (unsigned short int)(0x0A))
        strcatInstruction("PL") ;
    else if(Condition == (unsigned short int)(0x09))
        strcatInstruction("VS") ;
    else if(Condition == (unsigned short int)(0x08))
        strcatInstruction("VC") ;
    else if(Condition == (unsigned short int)(0))
        strcatInstruction("RA") ;
    else
        strcatInstruction("SR");

    strcatInstruction(" ") ;
}


void DisassembleInstruction( short int *OpCode)         // pointer to Opcode
{
    unsigned short int MSBits = (*OpCode >> 12);    //mask off the lower 12 bits leaving top 4 bit to analyse
    unsigned short int LS12Bits = (*OpCode & (unsigned short int)(0x0FFF));

    unsigned short int SourceBits, DestBits, Size ;
    unsigned char *Mode, Condition;

    unsigned short int Register, OpMode, EAMode, EARegister, Rx, Ry, EXGOpMode, DataSize, SourceReg;
    unsigned short int DataRegister, AddressRegister;
    signed char Displacement8Bit ;  // used for Bcc type instruction signed 8 bit displacement
    signed short int Displacement16Bit;
    short int Mask, DoneSlash;
    int i;

    strcpyInstruction("Unknown") ;

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is ABCD
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF1F0 )) == (unsigned short int)(0xC100))   {
        DestBits = (*OpCode >> 9) & (unsigned short int )(0x0007) ;
        SourceBits = (*OpCode & (unsigned short int )(0x0007));
        Mode = (*OpCode >> 3) & (unsigned short int )(0x0001) ;
        if(Mode == 0)
            sprintf(Instruction, "ABCD D%d,D%d", SourceBits, DestBits) ;
        else
            sprintf(Instruction, "ABCD -(A%d),-(A%d)", SourceBits, DestBits) ;
    }


    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is ADD or ADDA
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF000 )) == (unsigned short int)(0xD000))   {
        InstructionSize = 1;
        OpMode = ((*OpCode >> 6) & (unsigned short int)(0x0007)) ;

        if( (OpMode == (unsigned short int)(0x0003)) || (OpMode == (unsigned short int)(0x0007)))      // if destination is an address register then use ADDA otherwise use ADD
        {
            if(OpMode == (unsigned short int)(0x0003))
                strcpyInstruction("ADDA.W ") ;
            else
                strcpyInstruction("ADDA.L ") ;

            Decode6BitEA(OpCode,0,0,0)  ;
            sprintf(TempString, ",A%X", (*OpCode >> 9) & (unsigned short int)(0x0007)) ;
            strcatInstruction(TempString) ;
        }
        else {
            strcpyInstruction("ADD") ;
            Decode3BitOperandMode(OpCode) ;
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is ADDI or ANDI or CMPI or EORI or ORI or SUBI
    /////////////////////////////////////////////////////////////////////////////////
    if( (*OpCode & (unsigned short int)(0xFF00 )) == (unsigned short int)(0x0600) |
        (*OpCode & (unsigned short int)(0xFF00 )) == (unsigned short int)(0x0200) |
        (*OpCode & (unsigned short int)(0xFF00 )) == (unsigned short int)(0x0C00) |
        (*OpCode & (unsigned short int)(0xFF00 )) == (unsigned short int)(0x0A00) |
        (*OpCode & (unsigned short int)(0xFF00 )) == (unsigned short int)(0x0000) |
        (*OpCode & (unsigned short int)(0xFF00 )) == (unsigned short int)(0x0400))
    {
        InstructionSize = 1;
        if((*OpCode & (unsigned short int)(0xFF00 )) == (unsigned short int)(0x0600))
            strcpyInstruction("ADDI") ;
        else if((*OpCode & (unsigned short int)(0xFF00 )) == (unsigned short int)(0x0200))
            strcpyInstruction("ANDI") ;
        else if((*OpCode & (unsigned short int)(0xFF00 )) == (unsigned short int)(0x0C00))
            strcpyInstruction("CMPI") ;
        else if((*OpCode & (unsigned short int)(0xFF00 )) == (unsigned short int)(0x0A00))
            strcpyInstruction("EORI") ;
        else if((*OpCode & (unsigned short int)(0xFF00 )) == (unsigned short int)(0x0000))
            strcpyInstruction("ORI") ;
        else if((*OpCode & (unsigned short int)(0xFF00 )) == (unsigned short int)(0x0400))
            strcpyInstruction("SUBI") ;


        DataSize = Decode2BitOperandSize(*OpCode);                                  // add .b, .w, .l size indicator to instruction string
        DecodeBWLDataAfterOpCode(OpCode);                                // go add the 8,16,32 bit data to instruction string
        strcatInstruction(",") ;
        Decode6BitEA(OpCode,0,DataSize,0) ;                                         // decode EA
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is ADDI #data,SR
    /////////////////////////////////////////////////////////////////////////////////
    if(*OpCode  == (unsigned short int)(0x027c))   {
        InstructionSize = 2;
        sprintf(Instruction, "ANDI #$%X,SR", OpCode[1]);
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is ADDQ
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF100 )) == (unsigned short int)(0x5000))   {
        InstructionSize = 1;
        strcpyInstruction("ADDQ") ;
        Decode2BitOperandSize(*OpCode);                                  // add .b, .w, .l size indicator to instruction string
        sprintf(TempString, "#%1X,", ((*OpCode >> 9) & (unsigned short int)(0x0007)));    // print 3 bit #data in positions 11,10,9 in opcode
        strcatInstruction(TempString) ;
        Decode6BitEA(OpCode,0,0,0) ;                                           // decode EA
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is ADDX
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF130 )) == (unsigned short int)(0xD100))   {
        InstructionSize = 1;
        OpMode = ((*OpCode >> 6) & (unsigned short int)(0x0003)) ;

        if(OpMode != (unsigned short int)(0x0003)) // if size = 11 then it's ADDA not ADDX
        {
            strcpyInstruction("ADDX") ;
            Decode2BitOperandSize(*OpCode);                                  // add .b, .w, .l size indicator to instruction string
            if((*OpCode & (unsigned short int)(0x0008)) == (unsigned short int)(0))    // if bit 3 of opcode is 0 indicates data registers are used as source and destination
                sprintf(TempString, "D%X,D%X", (*OpCode & 0x0007), ((*OpCode >> 9) & 0x0007)) ;

            else        // -(ax),-(ay) mode used
                sprintf(TempString, "-(A%X),-(A%X)", (*OpCode & 0x0007), ((*OpCode >> 9) & 0x0007)) ;

            strcatInstruction(TempString) ;
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is AND
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF000 )) == (unsigned short int)(0xC000))   {
        InstructionSize = 1;
        // need to differentiate between AND and ABCD using Mode bits in 5,4,3
        OpMode = (*OpCode >> 4) & (unsigned short int)(0x001F);
        if(OpMode != (unsigned short int)(0x0010))   {
            strcpyInstruction("AND") ;
            Decode3BitOperandMode(OpCode) ;
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is ANDI to CCR
    /////////////////////////////////////////////////////////////////////////////////
    if(*OpCode == (unsigned short int)(0x023C))   {
        sprintf(Instruction, "ANDI #$%2X,CCR", OpCode[1] & (unsigned short int)(0x00FF)) ;
        InstructionSize = 2;
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is ASL/ASR/LSL/LSR/ROL/ROR NOTE two versions of this with different OPCodes
    /////////////////////////////////////////////////////////////////////////////////
    if( ((*OpCode & (unsigned short int)(0xF018 )) == (unsigned short int)(0xE000)) |   // ASL/ASR
        ((*OpCode & (unsigned short int)(0xFEC0 )) == (unsigned short int)(0xE0C0)) |

        ((*OpCode & (unsigned short int)(0xF018 )) == (unsigned short int)(0xE008)) |   // LSL/LSR
        ((*OpCode & (unsigned short int)(0xFEC0 )) == (unsigned short int)(0xE2C0)) |

        ((*OpCode & (unsigned short int)(0xF018 )) == (unsigned short int)(0xE018)) |   // ROR/ROL
        ((*OpCode & (unsigned short int)(0xFEC0 )) == (unsigned short int)(0xE6C0)) |

        ((*OpCode & (unsigned short int)(0xF018 )) == (unsigned short int)(0xE010)) |   // ROXR/ROXL
        ((*OpCode & (unsigned short int)(0xFEC0 )) == (unsigned short int)(0xE4C0)))
    {
        InstructionSize = 1;

        // 2nd version e.g. ASR/ASL/LSR/LSL/ROR/ROL/ROXL/ROXR <EA> shift a word 1 bit

        if((*OpCode & (unsigned short int)(0x00C0)) == (unsigned short int)(0x00C0)) // if bits 7,6 == 1,1
        {
      // test direction by testing bit 8
            if((*OpCode & (unsigned short int)(0xFEC0)) == (unsigned short int)(0xE0C0))    //asr/asl
                if((*OpCode & (unsigned short int)(0x0100)) == (unsigned short int)(0x0100))
                    strcpyInstruction("ASL") ;
                else
                    strcpyInstruction("ASR") ;

        // test direction by testing bit 8
            if((*OpCode & (unsigned short int)(0xFEC0)) == (unsigned short int)(0xE2C0))    //lsr/lsl
                if((*OpCode & (unsigned short int)(0x0100)) == (unsigned short int)(0x0100))
                    strcpyInstruction("LSL") ;
                else
                    strcpyInstruction("LSR") ;

       // test direction by testing bit 8
            if((*OpCode & (unsigned short int)(0xFEC0)) == (unsigned short int)(0xE6C0))    //ror/rol
                if((*OpCode & (unsigned short int)(0x0100)) == (unsigned short int)(0x0100))
                    strcpyInstruction("ROL") ;
                else
                    strcpyInstruction("ROR") ;

       // test direction by testing bit 8
            if((*OpCode & (unsigned short int)(0xFEC0)) == (unsigned short int)(0xE4C0))    //roxr/roxl
                if((*OpCode & (unsigned short int)(0x0100)) == (unsigned short int)(0x0100))
                    strcpyInstruction("ROXL") ;
                else
                    strcpyInstruction("ROXR") ;

            strcatInstruction("  ") ;
            Decode6BitEA(OpCode,0, 0,0) ;
        }



       // first version of above instructions, bit 5 is 0
        else
        {
       // test instruction and direction by testing bits 4,3
            if((*OpCode & (unsigned short int)(0x0018)) == (unsigned short int)(0x0))    //asr/asl
                if((*OpCode & (unsigned short int)(0x0100)) == (unsigned short int)(0x0100))
                    strcpyInstruction("ASL") ;
                else
                    strcpyInstruction("ASR") ;

        // test instruction and direction by testing bits 4,3
            if((*OpCode & (unsigned short int)(0x0018)) == (unsigned short int)(0x0008))    //lsr/lsl
                if((*OpCode & (unsigned short int)(0x0100)) == (unsigned short int)(0x0100))
                    strcpyInstruction("LSL") ;
                else
                    strcpyInstruction("LSR") ;

       // test instruction and direction by testing bits 4,3
            if((*OpCode & (unsigned short int)(0x0018)) == (unsigned short int)(0x0018))    //ror/rol
                if((*OpCode & (unsigned short int)(0x0100)) == (unsigned short int)(0x0100))
                    strcpyInstruction("ROL") ;
                else
                    strcpyInstruction("ROR") ;

       // test instruction and direction by testing bits 4,3
            if((*OpCode & (unsigned short int)(0x0018)) == (unsigned short int)(0x0010))    //roxr/roxl
                if((*OpCode & (unsigned short int)(0x0100)) == (unsigned short int)(0x0100))
                    strcpyInstruction("ROXL") ;
                else
                    strcpyInstruction("ROXR") ;

            Decode2BitOperandSize(*OpCode) ;
            if((*OpCode & (unsigned short int)(0x0020)) == (unsigned short int)(0)) {   // if shift count defined by #value (bit 5 = 0), e.g. asl #3,d0
                sprintf(TempString,"#$%X,D%X",
                    ((*OpCode >> 9) & (unsigned short int)(0x0007)),
                    (*OpCode & (unsigned short int)(0x0007))) ;
            }
            else {                                                                      // if shift is for example ASR D1,D2
                sprintf(TempString,"D%X,D%X",
                    ((*OpCode >> 9) & (unsigned short int)(0x0007)),
                    (*OpCode & (unsigned short int)(0x0007))) ;
            }
            strcatInstruction(TempString) ;
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is BCC and BSR and BRA
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF000 )) == (unsigned short int)(0x6000))
    {
       InstructionSize = 1;
       Condition = ((*OpCode >> 8) & (unsigned short int)(0xF)) ;
       strcpyInstruction("B") ;
       DecodeBranchCondition(Condition) ;
       Displacement8Bit = (*OpCode & (unsigned short int)(0xFF)) ;

       if(Displacement8Bit == (unsigned short int)(0))  {           // if 16 bit displacement
            sprintf(TempString, "$%X", (int)(OpCode) + (int)(OpCode[1]) +  2) ;
            InstructionSize = 2 ;
       }

       else
            sprintf(TempString, "$%X", (int)(OpCode) + Displacement8Bit + 2) ;           // 8 bit displacement

        strcatInstruction(TempString) ;
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is BCHG dn,<EA>
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF1C0 )) == (unsigned short int)(0x0140))   {
        InstructionSize = 1;
        strcpyInstruction("BCHG ") ;
        sprintf(TempString, "D%d,", (*OpCode >> 9) & (unsigned short int)(0x0007)) ;
        strcatInstruction(TempString) ;
        Decode6BitEA(OpCode,0,0,0) ;
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is BCHG #data,<EA>
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xFFC0 )) == (unsigned short int)(0x0840))   {
        strcpyInstruction("BCHG ") ;
        sprintf(TempString, "#$%X,", OpCode[1]) ;
        InstructionSize = 2 ;
        strcatInstruction(TempString) ;
        Decode6BitEA(OpCode,0,1,0) ;
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is BCLR  dn,<EA>
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF1C0 )) == (unsigned short int)(0x0180))   {
        InstructionSize = 1;
        strcpyInstruction("BCLR ") ;
        sprintf(TempString, "D%d,", (*OpCode >> 9) & (unsigned short int)(0x0007)) ;
        strcatInstruction(TempString) ;
        Decode6BitEA(OpCode,0,0,0) ;
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is BCLR #data,<EA>
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xFFC0 )) == (unsigned short int)(0x0880))   {
        strcpyInstruction("BCLR ") ;
        sprintf(TempString, "#$%X,", OpCode[1]) ;
        InstructionSize = 2 ;
        strcatInstruction(TempString) ;
        Decode6BitEA(OpCode,0,1,0) ;
    }

   /////////////////////////////////////////////////////////////////////////////////
    // if instruction is BSET dn,<EA>
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF1C0 )) == (unsigned short int)(0x01C0))   {
        InstructionSize = 1;
        strcpyInstruction("BSET ") ;
        sprintf(TempString, "D%d,", (*OpCode >> 9) & (unsigned short int)(0x0007)) ;
        strcatInstruction(TempString) ;
        Decode6BitEA(OpCode,0,0,0) ;
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is BSET #data,<EA>
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xFFC0 )) == (unsigned short int)(0x08C0))   {
        strcpyInstruction("BSET ") ;
        sprintf(TempString, "#$%X,", OpCode[1]) ;
        InstructionSize = 2 ;
        strcatInstruction(TempString) ;
        Decode6BitEA(OpCode,0,1,0) ;
    }

   /////////////////////////////////////////////////////////////////////////////////
    // if instruction is BTST dn,<EA>
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF1C0 )) == (unsigned short int)(0x0100))   {
        InstructionSize = 1;
        strcpyInstruction("BTST ") ;
        sprintf(TempString, "D%d,", (*OpCode >> 9) & (unsigned short int)(0x0007)) ;
        strcatInstruction(TempString) ;
        Decode6BitEA(OpCode,0,0,0) ;
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is BTST #data,<EA>
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xFFC0 )) == (unsigned short int)(0x0800))   {
        strcpyInstruction("BTST ") ;
        sprintf(TempString, "#$%X,", OpCode[1]) ;
        InstructionSize = 2 ;
        strcatInstruction(TempString) ;
        Decode6BitEA(OpCode,0,1,0) ;
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is CHK.W <EA>,DN
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF1C0 )) == (unsigned short int)(0x4180))   {
        InstructionSize = 1;
        strcpyInstruction("CHK ") ;
        Decode6BitEA(OpCode,0,0,0) ;
        sprintf(TempString, ",D%d", (*OpCode >> 9) & (unsigned short int)(0x0007)) ;
        strcatInstruction(TempString) ;
    }

   /////////////////////////////////////////////////////////////////////////////////
    // if instruction is CLR <EA>
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xFF00 )) == (unsigned short int)(0x4200))   {
        InstructionSize = 1;
        strcpyInstruction("CLR") ;
        Decode2BitOperandSize(*OpCode) ;
        Decode6BitEA(OpCode,0,0,0) ;
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is CMP, CMPA
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF000 )) == (unsigned short int)(0xB000))
    {
        InstructionSize = 1;
        OpMode = (*OpCode >> 6) & (unsigned short int)(0x0007) ;
        if((OpMode == (unsigned short int)(0x0003)) || (OpMode == (unsigned short int)(0x0007)))    {
            if(OpMode == (unsigned short int)(0x0003))
                strcpyInstruction("CMPA.W ") ;
            else
                strcpyInstruction("CMPA.L ") ;

            Decode6BitEA(OpCode,0,0,0) ;
            sprintf(TempString, ",A%d", ((*OpCode >> 9) & (unsigned short int)(0x0007))) ;
            strcatInstruction(TempString) ;
        }
        else {
            strcpyInstruction("CMP") ;
            Decode3BitOperandMode(OpCode) ;
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is CMPM
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF138 )) == (unsigned short int)(0xB108))
    {
        OpMode = (*OpCode >> 6) & (unsigned short int)(0x0003) ;
        if((OpMode >= (unsigned short int)(0x0000)) && (OpMode <= (unsigned short int)(0x0002)))
        {
            InstructionSize = 1;
            strcpyInstruction("CMPM") ;
            Decode2BitOperandSize(*OpCode) ;
            sprintf(TempString, "(A%d)+,(A%d)+", (*OpCode & (unsigned short int)(0x7)) , ((*OpCode >> 9) & (unsigned short int)(0x7)));
            strcatInstruction(TempString) ;
        }
    }

   /////////////////////////////////////////////////////////////////////////////////
    // if instruction is DBCC
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF0F8 )) == (unsigned short int)(0x50C8))
    {
       InstructionSize = 2;
       strcpy(Instruction,"DB") ;
       Condition = ((*OpCode >> 8) & (unsigned short int)(0x000F)) ;
       DecodeBranchCondition(Condition) ;
       sprintf(TempString, "D%d,%+d(PC) to Addr:$%X",(*OpCode & (unsigned short int)(0x7)), (int)(OpCode[1]), (int)(OpCode) + (int)(OpCode[1]) +  2) ;
       strcatInstruction(TempString) ;
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is DIVS
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF1C0 )) == (unsigned short int)(0x81C0))
    {
        InstructionSize = 1;
        strcpy(Instruction,"DIVS ") ;
        Decode6BitEA(OpCode,0,0,0) ;
        strcatInstruction(",") ;
        Decode3BitDataRegister(*OpCode) ;
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is DIVU
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF1C0 )) == (unsigned short int)(0x80C0))
    {
        InstructionSize = 1;
        strcpy(Instruction,"DIVU ") ;
        Decode6BitEA(OpCode,0,0,0) ;
        strcatInstruction(",") ;
        Decode3BitDataRegister(*OpCode) ;
    }

   /////////////////////////////////////////////////////////////////////////////////
    // if instruction is EOR
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF000 )) == (unsigned short int)(0xB000))   {
        OpMode = (*OpCode >> 6) & (unsigned short int)(0x0007) ;
        EAMode = (*OpCode >> 3) & (unsigned short int)(0x0007) ;    // mode cannot be 1 for EOR as it it used by CMPM instruction as a differentiator
        if( (OpMode >= (unsigned short int)(0x0004)) &&
            (OpMode <= (unsigned short int)(0x0006)) &&
            (EAMode != (unsigned short int)(0x0001)))
        {
            InstructionSize = 1;
            strcpyInstruction("EOR") ;
            Decode3BitOperandMode(OpCode);
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is EOR to CCR
    /////////////////////////////////////////////////////////////////////////////////
    if(*OpCode == (unsigned short int)(0x0A3C))   {
        InstructionSize = 1;
        sprintf(Instruction, "EORI #$%2X,CCR", OpCode[1] & (unsigned short int)(0x00FF)) ;
        InstructionSize += 1;
    }

   /////////////////////////////////////////////////////////////////////////////////
    // if instruction is EORI #data,SR
    /////////////////////////////////////////////////////////////////////////////////
    if(*OpCode  == (unsigned short int)(0x0A7C))   {
        InstructionSize = 2;
        sprintf(Instruction, "EORI #$%X,SR", OpCode[1]);
    }

   /////////////////////////////////////////////////////////////////////////////////
    // if instruction is EXG
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF100 )) == (unsigned short int)(0xC100))   {
        Rx = ((*OpCode >> 9) & (unsigned short int)(0x7)) ;
        Ry = (*OpCode & (unsigned short int)(0x7)) ;
        EXGOpMode = ((*OpCode >> 3) & (unsigned short int)(0x1F)) ;

        if(EXGOpMode == (unsigned short int)(0x0008))   {
            InstructionSize = 1;
            sprintf(Instruction, "EXG D%d,D%d", Rx, Ry) ;
        }
        else if(EXGOpMode == (unsigned short int)(0x0009))  {
            InstructionSize = 1;
            sprintf(Instruction, "EXG A%d,A%d", Rx, Ry) ;
        }
        else if(EXGOpMode == (unsigned short int)(0x0011))  {
            InstructionSize = 1;
            sprintf(Instruction, "EXG D%d,A%d", Rx, Ry) ;
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is EXT
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xFE38)) == (unsigned short int)(0x4800))
    {
        InstructionSize = 1;
        strcpy(Instruction,"EXT") ;
        if((*OpCode & (unsigned short int)(0x00C0)) == (unsigned short int)(0x00C0))
            strcatInstruction(".L ") ;
        else
            strcatInstruction(".W ") ;

        Decode6BitEA(OpCode,0,0,0) ;
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is ILLEGAL $4afc
    /////////////////////////////////////////////////////////////////////////////////
    if(*OpCode == (unsigned short int)(0x4AFC)) {
        InstructionSize = 1;
        strcpy(Instruction,"ILLEGAL ($4AFC)") ;
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is JMP
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xFFC0)) == (unsigned short int)(0x4EC0))
    {
        InstructionSize = 1;
        strcpy(Instruction,"JMP ") ;
        Decode6BitEA(OpCode,0,0,0) ;
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is JSR
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xFFC0)) == (unsigned short int)(0x4E80))
    {
        InstructionSize = 1;
        strcpy(Instruction,"JSR ") ;
        Decode6BitEA(OpCode,0,0,0) ;
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is LEA
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF1C0)) == (unsigned short int)(0x41C0))
    {
        InstructionSize = 1;
        strcpy(Instruction,"LEA ") ;
        Decode6BitEA(OpCode,0,0,0) ;
        sprintf(TempString, ",A%d", ((*OpCode >> 9) & (unsigned short int)(0x7)));
        strcatInstruction(TempString);
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is LINK.W
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xFFF8)) == (unsigned short int)(0x4E50))
    {
        InstructionSize = 1;
        strcpy(Instruction,"LINK ") ;
        sprintf(TempString, "A%d,#%d", ((*OpCode) & (unsigned short int)(0x7)),OpCode[1]);
        InstructionSize = 2 ;
        strcatInstruction(TempString);
    }

  /////////////////////////////////////////////////////////////////////////////////
    // if instruction is MOVE, MOVEA
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xC000)) == (unsigned short int)(0x0000))
    {
        Size = (*OpCode & (unsigned short int)(0x3000)) >> 12 ;   // get 2 bit size in bits 13/12 into 1,0
        OpMode = (*OpCode >> 3) & (unsigned short int)(0x0007);   // get 3 bit source mode operand
        SourceReg = (*OpCode) & (unsigned short int)(0x0007);     // get 3 bit source register number

        DataSize = 0 ;

        // if source addressing mode is d16(a0) or d8(a0,d0)
        if((OpMode == (unsigned short int)(0x0005)) || (OpMode == (unsigned short int)(0x0006)))
            DataSize = 1;  // source operands has 1 word after EA

        // if source addressing mode is a 16 or 32 bit address
        if((OpMode == (unsigned short int)(0x0007))) {
            if(SourceReg == (unsigned short int)(0x0000))         // short address
                DataSize = 1 ;
            else
                DataSize = 2 ;
        }

        // if source addressing mode is # then figure out size
        if((OpMode == (unsigned short int)(0x0007)) && (SourceReg == (unsigned short int)(0x0004)))    {
            if((Size == (unsigned short int)(1)) || (Size == (unsigned short int)(3)))
                DataSize = 1;
            else
                DataSize = 2 ;
            //printf("DataSize = %d",DataSize) ;
        }

        if(Size != 0)
        {
            InstructionSize = 1;
            if(Size == 1)
                strcpyInstruction("MOVE.B ") ;

            else if(Size == 2)
                strcpyInstruction("MOVE.L ") ;

            else
                strcpyInstruction("MOVE.W ") ;
            Decode6BitEA(OpCode,0,0,1) ;
            strcatInstruction(",") ;

            // tell next function how many words lie between opcode and destination, could be 1 or 2 e.g. with # addressing move.bwl #$data,<EA>
            // but subtract 1 to make the maths correct in the called function
            Decode6BitEA(OpCode,2,(DataSize),0) ;
        }
    }

     /////////////////////////////////////////////////////////////////////////////////
    // if instruction is MOVE <EA>,CCR
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xFFC0)) == (unsigned short int)(0x44C0))
    {
        InstructionSize = 1;
        strcpy(Instruction,"MOVE ") ;
        Decode6BitEA(OpCode,0,0,0) ;
        strcatInstruction(",CCR") ;
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is MOVE SR,<EA>
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xFFC0)) == (unsigned short int)(0x40C0))
    {
        InstructionSize = 1;
        strcpy(Instruction,"MOVE SR,") ;
        Decode6BitEA(OpCode,0,0,0) ;
    }

   /////////////////////////////////////////////////////////////////////////////////
    // if instruction is MOVE <EA>,SR
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xFFC0)) == (unsigned short int)(0x46C0))
    {
        InstructionSize = 1;
        strcpy(Instruction,"MOVE ") ;
        Decode6BitEA(OpCode,0,0,0) ;
        strcatInstruction(",SR") ;
    }

   /////////////////////////////////////////////////////////////////////////////////
    // if instruction is MOVE USP,An
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xFFF0)) == (unsigned short int)(0x4E60))
    {
        InstructionSize = 1;
        Register = (*OpCode & (unsigned short int)(0x0007)) ;
        if((*OpCode & (unsigned short int)(0x0008)) == (unsigned short int)(0x0008))        // transfer sp to address regier
            sprintf(Instruction, "MOVE USP,A%d", Register);
        else
            sprintf(Instruction, "MOVE A%d,USP", Register);
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is MOVEM
    /////////////////////////////////////////////////////////////////////////////////

    if((*OpCode & (unsigned short int)(0xFB80)) == (unsigned short int)(0x4880))
    {
        OpMode = (*OpCode >> 3) & (unsigned short int)(0x0007) ;

        if( (OpMode != (unsigned short int)(0x0)) &&
            (OpMode != (unsigned short int)(0x1)) &&
            (OpMode != (unsigned short int)(0x0)))
        {
            InstructionSize = 1;
            strcpy(Instruction,"MOVEM") ;
            InstructionSize ++ ;

            if((*OpCode & (unsigned short int)(0x0040)) == (unsigned short int)(0x0))
                strcatInstruction(".W ") ;
            else
               strcatInstruction(".L ") ;

            // movem  reg,-(An) if bit 10 = 0
            if((*OpCode & (unsigned short int)(0x0400))  == (unsigned short int)(0x0000))
            {
                Mask = 0x8000 ;                     // bit 15 = 1
                DoneSlash = 0 ;
                for(i = 0; i < 16; i ++)    {
                    printf("") ;    // fixes bug otherwise the address registers doen't get printed (don't know why), something to do with sprintf I guess
                    if((OpCode[1] & Mask) == Mask)    {
                        if(i < 8 )  {
                            if(DoneSlash == 0)  {
                                sprintf(TempString, "D%d", i) ;
                                DoneSlash = 1;
                            }
                            else
                               sprintf(TempString, "/D%d", i) ;
                        }
                        else   {
                            if(DoneSlash == 0)  {
                                sprintf(TempString, "A%d", i-8) ;
                                DoneSlash = 1;
                            }
                            else
                                sprintf(TempString, "/A%d", i-8) ;
                        }
                        strcatInstruction(TempString) ;
                    }
                    Mask = Mask >> 1 ;
                }
                strcatInstruction(",") ;
                Decode6BitEA(OpCode,0,0,0) ;
            }

            //movem  (An)+,reg
            else    {
                Decode6BitEA(OpCode,0,0,0) ;
                strcatInstruction(",") ;

                Mask = 0x0001 ;                     // bit 0 = 1
                DoneSlash = 0 ;

                for(i = 0; i < 16 ; i ++)    {
                    if((OpCode[1] & Mask) == Mask)    {
                        if(i < 8)   {       // data registers in bits 7-0
                            if(DoneSlash == 0)  {
                                sprintf(TempString, "D%d", i) ;
                                DoneSlash = 1;
                            }
                            else
                               sprintf(TempString, "/D%d", i) ;
                        }
                        else    {
                            if(DoneSlash == 0)  {
                                sprintf(TempString, "A%d", i-8) ;
                                DoneSlash = 1;
                            }
                            else
                                sprintf(TempString, "/A%d", i-8) ;
                        }
                        strcatInstruction(TempString) ;
                    }
                    Mask = Mask << 1 ;
                }
            }
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is MOVEP
    /////////////////////////////////////////////////////////////////////////////////

    if((*OpCode & (unsigned short int)(0xF038)) == (unsigned short int)(0x0008))
    {
        InstructionSize = 1;
        DataRegister = (*OpCode >> 9) & (unsigned short int)(0x0007);
        AddressRegister = (*OpCode & (unsigned short int)(0x0007)) ;
        OpMode = (*OpCode >> 6) & (unsigned short int)(0x0007)  ;
        InstructionSize++ ;

        if(OpMode == (unsigned short int)(0x4)) // transfer word from memory to register
            sprintf(Instruction, "MOVEP.W $%X(A%d),D%d", OpCode[1], AddressRegister, DataRegister) ;
        else if(OpMode == (unsigned short int)(0x5)) // transfer long from memory to register
            sprintf(Instruction, "MOVEP.L $%X(A%d),D%d", OpCode[1], AddressRegister, DataRegister) ;
        else if(OpMode == (unsigned short int)(0x6)) // transfer long from register to memory
            sprintf(Instruction, "MOVEP.W D%d,$%X(A%d)", DataRegister, OpCode[1], AddressRegister ) ;
        else if(OpMode == (unsigned short int)(0x7)) // transfer long from register to memory
            sprintf(Instruction, "MOVEP.L D%d,$%X(A%d)", DataRegister, OpCode[1], AddressRegister ) ;
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is MOVEQ
    /////////////////////////////////////////////////////////////////////////////////

    if((*OpCode & (unsigned short int)(0xF100)) == (unsigned short int)(0x7000))
    {
        InstructionSize = 1;
        DataRegister = (*OpCode >> 9) & (unsigned short int)(0x0007) ;
        sprintf(Instruction, "MOVEQ #$%X,D%d", (*OpCode & (unsigned short int)(0x00FF)), DataRegister) ;
    }

   /////////////////////////////////////////////////////////////////////////////////
    // if instruction is MULS.W
    /////////////////////////////////////////////////////////////////////////////////

    if((*OpCode & (unsigned short int)(0xF1C0)) == (unsigned short int)(0xC1C0))
    {
        InstructionSize = 1;
        DataRegister = (*OpCode >> 9) & (unsigned short int)(0x0007);
        strcpyInstruction("MULS ");
        Decode6BitEA(OpCode,0,0,0) ;

        sprintf(TempString, ",D%d", DataRegister) ;
        strcatInstruction(TempString);
    }

   /////////////////////////////////////////////////////////////////////////////////
    // if instruction is MULU.W
    /////////////////////////////////////////////////////////////////////////////////

    if((*OpCode & (unsigned short int)(0xF1C0)) == (unsigned short int)(0xC0C0))
    {
        InstructionSize = 1;
        DataRegister = (*OpCode >> 9) & (unsigned short int)(0x0007);
        strcpyInstruction("MULU ");
        Decode6BitEA(OpCode,0,0,0) ;

        sprintf(TempString, ",D%d", DataRegister) ;
        strcatInstruction(TempString);
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is NBCD <EA>
    /////////////////////////////////////////////////////////////////////////////////

    if((*OpCode & (unsigned short int)(0xFFC0)) == (unsigned short int)(0x4800))
    {
        InstructionSize = 1;
        strcpyInstruction("NBCD ");
        Decode6BitEA(OpCode,0,0,0);
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is NEG <EA>
    /////////////////////////////////////////////////////////////////////////////////

    if((*OpCode & (unsigned short int)(0xFF00)) == (unsigned short int)(0x4400))
    {
        if(((*OpCode >> 6) & (unsigned short int)(0x0003)) != (unsigned short int)(0x0003))
        {
            InstructionSize = 1;
            strcpyInstruction("NEG");
            Decode2BitOperandSize(*OpCode) ;
            Decode6BitEA(OpCode,0,0,0);
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is NEGX <EA>
    /////////////////////////////////////////////////////////////////////////////////

    if((*OpCode & (unsigned short int)(0xFF00)) == (unsigned short int)(0x4000))
    {
        if(((*OpCode >> 6) & (unsigned short int)(0x0003)) != (unsigned short int)(0x0003))
        {
            InstructionSize = 1;
            strcpyInstruction("NEGX");
            Decode2BitOperandSize(*OpCode) ;
            Decode6BitEA(OpCode,0,0,0);
        }
    }

   /////////////////////////////////////////////////////////////////////////////////
    // if instruction is NOP
    /////////////////////////////////////////////////////////////////////////////////

    if(*OpCode == (unsigned short int)(0x4E71))
    {
        InstructionSize = 1;
        strcpyInstruction("NOP");
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is NOT <EA>
    /////////////////////////////////////////////////////////////////////////////////

    if((*OpCode & (unsigned short int)(0xFF00)) == (unsigned short int)(0x4600))
    {
        if(((*OpCode >> 6) & (unsigned short int)(0x0003)) != (unsigned short int)(0x0003))
        {
            InstructionSize = 1;
            strcpyInstruction("NOT");
            Decode2BitOperandSize(*OpCode) ;
            Decode6BitEA(OpCode,0,0,0);
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is OR <EA>,Dn or OR Dn,<EA>
    /////////////////////////////////////////////////////////////////////////////////

    if((*OpCode & (unsigned short int)(0xF000)) == (unsigned short int)(0x8000))
    {
        OpMode = (*OpCode >> 6) & (unsigned short int)(0x0007) ;
        if( (OpMode <= (unsigned short int)(0x0002)) ||
            ((OpMode >= (unsigned short int)(0x0004)) && (OpMode <= (unsigned short int)(0x0006))))
        {
            InstructionSize = 1;
            strcpyInstruction("OR") ;
            Decode3BitOperandMode(OpCode) ;
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is ORI to CCR
    /////////////////////////////////////////////////////////////////////////////////
    if(*OpCode == (unsigned short int)(0x003C))   {
        sprintf(Instruction, "ORI #$%2X,CCR", OpCode[1] & (unsigned short int)(0x00FF)) ;
        InstructionSize = 2;
    }

   /////////////////////////////////////////////////////////////////////////////////
    // if instruction is ORI #data,SR
    /////////////////////////////////////////////////////////////////////////////////
    if(*OpCode  == (unsigned short int)(0x007c))
    {
        InstructionSize = 2;
        sprintf(Instruction, "ORI  #$%X,SR", OpCode[1]);
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is PEA
    /////////////////////////////////////////////////////////////////////////////////

    if((*OpCode & (unsigned short int)(0xFFC0)) == (unsigned short int)(0x4840))
    {
        InstructionSize = 1;
        strcpyInstruction("PEA ");
        Decode6BitEA(OpCode,0,0,0);
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is reset
    /////////////////////////////////////////////////////////////////////////////////
    if(*OpCode  == (unsigned short int)(0x4E70))
    {
        InstructionSize = 1;
        sprintf(Instruction, "RESET");
    }

   /////////////////////////////////////////////////////////////////////////////////
    // if instruction is RTE
    /////////////////////////////////////////////////////////////////////////////////
    if(*OpCode  == (unsigned short int)(0x4E73))
    {
        InstructionSize = 1;
        sprintf(Instruction, "RTE");
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is RTR
    /////////////////////////////////////////////////////////////////////////////////

    if(*OpCode == (unsigned short int)(0x4E77))
    {
        InstructionSize = 1;
        strcpyInstruction("RTR");
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is RTS
    /////////////////////////////////////////////////////////////////////////////////

    if(*OpCode == (unsigned short int)(0x4E75))
    {
        InstructionSize = 1;
        strcpyInstruction("RTS");
    }

     /////////////////////////////////////////////////////////////////////////////////
    // if instruction is STOP
    /////////////////////////////////////////////////////////////////////////////////
    if(*OpCode  == (unsigned short int)(0x4E72))
    {
        InstructionSize = 2;
        sprintf(Instruction, "STOP #$%X", OpCode[1]);
    }

   /////////////////////////////////////////////////////////////////////////////////
    // if instruction is SBCD
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF1F0 )) == (unsigned short int)(0x8100))
    {
        InstructionSize = 1;
        DestBits = (*OpCode >> 9) & (unsigned short int )(0x0007) ;
        SourceBits = (*OpCode & (unsigned short int )(0x0007));
        Mode = (*OpCode >> 3) & (unsigned short int )(0x0001) ;
        if(Mode == 0)
            sprintf(Instruction, "SBCD D%d,D%d", SourceBits, DestBits) ;
        else
            sprintf(Instruction, "SBCD -(A%d),-(A%d)", SourceBits, DestBits) ;
    }

  /////////////////////////////////////////////////////////////////////////////////
    // if instruction is Scc
    /////////////////////////////////////////////////////////////////////////////////

    if((*OpCode & (unsigned short int)(0xF0C0 )) == (unsigned short int)(0x50C0))
    {
       EAMode = (*OpCode >> 3) & (unsigned short int)(0x0007) ;    // mode cannot be 1 for Scc as it it used by DBcc instruction as a differentiator
       if(EAMode != (unsigned short int)(0x0001))
       {
           InstructionSize = 1;
           Condition = ((*OpCode >> 8) & (unsigned short int)(0xF)) ;
           strcpyInstruction("S") ;
           DecodeBranchCondition(Condition) ;
           Decode6BitEA(OpCode,0,0,0);
       }
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is SUB or SUBA
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF000 )) == (unsigned short int)(0x9000))   {
        OpMode = ((*OpCode >> 6) & (unsigned short int)(0x0007)) ;
        InstructionSize = 1;
        if((OpMode == (unsigned short int)(0x0003)) || (OpMode == (unsigned short int)(0x0007)))      // if destination is an address register then use ADDA otherwise use ADD
        {
            if(OpMode == (unsigned short int)(0x0003))
                strcpyInstruction("SUBA.W ") ;
            else
                strcpyInstruction("SUBA.L ") ;

            Decode6BitEA(OpCode,0,0,0)  ;
            sprintf(TempString, ",A%X", (*OpCode >> 9) & (unsigned short int)(0x0007)) ;
            strcatInstruction(TempString) ;
        }
        else {
            strcpyInstruction("SUB") ;
            Decode3BitOperandMode(OpCode) ;
        }
    }

  /////////////////////////////////////////////////////////////////////////////////
    // if instruction is SUBQ
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF100 )) == (unsigned short int)(0x5100))
    {
        OpMode = (*OpCode >> 6) & (unsigned short int)(0x0003) ;
        if(OpMode <= (unsigned short int)(0x0002))
        {
            InstructionSize = 1;
            strcpyInstruction("SUBQ") ;
            Decode2BitOperandSize(*OpCode);                                  // add .b, .w, .l size indicator to instruction string
            sprintf(TempString, "#%1X,", ((*OpCode >> 9) & (unsigned short int)(0x0007)));    // print 3 bit #data in positions 11,10,9 in opcode
            strcatInstruction(TempString) ;
            Decode6BitEA(OpCode,0,0,0) ;                                           // decode EA
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is SUBX
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xF130 )) == (unsigned short int)(0x9100))
    {
        InstructionSize = 1;
        OpMode = ((*OpCode >> 6) & (unsigned short int)(0x0003)) ;

        if(OpMode != (unsigned short int)(0x0003)) // if size = 11 then it's SUBA not SUBX
        {
            strcpyInstruction("SUBX") ;
            Decode2BitOperandSize(*OpCode);                                  // add .b, .w, .l size indicator to instruction string
            if((*OpCode & (unsigned short int)(0x0008)) == (unsigned short int)(0))    // if bit 3 of opcode is 0 indicates data registers are used as source and destination
                sprintf(TempString, "D%1X,D%1X", (*OpCode & 0x0007), ((*OpCode >> 9) & 0x0007)) ;

            else        // -(ax),-(ay) mode used
                sprintf(TempString, "-(A%1X),-(A%1X)", (*OpCode & 0x0007), ((*OpCode >> 9) & 0x0007)) ;

            strcatInstruction(TempString) ;
        }
    }

     /////////////////////////////////////////////////////////////////////////////////
    // if instruction is SWAP
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xFFF8 )) == (unsigned short int)(0x4840))
    {
        InstructionSize = 1;
        DataRegister = *OpCode & (unsigned short int)(0x0007) ;
        sprintf(Instruction, "SWAP D%d", DataRegister) ;
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is TAS
    /////////////////////////////////////////////////////////////////////////////////

    if((*OpCode & (unsigned short int)(0xFFC0 )) == (unsigned short int)(0x4AC0))
    {
        if(*OpCode != (unsigned short int)(0x4AFC))
        {
            InstructionSize = 1;
            strcpyInstruction("TAS ") ;
            Decode6BitEA(OpCode,0,0,0) ;
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is TRAP
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xFFF0 )) == (unsigned short int)(0x4E40))   {
        sprintf(Instruction, "TRAP #%d", *OpCode & (unsigned short int)(0x000F)) ;
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is TRAPV
    /////////////////////////////////////////////////////////////////////////////////
    if(*OpCode == (unsigned short int)(0x4E76))
    {
        InstructionSize = 1;
        strcpyInstruction("TRAPV") ;
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is TST
    /////////////////////////////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xFF00 )) == (unsigned short int)(0x4A00))
    {
        Size = (*OpCode >> 6) & (unsigned short int)(0x0003) ;
        if((*OpCode != (unsigned short int)(0x4AFC)) && (Size != (unsigned short int)(0x0003)))       { // test for size to eliminate TAS instruction which shares similar opcode
            InstructionSize = 1;
            strcpyInstruction("TST") ;
            Decode2BitOperandSize(*OpCode) ;
            Decode6BitEA(OpCode,0,0,0) ;
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    // if instruction is UNLK
    //////////////////////////////////////////////////////////
    if((*OpCode & (unsigned short int)(0xFFF8 )) == (unsigned short int)(0x4E58))
    {
        InstructionSize = 1;
        sprintf(Instruction, "UNLK A%d", *OpCode & (unsigned short int)(0x0007)) ;
    }

    FormatInstruction() ;
}