// Switch&led.c - A simple I/O device library for Visual68K
// Peter J. Fondse (c) 2002

// This library creates two standard I/O devices and binds to $200000
// Its purpose it to show how standard I/O devices can be used in a custum DLL.

#include <windows.h>

#define IOBASE    0x00200000  // Base address of this device ($200000)
#define IOSIZE    4           // device needs 4 bytes ($200000 - $200003)

// global variables
HWND hwMain;                  // Visual68K main window
HWND hwSwitch;                // Switches window
HWND hwLeds;                  // LEDs window
BYTE DeviceMemory[IOSIZE];    // Device memory (or registers)

__declspec(dllexport) BOOL APIENTRY InitDevice(HINSTANCE hinstDLL, HWND hWnd, LPDWORD lpdwBase, LPWORD lpwSize)
{
	hwMain = hWnd;
	*lpdwBase = IOBASE;
	*lpwSize = IOSIZE;
	hwSwitch = CreateWindow("SWITCHES", "My switches", WS_VISIBLE,
		50, 150, CW_USEDEFAULT, CW_USEDEFAULT, hWnd, NULL, NULL, NULL);
	SetWindowLong(hwSwitch, 0, IOBASE + 1);
	hwLeds = CreateWindow("LEDS", "My LED's", WS_VISIBLE,
		400, 150, CW_USEDEFAULT, CW_USEDEFAULT, hWnd, NULL, NULL, NULL);
	SetWindowLong(hwLeds, 0, IOBASE + 3);
	SetFocus(hWnd);
	return TRUE;
}

__declspec(dllexport) BYTE APIENTRY ReadByte(DWORD dwAddress)
{
	return DeviceMemory[dwAddress - IOBASE];
}

__declspec(dllexport) void APIENTRY WriteByte(DWORD dwAddress, BYTE cbData)
{
	DeviceMemory[dwAddress - IOBASE] = cbData;
	if (dwAddress == IOBASE + 3) SendMessage(hwLeds, WM_USER, 0, 0);
}

__declspec(dllexport) void APIENTRY CloseDevice()
{
	DestroyWindow(hwSwitch);
	DestroyWindow(hwLeds);
}


