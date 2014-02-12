/* This is a very basic code snippet to try the communication
 * between Drawbot and Arduino
 * When computer got a '>', it through two lines of G-Code.
 * And the G-Code let drawbot draw a circle
 *
 * Data: 2013-12-29
 * Written by Gfast
 */

import processing.serial.*;

Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port
int time = 1;
int counter = 0;

void setup() 
{
  size(200, 200);
  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  println(Serial.list());
  String portName = Serial.list()[2]; //third one
  myPort = new Serial(this, portName, 57600);
}


void draw()
{

  if ( myPort.available() > 0) {  // If data is available,
    val = myPort.read();         // read it and store it in val
    //println(val);
    if (val == 62) { // '>'
      ++time;
      print("time now:");
      println(time);
      if (time > 1) {
        myPort.write("G02 X0 Y-200 I0 J-100;G02 X0 Y0 I0 J100;"); //the first and second half
        time = 0;
        ++counter;
        print("total loop time: ");
        println(counter);
        print("Command send, time reset:");
        println(time);
      }
    }
  }
  background(255);             // Set background to white
  if (val == 0) {              // If the serial value is 0,
    fill(0);                   // set fill to black
  } 
  else {                       // If the serial value is not 0,
    fill(204);                 // set fill to light gray
  }
  rect(50, 50, 100, 100);
}


