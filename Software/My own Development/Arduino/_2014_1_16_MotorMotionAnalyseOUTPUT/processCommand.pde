


//------------------------------------------------------------------------------
void releaseMotor(){
  digitalWrite(EN,LOW);
}

//------------------------------------------------------------------------------
static void where() {
  Serial.print("X:");    Serial.print(posx);
  Serial.print("cm Y:"); Serial.print(posy);
  Serial.print("cm Z:"); Serial.print(posz);
  Serial.print(" F");    printFeedRate();
  Serial.print("\n");
}

//------------------------------------------------------------------------------
static void printConfig() {
  Serial.print(m1d);        Serial.print("=");  Serial.print(limit_top);  Serial.print(",");
  Serial.print(limit_left); Serial.print("\n");
  Serial.print(m2d);        Serial.print("=");  Serial.print(limit_top);  Serial.print(",");
  Serial.print(limit_right);Serial.print("\n");
  Serial.print("Bottom=");  Serial.println(limit_bottom);
  Serial.print("Feed rate=");  printFeedRate();
}

//------------------------------------------------------------------------------
static void help() {
  Serial.println();
  Serial.println("== DRAWBOT - http://github.com/i-make-robots/Drawbot/ ==");
  Serial.println("All commands end with a semi-colon.");
  Serial.println("HELP;  - display this message");
  Serial.println("CONFIG [Tx.xx] [Bx.xx] [Rx.xx] [Lx.xx];");
  Serial.println("       - display/update this robot's configuration.");
  Serial.println("TELEPORT [Xx.xx] [Yx.xx]; - move the virtual plotter.");
  //Serial.println("As well as the following G-codes (http://en.wikipedia.org/wiki/G-code):");
  Serial.println("support the following G-codes (http://en.wikipedia.org/wiki/G-code):");
  Serial.println("G00,G01,G02,G03,G04,G20,G21,G28,G90,G91,M18,M114");
}

//------------------------------------------------------------------------------
static void printFeedRate() {
  //Serial.print("f1= ");
  Serial.print(feed_rate * 60.0 / mode_scale);
  Serial.print(mode_name);
  Serial.println("/min");
}

//------------------------------------------------------------------------------
// feed rate is given in units/min and converted to cm/s ************************
// the units/min, units can be in "mm" or in "in"
static void setFeedRate(float v) {
  /*
  float v1 = v * mode_scale / 60.0;
  if( feed_rate != v1 ) {
    feed_rate = v1; //feed rate is now in unit: cm/s
    if(feed_rate > MAX_VEL) feed_rate=MAX_VEL;
    if(feed_rate < MIN_VEL) feed_rate=MIN_VEL;
  }
  
  long step_delay1 = 1000000.0 / (feed_rate/THREADPERSTEP1); //where comes the 1000000
  long step_delay2 = 1000000.0 / (feed_rate/THREADPERSTEP2); //in () unit: steps/s
  step_delay = step_delay1 > step_delay2 ? step_delay1 : step_delay2;
  
  Serial.print("step_delay=");
  Serial.println(step_delay);
  //printFeedRate();
  */
}

//------------------------------------------------------------------------------
// instantly move the virtual plotter position
// does not validate if the move is valid
static void teleport(float x,float y) {
  posx=x;
  posy=y;

  // @TODO: posz?
  long L1,L2; //teleport the new set point
  IK(posx,posy,L1,L2);
  laststep1=L1;
  laststep2=L2;
}

