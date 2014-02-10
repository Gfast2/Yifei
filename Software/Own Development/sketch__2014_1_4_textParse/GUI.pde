//------------------------------------------------
void gui() {
  cp5 = new ControlP5(this); //init button
  cp5.enableShortcuts();

  Group g4 = cp5.addGroup("Console")
                  //.setBackgroundColor(color(0, 64))
                  .setBackgroundHeight(316)
                  ;

  Textarea myTextarea = cp5.addTextarea("txt")
                  .moveTo(g4)
                  //.setPosition(450, 20)
                  .setSize(300, 316)
                  .setFont(createFont("", 10))
                  .setLineHeight(14)
                  .setColor(color(255))
                  .setColorBackground(color(0, 120))
                  .setColorForeground(color(255, 100));
                  ;

  Println console = cp5.addConsole(myTextarea);//
  
  
  Group g5 = cp5.addGroup("Schreibmaschine")
                  .setBackgroundColor(color(0, 64))
                  .setBackgroundHeight(150)
                  ;
                  
  cp5.addTextfield("input")
   .setLabelVisible(false)
   .moveTo(g5)
   .setSize(260,23)
   .setFont(f)
   .setFocus(true)
   .setColor(color(255,255,255))
   ;


  
  
  // create a new accordion
  // add g1, g2, and g3 to the accordion.
  accordionR = cp5.addAccordion("accR")
                 .setPosition(450,20)
                 .setWidth(300)
                 .addItem(g4)
                 .addItem(g5)
                 //.addItem(g3)
                 ;

  accordionR.open(1); //open which element of the right accordion 
  
  // use Accordion.MULTI to allow multiple group 
  // to be open at a time.
  accordionR.setCollapseMode(Accordion.MULTI);
  
  // group number 1, contains 2 bangs
  //  Group g1 = cp5.addGroup("myGroup1")
  Group g1 = cp5.addGroup("Manual")
                .setBackgroundColor(color(0, 64))
                .setBackgroundHeight(150)
                ;
  /*
  cp5.addBang("bang")
     .setPosition(10,20)
     .setSize(100,100)
     .moveTo(g1)
     .plugTo(this,"shuffle");
     ;
  */
  
  cp5.addButton("Y100")
     .setValue(0)
     .moveTo(g1)
     .setPosition(82,5)
     .setSize(28,19)
     ;
  cp5.addButton("Y10")
     .setValue(0)
     .moveTo(g1)
     .setPosition(84,25)
     .setSize(24,19)
     ;
  cp5.addButton("Y1")
     .setValue(0)
     .moveTo(g1)
     .setPosition(84,45)
     .setSize(24,19)
     ;
  cp5.addButton("Y_1")
     .setValue(0)
     .moveTo(g1)
     .setPosition(84,85)
     .setSize(24,19)
     ;
  cp5.addButton("Y_10")
     .setValue(0)
     .moveTo(g1)
     .setPosition(84,105)
     .setSize(24,19)
     ;
  cp5.addButton("Y_100")
     .setValue(0)
     .moveTo(g1)
     .setPosition(82,125)
     .setSize(28,19)
     ;
     
  cp5.addButton("X_100")
     .setValue(0)
     .moveTo(g1)
     .setPosition(5,65)
     .setSize(28,19)
     ;
  cp5.addButton("X_10")
     .setValue(0)
     .moveTo(g1)
     .setPosition(34,65)
     .setSize(24,19)
     ;
  cp5.addButton("X_1")
     .setValue(0)
     .moveTo(g1)
     .setPosition(59,65)
     .setSize(24,19)
     ;
  cp5.addButton("X1")
     .setValue(0)
     .moveTo(g1)
     .setPosition(109,65)
     .setSize(24,19)
     ;
  cp5.addButton("X10")
     .setValue(0)
     .moveTo(g1)
     .setPosition(134,65)
     .setSize(24,19)
     ;
  cp5.addButton("X100")
     .setValue(0)
     .moveTo(g1)
     .setPosition(159,65)
     .setSize(28,19)
     ;
  cp5.addButton("GoHOME")
     .setValue(0)
     .moveTo(g1)
     .setPosition(150,105)
     .setSize(40,40)
     ;
  cp5.addButton("SetHOME")
     .setValue(0)
     .moveTo(g1)
     .setPosition(191,105)
     .setSize(40,40)
     ;
     
  //for feed rate setting
  //Knob myKnobA = cp5.addKnob("knob")
  cp5.addKnob("feedrate")
     .moveTo(g1)
     .setRange(500,3500)
     .setValue(800)
     .setPosition(260,23)
     .setRadius(50)
     .setNumberOfTickMarks(20)
     .snapToTickMarks(true)
     .setDragDirection(Knob.VERTICAL)
     ;
   
  // group number 2, contains a radiobutton
  Group g2 = cp5.addGroup("myGroup2")
                .setBackgroundColor(color(0, 64))
                .setBackgroundHeight(150)
                ; 
  cp5.addRadioButton("radio")
     .setPosition(10,20)
     .setItemWidth(20)
     .setItemHeight(20)
     .addItem("black", 0)
     .addItem("red", 1)
     .addItem("green", 2)
     .addItem("blue", 3)
     .addItem("grey", 4)
     .setColorLabel(color(255))
     .activate(2)
     .moveTo(g2)
     ;
  cp5.addButton("Play")
     .moveTo(g2)
     .setValue(0)
     .setPosition(200,20)
     .setSize(49,40)
     ;     
  cp5.addButton("Pause")
     .moveTo(g2)
     .setValue(100)
     .setPosition(250,20)
     .setSize(49,40)
     ;     
  cp5.addButton("Stop")
     .moveTo(g2)
     .setPosition(300,20)
     .setSize(49,40)
     .setValue(0)
     ;
  cp5.addToggle("Motor_Active")
     .moveTo(g2)
     .setPosition(100,20)
     .setSize(50,20)
     .setValue(true)
     .setMode(ControlP5.SWITCH)
     //.setState(ture)
     ;
  cp5.addToggle("Pen_state")
     .moveTo(g2)
     .setPosition(100,60)
     .setSize(50,20)
     .setValue(true)
     .setMode(ControlP5.SWITCH)
     ;     

  // group number 3, contains a bang and a slider
  Group g3 = cp5.addGroup("myGroup3")
                .setBackgroundColor(color(0, 64))
                .setBackgroundHeight(150)
                ;  
  cp5.addBang("shuffle")
     .setPosition(10,20)
     .setSize(40,50)
     .moveTo(g3)
     ;     
  cp5.addSlider("hello")
     .setPosition(60,20)
     .setSize(100,20)
     .setRange(100,500)
     .setValue(100)
     .moveTo(g3)
     ;     
  cp5.addSlider("world")
     .setPosition(60,50)
     .setSize(100,20)
     .setRange(100,500)
     .setValue(200)
     .moveTo(g3)
     ;

  // create a new accordion
  // add g1, g2, and g3 to the accordion.
  accordion = cp5.addAccordion("acc")
                 .setPosition(20,20)
                 .setWidth(400)
                 .addItem(g1)
                 .addItem(g2)
                 .addItem(g3)
                 ;              
  /* 
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.open(0,1,2);}}, 'o');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.close(0,1,2);}}, 'c');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setWidth(300);}}, '1');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setPosition(0,0);accordion.setItemHeight(190);}}, '2'); 
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setCollapseMode(ControlP5.ALL);}}, '3');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setCollapseMode(ControlP5.SINGLE);}}, '4');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {cp5.remove("myGroup1");}}, '0');
  */
  accordion.open(0,1); //open number 0 and 1, close number 2 accordion
  
  // use Accordion.MULTI to allow multiple group 
  // to be open at a time.
  accordion.setCollapseMode(Accordion.MULTI);
  
  // when in SINGLE mode, only 1 accordion  
  // group can be open at a time.  
  // accordion.setCollapseMode(Accordion.SINGLE);
}

