class Perlin {
    float x, y, xv = 0, yv = 0;

    Perlin() {
        this.x = x;
        this.y = y;
    }

    void draw(CommandList cl, int n) {
        noiseDetail(4, 0);
        for ( int i = 0; i<n; i++) {
            float s    = 0.04;
            float f    = 5;

            if ( x<=0 || x>1 || y <= 0 || y > 1 ) {
                x    = random(0, 1);
                y    = random(0, 1);
                cl.moveTo( x, y );
            }
            xv = s *  cos( noise(x*f, y*f)*TWO_PI  );
            yv = s * -sin( noise(x*f, y*f)*TWO_PI  );

            cl.lineTo(x+xv, y+yv );
            x += xv;
            y += yv;
        }
    }
}

