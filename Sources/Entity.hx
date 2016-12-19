package ;

class Entity implements component.Collisions.CollisionShape implements component.Collisions.RectangleCollider {
	public var components = new ComponentList();
	public var pos:kha.math.Vector2 = new kha.math.Vector2();
	public var size:kha.math.Vector2 = new kha.math.Vector2(8,8);
	public function new (){
		
	}
	public function draw (g){
		components.callEvent("draw",g);
		components.draw(g);
	}
	public function update (delta:Float) {
		components.callEvent("update",delta);
		components.update(delta);
	}
}