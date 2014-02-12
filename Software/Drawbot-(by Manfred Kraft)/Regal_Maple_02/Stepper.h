
#pragma once
#include "wirish.h"

class Stepper {
public:
  Stepper( byte pDir, byte pStep );
  Stepper( byte pDir, byte pStep, boolean rev );
  void init( byte pDir, byte pStep, boolean rev );
  void setDir( int direction );
  void step();
  void setMSMode( int ms1, int ms2, int ms3 );
  void setMS( int steps );
  void setSleep( boolean sleep );
  void setMin();
  void setMax();
private:
  int  dir;
  long position;
  long minPos;
  long maxPos;
  byte pinDir;
  byte pinStep;
  boolean reverse;
  
  static const byte pinMS1A  = 1;
  static const byte pinMS2A  = 2;
  static const byte pinMS3A  = 3;
  static const byte pinSlpA  = 5;
  
  static const byte pinMS1B  = 25;
  static const byte pinMS2B  = 27;
  static const byte pinMS3B  = 29;
  static const byte pinSlpB  = 33;
  
  
  
  long getPos();
  void setPos( long pos );
};






