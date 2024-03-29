package component;

enum CollisionGroup {
	Friendly;
	Player;
	Enemy;
	Level;
	Bullet;
	Item;
	Particle;
	ShooterTrap;
	Chest;
}

class Rect {
	public var x:Float;
	public var y:Float;
	public var width:Int;
	public var height:Int;
	public var group:Array<CollisionGroup>;
	public var ignoreGroups:Array<CollisionGroup>;
	public var gridIndex:Array<Int> = [];
	public var ofEntity:eskimo.Entity;

	public function new (x:Float,y:Float,width:Int,height:Int){
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		group = [];
		ignoreGroups = [];
		
	}
}

class Collisions extends Component{
	// public var collisionRegions:Array<Rect>;
	
	public var ignoreGroups = new Array<CollisionGroup>();//Will ignore collisions with entities having, at minimum, ALL these fields.
	public var collisionGroups = new Array<CollisionGroup>(); //Groups that this entity resides in. Could be multiple.
	var x = new differ.data.ShapeCollision();
	var validCollision = false;
	var result:differ.data.ShapeCollision = null;
	public var fixed = false;
	public var AABB:Rect;
	public var midpoint:kha.math.Vector2;
	public var stopMovement = true;

	override public function new (?collisionGroups:Array<CollisionGroup>,?ignoreCollisionGroups:Array<CollisionGroup>,aabb:Rect,stopMovement = true) {
		//collisionRegions = new Array<Rect>();
		result = new differ.data.ShapeCollision();
		AABB = aabb;
		midpoint = new kha.math.Vector2(0,0);
		this.stopMovement = stopMovement;

		if (collisionGroups != null)
			this.collisionGroups = collisionGroups;
		
		if (ignoreCollisionGroups != null)
			this.ignoreGroups = ignoreCollisionGroups;

		
		AABB.group = this.collisionGroups;
		AABB.ignoreGroups = this.ignoreGroups;
		
		super();
	}
	/*public function registerCollisionRegion(collisionShape:Rect){
		collisionRegions.push(collisionShape);
		collisionShape.group = this.collisionGroups;
		collisionShape.ignoreGroups = this.ignoreGroups;
		AABB.width = Math.ceil(Math.max(AABB.width,collisionShape.width));
		AABB.height = Math.ceil(Math.max(AABB.height,collisionShape.height));
		recalculateAABB();
		midpoint.x = AABB.width/2;
		midpoint.y = AABB.height/2;
		return this;
	}*/
	/*
	public function recalculateAABB (){
		AABB.width = 0;
		AABB.height = 0;
		for (region in collisionRegions){
			if (region.x+region.width > AABB.width){
				AABB.width = Math.ceil(region.x+region.width);
			}
			if (region.y+region.height > AABB.height){
				AABB.height = Math.ceil(region.y+region.height);
			}
		}
	}
	*/
	/*public function getCollisionWithCollider(other:Collisions){
		validCollision = false;
		for (othersIgnore in other.ignoreGroups){
			if (collisionGroups.indexOf(othersIgnore) == -1){
				//The other entity is not ignoring one of our groups, this is a valid collision.
				validCollision = true;
				break;
			}
		}
		if (validCollision){
			for (ignore in ignoreGroups){
				if (other.collisionGroups.indexOf(ignore) != -1){
					//The other entity is not ignoring one of our groups, this is a valid collision.
					validCollision = false;
					break;
				}
			}
		}
		if (!validCollision)
			return null;
		
		/*

		x.separationX = x.separationY = 0;
		for (shape in collisionRegions){
			for (otherShape in other.collisionRegions){
				if (Math.abs(shape.x-otherShape.x) < 32 && Math.abs(shape.y-otherShape.y) < 32){
					/*if (shape.x < otherShape.x + otherShape.width &&
						shape.x + shape.width > otherShape.x &&
						shape.y < otherShape.y + otherShape.height &&
						shape.height + shape.y > otherShape.y) {
						
						return true;
					}
					differ.Collision.shapeWithShape(differ.shapes.Polygon.rectangle(shape.x,shape.y,shape.width,shape.height),differ.shapes.Polygon.rectangle(otherShape.x,otherShape.y,otherShape.width,otherShape.height),result);
					if (result != null){
						//if (x.separationX != result.separationX)
							//x.separationX += result.separationX;
						
						//if (x.separationY != result.separationY)
							//x.separationY += result.separationY;
					}
					
				}
				
			}
		}
		
		// differ.Collision.shapeWithShape(differ.shapes.Polygon.rectangle(shape.x,shape.y,shape.width,shape.height),differ.shapes.Polygon.rectangle(otherShape.x,otherShape.y,otherShape.width,otherShape.height),result);
					
		if (x.separationX == 0 && x.separationY == 0)
			return null;

		return x;
	}*/
}