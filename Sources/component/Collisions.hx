package component;

enum CollisionGroup {
	Friendly;
	Enemy;
	Level;
	Bullet;
	Particle;
}

typedef Rect = {
	var x:Float;
	var y:Float;
	var width:Int;
	var height:Int;
	@:optional var group:Array<CollisionGroup>;
	@:optional var ignoreGroups:Array<CollisionGroup>;
	@:optional var gridIndex:Array<Int>;
	@:optional var ofEntity:eskimo.Entity;
}

class Collisions extends Component{
	public var collisionRegions:Array<Rect>;
	
	public var ignoreGroups = new Array<CollisionGroup>();//Will ignore collisions with entities having, at minimum, ALL these fields.
	public var collisionGroups = new Array<CollisionGroup>(); //Groups that this entity resides in. Could be multiple.
	var x = new differ.data.ShapeCollision();
	var validCollision = false;
	var result:differ.data.ShapeCollision = null;
	public var fixed = false;
	
	override public function new (?collisionGroups:Array<CollisionGroup>,?ignoreCollisionGroups:Array<CollisionGroup>) {
		collisionRegions = new Array<Rect>();
		result = new differ.data.ShapeCollision();

		if (collisionGroups != null)
			this.collisionGroups = collisionGroups;
		
		if (ignoreCollisionGroups != null)
			this.ignoreGroups = ignoreCollisionGroups;
		
		super();
	}
	public function registerCollisionRegion(collisionShape:Rect){
		collisionRegions.push(collisionShape);
		collisionShape.group = this.collisionGroups;
		collisionShape.ignoreGroups = this.ignoreGroups;
		return this;
	}
	public function getCollisionWithCollider(other:Collisions){


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
		

		x.separationX = x.separationY = 0;
		for (shape in collisionRegions){
			for (otherShape in other.collisionRegions){
				if (Math.abs(shape.x-otherShape.x) < 32 && Math.abs(shape.y-otherShape.y) < 32){
					/*if (shape.x < otherShape.x + otherShape.width &&
						shape.x + shape.width > otherShape.x &&
						shape.y < otherShape.y + otherShape.height &&
						shape.height + shape.y > otherShape.y) {
						
						return true;
					}*/
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
		if (x.separationX == 0 && x.separationY == 0)
			return null;

		return x;
	}

	
}