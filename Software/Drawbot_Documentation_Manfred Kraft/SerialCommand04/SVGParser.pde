import geomerative.*;

RShape grp;
RPoint[][] pointPaths;
float lastX    = 0;
float lastY    = 0;


void parseSVG( CommandList cl, String filename) {

    RG.init(this);
    RG.ignoreStyles(true);
    RG.setPolygonizer(RG.ADAPTATIVE);
    //RG.setPolygonizerAngle(0.01);

    grp = RG.loadShape(filename);
    grp.centerIn(g, 100, 1, 1);

    pointPaths = grp.getPointsInPaths();
    for (int i = 0; i<pointPaths.length; i++) {

        cl.moveTo( pointPaths[i][0].x, pointPaths[i][0].y );

        if (pointPaths[i] != null) {
            for (int j = 0; j<pointPaths[i].length; j++) {
                cl.lineTo( pointPaths[i][j].x, pointPaths[i][j].y );
            }
        }
    }
}

