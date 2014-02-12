import java.util.ListIterator;
import processing.serial.*;

CommandList     commands;
Serial          serial;
FontIterator    fontIter;
BitmapScanner   scanner;
PImage          img;
int             ps = 8;    // preview Scaling

void setup() {
    size(ps*100, ps*200, JAVA2D);
    smooth();
    background(255);
    //img         = loadImage("paul.png");
    serial      = new Serial(this, Serial.list()[0], 57600);
    commands    = new CommandList( serial );
    fontIter    = new FontIterator( "Garamond", 300 );
    scanner     = new BitmapScanner( commands, "flo.png" );
}

void draw() {
    commands.read();
}

void calibrate() {
    commands.calibrate( 0, 28000 );
}

void keyPressed() {
    background(255);
    if ( key == 'i' ) {
        //drawText();
        fontIter.convert(commands, "Lorem ipsum");
        commands.normalize( 40, 65, 60 );
        preview();
    }
    else if ( key == 'c' ) {
        calibrate();
    } 
    else if ( key == 'p' ) {
        drawImage();
        commands.normalize( 50000, 30000, 10000 );
        preview();
    } 
    else if ( key == 's' ) {
        //parseSVG(commands, "nivea.svg");
        //commands.normalize( 25, 25, 55 );
        parseSVG(commands, "robot.svg");
        println( "OK");
        commands.normalize( 15000, 10000, 60000 );
        preview();
        println("OK");
    } 
    else if ( key == 'ü' ) {
        println( "start");
        commands.start();
    }
    else {
        if (key == CODED) 
            serial.write(keyCode);
        else
            serial.write(key);
    }
}

void drawImage() {
    scanner.scanBitmap( 1 );
    //scanner.testLines();
    //scanner.testCircles(40, 200 );
    //scanner.spirals( 50, 50, 6, 4.7);
    //scanner.waves( 4 );
}

void drawText() {
    fontIter.convert(commands, "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, consetetur sadipscing elitr");
}



void drawFile( String fileName ) {
    String lines[]    = loadStrings( fileName);
    for ( int i = 0; i< lines.length; i++) {
        String parts[]    = lines[i].split(",");
        commands.addCommand(parts[0], float(parts[1]), float(parts[2]));
    }
}

void preview() {
    float x=0, y=0;
    ListIterator itr = commands.commands.listIterator();
    float ps    =  width / commands.scale;
    while (itr.hasNext ())
    {
        Command cmd    = (Command)itr.next();
        if ( cmd.mode == 'l' ) {
            line(x, y, ps*(cmd.x-commands.xOffs), ps*(cmd.y-commands.yOffs));
        }
        x    = ps*(cmd.x-commands.xOffs);
        y    = ps*(cmd.y-commands.yOffs);
    }
}


