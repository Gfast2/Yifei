/*
 * This code is the very first TUIODraw code. It handle the communication between drawbot and computer
 * from reacTIVIsion comed position information will be saved in array 'G'. it have only 10000 elements
 * at framrate 12 means with it man can save only about 13.8 minutes line of G-code.
 * 
 * fiducial 1: draw lines
 * fiducial 2: save all excuted G-code in file "G.txt"
 * fiducial 3: Gondel go back to home (0,0) with pen up
 * other fiducial are used for line drawing without pen down
 * 
 * WARRNING: This code have to work with processing 1.5 !!
 * http://reactivision.sourceforge.net/
 *  
 * data: 2014-2-1
 * written by Gfast
 */
 
import TUIO.*;
import processing.serial.*; // and declare a TuioProcessing client variable

TuioProcessing tuioClient;
Serial myPort;

// these are some helper variables which are used
// to create scalable graphical feedback
float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
PFont font;

String[] lines = loadStrings("G.txt"); //G-code buffer file
String[] G = new String[10000]; //G-code for new target position.
long sent = 0; //the line number of sent code 
String[] data; //save serial output data according line diff in array

int echoFlag = 0; //mark if go the command excuted echo from MCU in this loop
//How many cmd in Arduino (executing + buffering) now.
//Init as '1' because when drawbot started properly,it will send a "> " as indicate
int bufferNum = 1; 
int cmdLine = 0; //Which com line has been sent.
long lineLen; //the database array "lines"'s length
int state = 0; //'0'-stop, '1'-play, '2'-pause
int playFlag = 0; //flag if in play section, '0'-not, '1'-playing
int linie=0; //save G-Code array's index & save the max. line number of the G-code array

////////////////////////////
//SETUP/////////////////////
////////////////////////////
void setup()
{
  //size(screen.width,screen.height);
  size(1280, 720);
  noStroke();
  fill(0);

  loop();
  frameRate(12);
  //noLoop();

  hint(ENABLE_NATIVE_FONTS);
  font = createFont("Courier", 32);
  scale_factor = height/table_size;

  // we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods (see below)
  tuioClient  = new TuioProcessing(this);

  //println(Serial.list()); //list out Seria ports
  String portName = Serial.list()[4];
  myPort = new Serial(this, portName, 57600); //drawbot working at 57600  
  
}


