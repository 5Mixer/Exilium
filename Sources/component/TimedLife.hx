package component;

class TimedLife extends Component {
	public var length:Float;
	public var fuse:Float;
	public var explode = false;
	public function new (length:Float = 1.0){
		this.length = length;
		super();
	}
}