/* This code is a not finished G-Code sender which compatible with
 * project Makelangelo's Arduino firmware. It's planned to control
 * Drawbot like a typrecorder. If I write text, the drawbot should
 * write them down.
 *
 * Stop working on it. : (
 *
 * data: 2014-1-4
 * Written by Gfast
 */

//Do text parse
import processing.serial.*;
import controlP5.*;

Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port

long lineLen; //the database array "lines"'s length

//define font
PFont f;

String[] lines; // 

ControlP5 cp5;
Accordion accordion;
Accordion accordionR; //acoordion on right including console and Text editor

int state = 0; //'0'-stop, '1'-play, '2'-pause

String[] data; //save serial output data according line diff in array
String[] LetterG; //store the G-Code commands for a letter to be print parsed from the total .txt database

///////////////////////////////////////////////////////
//SETUP
///////////////////////////////////////////////////////
void setup() 
{
  size(800, 400);
  frameRate(10);
  //println(Serial.list()); //Available serial ports
  String portName = Serial.list()[2]; //third one
  myPort = new Serial(this, portName, 57600);
  
  f = createFont("Arial", 16, true);
  
  lines = loadStrings("Jackson.Part1 [Profile1].ngc"); //load font G-Code data base, lines is the array save string from "H72.txt".each element is one line in .txt
  //println("There are " + lines.length + " lines.");
  /*
  for(int i = 0; i < lines.length; ++i){
    //println(lines[i]);
    sendG(lines[i]);
  }*/
  
  lineLen = lines.length;
  
  gui();
}

///////////////////////////////////////////////////////
//MAIN
///////////////////////////////////////////////////////
void draw()
{
  background(200);             // Set background to white
  
  if ( myPort.available() > 0) {  // If data is available,
    String inBuffer = myPort.readString();
    data = split(inBuffer,'\n'); //save the serial info. in lines
    for(int i=0; i<data.length; i++){
      println(data[i]);
    }
  }
  
  switch(state){
    case 0: //stop
      //println("stop state");
      break;
    case 1: //play
      serialCoord();
      //println("play state");
      break;
    case 2: //pause
      //println("pause state");
      break;
    
  }
  //println("main loop");
  /*
  textFont(f,12);
  fill(0);
  for (int i=0; i<lines.length; i++){
    text(lines[i], 450, 14 + i*14);
  }
  */
  //println("playFlag: " + playFlag);
}

///////////////////////////////////////////////////////
//METHODE
///////////////////////////////////////////////////////
/* after add accordion, this part shold not add.
public void controlEvent(ControlEvent theEvent) {
  println(theEvent.getController().getName());
  //n = 0;
}
*/

int bufferNum = 0; //How many cmd in Arduino (executing + buffering) now
int cmdLine = 0; //Which com line is been sent.
int echoFlag = 0; //mark if go the command executed flag
int playFlag = 0; //flag if in play section, '0'-not, '1'-playing
//handel the Serial buffer and stream the G-Code through Serial port
void serialCoord(){
  playFlag = 1; 
  for(int i=0; i<data.length; i++){
    //println("data output: " + data[i]);
    if(data[i].indexOf(">") == 0) { //the "data[i].equals("> ") == true" won't work
      data[i] = "0"; //reset a used "> " in command + waiting new reaction come.
      echoFlag = 1;
      bufferNum--;
      break;
    }
    else { echoFlag = 0;}   
  }
  
  //println(echoFlag);    

  while(bufferNum < 2 && echoFlag == 1){ //if buffer is less than 2 command in Arduino
    if(cmdLine >= lineLen) {
      cmdLine = 0; //setback Line number
      state = 0; //jump to stop state
      playFlag = 0;
      println("Jump back to stop");
      break;
    }
    else if (cmdLine < lineLen) {
      sendG(lines[cmdLine]); //send G-Code + print Comand on console
      cmdLine++;
      bufferNum++;
    }
  }
}

//send parsed G-Code with a ';'
void sendG(String cmd){
  String toSend = cmd + ';';
  println("sent: " + toSend);
  myPort.write(toSend);
}

//find to print letter's G-Code snippet from database and save it to String LetterG[]
void getLetterG(String cmd){
  String head = '(' + cmd + ')'; //"(A)" stands for the start line of charactor 'A'
  for(int i=0; i<lineLen; i++){ //find the start line of the charactor indicator. 
    if(head == lines[i]){
      int j = i; //get the start line number
      for(;j<lineLen;j++){
        LetterG[j-i] = lines[j]; //LetterG store tobe print letter's G-Code from its first element
        if(lines[j] == "M30") break; //LetterG won't get "M30" as the last letter
      }
      break;
    }    
  }
}

//parse Z axis info from G-Code
void parseG_Z(String cmd){}
