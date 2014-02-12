
public class Point3D {
	float x, y, z;
	
	public Point3D(float xx,float yy,float zz) {
		set(xx,yy,zz);
	}
	public Point3D(double xx,double yy,double zz) {
		set((float)xx,(float)yy,(float)zz);
	}
	
	public void set(float xx,float yy,float zz) {
		x=xx;
		y=yy;
		z=zz;
	}
}

/**
 * This file is part of DrawbotGUI.
 *
 * DrawbotGUI is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * DrawbotGUI is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */