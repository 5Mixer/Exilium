package ;

class Entity {
	public var components = new ComponentList();
	public var pos:kha.math.Vector2 = new kha.math.Vector2();
	public var size:kha.math.Vector2 = new kha.math.Vector2(8,8);
	public var events:EventManager = new EventManager();
	public function new (){
		
	}
	public function draw (g){
		events.callEvent("draw",g);
	}
	public function update (delta:Float) {
		events.callEvent("update",delta);
	}
}