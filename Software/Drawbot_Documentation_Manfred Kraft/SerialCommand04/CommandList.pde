import processing.serial.*; 
import java.util.ListIterator;
import java.util.LinkedList;

class CommandList {

    LinkedList<Command>    commands;
    Serial                 serial;
    boolean                sendMode       = false;
    boolean                arduinoReady   = false;
    
        float xMin, xMax, yMin, yMax, w, h, s, xOffs, yOffs, scale;

    CommandList( Serial serial ) {
        commands       = new LinkedList<Command>();
        this.serial    = serial;
    }

    void calibrate( long x, long y ) {
        addCommand( "c", x, y );
    }

    void moveTo( float x, float y ) {
        addCommand( "m", x, y );
    }

    void lineTo( float x, float y ) {
        addCommand( "l", x, y );
    }

    void addCommand( String mode, float x, float y ) {
        commands.addLast( new Command( mode, x, y ) );
    }

    void clear() { 
        stop();
        commands.clear();
    }

    void start() {
        sendMode    = true;  
        serial.write(">");
    }

    void stop() {
        sendMode    = false;
    }

    void normalize( float tx, float ty, float size ) {

        xMin = yMin = 1000000;
        xMax = yMax = -1000000;
        
        xOffs    = tx;
        yOffs    = ty;
        scale    = size;

        ListIterator itr = commands.listIterator();
        while (itr.hasNext ())
        {
            Command cmd    = (Command)itr.next();
            xMin    = min( xMin, cmd.x );
            yMin    = min( yMin, cmd.y );
            xMax    = max( xMax, cmd.x );
            yMax    = max( yMax, cmd.y );
        }
        w    = xMax - xMin;
        h    = yMax - yMin;
        s    = max( w, h );

        itr = commands.listIterator();
        while (itr.hasNext ())
        {
            Command cmd    = (Command)itr.next();
            cmd.x   -= xMin;
            cmd.y   -= yMin;
            cmd.x   = size * cmd.x / w;
            cmd.y   = size * cmd.y / w;
            cmd.x   += tx;
            cmd.y   += ty;
        }
    }

    void read() {
        while (serial.available () > 0) {
            String myString = serial.readStringUntil('\n');
            if ( myString != null ) {
                myString = trim(myString);

                //println( myString );

                if ( myString.equals( "ok" )) {
                    //println( "OK");
                    arduinoReady    = true;
                }
            }
        }
        //if ( arduinoReady && sendMode ) {
            if ( sendMode ) {
            sendCommand();
        }
    }
    String lastOut;
    void sendCommand() {
        if ( commands.size() > 0 ) {
            Command cmd   = (Command) commands.removeFirst();
            String out    = (String) cmd.toString();
            if (cmd.mode == 'l') {
               serial.write( "v,800,600;" );
               serial.write( "v,800,3200;" );
            } else {
               serial.write( "v,900,6000;" );
               serial.write( "v,900,12000;" );
            } 
            serial.write( out );
            serial.write( ';' );
            /*
            if ( out.equals( lastOut )) {
             println( "double command" );
             } 
             else {
             serial.write( out );
             serial.write( ';' );
             }
             lastOut    = out;
             */
            //serial.write( '\n' );
            println( out);
            arduinoReady  = false;
        }
    }
}

