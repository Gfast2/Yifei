

typedef struct Command {
    char type;
    long params[2];
} 
Command;
Command command;

char input[20];
long value  = 0;
byte state  = 0;
int  ind    = 0;
int  cnt    = 0;

void readChar( int ch ) 
{
    if ( ch == 'm' || ch == 'l' || ch == 'r' || ch == 'c' || ch == 'd' || ch == 's' || ch == 'v' || ch == 'k' || ch == 'a' ) {
        command.type  = ch;
        state  = 0;
    } 
    else if ( (ch >= '0' && ch <= '9') || ch =='-' ) {
        input[ind++]  = ch;
    } 
    else  if ( ch == ';' || ch == ',' ) {
        input[ind]  = 0;
        ind = 0;
        value  = atol( input );
        if ( state == 1 || state == 2 ) {
            command.params[state-1]  = value;
        }
        state++;
        if ( ch == ';' ) {
            execute();
        }
    } 
    else {
        SerialUSB.println( "ok" ); 
    }
}

void execute() {
    long p1        = command.params[0] / msSteps;
    long p2        = command.params[1] / msSteps;

    if (command.type == 'l' ) {
        hanger.down();
        hanger.gotoXY( p1, p2, 10);
    } 
    else if (command.type == 'm' ) {
        hanger.up();
        hanger.gotoXY( p1, p2 );
    }
    else if (command.type == 'r' ) {
        hanger.up();
        hanger.gobyLR( p1, p2 );
    }
    else if (command.type == 'k' ) {
        hanger.calibrateLR( p1, p2 );
    }
    else if (command.type == 'c' ) {
        hanger.calibrateXY( p1, p2 );
    }
    else if (command.type == 'd' ) {
        hanger.gobyXY( p1, p2 );
    }
    else if (command.type == 's' ) {
        hanger.down();
        hanger.gobyLR( p1, p2 );
    }
    else if (command.type == 'v' ) {
        hanger.setVelocity( command.params[0], command.params[1] );
    }
    else if (command.type == 'a' ) {
        hanger.setAcceleration( command.params[0], command.params[1] );
    }

    hanger.debug();
    SerialUSB.println( "ok" ); 
}

void reset() {
    command.type  = ' ';
}













