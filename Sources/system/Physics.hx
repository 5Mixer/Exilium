package system;

import component.Collisions.RectangleCollisionShape;
import kha.math.Vector2;

class Physics extends System {
	var colliders:Array<Entity>;
	public function new (colliders:Array<Entity>){
		this.colliders = colliders;
		super();
	}

	override public function update (delta:Float,entities:Array<Entity>){
		super.update(delta,entities);

		for (entity in entities){
			if (entity.components.has("transformation") && entity.components.has("physics") && entity.components.has("collider")){
				var transformation:component.Transformation = cast entity.components.get("transformation");
				var physics:component.Physics = cast entity.components.get("physics");
				var collider:component.Collisions = cast entity.components.get("collider");

				
				physics.velocity = physics.velocity.mult(.7);


				var newCollider = cast (collider.collisionRegions[0],component.Collisions.RectangleCollisionShape).offset(new Vector2(transformation.pos.x+physics.velocity.x,transformation.pos.y));
		
				var collides = false;
				for (otherCollider in entities){
					if (otherCollider == entity) continue;
					if (otherCollider.components.has("collider")){
						if (cast(otherCollider.components.get("collider"),component.Collisions).doesShapeCollide(newCollider)){
							collides = true;
							//pos.x = Math.round(pos.x/8)*8;
							break;
						}
					}
				}
				if (!collides)
					transformation.pos.x += physics.velocity.x;


				var newCollider = cast (collider.collisionRegions[0],component.Collisions.RectangleCollisionShape).offset(new Vector2(transformation.pos.x,transformation.pos.y+physics.velocity.y));
		
				var collides = false;
				for (otherCollider in entities){
					if (otherCollider == entity) continue;
					if (otherCollider.components.has("collider")){
						if (cast(otherCollider.components.get("collider"),component.Collisions).doesShapeCollide(newCollider)){
							collides = true;
							//pos.x = Math.round(pos.x/8)*8;
							break;
						}
					}
				}
				if (!collides)
					transformation.pos.y += physics.velocity.y;

			}
		}
	}
}