////////////////////////////
//DRAW//////////////////////
////////////////////////////
// within the draw method we retrieve a Vector (List) of TuioObject and TuioCursor (polling)
// from the TuioProcessing client and then loop over both lists to draw the graphical feedback.
void draw()
{  
  background(#F5FFF6);
  textFont(font, 18*scale_factor);
  float obj_size = object_size*scale_factor; 
  float cur_size = cursor_size*scale_factor; 

  Vector tuioObjectList = tuioClient.getTuioObjects();
  int message = tuioObjectList.size(); //get the total number of TUIO objects
  //println(message);
  //myPort.write(message); //write the total number of TUINO objects


  for (int i=0;i<message;i++) {
    TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);
    stroke(0);
    fill(#5B537E);

    long x = width - tobj.getScreenX(width); //"width" get the width of the window
    long y = tobj.getScreenY(height);
    float x_Disp = reX(x); //these are the position for drawbot to use
    float y_Disp = reY(y);     
    
    //print(i); //loop number
    //println(" Hi");
    
    //part generate G-Code for drawbot
    if (tobj.getSymbolID() == 1) { //if drawing      
      Ggenerator(x_Disp, y_Disp, 0); //generate new target position for drawbot
    }
    else if (tobj.getSymbolID() == 2) { //save the drawed G-Code
      GSaver();
    }
    else if (tobj.getSymbolID() == 3) { //Gondel go back to (0,0)
      GoHome();
    }
    else {
      Ggenerator(x_Disp, y_Disp, 5); //Z axis 5 is put up the pen
    }
    //from here, draw the shape on screen.
    pushMatrix();
    translate(x, y);
    //rotate(tobj.getAngle()); //trace the rotation of the thing
    rectMode(CENTER);
    rect(0, 0, 50, 50);    
    fill(255);
    textAlign(CENTER);
    text(""+tobj.getSymbolID(), 0, 5);    
    popMatrix();       
  }

  print("cmdLine:");     print(cmdLine);
  print(" bufferNum:");  print(bufferNum);
  print(" GEnder():");   print(GEnder());
  print(" linie:");      println(linie);

  ParseEcho(); //handle the communication between drawbot and computer

  myPort.clear(); //equal to arduino "Serial.flush()"
}

//////////////////////////////
//METHOD//////////////////////
//////////////////////////////

//Generate G-Code and write to the G.txt file waiting to be sent
void Ggenerator(float x, float y, float z) {
  G[linie++] = "G0 X" + x + " Y" + y + " Z" + z + ";"; //zB.: G0 X1.0 Y4.32 Z234;
  //println(G[linie-1]);
}

//Save drawned picture
void GSaver() {
  saveStrings("G.txt", G);
}

//let Gondol Go home
void GoHome() {Ggenerator(0,0,5);} //pen up + go home.

//send G-Code to drawbot
void sendG(String cmd) {  
  myPort.write(cmd);
  print("send cmd now: ");
  println(cmd);
}

//figure out how many guiltig G-Code in command array 'G'
//Because in the acual programm in the G array the guiltige elements number are changing
long GEnder() {
  for (int i=0; i<=10000; i++) {//'int' in processing is 32bit, can be as large to 2147483647
    if (G[i] == null) { //and the data type in "[]" must be int
      //print("the first null line at ");    
      //println(i);
      return i; //return the line number (started from 0) and from here break
    }
  }
  //println("there is no line in G array is still empty");
  return 10000; //if all the element in array G are not null, the array overflowed
}

//Parse the echo from drawbot
//if got the "> " from ChipKIT send the next line of G-Code
void ParseEcho() {
  if (myPort.available() > 0) {
    String inBuffer = myPort.readString();
    data = split(inBuffer, '\n'); //save the serial info. in lines
    println(data);
    
    for (int i=0; i<data.length; i++) {
      //println("data output: " + data[i]);
      //if (data[i].indexOf("> ") == 0) { //the "data[i].equals("> ") == true" won't work
      if (data[i].indexOf(">") == 0) { //the "data[i].equals("> ") == true" won't work
        data[i] = "0"; //reset a used "> " in command + waiting new reaction come.
        //echoFlag = 1;
        bufferNum--; //when got one line "> " means ONE line G-code excuted
        break; //if got any line of correct G-Code, jump out the for loop
      }
      //else {echoFlag = 0;} //only when in this loop got "> " than let it go into acutal GDecider()
    }
    
    println("ParseEcho here");
    
  }
  GDecider(); //decide if to send new command to the drawbot    
}

//decide if in this loop send G-Code, and if the send G-Code is guilty
void GDecider() {
  //while (bufferNum < 2 && echoFlag == 1) { //if buffer is less than 2 command in Arduino
  if(bufferNum < 2) { //if buffer is less than 2 command in Arduino
    if(cmdLine < GEnder()-1){ //sent G-code line should one line smaller than the first empty line of G
      sendG(G[cmdLine]); //send acual line of G-code
      cmdLine++; //store the sent G-code number        
      bufferNum++; //store the total in arduino buffered command
      //println("Send cmd");
    }
  }
}

//remap the position from the 1280 x 720px window on computer to 110 x 70cm paper
//Coordinate system of processing window up left point is the origin
//Coordinate system of drawbot is in the center of the papaer
float reX(long x){
  //float mid= x - width; //let the coordinate system go to middle
  float mid = map(x, 0, width, -500,500);//mid,width unit: px, 500 unit: mm
  return mid;
}
float reY(long y){
  float mid = map(y,0,height,300.0,-300.0); //original Y axis on processing towards down
  return mid;
}




// these callback methods are called whenever a TUIO event occurs
/*
// called when an object is added to the scene
 void addTuioObject(TuioObject tobj) {
 println("add object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
 }
 
 // called when an object is removed from the scene
 void removeTuioObject(TuioObject tobj) {
 println("remove object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
 }
 
 // called when an object is moved
 void updateTuioObject (TuioObject tobj) {
 println("update object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
 +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
 }
 
 // called when a cursor is added to the scene
 void addTuioCursor(TuioCursor tcur) {
 println("add cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
 }
 
 // called when a cursor is moved
 void updateTuioCursor (TuioCursor tcur) {
 println("update cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
 +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
 }
 
 // called when a cursor is removed from the scene
 void removeTuioCursor(TuioCursor tcur) {
 println("remove cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
 }
 
 // called after each message bundle
 // representing the end of an image frame
 void refresh(TuioTime bundleTime) { 
 redraw();
 }
 */
