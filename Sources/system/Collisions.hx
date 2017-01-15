package system;

class Collisions extends System {
	var view:eskimo.views.View;
	public var grid:util.SpatialHash;
	override public function new (entities:eskimo.EntityManager){
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Collisions]));
		grid = new util.SpatialHash(new kha.math.Vector2(), new kha.math.Vector2(100*16,100*16),16);
		super();
	}
	override public function onUpdate (delta:Float){
		grid = new util.SpatialHash(new kha.math.Vector2(), new kha.math.Vector2(100*16,100*16),16);
		for (entity in view.entities){
			var collisions = entity.get(component.Collisions);
			for (collider in collisions.collisionRegions){
				grid.addCollider(collider);
			}
		}
	}
}