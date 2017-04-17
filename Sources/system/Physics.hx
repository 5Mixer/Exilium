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

			

			if (collider == null){
				transformation.pos.x += physics.velocity.x;
				transformation.pos.y += physics.velocity.y;
			}else{
				

				var collision = false;
				var collidingShape:component.Collisions.Rect = null;
				//Cast ray so fast movement doesn't go through walls
				
				var px = transformation.pos.x + (collider.collisionRegions[0].width/2) +1;
				var py = transformation.pos.y + (collider.collisionRegions[0].height/2) +1;
				//var velocityRayLength = collisionSys.fireRay(new differ.shapes.Ray(new differ.math.Vector(px,py),new differ.math.Vector(px + physics.velocity.x,py + physics.velocity.y)),[component.Collisions.CollisionGroup.Player]);
				
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
							//if (!validCollision(shape,otherShape)) continue;
							if (!otherShape.ofEntity.has(component.Transformation)) continue;

							var otherTransform = otherShape.ofEntity.get(component.Transformation).pos;

							var rect1 = { x: shape.x+transformation.pos.x, y: shape.y+transformation.pos.y, width: shape.width, height:shape.height };
							var rect2 = { x: otherShape.x+otherTransform.x, y: otherShape.y+otherTransform.y, width: otherShape.width, height: otherShape.height };
							if (rect1.x < rect2.x + rect2.width &&
								rect1.x + rect1.width > rect2.x &&
								rect1.y < rect2.y + rect2.height &&
								rect1.height + rect1.y > rect2.y && validCollision(shape,otherShape)) {

								var c = differ.Collision.shapeWithShape(
								differ.shapes.Polygon.rectangle(shape.x+transformation.pos.x,shape.y+transformation.pos.y,shape.width,shape.height,false),
								differ.shapes.Polygon.rectangle(otherShape.x+otherTransform.x,otherShape.y+otherTransform.y,otherShape.width,otherShape.height,false));
							
								if (c.separationX != 0){

									collision = true;
									collidingShape = otherShape;
									if (otherShape.ofEntity.get(component.Collisions).stopMovement && validCollision(shape,otherShape)){
										transformation.pos.x += c.separationX;
									}
									reflectx = physics.reflect;

									onCollision(shape,otherShape);
									onCollision(otherShape,shape);
								}
									
							}
						}
					}
					
					transformation.pos.y += physics.velocity.y*sampleMultiplier;
					
					for (shape in collider.collisionRegions){
						for (otherShape in grid.findContacts(shape)){
							
							//if (!validCollision(shape,otherShape)) continue;
							if (!otherShape.ofEntity.has(component.Transformation)) continue;
							var otherTransform = otherShape.ofEntity.get(component.Transformation).pos;

							var rect1 = { x: shape.x+transformation.pos.x, y: shape.y+transformation.pos.y, width: shape.width, height:shape.height };
							var rect2 = { x: otherShape.x+otherTransform.x, y: otherShape.y+otherTransform.y, width: otherShape.width, height: otherShape.height };
							if (rect1.x < rect2.x + rect2.width &&
								rect1.x + rect1.width > rect2.x &&
								rect1.y < rect2.y + rect2.height &&
								rect1.height + rect1.y > rect2.y && validCollision(shape,otherShape)) {

								var c = differ.Collision.shapeWithShape(
								differ.shapes.Polygon.rectangle(shape.x+transformation.pos.x,shape.y+transformation.pos.y,shape.width,shape.height,false),
								differ.shapes.Polygon.rectangle(otherShape.x+otherTransform.x,otherShape.y+otherTransform.y,otherShape.width,otherShape.height,false));
							
								if (c.separationY != 0){
									collision = true;
									collidingShape = otherShape;
									if (otherShape.ofEntity.get(component.Collisions).stopMovement && validCollision(shape,otherShape)){
										transformation.pos.y += c.separationY;
									}
									reflecty = physics.reflect;

									onCollision(shape,otherShape);
									onCollision(otherShape,shape);

								}
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
		
		collisionSys.onCollision(shape,otherShape);
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