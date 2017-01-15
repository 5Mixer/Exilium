package util;
import kha.graphics2.Graphics;

class KhaShapeDrawer extends differ.ShapeDrawer{

	var g:Graphics;

	public function SetGraphics(g2:Graphics) : Void {
		g = g2;
	}

	public override function drawLine( p0x:Float, p0y:Float, p1x:Float, p1y:Float, ?startPoint:Bool = true ) {
		g.drawLine(p0x,p0y,p1x,p1y,.25);
    }

}