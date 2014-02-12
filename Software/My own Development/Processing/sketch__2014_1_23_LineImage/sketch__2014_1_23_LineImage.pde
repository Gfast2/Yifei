/* Converse a white&black image into Tilt line style
 * Please Mode your .img, .jpg, .png file into grayscale mode and 
 * make sure the black part is 100% black (if not this code won't
 * works). Save the file and drag it into "data" folder here. 
 * Change the size() function parameter to meet the need of the 
 * new images. And change the loadImage() file name to the name 
 * of your new images. Run code and you will get the .svg file in
 * this code's sketch folder.
 *
 * That's it! Have fun!
 *
 * data: 2014-1-23
 * written by Gfast
 */

import org.philhosoft.p8g.svg.P8gGraphicsSVG;

int itX, itY;
int imgH,imgW;

void setup() {
  //size(555, 540);
  size(6496, 4134);
  //PImage img = loadImage("skull2.png");
  PImage img = loadImage("Zebra.png");
  image(img, 0, 0);
  imgH = img.height;
  imgW = img.width;

  stroke(255);
  fill(255);

  beginRecord(P8gGraphicsSVG.SVG, "Zebra.svg");


  for (int i=0; i<imgW; i=i+10) {
    for (int j=0; j<imgH; j=j+10) {
      int bright = int(brightness(get(i, j)));
      itX=i; 
      itY=j;

      if (bright == 0) {
        recursive(itX, itY);
      }
    }
  }
  
  /*
  for (int i=0; i<img.width; i=i+5) {
    for (int j=0; j<img.height; j=j+5) {
      line(i,j,i+5,j);   
      line(i,j,i,j+5);
    }
  }
  */
  
  
  println("OK");
    endRecord();

}

int recursive(int x, int y) {
  if (x >= imgW || y >= imgH) {
    return 0;
  } 
  else if (int(brightness(get(x+1, y+1))) > 0) {
    print(x);
    print(" ");
    println(y);
    line(itX, itY, x, y);
    return 1;
  }
  else {
    return recursive(x+2, y+2); //the 45 grad right down direction lines.
  }
}

void loop() {
  background(255);
}

