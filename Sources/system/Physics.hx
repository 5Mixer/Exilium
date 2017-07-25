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

			var localDelta = delta;
			if (entity.has(component.GhostModeCustomMultiplier)){
				localDelta = entity.get(component.GhostModeCustomMultiplier).multiplier;
			}

			if (collider == null){
				transformation.pos.x += physics.velocity.x * localDelta;
				transformation.pos.y += physics.velocity.y * localDelta;
			}else{
				
				var collision = false;
				var collidingShape:component.Collisions.Rect = null;
				//Cast ray so fast movement doesn't go through walls
				
				//var px = transformation.pos.x + (collider.collisionRegions[0].width/2) +1;
				//var py = transformation.pos.y + (collider.collisionRegions[0].height/2) +1;
				//var velocityRayLength = collisionSys.fireRay(new differ.shapes.Ray(new differ.math.Vector(px,py),new differ.math.Vector(px + physics.velocity.x,py + physics.velocity.y)),[component.Collisions.CollisionGroup.Player]);
				
				//physics.velocity.x*=velocityRayLength;
				//physics.velocity.y*=velocityRayLength;

				var sampleMaxLength = 1;
				var multiSamples = 1;//Math.ceil(Math.sqrt(Math.pow(physics.velocity.x,2)+Math.pow(physics.velocity.y,2))/sampleMaxLength);
				var sampleMultiplier = 1/multiSamples;
				var reflectx = false;
				var reflecty = false;
				for (sample in 0...multiSamples){
					transformation.pos.x += physics.velocity.x*sampleMultiplier*localDelta;
					
					for (otherShape in grid.findContacts(collider.AABB)){
						//if (!validCollision(shape,otherShape)) continue;
						if (!otherShape.ofEntity.has(component.Transformation)) continue;

						var otherTransform = otherShape.ofEntity.get(component.Transformation).pos;

						if (aabb(collider.AABB.x+transformation.pos.x, collider.AABB.y+transformation.pos.y, collider.AABB.width, collider.AABB.height,
								otherShape.x+otherTransform.x,otherShape.y+otherTransform.y,otherShape.width,otherShape.height)
								&& validCollision(collider.AABB,otherShape)) {

							var c = differ.Collision.shapeWithShape(
							differ.shapes.Polygon.rectangle(collider.AABB.x+transformation.pos.x,collider.AABB.y+transformation.pos.y,collider.AABB.width,collider.AABB.height,false),
							differ.shapes.Polygon.rectangle(otherShape.x+otherTransform.x,otherShape.y+otherTransform.y,otherShape.width,otherShape.height,false));
						
							if (c.separationX != 0){

								collision = true;
								collidingShape = otherShape;
								if (otherShape.ofEntity.get(component.Collisions).stopMovement && validCollision(collider.AABB,otherShape)){
									transformation.pos.x += c.separationX - (c.separationX * physics.pushStrength);
								}
								reflectx = physics.reflect;

								onCollision(collider.AABB,otherShape);
								onCollision(otherShape,collider.AABB);
							}
								
						}
						
					}
					
					transformation.pos.y += physics.velocity.y*sampleMultiplier*localDelta;
					
					for (otherShape in grid.findContacts(collider.AABB)){
						
						//if (!validCollision(shape,otherShape)) continue;
						if (!otherShape.ofEntity.has(component.Transformation)) continue;
						var otherTransform = otherShape.ofEntity.get(component.Transformation).pos;

						if (aabb(collider.AABB.x+transformation.pos.x, collider.AABB.y+transformation.pos.y, collider.AABB.width, collider.AABB.height,
								otherShape.x+otherTransform.x,otherShape.y+otherTransform.y,otherShape.width,otherShape.height)
								&& validCollision(collider.AABB,otherShape)) {


							var c = differ.Collision.shapeWithShape(
							differ.shapes.Polygon.rectangle(collider.AABB.x+transformation.pos.x,collider.AABB.y+transformation.pos.y,collider.AABB.width,collider.AABB.height,false),
							differ.shapes.Polygon.rectangle(otherShape.x+otherTransform.x,otherShape.y+otherTransform.y,otherShape.width,otherShape.height,false));
						
							if (c.separationY != 0){
								collision = true;
								collidingShape = otherShape;
								if (otherShape.ofEntity.get(component.Collisions).stopMovement && validCollision(collider.AABB,otherShape)){
									transformation.pos.y += c.separationY - (c.separationY * physics.pushStrength);
								}
								reflecty = physics.reflect;

								onCollision(collider.AABB,otherShape);
								onCollision(otherShape,collider.AABB);

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
		if (otherShape.ignoreGroups == null || shape.ignoreGroups == null) return true;
		if (otherShape.ignoreGroups.length == 0 && shape.ignoreGroups.length == 0) return true;
		//If the shape has a group that is being ignored by otherShape, don't collide.
		for (group in shape.group){
			if (otherShape.ignoreGroups.indexOf(group) != -1){
				return false;
			}
		}
		return true;

	}

	function aabb(ax:Float,ay:Float,awidth:Float,aheight:Float,bx:Float,by:Float,bwidth:Float,bheight:Float){
		return (ax < bx + bwidth &&
				ax + awidth > bx &&
				ay < by + bheight &&
				aheight + ay > by);
	}
}