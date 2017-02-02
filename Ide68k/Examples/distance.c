/* DISTANCE.C - Computes the distance between A and B in nautical miles.
 *
 * This program computes the angle between two locations on earth as seen
 * from the center of the earth. Computation is based on the so-called
 * cosine-rule of spherical geometry
 *
 * By definition, one arc-minute of this angle (1/60 of a degree) corresponds
 * to a distance of one nautical mile on the earth's surface.
 *
 * Two functions are provided, one is written in C, the other, more efficient,
 * is coded in assembly using 68881 floating-point coprocessor instructions.
 *
 * (c) Peter J. Fondse, 2004 (pfondse@hetnet.nl)
 */

#include <stdio.h>
#include <math.h>

typedef struct {
    char *name;         // name of city
    float latitude;     // North +, South -
    float longitude;    // East +, West -
} CITY;

float distance (CITY *, CITY *);

void main(void)
{
    CITY A = { "New York", 40.72, -74.00 };
    CITY B = { "Paris", 48.85, 2.35 };

    printf("Distance from %s to %s is %0.0f nm.\n", A.name, B.name, distance(&A, &B));
}

/* uncomment this function if the C function distance() is used
 * and delete distance.a68 from the project list

float distance(CITY *a, CITY *b)
{
    register float x1, x2, y1, y2;
    register float cf = M_PI / 180;

    // convert degrees to rad
    x1 = cf * a->longitude;
    x2 = cf * b->longitude;
    y1 = cf * a->latitude;
    y2 = cf * b->latitude;
    // compute distance in  nautical miles
    return (60 * 180 / M_PI) * acos(sin(y1) * sin(y2) + cos(y1) * cos(y2) * cos(x1 - x2));
}

*/
