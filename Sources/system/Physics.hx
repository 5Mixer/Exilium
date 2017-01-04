package system;

import component.Collisions.RectangleCollisionShape;
import kha.math.Vector2;

class Physics extends System {
	var view:eskimo.views.View;
	var colliders:eskimo.views.View;
	public function new (entities:eskimo.EntityManager){
		super();
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Transformation, component.Physics]),entities);
		colliders = new eskimo.views.View(new eskimo.filters.Filter([component.Transformation, component.Collisions]),entities);
	}

	override public function onUpdate (delta:Float){
		super.onUpdate(delta);

		for (entity in view.entities){
			var transformation = entity.get(component.Transformation);
			var physics = entity.get(component.Physics);
			var collider = entity.get(component.Collisions);

			
			physics.velocity = physics.velocity.mult(physics.friction);

			if (collider == null){
				transformation.pos.x += physics.velocity.x;
				transformation.pos.y += physics.velocity.y;

			}else{
				var newCollider = cast (collider.collisionRegions[0],component.Collisions.RectangleCollisionShape).offset(new Vector2(transformation.pos.x+physics.velocity.x,transformation.pos.y));
		
				var collides = false;
				for (otherCollider in colliders.entities){
					if (otherCollider == entity) continue;
					if (otherCollider.get(component.Collisions).doesShapeCollide(newCollider)){
						collides = true;
						break;
					
					}
				}
				if (!collides)
					transformation.pos.x += physics.velocity.x;


				var newCollider = cast (collider.collisionRegions[0],component.Collisions.RectangleCollisionShape).offset(new Vector2(transformation.pos.x,transformation.pos.y+physics.velocity.y));
		
				var collides = false;
				for (otherCollider in colliders.entities){
					if (otherCollider == entity) continue;
					if (otherCollider.get(component.Collisions).doesShapeCollide(newCollider)){
						collides = true;
						//pos.x = Math.round(pos.x/8)*8;
						break;
					
					}
				}
				if (!collides)
					transformation.pos.y += physics.velocity.y;
					
			}
		}
	}
}