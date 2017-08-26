package component;

class ReleaseOnDeath extends Component{
	public var release:Array<component.Inventory.Item> = [];
	public var collisionGroups:Array<component.Collisions.CollisionGroup>;
	public function new (release:Array<component.Inventory.Item>,groups:Array<component.Collisions.CollisionGroup>,once = true){
		this.release = release;
		this.collisionGroups = groups;
		super();
	}
}