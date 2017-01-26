package component;

class ReleaseOnCollision extends Component{
	public var once = true;
	public var collisionGroups:Array<component.Collisions.CollisionGroup>;
	public function new (groups:Array<component.Collisions.CollisionGroup>,once = true){
		this.once = once;
		this.collisionGroups = groups;
		super();
	}
}