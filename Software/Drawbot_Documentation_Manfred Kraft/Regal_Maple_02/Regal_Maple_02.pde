#include <stdlib.h>
#include <Servo.h>
#include "Hanger.h"

int     dir          = 0; 
long    msSteps      = 1L;
long    dist         = 60000L / msSteps;   
bool    commandMode  = false; 
Servo   servo;
Stepper rightStepper( 37, 35,false );
Stepper leftStepper( 7, 6, false );

Hanger  hanger( &leftStepper, &rightStepper, dist, &servo );

void setup() {
    leftStepper.setMS( 16 / msSteps );
    rightStepper.setMS( 16 / msSteps );
    hanger.setAcceleration( 1,500 );
    hanger.setVelocity( 400,8000 );
    //  servo.attach(9); 
    SerialUSB.println("ok");
}

void loop() {

    if (SerialUSB.available() > 0) {
        int in = SerialUSB.read();
        readChar( in );

        /*
    if ( in == '>' ) {
         commandMode  = true;
         SerialUSB.println( "ok" ); 
         } 
         else if (in == '|' ) {
         SerialUSB.println( "ok" ); 
         commandMode  = false;
         reset();
         }
         
         if ( commandMode ) { 
         readChar( in );
         } 
         */
    }
}






















