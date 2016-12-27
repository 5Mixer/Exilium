package component;

class Transformation extends Component {
	public var pos:kha.math.Vector2;
	public var angle:Float;
	override public function new (pos:kha.math.Vector2){
		this.pos = pos;
		super();
	}
}