//-----------------------------------
void shuffle() {
  color c = color(random(255),random(255),random(255),random(128,255));
}
//-----------------------------------
void X100(){
  myPort.write("G0 G91 G21 F2000.0 X100;");   println("X100");}
//-----------------------------------
void X10(){
  myPort.write("G0 G91 G21 F2000.0 X10;");    println("X10");}
//-----------------------------------
void X1(){
  myPort.write("G0 G91 G21 F2000.0 X1;");     println("X1");}
//-----------------------------------
void X_1(){
  myPort.write("G0 G91 G21 F2000.0 X-1;");    println("X-1");}
//-----------------------------------
void X_10(){
  myPort.write("G0 G91 G21 F2000.0 X-10;");   println("X-10");}
//-----------------------------------
void X_100(){
  myPort.write("G0 G91 G21 F2000.0 X-100;");  println("X-100");}
//-----------------------------------
void Y100(){
  myPort.write("G0 G91 G21 F2000.0 Y100;");   println("Y100");}
//-----------------------------------
void Y10(){
  myPort.write("G0 G91 G21 F2000.0 Y10;");    println("Y10");}
//-----------------------------------
void Y1(){
  myPort.write("G0 G91 G21 F2000.0 Y1;");     println("Y1");}
//-----------------------------------
void Y_1(){
  myPort.write("G0 G91 G21 F2000.0 Y-1;");    println("Y-1");}
