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
	public function fireRay(ray:differ.shapes.Ray,ignoreGroups:Array<component.Collisions.CollisionGroup>){
		var l = 1.0;
		var minx = Math.min(ray.start.x,ray.end.x);
		var maxx = Math.max(ray.start.x,ray.end.x);
		var miny = Math.min(ray.start.y,ray.end.y);
		var maxy = Math.max(ray.start.y,ray.end.y);
		var possibles = grid.query(minx,miny,maxx,maxy);

		for (collider in possibles){
			var valid = true;
			for (group in collider.group)
				if (ignoreGroups.indexOf(group) != -1)
					valid = false;
			if (valid){
				var r = differ.Collision.rayWithShape(ray,differ.shapes.Polygon.rectangle(collider.x,collider.y,collider.width,collider.height,false));
				if (r != null)
					l = Math.min(r.start,l);
			}
		}
		return l;
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