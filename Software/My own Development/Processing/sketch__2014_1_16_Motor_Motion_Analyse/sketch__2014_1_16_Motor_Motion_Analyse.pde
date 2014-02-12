/* Load a analyse data output that saved in a .txt file
 * Through the output of the motor I made a small data visualization
 * This visualization indicate that motors' movement are not coherent 
 * In other words. For this construction of the maschine, drawbot 
 * should not move to fast, in order to reduce the deviation caused
 * by inertia.
 *
 *
 * data: 2014/1/16
 * written by Gfast
 * 
 */

String[] motors; //motor motion test output (from different test, saved in diff elements)
String read; //store one test output.
int index = 0;
PFont f;

void setup() {
  size(800, 200);
  background(0);
  stroke(255);
  frameRate(5);
  motors = loadStrings("line10cm move back.txt");
  read = motors[0];
  print("Data element total: ");
  println(read.length());
  
  f = createFont("Avenir-BlackOblique", 14, false);
}

void draw() {
  while (index < read.length()) {
    char startChar = read.charAt(0); //which char string start with
    float scaler = 1.5; //used to scale the distance between each step of the motor's
    noStroke();
    textSize(14);
    textFont(f);
    text("Motor1 steps", 10, 30);
    text("Motor2 steps", 10, 80);
    text("Each line stands for one step of the Motor respectively.", 10, 150);
    text("Motor move first: ",10, 190);
    text(startChar, 130, 190);
    stroke(255);
    
    //according to the Bresenham's algorithmus that used in drawbot firmware
    //which motor start first, it will move one step in each loop, 
    //but the other one will not.
    if(read.charAt(index) == startChar){
      line (index*scaler, 40, index*scaler, 50 );
    } else {
      line (index*scaler, 40, index*scaler, 50);
      line ((index-1)*1.5 , 90,(index-1)*1.5,120);   
    }
    index = index + 1;
  }
}
