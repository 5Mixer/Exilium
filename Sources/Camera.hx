package ;

class Camera {
	public var rotation = 0;
	public var pos:kha.math.Vector2;
	public var offset:kha.math.Vector2; //For screenshake etc.
	public var offsetRestore:Float = .3; //Smaller is faster.
	public var scale = {x : 4.0, y : 4.0};
	public function new (){
		pos = new kha.math.Vector2(-kha.System.windowWidth()/2,-kha.System.windowHeight()/2);
		offset = new kha.math.Vector2();
	}
	public function transform (g:kha.graphics2.Graphics) {
		g.pushTransformation(g.transformation);
		
		g.transformation._00 = scale.x;
		g.transformation._11 = scale.y;

		g.translate(-pos.x*scale.x,-pos.y*scale.y);
		g.rotate(rotation * (Math.PI/180),kha.System.windowWidth(0)/2,kha.System.windowHeight(0)/2);
		g.translate(pos.x*scale.x,pos.y*scale.y);

		g.translate(Math.round(-offset.x),Math.round(-offset.y));
		g.translate(Math.round(-pos.x*scale.x),Math.round(-pos.y*scale.y));

		offset = offset.mult(offsetRestore);
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
		return new kha.math.Vector2(world.x*4-pos.x*4,world.y*4-pos.y*4);
	}
	//Remember, this might screw up if called inside camera.transform and restore.
	public function screenToWorld (screen:kha.math.Vector2){
		return new kha.math.Vector2(pos.x+(screen.x/4),pos.y+(screen.y/4));
	}
}