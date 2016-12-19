package ;

class Camera {
	public var rotation = 0;
	public var pos:kha.math.Vector2;
	public var scale = {x : 8.0, y : 8.0};
	public function new (){
		pos = new kha.math.Vector2(-kha.System.windowWidth()/2,-kha.System.windowHeight()/2);
	}
	public function transform (g:kha.graphics2.Graphics) {
		g.pushTransformation(g.transformation);

		
		g.transformation._00 = scale.x;
		g.transformation._11 = scale.y;

		g.translate(-pos.x*scale.x,-pos.y*scale.y);
		g.rotate(rotation * (Math.PI/180),kha.System.windowWidth(0)/2,kha.System.windowHeight(0)/2);
		g.translate(pos.x*scale.x,pos.y*scale.y);

		g.translate(Math.round(-pos.x*scale.x),Math.round(-pos.y*scale.y));
	}
	public function restore (g:kha.graphics2.Graphics) {
		g.popTransformation();
	}
}