package system;

import kha.math.Vector2;

class Physics extends System {
	var view:eskimo.views.View;
	var colliders:eskimo.views.View;
	public var grid:util.SpatialHash;
	var entities:eskimo.EntityManager;
	public function new (entities:eskimo.EntityManager,broadPhaseGrid:util.SpatialHash){
		super();
		this.entities = entities;
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

							onCollision(shape,otherShape);
							onCollision(otherShape,shape);
								
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

							onCollision(shape,otherShape);
							onCollision(otherShape,shape);

							break;
						}
					}
				}
				
			
					
			}
		}
	}
	function onCollision(shape:component.Collisions.Rect,otherShape:component.Collisions.Rect){
		var shapeEntity = shape.ofEntity;
		var otherShapeEntity = otherShape.ofEntity;
		if (shapeEntity.has(component.ReleaseOnCollision)){
			var roc = shapeEntity.get(component.ReleaseOnCollision);
			for (releaseGroup in roc.collisionGroups){
				if (otherShape.group.indexOf(releaseGroup) != -1){
					var i = 10+Math.floor(Math.random()*5);
					for (i in 0...i){
						var gold = entities.create();
						gold.set(new component.Name("Gold"));
						gold.set(new component.Transformation(shapeEntity.get(component.Transformation).pos.mult(1)));
						gold.set(new component.Sprite(Project.spriteData.entity.gold));
						gold.set(new component.TimedLife(5+Math.random()*3));
						gold.set(new component.Physics().setVelocity(new kha.math.Vector2(-6+Math.random()*12,-6+Math.random()*12)));
						gold.set(new component.Collisions([]).registerCollisionRegion(new component.Collisions.Rect(0,0,8,8)));
						gold.set(new component.Collectable([component.Collisions.CollisionGroup.Friendly],[1]));
					}

					if (shapeEntity.has(component.AnimatedSprite))
						shapeEntity.get(component.AnimatedSprite).playAnimation("open","emptied");

					if (roc.once)
						shapeEntity.remove(component.ReleaseOnCollision);

					break;
				}
			}
		}
		if (shapeEntity.has(component.DieOnCollision)){
			for (killingGroup in shapeEntity.get(component.DieOnCollision).collisionGroups){
				if (otherShape.group.indexOf(killingGroup) != -1){
					shapeEntity.destroy();
					break;
				}
			}
		}
		if (shapeEntity.has(component.Collectable)){
			if (otherShapeEntity.has(component.Inventory)){
				for (group in shapeEntity.get(component.Collectable).collisionGroups){
					if (otherShape.group.indexOf(group) != -1){
						otherShapeEntity.get(component.Inventory).items = otherShapeEntity.get(component.Inventory).items.concat(shapeEntity.get(component.Collectable).items);
					
						shapeEntity.destroy();
						break;
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