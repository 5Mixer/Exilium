package system;

import kha.math.Vector2;

class Physics extends System {
	var view:eskimo.views.View;
	var colliders:eskimo.views.View;
	public var grid:util.SpatialHash;
	var entities:eskimo.EntityManager;
	var collisionListeners:Array<eskimo.Entity->eskimo.Entity->Void>;
	var collisionSys:system.Collisions;
	public function new (entities:eskimo.EntityManager,broadPhaseGrid:util.SpatialHash,collisionSys:system.Collisions){
		super();
		this.entities = entities;
		this.collisionSys = collisionSys;
		grid = broadPhaseGrid;
		collisionListeners = [];
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

			if (collider == null || !collider.stopMovement){
				transformation.pos.x += physics.velocity.x;
				transformation.pos.y += physics.velocity.y;

				if (!collider.stopMovement){
					for (shape in collider.collisionRegions){

						for (otherShape in grid.findContacts(shape)){
							if (!validCollision(shape,otherShape)) continue;
							if (!otherShape.ofEntity.has(component.Transformation)) continue;

							var otherTransform = otherShape.ofEntity.get(component.Transformation).pos;

							var c = differ.Collision.shapeWithShape(
								differ.shapes.Polygon.rectangle(shape.x+transformation.pos.x,shape.y+transformation.pos.y,shape.width,shape.height,false),
								differ.shapes.Polygon.rectangle(otherShape.x+otherTransform.x,otherShape.y+otherTransform.y,otherShape.width,otherShape.height,false));
							
							if (c != null){

								onCollision(shape,otherShape);
								onCollision(otherShape,shape);
									
							}
						}
					}
				}

			}else{
				var collision = false;
				var collidingShape:component.Collisions.Rect = null;
				//Cast ray so fast movement doesn't go through walls
				
				var px = transformation.pos.x + (collider.collisionRegions[0].width/2) +1;
				var py = transformation.pos.y + (collider.collisionRegions[0].height/2) +1;
				var velocityRayLength = collisionSys.fireRay(new differ.shapes.Ray(new differ.math.Vector(px,py),new differ.math.Vector(px + physics.velocity.x,py + physics.velocity.y)),[component.Collisions.CollisionGroup.Player]);
				
				//physics.velocity.x*=velocityRayLength;
				//physics.velocity.y*=velocityRayLength;


				var sampleMaxLength = 1;
				var multiSamples = Math.ceil(Math.sqrt(Math.pow(physics.velocity.x,2)+Math.pow(physics.velocity.y,2))/sampleMaxLength);
				var sampleMultiplier = 1/multiSamples;
				var reflectx = false;
				var reflecty = false;
				for (sample in 0...multiSamples){
					transformation.pos.x += physics.velocity.x*sampleMultiplier;
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
								if (physics.reflect){
									reflectx = true;
								}

								onCollision(shape,otherShape);
								onCollision(otherShape,shape);
									
							}
						}
					}
					
					transformation.pos.y += physics.velocity.y*sampleMultiplier;
					
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
								if (physics.reflect){
									reflecty = true;
								}

								onCollision(shape,otherShape);
								onCollision(otherShape,shape);

							}
						}
					}
				}
				if (reflectx){
					physics.velocity.x *= -1;
					transformation.angle = Math.atan2(physics.velocity.y,physics.velocity.x) * 180/Math.PI;	
				}
				if (reflecty){
					physics.velocity.y *= -1;
					transformation.angle = Math.atan2(physics.velocity.y,physics.velocity.x) * 180/Math.PI;
				}
					
			}
		}
	}
	function onCollision(shape:component.Collisions.Rect,otherShape:component.Collisions.Rect){
		var shapeEntity = shape.ofEntity;
		var otherShapeEntity = otherShape.ofEntity;
		for (collisionListener in collisionListeners) {
			collisionListener(shapeEntity,otherShapeEntity);
		}
		if (shapeEntity.has(component.ReleaseOnCollision)){
			var roc = shapeEntity.get(component.ReleaseOnCollision);
			for (releaseGroup in roc.collisionGroups){
				if (otherShape.group.indexOf(releaseGroup) != -1){
					for (item in roc.release){
						var droppedItem = EntityFactory.makeItem(entities,item,{pos:{x:shapeEntity.get(component.Transformation).pos.x,y:shapeEntity.get(component.Transformation).pos.y}});
						droppedItem.set(new component.Physics().setVelocity(new kha.math.Vector2(-6+Math.random()*12,-6+Math.random()*12)));
					}
					shapeEntity.set(new component.Light());
					shapeEntity.get(component.Light).colour = kha.Color.fromBytes(250,240,180);//kha.Color.Green;
					shapeEntity.get(component.Light).strength = .5;

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
		if (shapeEntity.has(component.Health)){
			if (otherShapeEntity.has(component.Damager)){
				var damager = otherShapeEntity.get(component.Damager);
				if (damager.active){
					shapeEntity.get(component.Health).current -= Math.floor(-damager.damage);
				}
			}
		}
		if (shapeEntity.has(component.Collectable)){
			if (otherShapeEntity.has(component.Inventory)){
				for (group in shapeEntity.get(component.Collectable).collisionGroups){
					if (otherShape.group.indexOf(group) != -1){
						for (thing in shapeEntity.get(component.Collectable).items)
							otherShapeEntity.get(component.Inventory).putIntoInventory(thing);
					
						shapeEntity.destroy();
						break;
					}
				}
			}
		}
		if (shapeEntity.has(component.CustomCollisionHandler)){
			for (group in shapeEntity.get(component.CustomCollisionHandler).collisionGroups){
				if (otherShape.group.indexOf(group) != -1){
					shapeEntity.get(component.CustomCollisionHandler).handler();
					break;
				}
			}
		}
	}
	//If the other shape is not ignoring one of shapes groups.
	function validCollision(shape:component.Collisions.Rect,otherShape:component.Collisions.Rect){
		//If both shapes are ignoring nothing, they should collide.
		if (otherShape.ignoreGroups.length == 0 && shape.ignoreGroups.length == 0) return true;
		//If the shape has a group that is being ignored by otherShape, don't collide.
		for (group in shape.group){
			if (otherShape.ignoreGroups.indexOf(group) != -1){
				return false;
			}
		}
		return true;

	}
}