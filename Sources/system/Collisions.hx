package system;

class Collisions extends System {
	var view:eskimo.views.View;
	public var grid:util.SpatialHash;
	override public function new (entities:eskimo.EntityManager){
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Collisions]),entities);
		grid = new util.SpatialHash(new kha.math.Vector2(), new kha.math.Vector2(130*16,130*16),16);
		super();
	}
	override public function onUpdate (delta:Float){
		super.onUpdate(delta);
		grid.empty();
		
		for (entity in view.entities){
			var collisions = entity.get(component.Collisions);
			for (collider in collisions.collisionRegions){
				grid.addCollider(collider);
			}
		}
	}
}