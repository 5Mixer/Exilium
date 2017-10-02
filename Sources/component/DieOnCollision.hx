package component;

class DieOnCollision extends Component {
	public var collisionGroups:Array<component.Collisions.CollisionGroup>;
	public var explode = false;
	public function new (?collisionGroups:Array<component.Collisions.CollisionGroup>){
		this.collisionGroups = collisionGroups;
		if (collisionGroups == null)
			this.collisionGroups = component.Collisions.CollisionGroup.createAll();//[];

		
		super();
	}
}