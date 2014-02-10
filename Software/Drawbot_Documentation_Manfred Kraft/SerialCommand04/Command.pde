
class Command {
    float   x, y;
    char    mode;
    
    Command( String mode, float x, float y ) {
        this.x     = x;
        this.y     = y;
        this.mode  = mode.charAt(0);
    }
    
    String toString() {
        //return "" + mode + "," + round(x*280.0) + "," + round(280.0*y);
        return "" + mode + "," + round(x) + "," + round(y);
    }
}
