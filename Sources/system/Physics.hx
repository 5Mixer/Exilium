package system;

import kha.math.Vector2;

class Physics extends System {
	var view:eskimo.views.View;
	var colliders:eskimo.views.View;
	public var grid:util.SpatialHash;
	public function new (entities:eskimo.EntityManager,broadPhaseGrid:util.SpatialHash){
		super();
		grid = broadPhaseGrid;
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
				var collision = false;
				var collidingShape:component.Collisions.Rect = null;

				transformation.pos.x += physics.velocity.x;
				for (shape in collider.collisionRegions){

					for (otherShape in grid.findContacts(shape)){
						if (!validCollision(shape,otherShape)) continue;
						if (!otherShape.ofEntity.has(component.Transformation)) continue;

						var otherTransform = otherShape.ofEntity.get(component.Transformation).pos;

						var c = differ.Collision.shapeWithShape(
							differ.shapes.Polygon.rectangle(shape.x+transformation.pos.x,shape.y+transformation.pos.y,shape.width,shape.height,false),
							differ.shapes.Polygon.rectangle(otherShape.x+otherTransform.x,otherShape.y+otherTransform.y,otherShape.width,otherShape.height,false));
						
						if (c != null && c.separationX != 0){
							collision = true;
							collidingShape = otherShape;
							transformation.pos.x += c.separationX;

							if (collidingShape.ofEntity.has(component.DieOnCollision))
								for (group in shape.group)
									if (collidingShape.ofEntity.get(component.DieOnCollision).collisionGroups.indexOf(group) != -1){
										collidingShape.ofEntity.destroy();
										break;
									}
								
							break;
						}
					}
				}

				transformation.pos.y += physics.velocity.y;
				
				for (shape in collider.collisionRegions){
					for (otherShape in grid.findContacts(shape)){
						
						if (!validCollision(shape,otherShape)) continue;
						if (!otherShape.ofEntity.has(component.Transformation)) continue;
						var otherTransform = otherShape.ofEntity.get(component.Transformation).pos;
						var c = differ.Collision.shapeWithShape(
							differ.shapes.Polygon.rectangle(shape.x+transformation.pos.x,shape.y+transformation.pos.y,shape.width,shape.height,false),
							differ.shapes.Polygon.rectangle(otherShape.x+otherTransform.x,otherShape.y+otherTransform.y,otherShape.width,otherShape.height,false));
						
						if (c != null && c.separationY != 0){
							collision = true;
							collidingShape = otherShape;
							transformation.pos.y += c.separationY;

							if (collidingShape.ofEntity.has(component.DieOnCollision))
								for (group in shape.group)
									if (collidingShape.ofEntity.get(component.DieOnCollision).collisionGroups.indexOf(group) != -1){
										collidingShape.ofEntity.destroy();
										break;
									}

							break;
						}
					}
				}
				
				if (collision){
					if (entity.has(component.DieOnCollision)){
						for (killingGroup in entity.get(component.DieOnCollision).collisionGroups){
							if (collidingShape.group.indexOf(killingGroup) != -1){
								entity.destroy();
								break;
							}
						}
					}
				}
			
					
			}
		}
	}
	function validCollision(shape:component.Collisions.Rect,otherShape:component.Collisions.Rect){
		var valid = false;
		for (othersIgnore in otherShape.ignoreGroups){
			if (shape.group.indexOf(othersIgnore) == -1){
				//The other entity is not ignoring one of our groups, this is a valid collision.
				valid = true;
				break;
			}
		}
		if (valid){
			for (ignore in shape.ignoreGroups){
				if (otherShape.group.indexOf(ignore) != -1){
					//The other entity is not ignoring one of our groups, this is a valid collision.
					valid = false;
					break;
				}
			}
		}
		return valid;

	}
}