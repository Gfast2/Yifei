

void Hanger::stepBy( long stepsLeft, long stepsRight ) {

  stepsLeft  = stepsLeft;
  stepsRight = stepsRight;


  long pdx, pdy, es, el, err;
  long directionLeft  = sgn( stepsLeft );
  long directionRight = sgn( stepsRight );
  stepsLeft           = abs( stepsLeft );
  stepsRight          = abs( stepsRight );

  if ( stepsLeft > stepsRight )
  {  /* x ist schnelle Richtung */
    pdx  = directionLeft; 
    pdy  = 0L;       
    es   = stepsRight;   
    el   = stepsLeft;     
  } 
  else
  {  /* y ist schnelle Richtung */
    pdx  = 0L;    
    pdy  = directionRight;     
    es   = stepsLeft;   
    el   = stepsRight;       
  }   
  leftStepper.setDir( directionLeft );
  rightStepper.setDir( directionRight );

  err = el/2;
  long t = 0;
  long elapsed  = 0;
  long last;
  for(;;) {
    if ( (micros() - last) >= period ) {
      if ( t >= el ) {
        break; 
      }
      
      adjustSpeed();

      err -= es; 
      if(err<0)
      { 
        err += el;  // Fehlerterm wieder positiv (>=0) machen
        if ( directionLeft != 0  ) {
          leftStepper.step();
        }
        if ( directionRight != 0  ) {
          rightStepper.step();
        }
      } 
      else
      { 
        if ( pdx != 0  ) {
          leftStepper.step();
        }
        if ( pdy != 0  ) {
          rightStepper.step();
        }
      }
      t++;
      last  = micros();
    }
  }
} 



