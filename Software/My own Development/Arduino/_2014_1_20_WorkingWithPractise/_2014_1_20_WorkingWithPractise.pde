/* This is the final version of my Drawbot project. I use this firmware to do my Final presentation in
 * my school. 
 * This firmare is inspired from the project "Makelangelo" by Dan Royer
 * Refered Link:
 * http://www.marginallyclever.com/blog/2012/02/linear-interpolation-vs-trapezoid-motioninterpolation/
 * Coordinate system setting: X point to right, Y point to up
 * The pen start point is the zero point (0,0) of the coordinate system
 * All input units converts to cm innerly in the whole arduino system.
 * time units: second, Length Units: centimeter
 * The Feedrate setting don't works till now. 
 * There is a small acceleration setting posibility by changing the variable in function delayMashine()
 * and delayMashine2(). The setting won't work both line and arc drawing.
 * The top left and top right points distance: 152 - 152.1 cm,  if it is different, change: limit_top
 * limit_left, limit_right and laststep1, laststep2 to meet the new settings.
 *
 *
 * Data: 2014-2-11
 * written by Gfast
 */

//------------------------------------------------------------------------------
// INCLUDES
//------------------------------------------------------------------------------
#include <Gfaststepper.h>

#include <Servo.h> 

// Saving config
#include <EEPROM.h>

/*
// SD card library
 #ifdef USE_SD_CARD
 #include <SD.h>
 #endif
 */

//------------------------------------------------------------------------------
// constants
//------------------------------------------------------------------------------
#define DELAY   (5)
#define BAUD    (57600)
#define MAX_BUF (64)
#define STEPS_PER_TURN  (3200.0) //200 steps/round x 1/16th mode
#define MAX_RPM         (200.0) //3.33 round per second

#define PEN_UP_ANGLE    (170)
#define PEN_DOWN_ANGLE  (10)  // Some steppers don't like 0 degrees
#define PEN_DELAY       (250)  // in ms

#define EndShalter 9 //Endshalter for Servo position control

#define EN 28
#define X_pu 29
#define X_Dir  30
#define Y_pu 31
#define Y_Dir 32

Gfaststepper stepper1(X_pu, X_Dir);
Gfaststepper stepper2(Y_pu, Y_Dir);

// for arc directions
#define ARC_CW          (1)
#define ARC_CCW         (-1)

// Arcs are split into many line segments.  How long are the segments?
#define CM_PER_SEGMENT   (0.2)

// what are the motors called?
char m1d='L'; //left one
char m2d='R'; //right one

#define MAX_STEPS_S     (STEPS_PER_TURN*MAX_RPM/60.0)  // steps/s

#define MIN_VEL         (0.001) // cm/s

// delay between steps, in microseconds.
#define STEP_DELAY      (5200)  // = 3.5ms, 5200 in Unit MicroSeconds

//------------------------------------------------------------------------------
// EEPROM MEMORY MAP
//------------------------------------------------------------------------------
#define EEPROM_VERSION   4             // Increment EEPROM_VERSION when adding new variables
#define ADDR_VERSION     0             // address of the version number (one byte)
#define ADDR_UUID        1             // address of the UUID (long - 4 bytes)
#define ADDR_SPOOL_DIA1  5             // address of the spool diameter (float - 4 bytes)
#define ADDR_SPOOL_DIA2  9             // address of the spool diameter (float - 4 bytes)

//------------------------------------------------------------------------------
// global variables
//------------------------------------------------------------------------------
static Servo s1;
int SERVO_PIN = 10;

char buffer[MAX_BUF];
int sofar;

//plotter position
//define now this is the original position (0,0)
static float posx = 0; //2014/1/2 huge founden: change here from long to float
static float posy = 0;
static float posz;  // pen state
static float feed_rate = 10 / 3; // feed rate is given in units/min and converted to cm/s
static long step_delay;

int M1_REEL_IN = 1;
int M2_REEL_IN = 1;
int M1_REEL_OUT = 0;
int M2_REEL_OUT = 0;

const int FORWARD = 1;
const int BACKWARD = 0;

//Motor position
//the length of left wire in the "last step".  = l1 (Old) Unit: steps
static long laststep1 = 37217;//35839;28cm:34559; //36378;new set:95cm    .42107; //41830;//106.773cm
static long laststep2 = 37217; //41830;//106.773cm

