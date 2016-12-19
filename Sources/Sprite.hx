package ;

class Sprite {
	var tileset:kha.Image;
	var id:Int;
	public function new (tileset:kha.Image,id:Int){
		this.tileset = tileset;
		this.id = id;
	}
	public function draw (g:kha.graphics2.Graphics,x:Float,y:Float){
		var sourcePos = { x: (8%id)*8, y:Math.floor(id/8)*8 };
		g.drawScaledSubImage(this.tileset,sourcePos.x,sourcePos.y,8,8,x,y,8,8);
		
	}
}