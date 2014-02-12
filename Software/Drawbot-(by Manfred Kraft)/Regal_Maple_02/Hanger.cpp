
#include "Hanger.h"
#include <stdint.h>

Hanger::Hanger( Stepper * left, Stepper * right, long dist, Servo * s ) {
  stepperLeft   = left;
  stepperRight  = right;
  servo         = s;

  distance      = dist;
  setAcceleration( 1,500 );
  setVelocity( 400,10000 );
  setMSMode( 16 );
  up();
}


/* 
 * Coordinate Conversions
 */

void Hanger::setXY( long x, long y ) {
  posX       = x;
  posY       = y;
  long rest  = distance - posX;
  float ys   = sq((float)posY);
  posL       = long(sqrt( sq((float)posX) + ys ));
  posR       = long(sqrt( sq((float)rest) + ys ));
}

void Hanger::setLR( long l, long r ) {
  posL       = l;
  posR       = r;
  posX       = long( (sq(float(posL)) - sq(float(posR)) + sq(float(distance))) / (2 * distance));
  posY       = long(sqrt( sq(float(posL)) - sq(float(posX)) ));
}

/*
 *  Radius related functions
 *  polar coordinates 
 */

void Hanger::gotoLR( long radiusLeft, long radiusRight ) {
  gobyLR( radiusLeft  - posL, radiusRight - posR );
}

void Hanger::gobyLR( long radiusLeft, long radiusRight ) {
  setLR( posL + radiusLeft, posR + radiusRight );
  initMove( max(abs(radiusLeft), abs(radiusRight)) );
  stepBy( radiusLeft, radiusRight );
}

void Hanger::calibrateLR( long radiusLeft, long radiusRight ) {
  setLR( radiusLeft, radiusRight );
}


/*
 *  Cartesian related functions
 *  (x,y) coordinates 
 */
 
void Hanger::calibrateXY( long x, long y ) {
  setXY(  x, y );
}


void Hanger::_gotoXY( long x, long y ) {
  long oldL  = posL;
  long oldR  = posR;
  setXY(  x, y );
  long dL    = posL - oldL;
  long dR    = posR - oldR;
  //initMove( max(abs(dL), abs(dR)) );
  stepBy( dL, dR );
}


void Hanger::gotoXY( long x, long y ) {
  long oldL  = posL;
  long oldR  = posR;
  setXY(  x, y );
  long dL    = posL - oldL;
  long dR    = posR - oldR;
  initMove( max(abs(dL), abs(dR)) );
  stepBy( dL, dR );
}

void Hanger::gotoXY( long x, long y, int steps ) {
  long sx      = (x - posX) / steps;
  long sy      = (y - posY) / steps;

  initMove( max(abs(x-posX), abs(y-posY)) ) ;

  for( int i = 0; i<steps; i++ ) {
    _gotoXY( posX + sx, posY + sy );
  }
  _gotoXY( x, y );
}

void Hanger::gobyXY( long x, long y ) {
  gotoXY( posX + x, posY + y );
}








/*
 *  Speed related functions
 *  
 */

void Hanger::setMSMode( byte msmode ) {
  stepperLeft->setMS( msmode );
  stepperRight->setMS( msmode );
  //msSteps  = 16 / msmode;
}

void Hanger::setDelay( int d ) {
  //period    = d;
}

void Hanger::setSpeed( long spd ) {
  if ( spd != curSpeed ) {
    curSpeed    = spd;
    long p    = 1000000L / spd;
    if ( p != period ) {
      period    = p;
    }
  }
}

long Hanger::getSpeed() {
  return 1000000L / period;
}

void Hanger::setVelocity( int minspeed, long maxspeed ) {
  minSpeed    = minspeed;
  maxSpeed    = maxspeed;
}


int nonLinear  = 500;

void Hanger::setAcceleration( long acceleraton, long nonlinear ) {
  acc         = acceleraton;
  nonLinear   = nonlinear;
}


unsigned long accTime;
boolean accelFinish;
long speed;

void Hanger::initMove( long numsteps) {
  numSteps    = abs(numsteps);
  currentStep = 0;
  accSteps    = min( (maxSpeed - minSpeed) / acc , numsteps/2 );
  decSteps    = numSteps - accSteps ;
  decSteps    = numSteps;
  halfSteps   = numSteps/2;
  accelFinish = false;
  setSpeed( minSpeed);
  accTime     = 2000000 * accSteps / maxSpeed;  
}

void Hanger::adjustSpeed() {
  if ( minSpeed == maxSpeed )  return;
  if (! accelFinish) {
    if ( (speed <= maxSpeed) && (currentStep <= halfSteps)) {
      speed  += acc + acc * period / nonLinear; 
      //setSpeed( speed );
      period  = 1000000L / speed;
    } 
    else  {
      accelFinish  = true;
      decSteps     = numSteps - currentStep - 0; 
      //setSpeed( maxSpeed );
      period  = 1000000L / maxSpeed;
      SerialUSB.print( "MaxSpeed: " ); 
      SerialUSB.println( period ); 
    }
  } 
  else {
    if ( currentStep >= decSteps ) {
      speed  -= acc + acc * period / nonLinear;
      if (speed > 0)
        period  = 1000000L / speed;
      //setSpeed( speed );
    } 
  }
  currentStep++;
}





void Hanger::debug() {
  SerialUSB.print( "l: " ); 
  SerialUSB.print( posL ); 
  SerialUSB.print( ", r: " ); 
  SerialUSB.print( posR ); 
  SerialUSB.print( ", x: " ); 
  SerialUSB.print( posX ); 
  SerialUSB.print( ", y: " ); 
  SerialUSB.println( posY ); 
}



