float THREADPERSTEP1 = 0.00261145f;//new diameter:2.66cm //.0.00255254f;// in cm, diameter 2.6cm
float THREADPERSTEP2 = 0.00255254f;// in cm, diameter 2.6cm
//Y-up, X-right
float limit_top = 57;//here is the 5:4:3 triangle. 45grad triangle: 76; // in cm
float limit_left = -76; // in cm
float limit_right = 76; //in cm. 
/* //Used to make a Y-down, X-right coordinate system
float limit_top = -76; // in cm
float limit_left = -76; // in cm
float limit_right = 76; //in cm. 
*/
static float limit_bottom = 0;  // Distance to bottom of drawing area.

static float mode_scale = 0.1;   // mm or inches?
static char mode_name[4] = "mm"; //'in' or 'mm' mode

static char absolute_mode=1;  // absolute or incremental programming mode. '1'- abs mode.

// calculate some numbers to help us find feed_rate
float SPOOL_DIAMETER1 = 2.6 ;// was 0.950, 26 is averag size of new spool, in cm
float SPOOL_DIAMETER2 = 2.6;

float MAX_VEL = MAX_STEPS_S * THREADPERSTEP1;  // cm/s

// robot UID
int robot_uid=0;



//------------------------------------------------------------------------------
// methods
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// from http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1234477290/3
void EEPROM_writeLong(int ee, long value) {
  byte* p = (byte*)(void*)&value;
  for (int i = 0; i < sizeof(value); i++)
    EEPROM.write(ee++, *p++);
}


//------------------------------------------------------------------------------
// from http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1234477290/3
float EEPROM_readLong(int ee) {
  long value = 0;
  byte* p = (byte*)(void*)&value;
  for (int i = 0; i < sizeof(value); i++)
    *p++ = EEPROM.read(ee++);
  return value;
}

//------------------------------------------------------------------------------
static void LoadConfig() {
  char version_number=EEPROM.read(ADDR_VERSION);
  
  if(version_number<3 || version_number>EEPROM_VERSION) {
    // If not the current EEPROM_VERSION or the EEPROM_VERSION is sullied (i.e. unknown data)
    // Update the version number
    Serial.println("LoadConfig case 1");
    EEPROM.write(ADDR_VERSION,EEPROM_VERSION);
    // Update robot uuid
    robot_uid=0;
    SaveUID();
    // Update spool diameter variables
    SaveSpoolDiameter();
  }
  
  if(version_number==3) {
    // Retrieve Stored Configuration
    Serial.println("LoadConfig case 2");
    robot_uid=EEPROM_readLong(ADDR_UUID);
    adjustSpoolDiameter((float)EEPROM_readLong(ADDR_SPOOL_DIA1)/10000.0f,
    (float)EEPROM_readLong(ADDR_SPOOL_DIA1)/10000.0f);   //3 decimal places of percision is enough   
    // save the new data so the next load doesn't screw up one bobbin size
    SaveSpoolDiameter();
    // update the EEPROM version
    EEPROM.write(ADDR_VERSION,EEPROM_VERSION);
  } 
  
  else if(version_number==EEPROM_VERSION) {
    Serial.println("LoadConfig case 3");
    // Retrieve Stored Configuration
    robot_uid=EEPROM_readLong(ADDR_UUID);
    adjustSpoolDiameter((float)EEPROM_readLong(ADDR_SPOOL_DIA1)/10000.0f,
    (float)EEPROM_readLong(ADDR_SPOOL_DIA2)/10000.0f);   //3 decimal places of percision is enough   
  } 
  
  else {
    // Code should not get here if it does we should display some meaningful error message
    Serial.println("An Error Occurred during LoadConfig");
  }
}


//------------------------------------------------------------------------------
static void SaveUID() {
  EEPROM_writeLong(ADDR_UUID,(long)robot_uid);
}

//------------------------------------------------------------------------------
static void SaveSpoolDiameter() {
  EEPROM_writeLong(ADDR_SPOOL_DIA1,SPOOL_DIAMETER1*10000);
  EEPROM_writeLong(ADDR_SPOOL_DIA2,SPOOL_DIAMETER2*10000);
}

