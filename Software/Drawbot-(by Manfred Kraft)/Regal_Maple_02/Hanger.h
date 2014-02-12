
#pragma once
#include <Servo.h>
#include "Stepper.h"

class Hanger
{
public:
  Hanger( Stepper * left, Stepper * right, long distCm, Servo * servo ) ;
  
  // primitive
  void stepBy( long stepsLeft, long stepsRight);
  
  // Coordinate Conversions
  void setXY( long x, long y );
  void setLR( long l, long r );
  
  // polar coordinates
  void gotoLR( long radiusLeft, long radiusRight );
  void gobyLR( long radiusLeft, long radiusRight );
  void calibrateLR( long radiusLeft, long radiusRight );
    
  // cartesian coordinates
  void gotoXY( long x, long y );
  void _gotoXY( long x, long y );
  void gobyXY( long x, long y );
  void gotoXY( long x, long y, int steps );
  void calibrateXY( long radiusLeft, long radiusRight );
  
  // speed & acceleration
  void setDelay( int delay );
  void setSpeed( long spd );
  long getSpeed();
  
  void setVelocity( int minspeed, long maxspeed );
  void setAcceleration( long acceleraton, long nonlinear );
  
  
  void setMSMode( byte msmode);
  void initMove( long numsteps);
  void adjustSpeed();
    
  void moveSteps( long x, long y );
  void moveSteps( long x, long y, int steps );
  
  void lineSteps( long x, long y );
  void lineSteps( long x, long y, int steps );
  
  // drawing functions
  void up();
  void down();
    
  void debug();
    

private: 

  Servo   * servo; 
  Stepper * stepperLeft;
  Stepper * stepperRight;
  
  boolean   isDown;
  // Position
  long    posX;
  long    posY;
  long    posL;
  long    posR;
  
  long    distance;
  
  long    currentStep;
  long    minSpeed;
  long    maxSpeed;
  long    accSteps;
  long    decSteps;
  long    numSteps;
  long    halfSteps;
  long    curSpeed;
  
  //long    speed;
  long    period;
  long    acc;
  

};







