package ;

import kha.math.FastMatrix3;

class Sprite {
	var tileset:kha.Image;
	var id:Int;
	var tilesize = 16;
	public var angle:Int;
	public function new (tileset:kha.Image,id:Int){
		this.tileset = tileset;
		this.id = id;
	}
	public function draw (g:kha.graphics2.Graphics,x:Float,y:Float){
		
		//var t = g.transformation.add(kha.math.FastMatrix3.empty());
		var originX = 4;
		var originY = 4;
		g.pushTransformation(g.transformation.multmat(FastMatrix3.translation(x + originX, y + originY)).multmat(FastMatrix3.rotation(angle*(Math.PI / 180))).multmat(FastMatrix3.translation(-x - originX, -y - originY)));
		//g.rotate(angle / (Math.PI / 180),x+4,y+4);

		
		g.drawScaledSubImage(this.tileset,Math.floor((id%tilesize)*tilesize),Math.floor(Math.floor(id/tilesize)*tilesize),tilesize,tilesize,x,y,tilesize,tilesize);
		
		g.popTransformation();
		
	}
}