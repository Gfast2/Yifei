
#include "Hanger.h"
#include <stdint.h>



void Hanger::moveSteps( long x, long y, int steps ) {
    up();
    gotoXY( x, y, steps ); 
}

void Hanger::moveSteps( long x, long y ) {
    up();
    gotoXY( x, y ); 
}

void Hanger::lineSteps( long x, long y, int steps ) {
    down();
    gotoXY( x, y, steps ); 
}

int servoMin  = 0;
int servoMax  = 90;
//int servoMin  = 60;
//  int servoMax  = 90;
int servoDly  = 40;

void Hanger::up() {
    if ( isDown )
        for (int i = servoMin; i<servoMax; i+= 5 ) {
            servo->write(i);
            delay(servoDly);
        }
    isDown  = false;
}


void Hanger::down() {
    if ( ! isDown)
        for (int i = servoMax; i>=servoMin; i-= 5 ) {
            servo->write(i);
            delay(servoDly);
        }
    isDown  = true;
}

