package component;

class ReleaseOnCollision extends Component{
	public var once = true;
	public var release:Array<component.Inventory.Item> = [];
	public var collisionGroups:Array<component.Collisions.CollisionGroup>;
	public function new (release:Array<component.Inventory.Item>,groups:Array<component.Collisions.CollisionGroup>,once = true){
		this.once = once;
		this.release = release;
		this.collisionGroups = groups;
		super();
	}
}