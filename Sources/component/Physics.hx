package component;

class Physics extends Component{
	public var velocity:kha.math.Vector2;
	override public function new (){
		velocity = new kha.math.Vector2();
		super();
	}
}