//------------------------------------------------------------------------------
static int processSubcommand() {
  int found=0;
  char *ptr=buffer;
  
  while(ptr && ptr<buffer+sofar && strlen(ptr)) {
    if(!strncmp(ptr,"G20",3)) {
      Serial.println("input Unite: inches");
      mode_scale=2.54f;  // inches -> cm, 1 inche == 2.54 cm
      strcpy(mode_name,"in");
      printFeedRate();
      found=1;
    } 
    else if(!strncmp(ptr,"G21",3)) { //say the imput parameter is always set to "mm" and be here convertered.
      Serial.println("input Unite: mm");
      mode_scale=0.1;  // mm -> cm, 1 mm = 0.1 cm
      strcpy(mode_name,"mm");
      printFeedRate();
      found=1;
    }
    else if(!strncmp(ptr,"G90",3)) {
      // absolute mode
      absolute_mode=1;
      found=1;
      Serial.println("in absolute mode");
    } 
    else if(!strncmp(ptr,"G91",3)) {
      // relative mode
      absolute_mode=0;
      found=1;
      Serial.println("in relative mode");
    }
    //ptr=strchr(ptr,' ')+1; //here is the deal!!
    //when strchr() return NULL, this ChipKIT IDE can not handle
    ptr=strchr(ptr,' '); 
    if(ptr != NULL){
      ptr += 1;
    }
    /*
    else{
      break;
    }
    */
  }
  return found;
}