//------------------------------------------------------------------------------
// calculate max velocity, threadperstep.
static void adjustSpoolDiameter(float diameter1,float diameter2) {
  SPOOL_DIAMETER1 = diameter1;
  float SPOOL_CIRC = SPOOL_DIAMETER1*PI;  // circumference
  THREADPERSTEP1 = SPOOL_CIRC/STEPS_PER_TURN;  // thread per step

  SPOOL_DIAMETER2 = diameter2;
  SPOOL_CIRC = SPOOL_DIAMETER2*PI;  // circumference
  THREADPERSTEP2 = SPOOL_CIRC/STEPS_PER_TURN;  // thread per step
  
  //correct the initial last step value
  //if not, old laststep value and new diameter will cause the first command
  // of robot without movement command "move to the correct position" problem
  IK(0, 0, laststep1, laststep2);
  Serial.println("laststep1:" + String(laststep1) + "\nlaststep2:" + String(laststep2));

  float MAX_VEL1 = MAX_STEPS_S * THREADPERSTEP1;  // cm/s
  float MAX_VEL2 = MAX_STEPS_S * THREADPERSTEP2;  // cm/s
  MAX_VEL = MAX_VEL1 > MAX_VEL2 ? MAX_VEL1 : MAX_VEL2;
  //"* 1000" cause "Serial.print" can only display float number with two digit after floating point
  Serial.print("SpoolDiameter1 = "); 
  Serial.print(SPOOL_DIAMETER1);  Serial.print("cm Threadperstep( * 1000):");
  Serial.print(THREADPERSTEP1 * 1000);  Serial.println("cm");
  Serial.print("SpoolDiameter2 = "); 
  Serial.print(SPOOL_DIAMETER2);  Serial.print("cm Threadperstep( * 1000):");
  Serial.print(THREADPERSTEP2 * 1000);  Serial.println("cm");
}

//------------------------------------------------------------------------------
// Change pen state.
// Compatible to the original servo control method
static void setPenAngle(int pen_angle) {
  if(posz!=pen_angle) {
    posz=pen_angle;
    
    //TODO: treat value different with 170 an 10.
    if(posz == 170 || posz == 5){ //pen move up
      s1.write(150); //slowly counterclock rotate
      while(digitalRead(EndShalter) == LOW)  //Serial.println("in servo loop");
      
      //if(digitalRead(EndShalter) == HIGH){
          delay(100); //let the servo run to the max. position
          s1.write(90); //stop servo
          //delay(10); // waiting for the pen to stable.
        //}
    }
    else if(posz == 10 || posz == 0){ //pen move down
      s1.write(30); //slowly clock rotate, war 82-slowly put pen down
      while(digitalRead(EndShalter) == HIGH)
      delay(230); //war 500
      s1.write(90); //stop the servo
    }
  }
}


//------------------------------------------------------------------------------
void pause(long ms) {
  delay(ms/1000);
  delayMicroseconds(ms%1000);
}

//------------------------------------------------------------------------------
// Inverse Kinematics - turns XY coordinates into lengths L1,L2
//XY is in Unit: cm, l1, l2 is in Unit:step
static void IK(float x, float y, long &l1, long &l2) {
  // find length to M1
  float dy = y - limit_top;
  float dx = x - limit_left;
  l1 = floor( sqrt(dx*dx+dy*dy) / THREADPERSTEP1 ); //unit: steps
  // find length to M2
  dx = limit_right - x;
  l2 = floor( sqrt(dx*dx+dy*dy) / THREADPERSTEP2 );
}

//---------------------------------------------------------
//acceleration generation for line drawing
void delayMashine(long ad1, long i){
  long delayMax = 1500; //Max. delay time
  //long delayMin = 150; //Min. delay time
  long delayMin = 800; //Min. delay time
    
  long mid = ad1 / 2;
  
  if(i < mid){
    delayMax -= i/3;
  } else {
    delayMax = delayMax - mid/3 + (i - mid)/3;
  }
  
  if(delayMax < delayMin) delayMax = delayMin;
  //Serial.println("delay: " + String(delayMax));
  delayMicroseconds(delayMax);
}


