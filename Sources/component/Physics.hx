package component;

class Physics extends Component{
	public var velocity:kha.math.Vector2;
	public var friction:Float=.7;
	public var reflect = false;
	override public function new (reflect = false){
		velocity = new kha.math.Vector2();
		this.reflect = reflect;
		super();
	}
	//For oneline chaining
	public inline function setVelocity(v:kha.math.Vector2){
		velocity = v;
		return this;
	}
}