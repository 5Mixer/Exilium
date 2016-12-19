package component;

interface CollisionShape {
}
interface RectangleCollider {
	public var pos:kha.math.Vector2;
	public var size:kha.math.Vector2;
}
class RectangleCollisionShape implements CollisionShape implements RectangleCollider {
	public var pos:kha.math.Vector2;
	public var size:kha.math.Vector2;
	
	public function new (pos:kha.math.Vector2,size:kha.math.Vector2){
		this.pos = pos;
		this.size = size;
	}
}

@:enum abstract Side(Int) from Int to Int
{
    var Left = value(0);
    var Right = value(1);
    var Top = value(2);
    var Bottom  = value(3);

    var Horizontal = Left | Right;
    var Vertical = Top | Bottom;

	var All = Left | Right | Top | Bottom;

    static inline function value(index:Int) return 1 << index;
}
 

class Collisions extends Component{
	public var collisionRegions:Array<CollisionShape>;
	override public function new (parent) {
		collisionRegions = new Array<CollisionShape>();
		super(parent);
	}
	public function registerCollisionRegion(collisionShape){
		collisionRegions.push(collisionShape);
	}
	public function doesShapeGroupCollide(a:Collisions,?mask:Int){
		if (mask == null) mask = Side.All;
		for (region in a.collisionRegions){
			if (doesShapeCollide(region,mask))
				return true;
		}
		return false;
	}
	public function doesShapeCollide(a:CollisionShape,?mask:Int){
		if (mask == null) mask = Side.All;
		for (region in collisionRegions){
			if (doShapesCollide(a,region,mask))
				return true;
		}
		return false;
	}
	function doShapesCollide (a:CollisionShape,b:CollisionShape,?mask:Int):Bool {
		if (mask == null) mask = Side.All;
		if (Std.is(a,RectangleCollider) && Std.is(b,RectangleCollider)){

			var a:RectangleCollider = cast a;
			var b:RectangleCollider = cast b;
		
			return ((a.pos.x < b.pos.x + b.size.x && Side.Horizontal & mask !=0 ) &&
					(a.pos.x + a.size.x > b.pos.x && Side.Horizontal & mask !=0 ) &&
					(a.pos.y < b.pos.y + b.size.y && Side.Vertical & mask !=0 ) &&
					(a.size.y + a.pos.y > b.pos.y && Side.Vertical & mask !=0 ));
		
		}
		trace("Unrecognised shape colliders");
		return false;
	}
}