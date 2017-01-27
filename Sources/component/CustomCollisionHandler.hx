package component;

class CustomCollisionHandler extends Component {
	public var collisionGroups:Array<component.Collisions.CollisionGroup>;
	public var handler:Void->Void;
	public function new (?collisionGroups:Array<component.Collisions.CollisionGroup>,handler:Void->Void){
		this.collisionGroups = collisionGroups;
		this.handler = handler;
		if (collisionGroups == null)
			this.collisionGroups = component.Collisions.CollisionGroup.createAll();//[];

		
		super();
	}
}