
import java.awt.font.FontRenderContext;
import java.awt.font.GlyphVector;
import java.awt.geom.Point2D;
import java.awt.geom.PathIterator;
import java.awt.Shape;
import java.awt.Graphics2D;
import java.awt.Font;

class FontIterator {
    Font               font;
    Graphics2D         g2d;
    FontRenderContext  frc;

    FontIterator() {
        this("", 12);
    }

    FontIterator(String fontName, int fontSize) {
        g2d = ((PGraphicsJava2D)g).g2;

        frc = g2d.getFontRenderContext();
        loadFont(fontName, fontSize);
    }

    void loadFont(String name, int size) {
        font = new Font(name, Font.PLAIN, size);
    }


    void convert(CommandList cl, String text) {
        if (font==null) return;

        float x=0, y=0, cx=0, cy=0, mx=0, my=0;
        float [] seg    = new float[6];
        GlyphVector gv  = font.createGlyphVector(frc, text);
        Shape glyph     = gv.getOutline(0, 0);
        PathIterator pi = glyph.getPathIterator(null);

        while (!pi.isDone ()) {
            int segtype = pi.currentSegment(seg);
            int mode    = 0;
            switch(segtype) { 
            case PathIterator.SEG_MOVETO:
                x = mx = seg[0];
                y = my = seg[1];
                cl.moveTo( x, y );
                break;
            case PathIterator.SEG_LINETO:
                x = seg[0];
                y = seg[1];
                cl.lineTo( x, y );
                break;
            case PathIterator.SEG_QUADTO:
                float px    = x;
                float py    = y;
                // quadratische nach kubische Bezier wandeln
                x = seg[2];
                y = seg[3];
                cx= seg[0];
                cy= seg[1];
                float cx1    = px + (cx-px)*2/3;
                float cy1    = py + (cy-py)*2/3;
                float cx2    = x  + (cx-x )*2/3;
                float cy2    = y  + (cy-y )*2/3;
                // durch Bezier iterieren
                int steps    = 8;
                for ( int i=0; i<=steps; i++) {
                    float t  = i / float(steps);
                    float tx = bezierPoint(px, cx1, cx2, x, t);
                    float ty = bezierPoint(py, cy1, cy2, y, t);
                    cl.lineTo( tx, ty );
                }
                break;
            case PathIterator.SEG_CUBICTO:
                // toDo: cubic bezier implementieren
                cl.lineTo( seg[0], seg[1] );
                break;
            case PathIterator.SEG_CLOSE:
                x = mx;
                y = my;
                cl.lineTo( x, y );
                break;
            } 
            pi.next();
        } 
    }
}

