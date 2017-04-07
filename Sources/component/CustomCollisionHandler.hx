package component;

class CustomCollisionHandler extends Component {
	public var collisionGroups:Array<component.Collisions.CollisionGroup>;
	public var handler:eskimo.Entity->Void;
	public function new (?collisionGroups:Array<component.Collisions.CollisionGroup>,handler:eskimo.Entity->Void){
		this.collisionGroups = collisionGroups;
		this.handler = handler;
		if (collisionGroups == null)
			this.collisionGroups = component.Collisions.CollisionGroup.createAll();//[];

		super();
	}
}