//------------------------------------------------------------------------------
void processCommand() {
  //------------------------------------------------------------------------------
  //------------------------------------------------------------------------------
  // blank lines
  if(buffer[0]==';') return;

  if(!strncmp(buffer,"HELP",4)) {help();} 
  else if(!strncmp(buffer,"UID",3)) {
    robot_uid=atoi(strchr(buffer,' ')+1);
    SaveUID();
  } 
  else if(!strncmp(buffer,"G28",3)) {
    //FindHome();
  }  
  else if(!strncmp(buffer,"TELEPORT",8)) {
    float xx=posx;
    float yy=posy;

    char *ptr=buffer;
    while(ptr && ptr<buffer+sofar) {
      ptr=strchr(ptr,' ');
      if(ptr != NULL) {
        ptr += 1;
        switch(*ptr) {
          case 'X': xx=atof(ptr+1)*mode_scale;  break;
          case 'Y': yy=atof(ptr+1)*mode_scale;  break;
          default: ptr=0; break;
        }
      }
    }
    teleport(xx,yy);
  }
  else if(!strncmp(buffer,"M114",4)) {
    where();
  } 
  else if(!strncmp(buffer,"M18",3)) {
    // disable motors, we have only one Enable pin for All 3 Axis motors
    releaseMotor(); 
  } 
  
  //set limits, in cm!
  else if(!strncmp(buffer,"CONFIG",6)) {
    float tt=limit_top;
    float bb=limit_bottom;
    float rr=limit_right;
    float ll=limit_left;
    char gg=m1d;
    char hh=m2d;

    char *ptr=buffer;
    while(ptr && ptr<buffer+sofar && strlen(ptr)) {
      ptr=strchr(ptr,' ');
      if(ptr != NULL){
        ptr += 1;
        switch(*ptr) {
        case 'T': tt=atof(ptr+1); break;
        case 'B': bb=atof(ptr+1); break;
        case 'R': rr=atof(ptr+1); break;
        case 'L': ll=atof(ptr+1); break;
        case 'G': gg=*(ptr+1);    break; //here save a char
        case 'H': hh=*(ptr+1);    break; //here save a char
        case 'I':
          if(atoi(ptr+1)>0) {
            M1_REEL_IN=FORWARD;
            M1_REEL_OUT=BACKWARD;
          } 
          else {
            M1_REEL_IN=BACKWARD;
            M1_REEL_OUT=FORWARD;
          }
          break;
        case 'J':
          if(atoi(ptr+1)>0) {
            M2_REEL_IN=FORWARD;
            M2_REEL_OUT=BACKWARD;
          } 
          else {
            M2_REEL_IN=BACKWARD;
            M2_REEL_OUT=FORWARD;
          }
          break;
        }
      }
    }

    // @TODO: check t>b, r>l ?
    limit_top=tt;
    limit_bottom=bb;
    limit_right=rr;
    limit_left=ll;
    m1d=gg;
    m2d=hh;

    teleport(0,0);
    printConfig();
  }
  ////////////////////////////
  //Draw line. G00 - fast move. G01 draw line.
  else if(!strncmp(buffer,"G00 ",4) || !strncmp(buffer,"G01 ",4)
    || !strncmp(buffer,"G0 " ,3) || !strncmp(buffer,"G1 " ,3) ) {
    processSubcommand();
    float xx, yy, zz;
    if(absolute_mode==1) {
      xx=posx;
      yy=posy;
      zz=posz;
      /*
      Serial.print("posx:");
      Serial.print(posx);
      Serial.print(" posy:");
      Serial.print(posy);
      Serial.print(" posz");
      Serial.print(posz);
      Serial.println(" Absolute mode");
      */
    } 
    else {
      xx=0;
      yy=0;
      zz=0;
    }
    char *ptr=buffer;
    while(ptr && ptr<buffer+sofar && strlen(ptr)) {
      ptr=strchr(ptr,' ');
      if(ptr != NULL) {
        ptr += 1;
        switch(*ptr) {
          case 'X': xx=atof(ptr+1) * mode_scale; break; //through mode_scale change the position in loop to 'cm'.
          case 'Y': yy=atof(ptr+1) * mode_scale; break;
          case 'Z': zz=atof(ptr+1);              break;
          case 'F': setFeedRate(atof(ptr+1));    break;
        }
      }
    }
    //get the abs position from the relative position
    if(absolute_mode==0) {
      xx+=posx;
      yy+=posy;
      zz+=posz;
      /*
      Serial.print("posx:");
      Serial.print(posx);
      Serial.print(" posy:");
      Serial.print(posy);
      Serial.print(" posz");
      Serial.print(posz);
      Serial.println(" relative mode");
      */
    }
    /*
    Serial.print("xx:");
    Serial.print(xx);
    Serial.print(" yy");
    Serial.print(yy);
    Serial.print(" zz");
    Serial.print(zz);
    Serial.println();
    */
    //line_safe(xx,yy,zz); //inorder to drawn line straighter
    line(xx,yy,zz);
  }
  
  
  
  // arc
  else if(!strncmp(buffer,"G02 ",4) || !strncmp(buffer,"G2 " ,3) 
    || !strncmp(buffer,"G03 ",4) || !strncmp(buffer,"G3 " ,3)) {
    processSubcommand();
    float xx, yy, zz;
    // if command is "G02" or "G2", draw arc clockwise, otherwise counterclockwise. "dd" is the direction of the arc
    float dd = (!strncmp(buffer,"G02",3) || !strncmp(buffer,"G2",2)) ? -1 : 1;
    float ii = 0; // Circle Center X
    float jj = 0; // Circle Center Y

    if(absolute_mode==1) { // In absolute mode
      xx=posx; 
      yy=posy;
      zz=posz;
    } 
    else {
      xx=0;
      yy=0;
      zz=0;
    }
    char *ptr=buffer;
    while(ptr && ptr<buffer+sofar && strlen(ptr)) {
      ptr=strchr(ptr,' ');
      if(ptr != NULL){
        ptr += 1;
        switch(*ptr) {
        case 'I': ii=atof(ptr+1) * mode_scale;  break; // Circle Center X
        case 'J': jj=atof(ptr+1) * mode_scale;  break; // Circle Center Y
        case 'X': xx=atof(ptr+1) * mode_scale;  break; // End position X
        case 'Y': yy=atof(ptr+1) * mode_scale;  break; // End position Y
        case 'Z': zz=atof(ptr+1);  break;
        case 'F': setFeedRate(atof(ptr+1));  break; // Feed rate
        }
      }
    }
    if(absolute_mode==0) { //find in relative mode defined position in abs mode coordinate.
      xx+=posx;
      yy+=posy;
      zz+=posz;
    }
    arc(posx+ii,posy+jj,xx,yy,zz,dd);
  }
  
  
  
  // dwell, drilling hole wait time.
  else if(!strncmp(buffer,"G04 ",4) || !strncmp(buffer,"G4 ",3)) {
    long xx=0; // drill hole latency
    char *ptr=buffer;
    while(ptr && ptr<buffer+sofar && strlen(ptr)) {
      ptr=strchr(ptr,' ');
      if(ptr != NULL){
        ptr += 1;
        switch(*ptr) {
        case 'X': 
        case 'U': 
        case 'P': 
          xx=atol(ptr+1); 
          Serial.print("Drill hole time delay: "); 
          Serial.println(xx); 
          break;
        }
      }
    }
    delay(xx);
  }
  //Move only one motor n steps.
  else if(!strncmp(buffer,"D00 ",4)) {
    // move one motor
    char *ptr= strchr(buffer,' ')!=NULL ? strchr(buffer,' ')+1 : NULL;
    long amount = atol(ptr+1);
    int i, dir;
    Serial.print("Motor: "); 
    Serial.print(*ptr); 
    Serial.print(" moves "); 
    Serial.print(amount); 
    Serial.println(" steps.");
    if(*ptr == m1d) {
      dir = amount < 0 ? M1_REEL_IN : M1_REEL_OUT;
      amount=abs(amount);
      for(i=0;i<amount;++i) {  /*oneStep(1,dir)*/
        stepper1.oneStep(dir);  
        delay(2);  
      }
    } 
    else if(*ptr == m2d) {
      dir = amount < 0 ? M2_REEL_IN : M2_REEL_OUT;
      amount = abs(amount);
      for(i=0;i<amount;++i) {  /*oneStep(2,dir)*/
        stepper2.oneStep(dir);  
        delay(2);  
      }
    }
  }
  //Setting spool's diameter, input value in unit:cm
  else if(!strncmp(buffer,"D01 ",4)) {
    // adjust spool diameters. 
    float amountL=SPOOL_DIAMETER1;
    float amountR=SPOOL_DIAMETER2;

    char *ptr=buffer;
    while(ptr && ptr<buffer+sofar && strlen(ptr)) {
      ptr=strchr(ptr,' ');
      if(ptr != NULL) {
        ptr += 1;
        switch(*ptr) {
          case 'L': amountL=atof(ptr+1);  break;
          case 'R': amountR=atof(ptr+1);  break;
        }
      }
    }
    float tps1=THREADPERSTEP1;
    float tps2=THREADPERSTEP2;
    //TODO: setting float number to let default save more digits, in order to get more acurate number.
    adjustSpoolDiameter(amountL,amountR);
    if(THREADPERSTEP1 != tps1 || THREADPERSTEP2 != tps2) {
      // Update EEPROM
      SaveSpoolDiameter();
    }
  }
  //Display spools' diameter 
  else if(!strncmp(buffer,"D02 ",4)) {
    Serial.print('L');
    Serial.print(SPOOL_DIAMETER1);
    Serial.print(" R ");
    Serial.println(SPOOL_DIAMETER2);
  }
  else if(!strncmp(buffer,"where",5)) {
    where();
  } 
  else if(!strncmp(buffer,"test",4)) {
    // one whole number parameter
    char *state=strchr(buffer,' ');

    if(state != NULL) {
      state = state + 1;
      Serial.println(state);
      if(state[0]=='0') {
        //test_on=0;
        Serial.println("Deactivate Motor.");
        digitalWrite(EN,LOW);
      } 
      else {
        //test_on=1;
        Serial.println("Activate Motor.");
        digitalWrite(EN,HIGH);
      }
    } 
  }
  
  else if(!strncmp(buffer,"clear",5)) {
    for(int k = 0; k < 100; ++k){
      Serial.println();
      delayMicroseconds(1);
    }
  }
  
  else { //When code unreadable.
    if(processSubcommand()==0) {
      Serial.print("Invalid command '");
      Serial.print(buffer);
      Serial.println("'");
    }
  }
}/*--------End processCommand------------*/


