package component;

import differ.shapes.Shape;

enum CollisionGroup {
	Friendly;
	Enemy;
	Level;
	Bullet;
	Particle;
}

class Collisions extends Component{
	public var collisionRegions:Array<Shape>;
	
	var ignoreGroups = new Array<CollisionGroup>();//Will ignore collisions with entities having, at minimum, ALL these fields.
	var collisionGroups = new Array<CollisionGroup>(); //Groups that this entity resides in. Could be multiple.
	public var lockShapesToEntityTransform = true;

	override public function new (?collisionGroups:Array<CollisionGroup>,?ignoreCollisionGroups:Array<CollisionGroup>) {
		collisionRegions = new Array<Shape>();

		if (collisionGroups != null)
			this.collisionGroups = collisionGroups;
		
		if (ignoreCollisionGroups != null)
			this.ignoreGroups = ignoreCollisionGroups;
		
		super();
	}
	public function registerCollisionRegion(collisionShape:Shape){
		collisionRegions.push(collisionShape);
		return this;
	}
	public function getCollisionWithCollider(other:Collisions){
		
		var validCollision = false;
		for (othersIgnore in other.ignoreGroups){
			if (collisionGroups.indexOf(othersIgnore) == -1){
				//The other entity is not ignoring one of our groups, this is a valid collision.
				validCollision = true;
			}
		}
		if (!validCollision)
			return null;
		

		//Problem isn't shape with shapes.
		//It's that we return in this loop at all.
		//This loops through all the tiles in a map.
		//If we find a collision, a return, we haven't tried following tiles.
		//We might have tried a tile which isn't being entered, just intersecting on the edge.
		var overlaps = new Array<differ.data.ShapeCollision>();
		for (shape in collisionRegions){
			for (otherShape in other.collisionRegions){
				var c = differ.Collision.shapeWithShape(shape,otherShape);
				if (c != null && (c.separationX != 0 || c.separationY != 0) && (c.otherOverlap>0 || c.overlap>0)){
					overlaps.push(c);
				}
			}
		}
		if (overlaps.length != 0)
			return overlaps;
		
		return null;
	}
}