//-----------------------------------
void Y_10(){
  myPort.write("G0 G91 G21 F2000.0 Y-10;");   println("Y-10");
}
//-----------------------------------
void Y_100(){
  myPort.write("G0 G91 G21 F2000.0 Y-100;");  println("Y-100");}

// function colorA will receive changes from 
// controller with name colorA
public void Play(int theValue) {
  println("Play pushed");
  state = 1;
  sendG(lines[cmdLine]);
  //c1 = c2;
  //c2 = color(0,160,100);
}

// function colorB will receive changes from 
// controller with name colorB
boolean pauseFlag = false; // '0'-paused, '1' back
public void Pause(int theValue) {
  println("Pause pushed");
  if(playFlag == 1){
    pauseFlag = !pauseFlag;
    if (pauseFlag == true){ //first time pushed,
      println(pauseFlag);
      state = 2;
      //TODO: put a icon to indicate should push here again
    }
    else{
      println(pauseFlag);
      sendG(lines[cmdLine]);
      state = 1; //put it back to go on code sending
    }
    //c1 = c2;
    //c2 = color(150,0,0);
  }
}

public void Stop(int theValue) {
  println("Stop pushed");
  cmdLine = 0; //stop whole process, set reading line back
  playFlag = 0;
  println("playFlag: " + playFlag);
  state = 0;
  //c1 = c2;
  //c2 = color(150,0,0);
}

void Motor_Active(boolean theFlag) {
  if(theFlag==true) {
    //col = color(255);
    myPort.write("test 1;");
    println("MOTOR ACTIVATE");
  } else {
    //col = color(100);
    myPort.write("test 0;");
    println("MOTOR DEACTIVATE");
  }
}

void Pen_state(boolean theFlag) {
  if(theFlag==true) {
    //col = color(255);
    myPort.write("G00 G90 Z10;");
    println("Pen down");
  } else {
    //col = color(100);
    myPort.write("G00 G90 Z170;");
    println("Pen Up;");
  }
  //println("a toggle event.");
}

void GoHOME(int theValue){
  println("GoHOME pushed");
  myPort.write("G00 G90 X0 Y0;");
}

void SetHOME(int theValue){
  println("SetHOME pushed");
  myPort.write("TELEPORT X0 Y0;");
}
