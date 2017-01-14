package system;

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
				transformation.pos.x += physics.velocity.x;
				if (collider.lockShapesToEntityTransform){
					for (shape in collider.collisionRegions){
						shape.position = new differ.math.Vector(transformation.pos.x,transformation.pos.y);
					}
				}

				var collision = false;
				var thingThatCollided:eskimo.Entity = null;
			
				for (otherCollider in colliders.entities){
					if (otherCollider == entity) continue;

					
					
					var c = otherCollider.get(component.Collisions).getCollisionWithCollider(collider);
					if (c != null && c.length != 0){
						for (correction in c){
							if (correction != null){
								
								if (otherCollider.has(component.DieOnCollision))
									for (groupThatKills in otherCollider.get(component.DieOnCollision).collisionGroups)
										if (collider.collisionGroups.indexOf(groupThatKills) != -1)
											otherCollider.destroy();
										
								thingThatCollided = otherCollider;

								transformation.pos.x -= correction.separationX;

								if (correction.separationX != 0){
									if (!collision) collision = true;
									break;
								}

							}
						}
					}
				}

				
				transformation.pos.y += physics.velocity.y;

				if (collider.lockShapesToEntityTransform){
					for (shape in collider.collisionRegions){
						shape.position = new differ.math.Vector(transformation.pos.x,transformation.pos.y);
					}
				}
			
				for (otherCollider in colliders.entities){
					if (otherCollider == entity) continue;

				

					var c = otherCollider.get(component.Collisions).getCollisionWithCollider(collider);
					
					if (c != null && c.length != 0){
						
						for (correction in c){
							if (correction != null){

								if (otherCollider.has(component.DieOnCollision))
									for (groupThatKills in otherCollider.get(component.DieOnCollision).collisionGroups)
										if (collider.collisionGroups.indexOf(groupThatKills) != -1)
											otherCollider.destroy();

								thingThatCollided = otherCollider;

								transformation.pos.y -= correction.separationY;
								if (correction.separationY != 0){
									if (!collision) collision = true;
									break;
								}
							}
						}
					
					}
				}

				if (collider.lockShapesToEntityTransform){
					for (shape in collider.collisionRegions){
						shape.position = new differ.math.Vector(transformation.pos.x,transformation.pos.y);
					}
				}

				if (collision){
					if (entity.has(component.DieOnCollision)){
						entity.destroy();
					}
				}
			
					
			}
		}
	}
}