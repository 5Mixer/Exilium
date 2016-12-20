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
	public function isWorldPointOnScreen(point:kha.math.Vector2){
		return isScreenPointOnScreen(worldToScreen(point));
	}
	public function isScreenPointOnScreen(point:kha.math.Vector2){
		return !(point.x < 0 || point.y < 0 ||
				point.x > kha.System.windowWidth() || point.y > kha.System.windowHeight());
	}
	public function worldToScreen(world:kha.math.Vector2){
		return new kha.math.Vector2(world.x*8-pos.x*8,world.y*8-pos.y*8);
	}
	//Remember, this might screw up if called inside camera.transform and restore.
	public function screenToWorld (screen:kha.math.Vector2){
		return new kha.math.Vector2(pos.x+(screen.x/8),pos.y+(screen.y/8));
	}
}