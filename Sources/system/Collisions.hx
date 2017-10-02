package system;


class Collisions extends System {
	var view:eskimo.views.View;
	public var grid:util.SpatialHash;
	public var processFixedEntities = true;
	public var frame = 0;
	var play:states.Play;
	var entities:eskimo.EntityManager;
	override public function new (entities:eskimo.EntityManager,play:states.Play){
		this.entities = entities;
		view = new eskimo.views.View(new eskimo.filters.Filter([component.Collisions]),entities);
		grid = new util.SpatialHash(60*16,60*16,16);
		this.play = play;
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
		frame++;
		
		for (entity in view.entities){
			// if (entity.get(component.Collisions).fixed && !processFixedEntities) continue;
			entity.get(component.Collisions).AABB.ofEntity = entity;
			grid.addCollider(entity.get(component.Collisions).AABB,entity.get(component.Transformation).pos);
		}
		
		// for (entity in view.entities){
		// 	var collider = entity.get(component.Collisions);
		// 	var transformation = entity.get(component.Transformation);
		// 	if (entity.has(component.Damager) != true) continue;
			
		// 	for (otherShape in grid.findContacts(collider.AABB)){
		// 		//if (!validCollision(shape,otherShape)) continue;
		// 		//if (!otherShape.ofEntity.has(component.Transformation)) continue;
		// 		if (!entity.has(component.Transformation) || !otherShape.ofEntity.has(component.Transformation)) continue;
		// 		var otherTransform = otherShape.ofEntity.get(component.Transformation).pos;

		// 		var c = differ.Collision.shapeWithShape(
		// 			differ.shapes.Polygon.rectangle(collider.AABB.x+transformation.pos.x,collider.AABB.y+transformation.pos.y,collider.AABB.width,collider.AABB.height,false),
		// 			differ.shapes.Polygon.rectangle(otherShape.x+otherTransform.x,otherShape.y+otherTransform.y,otherShape.width,otherShape.height,false));
				
		// 		if (c != null && c.separationX != 0){

		// 			onCollision(collider.AABB,otherShape);
						
		// 		}
		// 	}
		// }

		processFixedEntities = false;
	}
	public function onCollision(shape:component.Collisions.Rect,otherShape:component.Collisions.Rect){
		if (!validCollision(shape,otherShape)) return;

		CollectHandler(shape,otherShape);
		CustomCollisionHandler(shape,otherShape);
		ReleaseHandler(shape,otherShape);

		CollectHandler(otherShape,shape);
		CustomCollisionHandler(otherShape,shape);
		ReleaseHandler(otherShape,shape);
		
		DamageHandler(shape,otherShape);
		DamageHandler(otherShape,shape);

		DieHandler(shape,otherShape);
		DieHandler(otherShape,shape);

		SignHandler(shape,otherShape);
		SignHandler(otherShape,shape);

		ShopHandler(shape,otherShape);
		ShopHandler(otherShape,shape);
		
		
	}
	function SignHandler(shape:component.Collisions.Rect,otherShape:component.Collisions.Rect){
		var shapeEntity = shape.ofEntity;
		var otherShapeEntity = otherShape.ofEntity;

		if (shapeEntity.has(component.Message))
			if (otherShapeEntity.has(component.Collisions))
				if (otherShapeEntity.get(component.Collisions).collisionGroups.indexOf(component.Collisions.CollisionGroup.Player) != -1)
					shapeEntity.get(component.Message).shown = true;
	}
	function validCollision(shape:component.Collisions.Rect,otherShape:component.Collisions.Rect){
		//If both shapes are ignoring nothing, they should collide.
		if (otherShape.ignoreGroups == null	 && shape.ignoreGroups == null	) return true;
		
		if (otherShape.ignoreGroups.length == 0 && shape.ignoreGroups.length == 0) return true;
		//If the shape has a group that is being ignored by otherShape, don't collide.
		for (group in shape.group){
			if (otherShape.ignoreGroups.indexOf(group) != -1){
				return false;
			}
		}
		return true;

	}
	public function CollectHandler(shape:component.Collisions.Rect,otherShape:component.Collisions.Rect){
		var shapeEntity = shape.ofEntity;
		var otherShapeEntity = otherShape.ofEntity;

		if (shapeEntity.has(component.Collectable)){
			if (otherShapeEntity.has(component.Inventory)){
				for (group in shapeEntity.get(component.Collectable).collisionGroups){
					if (otherShape.group.indexOf(group) != -1){
						for (thing in shapeEntity.get(component.Collectable).items)
							otherShapeEntity.get(component.Inventory).putIntoInventory(thing);

							
						// kha.audio1.Audio.play(kha.Assets.sounds.pickup_item);
					
						shapeEntity.destroy();
						break;
					}
				}
			}
		}
	}
	public function CustomCollisionHandler(shape:component.Collisions.Rect,otherShape:component.Collisions.Rect){
		var shapeEntity = shape.ofEntity;
		var otherShapeEntity = otherShape.ofEntity;

		if (shapeEntity.has(component.CustomCollisionHandler)){
			for (group in shapeEntity.get(component.CustomCollisionHandler).collisionGroups){
				if (otherShape.group.indexOf(group) != -1){
					shapeEntity.get(component.CustomCollisionHandler).handler(otherShapeEntity);
					break;
				}
			}
		}
	}
	public function ReleaseHandler(shape:component.Collisions.Rect,otherShape:component.Collisions.Rect){
		var shapeEntity = shape.ofEntity;
		var otherShapeEntity = otherShape.ofEntity;

		if (shapeEntity.has(component.ReleaseOnCollision)){
			var roc = shapeEntity.get(component.ReleaseOnCollision);
			for (releaseGroup in roc.collisionGroups){
				if (otherShape.group.indexOf(releaseGroup) != -1){
					
					//kha.audio1.Audio.play(kha.Assets.sounds.treasure_open);
					
					for (item in roc.release){
						var droppedItem = EntityFactory.createItem(entities,item,shapeEntity.get(component.Transformation).pos.x,shapeEntity.get(component.Transformation).pos.y);
						droppedItem.set(new component.Physics().setVelocity(new kha.math.Vector2(-20+Math.random()*40,-20+Math.random()*40)));
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
	}


	public function DamageHandler(shape:component.Collisions.Rect,otherShape:component.Collisions.Rect){
		var shapeEntity = shape.ofEntity;
		var otherShapeEntity = otherShape.ofEntity;
		if (shapeEntity.has(component.Health)){
			
			if (otherShapeEntity.has(component.Damager)){
				var damager = otherShapeEntity.get(component.Damager);
				if (damager.active){
					shapeEntity.get(component.Health).addToHealth(-damager.damage);
				}
			}
		}
	}

	public function DieHandler(shape:component.Collisions.Rect,otherShape:component.Collisions.Rect){
		var shapeEntity = shape.ofEntity;
		var otherShapeEntity = otherShape.ofEntity;
		if (shapeEntity.has(component.DieOnCollision)){
			for (killingGroup in shapeEntity.get(component.DieOnCollision).collisionGroups){
				
				if (otherShape.group == null || otherShape.group.indexOf(killingGroup) != -1){
					if (shapeEntity.get(component.DieOnCollision).explode){
						EntityFactory.createExplosion(entities,shapeEntity.get(component.Transformation).pos.add(new kha.math.Vector2(5,5)));
					}
					shapeEntity.destroy();
					break;
				}
			}
		}
	}

	public function ShopHandler(shape:component.Collisions.Rect,otherShape:component.Collisions.Rect){
		var shapeEntity = shape.ofEntity;
		var otherShapeEntity = otherShape.ofEntity;
		if (shapeEntity.has(component.Shop) && otherShapeEntity.has(component.Inventory)){
			play.openShop = shapeEntity.get(component.Shop).shop;
			play.openShop.inventory = otherShapeEntity.get(component.Inventory);
		}
	}
}