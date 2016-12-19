package ;

import kha.math.FastMatrix3;

class Sprite {
	var tileset:kha.Image;
	var id:Int;
	public var angle:Int;
	public function new (tileset:kha.Image,id:Int){
		this.tileset = tileset;
		this.id = id;
	}
	public function draw (g:kha.graphics2.Graphics,x:Float,y:Float){
		var sourcePos = { x: (id%8)*8, y:Math.floor(id/8)*8 };

		//var t = g.transformation.add(kha.math.FastMatrix3.empty());
		var originX = 4;
		var originY = 4;
		g.pushTransformation(g.transformation.multmat(FastMatrix3.translation(x + originX, y + originY)).multmat(FastMatrix3.rotation(angle*(Math.PI / 180))).multmat(FastMatrix3.translation(-x - originX, -y - originY)));
		//g.rotate(angle / (Math.PI / 180),x+4,y+4);

		
		g.drawScaledSubImage(this.tileset,sourcePos.x,sourcePos.y,8,8,x,y,8,8);
		
		g.popTransformation();
		
	}
}