//---------------------------------------------------------
//acceleration generation for arc drawing
void delayMashine2(long ad1, long i){
  long delayMax = 1000; //Max. delay time 1300 war gut und stabile
  //long delayMin = 500; //Min. delay time
  long delayMin = 550; //Min. delay time 750 war gut und stabile,600 war auch OK
  
  long mid = ad1 / 2;
  long scaler = 15;
  
  if(i < mid){
    delayMax -= i*scaler;
  } else {
    delayMax = delayMax - mid*scaler + (i - mid)*scaler;
  }
  
  if(delayMax < delayMin) delayMax = delayMin;
  //Serial.println("delay: " + String(delayMax));
  delayMicroseconds(delayMax);
  //Serial.println(delayMax);
}


//------------------------------------------------------------------------------
static void line_safe(float x,float y,float z) {
  // split up long lines to make them straighter?
  float dx=x-posx;
  float dy=y-posy;

  float len=sqrt(dx*dx+dy*dy);

  setPenAngle((int)z);

  if(len<=CM_PER_SEGMENT) {
    line(x,y,z);
    return;
  }

  // too long!
  long pieces=floor(len/CM_PER_SEGMENT);
  float x0=posx;
  float y0=posy;
  float z0=posz;
  float a;
  for(long j=0;j<=pieces;++j) {
    a=(float)j/(float)pieces;

    line( (x-x0)*a+x0, (y-y0)*a+y0, (z-z0)*a+z0, pieces, j );
  }
  line(x,y,z);
}

//------------------------------------------------------------------------------
static void line(float x,float y,float z) {
  /*
  Serial.println("Jump in line() function");
  Serial.print("x:");
  Serial.print(x);
  Serial.print(" y:");
  Serial.println(y);
  */
  long l1,l2;
  IK(x,y,l1,l2);
  long d1 = l1 - laststep1;
  long d2 = l2 - laststep2;
  /*
  Serial.print("l1:");
  Serial.print(l1);
  Serial.print(" laststep1:");
  Serial.print(laststep1);
  Serial.print(" d1:");
  Serial.println(d1);
  Serial.print("l2:");
  Serial.print(l2);
  Serial.print(" laststep2:");
  Serial.print(laststep2);
  Serial.print(" d2:");
  Serial.println(d2);
  */

  long ad1=abs(d1);
  long ad2=abs(d2);
  int dir1=d1<0 ? M1_REEL_IN : M1_REEL_OUT;
  int dir2=d2<0 ? M2_REEL_IN : M2_REEL_OUT;
  long over=0;
  long i;

  setPenAngle((int)z);

  // bresenham's line algorithm.
  if(ad1>ad2) {
    for(i=0;i<ad1;++i) {
      stepper1.oneStep(dir1);
      //Serial.print("log1 ");
      //Serial.println(i);
      over+=ad2;
      if(over>=ad1) {
        over-=ad1;
        stepper2.oneStep(dir2);
      }
      //pause(step_delay);
      delayMicroseconds(1000);
      //delayMashine(ad1, i);
      //if(readSwitches()) return;
    }
  } 
  else {
    for(i=0;i<ad2;++i) {
      stepper2.oneStep(dir2);
      //Serial.print("log2 ");
      //Serial.println(i);  
      over+=ad1;
      if(over>=ad2) {
        over-=ad2;
        stepper1.oneStep(dir1);
      }
      //pause(step_delay);
      delayMicroseconds(1000);
      //delayMashine(ad2, i);
      //if(readSwitches()) return;
    }
  }

  laststep1=l1;
  laststep2=l2;
  posx=x;
  posy=y;
}



