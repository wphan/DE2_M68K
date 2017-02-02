// HELLODIR.C - A minimalistic program to print Hello world!
// uses trap 15 call

// Author: Peter J. Fondse (pfondse@hetnet.nl)

void main()
{
    _A0 = "Hello world!\r\n";  // A0 is pointer to string
    _trap(15);
    _word(7);                  // system call PRTSTR
}
