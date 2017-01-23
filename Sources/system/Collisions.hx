package system;

class Collisions extends System {
	var view:eskimo.views.View;
	public var grid:util.SpatialHash;
	public var processFixedEntities = true;
	override public function new (entities:eskimo.EntityManager){
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Collisions]),entities);
		grid = new util.SpatialHash(60*16,60*16,16);
		super();
	}
	override public function onUpdate (delta:Float){
		super.onUpdate(delta);
		grid.empty();
		
		for (entity in view.entities){
			//if (entity.get(component.Collisions).fixed && !processFixedEntities) continue;
			for (collider in entity.get(component.Collisions).collisionRegions){
				collider.ofEntity = entity;
				grid.addCollider(collider,entity.get(component.Transformation).pos);
			}
		}

		processFixedEntities = false;
	}
}