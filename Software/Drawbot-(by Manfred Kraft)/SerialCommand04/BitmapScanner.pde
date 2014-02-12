
class BitmapScanner {

    private PImage         img;
    private int            imgW;
    private int            imgH;
    private CommandList    cl;

    BitmapScanner( CommandList commandList, String fileName ) {
        img    = loadImage( fileName );
        imgW   = img.width;
        imgH   = img.height;
        cl     = commandList;
    }


    void crossCircle( float cx, float cy, float r, int numSteps ) {

        boolean first    = true;

        cl.moveTo( cx+r, cy);
        for ( int i = 0; i<=numSteps; i++ ) {
            float a    = float(i) / numSteps * TWO_PI;
            float x    = cx + r * cos( a );
            float y    = cy + r * sin( a );

            color c    = img.get( int(x), int(y) );
            int   v    = (int)brightness( c );
            boolean down       = ( v < 128 );
            if ( down ) {
                cl.lineTo( x, y);
            } 
            else {
                cl.moveTo( x, y);
            }
        }
    }

    void crossLine( float x1, float y1, float x2, float y2, int numSteps ) {
        boolean last     = false;

        float xa    = x1*imgW;
        float ya    = y1*imgH;
        float xb    = x2*imgW;
        float yb    = y2*imgH;

        float dx    = xb-xa;
        float dy    = yb-ya;
        float sx    = dx / numSteps;
        float sy    = dy / numSteps;

        cl.moveTo( xa, ya);

        for ( int i = 0; i<numSteps; i++) {
            int x    = int( xa+i*sx );
            int y    = int( ya+i*sy );
            color c    = img.get( x, y );
            int   v    = (int)brightness( c );
            boolean down       = ( v < 128 );
            if ( down != last  ) {
                if ( down ) {
                    cl.moveTo( x, y);
                } 
                else {
                    cl.lineTo( x, y);
                }
                last  = down;
            }
        }
    }


    void scanBitmap( int offs) {
        boolean dirRight = false;
        boolean down     = false;
        boolean last     = false;

        for ( int y = 0; y < img.height; y+= offs ) {
            dirRight     =! dirRight;
            down         = false;
            last         = false;
            for ( int cx = 0; cx <img.width; cx++ ) {
                int   x    = dirRight ? cx : (img.width-cx-1);
                color c    = dirRight ? img.get( x, y ) : img.get( x-1, y );
                int   v    = (int)brightness( c );
                down       = ( v < 128 );

                if ( down != last  ) {
                    if ( down ) {
                        cl.moveTo( x, y );
                    } 
                    else {
                        cl.lineTo( x, y );
                    }
                    last  = down;
                }
            }
        }
    }

    void spiral( float cx, float cy, float r, float numTurns ) {
        //cl.moveTo( cx, cy);
        int     numSteps    = 90;
        float   rad1        = 0;
        int     totalSteps  = int( numSteps*numTurns);
        float   inc         = r / totalSteps;

        for ( int i = 0; i<=totalSteps; i++ ) {
            float a    = float(i) / numSteps * TWO_PI;
            float x    = cx + rad1 * cos( a );
            float y    = cy + rad1 * sin( a );

            cl.lineTo( x, y);
            rad1    += inc;
        }
    }

    void spirals( int numXSteps, int numYSteps, float maxSize, float numTurns) {
        int     stepXSize = width / numXSteps;
        int     stepYSize = height / numYSteps;
        float   spiralSize    = 0;
        boolean dirRight = false;

        for ( int y = 0; y < img.height; y+= stepYSize ) {
            dirRight     =! dirRight;
            //cl.moveTo( 0, y);

            for ( int cx = 0; cx <img.width; cx+= stepXSize ) {
                int   x    = dirRight ? cx : (img.width-cx-1);
                color c    = dirRight ? img.get( x, y ) : img.get( x-1, y );
                int   v    = (int)brightness( c );
                spiralSize    = int(maxSize * (255 - v) / 255);
                spiralSize    = (spiralSize<5) ? 0: spiralSize;
                cl.moveTo( x, y);
                //if ( spiralSize > 0) {
                spiral( x, y, spiralSize, numTurns * spiralSize / 10  );
                //}
            }
        }
    }

    void waves( int offs) {

        boolean dirRight = false;
        float maxSize    = 4;

        for ( int y = 0; y < img.height; y+= offs ) {
            dirRight     =! dirRight;
            for ( int cx = 0; cx <img.width; cx++ ) {
                int   x    = dirRight ? cx : (img.width-cx-1);
                color c    = dirRight ? img.get( x, y ) : img.get( x-1, y );
                int   v    = (int)brightness( c );
                float   a    = maxSize * (255 - v) / 255;
                //a    = (a<2) ? 0: a;
                float amp    = sin( 0.9 * cx * a) * a;
                if ( a > 0 ) {
                    cl.lineTo( x, y + amp );
                } 
                else {
                    cl.lineTo( x, y + amp );
                }
            }
        }
    }
    
    
            float x1    = (random( 1));
            float x2    = (random( 1));
            float y1    = (random( 1));
            float y2    = (random( 1));

    void testLines() {
        for ( int i = 0; i<1000; i++ ) {
            x2    = (random( 1));
            y2    = (random( 1));
            crossLine(x1, y1, x2, y2, 200);
            x1    = x2;
            y1    = y2;
        }
    }

    void testCircles( int numCircles, int numSegments ) {
        for ( int i = 0; i<numCircles; i++ ) {
            crossCircle( img.width/2, img.height/2, i*(img.width/2) / numCircles, numSegments );
        }
    }
}

