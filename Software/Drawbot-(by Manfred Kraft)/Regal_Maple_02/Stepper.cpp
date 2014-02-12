
#include "Stepper.h"

void Stepper::setDir( int direction ) {
  if ( direction != dir ) {
    if ( direction == -1 ) {
      reverse ? digitalWrite( pinDir, HIGH  ) : digitalWrite( pinDir, LOW  ); 
    } 
    else {
      reverse ? digitalWrite( pinDir, LOW  ) : digitalWrite( pinDir, HIGH  ); 
    }
    dir    = direction;
  }
}

void Stepper::step() { 
  digitalWrite( pinStep, LOW  );  
  //delayMicroseconds( 1 );          
  digitalWrite( pinStep, HIGH ); 
  position  += dir;
}


void Stepper::setMSMode( int ms1, int ms2, int ms3 ) {
  digitalWrite( pinMS1A, ms1 );           
  digitalWrite( pinMS2A, ms2 );          
  digitalWrite( pinMS3A, ms3 );
  digitalWrite( pinMS1B, ms1 );           
  digitalWrite( pinMS2B, ms2 );          
  digitalWrite( pinMS3B, ms3 );
}

void Stepper::setMS( int steps ) {  
  if ( steps == 1 ) 
    setMSMode( LOW, LOW, LOW );
  else if ( steps == 2 )
    setMSMode( HIGH, LOW, LOW );
  else if ( steps == 4 )
    setMSMode( LOW, HIGH, LOW );
  else if ( steps == 8 )
    setMSMode( HIGH, HIGH, LOW );
  else if ( steps == 16 )
    setMSMode( HIGH, HIGH, HIGH );
}

void Stepper::setSleep( boolean sleep ) {
  if ( sleep) {    
    digitalWrite( pinSlpA, LOW );
    digitalWrite( pinSlpB, LOW );
  } 
  else {
    digitalWrite( pinSlpA, HIGH );
    digitalWrite( pinSlpB, HIGH );
  }
}



void Stepper::setMin() {
  position  = 0L;
}

void Stepper::setMax() {
  maxPos  = position;
}

void Stepper::setPos( long pos ) {
  position = pos;
}

long Stepper::getPos() {
  return position;
}

void Stepper::init( byte pDir, byte pStep, boolean rev ) {
  reverse = rev;
  pinDir  = pDir;
  pinStep = pStep;  
  pinMode( pinDir,  OUTPUT ); 
  pinMode( pinStep, OUTPUT ); 
  pinMode( pinSlpA,  OUTPUT ); 
  pinMode( pinMS1A,  OUTPUT ); 
  pinMode( pinMS2A,  OUTPUT ); 
  pinMode( pinMS3A,  OUTPUT ); 
  pinMode( pinSlpB,  OUTPUT ); 
  pinMode( pinMS1B,  OUTPUT ); 
  pinMode( pinMS2B,  OUTPUT ); 
  pinMode( pinMS3B,  OUTPUT ); 
  setSleep( false );
  setMS( 16 );
}


Stepper::Stepper( byte pDir, byte pStep ) { 
  init( pDir, pStep, false );
}

Stepper::Stepper( byte pDir, byte pStep, boolean rev ) {
  init( pDir, pStep, rev );
}









