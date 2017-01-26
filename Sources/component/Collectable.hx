package component;

class Collectable extends Component {
	public var collisionGroups:Array<component.Collisions.CollisionGroup>;
	public var items:Array<Int> = [];
	public function new (?collisionGroups:Array<component.Collisions.CollisionGroup>,items:Array<Int>){
		this.collisionGroups = collisionGroups;
		if (collisionGroups == null)
			this.collisionGroups = component.Collisions.CollisionGroup.createAll();//[];

		this.items = items;
		
		super();
	}
}