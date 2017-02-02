// Simpledev.c - A simple I/O device library for Visual68K
// Peter J. Fondse (c) 2002

#include <windows.h>
#include "Simpledev.h"

#define IOBASE    0x00200000  // Base address of this device ($200000)
#define IOSIZE    6           // device needs 6 bytes ($200000 - $200005)

// global variables
HWND hwMain;                  // Visual68K main window
HWND hwDevice;                // IO device window
BYTE DeviceMemory[IOSIZE];    // Device needs 6 bytes of memory (or registers)

// Callback procedure for device dialog

BOOL CALLBACK DeviceDlgProc(HWND hDlg, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	char txt[4];

	switch (uMsg) {
	case WM_INITDIALOG:
		SendDlgItemMessage(hDlg, IDC_PORT_A, EM_SETLIMITTEXT, 2, 0);
		SendDlgItemMessage(hDlg, IDC_PORT_B, EM_SETLIMITTEXT, 2, 0);
		break;
	case WM_COMMAND:
		switch (LOWORD(wParam)) {
		case IDC_PORT_A: // Input A
			if (HIWORD(wParam) == EN_CHANGE) {
				GetDlgItemText(hDlg, IDC_PORT_A, txt, 4);
				DeviceMemory[1] = (BYTE) strtol(txt, NULL, 16);
			}
			break;
		case IDC_PORT_B: // Input B
                	if (HIWORD(wParam) == EN_CHANGE) {
				GetDlgItemText(hDlg, IDC_PORT_B, txt, 4);
				DeviceMemory[3] = (BYTE) strtol(txt, NULL, 16);
			}
			break;
		case IDC_INT5: // Interrupt 5 button
			SendMessage(hwMain, WM_USER, 5, 0); // use level 5 interrupt autovector
			break;
		case IDC_INT6: // Interrupt 6 button
			SendMessage(hwMain, WM_USER, 6, 0); // use level 6 interrupt autovector
			break;
                case IDCANCEL: // Windows menu: close
                        SendMessage(hwMain, WM_USER, 0, 0);
                        break;
		}
	}
	return FALSE;
}

// This function is called when device is opened by the visual simulator

__declspec(dllexport) BOOL APIENTRY InitDevice(HINSTANCE hinstDLL, HWND hWnd, LPDWORD lpdwBase, LPWORD lpwSize)
{
	// save handle for interrupt commands
	hwMain = hWnd;
	// report memory region to Visual Simulator
	*lpdwBase = IOBASE;
	*lpwSize = IOSIZE;
	// Create device window (modeless dialog)
	hwDevice = CreateDialog(hinstDLL, MAKEINTRESOURCE(1), hWnd, DeviceDlgProc);
	// set focus to main window
	SetFocus(hWnd);
	// return TRUE if window is created
	return hwDevice != NULL;
}

// This function is called when the 68000 reads a byte from device memory

__declspec(dllexport) BYTE APIENTRY ReadByte(DWORD dwAddress)
{
	return DeviceMemory[dwAddress - IOBASE];
}

// This function is called when the 68000 writes a byte to device memory

__declspec(dllexport) void APIENTRY WriteByte(DWORD dwAddress, BYTE cbData)
{
	char txt[4];

	// if not changed, do not update
	if (cbData == DeviceMemory[dwAddress - IOBASE]) return;
	DeviceMemory[dwAddress - IOBASE] = cbData;
	// write to address $200005
	if (dwAddress == IOBASE + 5) {
		wsprintf(txt, "%02X", cbData);
		SetDlgItemText(hwDevice, IDC_PORT_C, txt);
	}
}

// This function is called when device is closed by the visual simulator

__declspec(dllexport) void APIENTRY CloseDevice()
{
	DestroyWindow(hwDevice);
}