//------------------------------------------------------------------------------
// overloaded line function for arc drawing
static void line(float x,float y,float z,long Segments,long n) { //n-which segment, Segments-total Segments

  long l1,l2;
  IK(x,y,l1,l2);
  long d1 = l1 - laststep1;
  long d2 = l2 - laststep2;

  long ad1=abs(d1);
  long ad2=abs(d2);
  int dir1=d1<0 ? M1_REEL_IN : M1_REEL_OUT;
  int dir2=d2<0 ? M2_REEL_IN : M2_REEL_OUT;
  long over=0;
  long i;

  setPenAngle((int)z);

  // bresenham's line algorithm.
  if(ad1>ad2) {
    for(i=0;i<ad1;++i) {
      stepper1.oneStep(dir1);
      //Serial.print("log1 ");
      //Serial.println(i);
      over+=ad2;
      if(over>=ad1) {
        over-=ad1;
        stepper2.oneStep(dir2);
      }
      //pause(step_delay);
      //delayMicroseconds(1500);
      delayMashine2(Segments, n);
      //if(readSwitches()) return;
    }
  } 
  else {
    for(i=0;i<ad2;++i) {
      stepper2.oneStep(dir2);
      //Serial.print("log2 ");
      //Serial.println(i);  
      over+=ad1;
      if(over>=ad2) {
        over-=ad2;
        stepper1.oneStep(dir1);
      }
      //pause(step_delay);
      //delayMicroseconds(1500);
      delayMashine2(Segments, n);
      //if(readSwitches()) return;
    }
  }

  laststep1=l1;
  laststep2=l2;
  posx=x;
  posy=y;
}



//------------------------------------------------------------------------------
// returns angle of dy/dx as a value from 0...2PI
static float atan3(float dy,float dx) {
  float a=atan2(dy,dx);
  if(a<0) a=(PI*2.0)+a; //?
  return a;
}

//------------------------------------------------------------------------------
// This method assumes the limits have already been checked.
// This method assumes the start and end radius match.
// This method assumes arcs are not >180 degrees (PI radians)
// cx/cy - center of circle
// x/y - end position
// dir - ARC_CW or ARC_CCW to control direction of arc
static void arc(float cx,float cy,float x,float y,float z,float dir) {
  // get radius
  float dx = posx - cx;
  float dy = posy - cy;
  float radius=sqrt(dx*dx+dy*dy);

  // find angle of arc (sweep)
  float angle1=atan3(dy,dx);
  float angle2=atan3(y-cy,x-cx);
  float theta=angle2-angle1;

  if(dir>0 && theta<0) angle2+=2*PI;
  else if(dir<0 && theta>0) angle1+=2*PI;

  theta=angle2-angle1;

  // get length of arc
  // float circ=PI*2.0*radius;
  // float len=theta*circ/(PI*2.0);
  // simplifies to
  float len = abs(theta) * radius;

  long i, segments = floor( len / CM_PER_SEGMENT );

  float nx, ny, nz, angle3, scale;

  for(i=0;i<segments;++i) {
    // interpolate around the arc
    scale = ((float)i)/((float)segments);

    angle3 = ( theta * scale ) + angle1;
    nx = cx + cos(angle3) * radius;
    ny = cy + sin(angle3) * radius;
    nz = ( z - posz ) * scale + posz;
    // send it to the planner
    line(nx,ny,nz);
  }

  line(x,y,z);
}


//-----------------------------------------------------------------------------
//MAIN
//-----------------------------------------------------------------------------
void setup(){
  
  pinMode(EN, OUTPUT); //Motor Enable pin
  digitalWrite(EN, HIGH);

   // initialize the read buffer
  sofar=0;

  // servo should be on SER1, pin 10.
  s1.attach(SERVO_PIN);

  Serial.begin(BAUD);
  LoadConfig();
  Serial.print("\n\nHELLO WORLD! I AM DRAWBOT #");
  Serial.println(robot_uid);
  
  strcpy(mode_name,"mm");
  mode_scale=0.1;
  
  //setFeedRate(MAX_VEL*30/mode_scale);  // *30 because i also /2
  setFeedRate(2000); //start at a lower speed.
  
  Serial.println("> ");
  
  setPenAngle(5); //init pull up the pen
}

void loop(){
  // listen for serial commands
  while(Serial.available() > 0) {
    buffer[sofar++]=Serial.read();
    if(buffer[sofar-1]==';') break;  // in case there are multiple instructions
  }

  // if we hit a semi-colon, assume end of instruction.
  if(sofar>0 && buffer[sofar-1]==';') {
    // what if message fails/garbled?

    // echo confirmation
    buffer[sofar]=0;
    //Serial.println(buffer);

    // do something with the command
    processCommand();
//laststep1
    // reset the buffer
    sofar=0;

    // echo completion
    Serial.println("> ");
  }
}











